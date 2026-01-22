package com.benefits.core.service;

import com.benefits.core.dto.CreditBatchRequest;
import com.benefits.core.dto.CreditBatchResponse;
import com.benefits.core.dto.CreditBatchListResponse;
import com.benefits.core.entity.CreditBatch;
import com.benefits.core.entity.CreditBatchItem;
import com.benefits.core.repository.CreditBatchRepository;
import com.benefits.core.repository.CreditBatchItemRepository;
import com.benefits.core.event.DomainEvent;
import com.benefits.core.event.EventPublisher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Credit batch processing service
 * Implements F05 batch credit logic with persistence
 *
 * Responsibilities:
 * - Validate batch items (not null, not empty, max 5k)
 * - Persist batch and items to database
 * - Handle idempotency via DB unique constraint
 * - Reactive processing with WebFlux
 */
@Service
public class CreditBatchService {

    private static final Logger log = LoggerFactory.getLogger(CreditBatchService.class);
    private static final int MAX_ITEMS = 5000;

    private final CreditBatchRepository creditBatchRepository;
    private final CreditBatchItemRepository creditBatchItemRepository;

    public CreditBatchService(CreditBatchRepository creditBatchRepository,
                             CreditBatchItemRepository creditBatchItemRepository) {
        this.creditBatchRepository = creditBatchRepository;
        this.creditBatchItemRepository = creditBatchItemRepository;
    }

    /**
     * Submit credit batch with persistence
     */
    @Transactional
    public Mono<CreditBatchResponse> submitBatch(UUID tenantId, UUID employerId,
                                                 CreditBatchRequest batchRequest, String idempotencyKey,
                                                 UUID submittedByPid) {

        log.info("[F05] CreditBatchService.submitBatch - Starting with tenantId={}, employerId={}, idempotencyKey={}",
                tenantId, employerId, idempotencyKey);

        return Mono.defer(() -> {
            if (batchRequest == null || batchRequest.getItems() == null || batchRequest.getItems().isEmpty()) {
                return Mono.error(new ResponseStatusException(HttpStatus.BAD_REQUEST, "items are required"));
            }
            if (batchRequest.getItems().size() > MAX_ITEMS) {
                return Mono.error(new ResponseStatusException(HttpStatus.BAD_REQUEST, "items exceeds limit"));
            }

            // check idempotency
            if (idempotencyKey != null) {
                return creditBatchRepository.findByTenantIdAndIdempotencyKey(tenantId, idempotencyKey)
                    .flatMap(existingBatch -> {
                        log.info("[F05] Idempotency hit: Batch {} already exists for key {}", existingBatch.getId(), idempotencyKey);
                        return buildResponseFromEntity(existingBatch);
                    })
                    .switchIfEmpty(createNewBatch(tenantId, employerId, batchRequest, idempotencyKey, submittedByPid));
            }

            return createNewBatch(tenantId, employerId, batchRequest, null, submittedByPid);
        });
    }

    private Mono<CreditBatchResponse> createNewBatch(UUID tenantId, UUID employerId,
                                                    CreditBatchRequest batchRequest, String idempotencyKey,
                                                    UUID submittedByPid) {
        UUID batchId = UUID.randomUUID();

        // Calculate total amount from items
        BigDecimal totalAmount = batchRequest.getItems().stream()
            .map(item -> item.getAmount() != null ? item.getAmount() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        Long totalAmountCents = totalAmount.multiply(BigDecimal.valueOf(100)).longValue();
        
        CreditBatch batch = new CreditBatch(
            tenantId,
            employerId,
            batchRequest.getBatchReference() != null ? batchRequest.getBatchReference() : "Batch-" + batchId.toString().substring(0, 8),
            totalAmountCents,
            batchRequest.getItems().size(),
            idempotencyKey
        );
        // Ensure ID is determined by constructor (it uses randomUUID)
        
        log.info("[F05] Persisting new batch: {}", batch.getId());

        return creditBatchRepository.save(batch)
            .flatMap(savedBatch -> {
                List<CreditBatchItem> items = batchRequest.getItems().stream()
                    .map(itemRequest -> mapToItem(savedBatch.getId(), tenantId, itemRequest))
                    .collect(Collectors.toList());

                return creditBatchItemRepository.saveAll(items)
                    .collectList()
                    .map(savedItems -> savedBatch);
            })
            .flatMap(this::buildResponseFromEntity)
            .doOnError(e -> log.error("[F05] Failed to create batch", e));
    }

    private CreditBatchItem mapToItem(UUID batchId, UUID tenantId, CreditBatchRequest.CreditBatchItemRequest itemRequest) {
        if (itemRequest.getPersonId() == null || itemRequest.getWalletId() == null) {
            throw new IllegalArgumentException("person_id and wallet_id are required");
        }
        
        UUID userId = UUID.fromString(itemRequest.getPersonId());
        // TODO: Resolve wallet type from walletId if needed. Using placeholder "MEAL" for MVP.
        // In full implementation, we would query the wallet to get its type.
        String walletType = "MEAL"; 
        
        Long amountCents = itemRequest.getAmount().multiply(BigDecimal.valueOf(100)).longValue();

        return new CreditBatchItem(
            batchId,
            tenantId,
            userId,
            walletType,
            amountCents
        );
    }

    private Mono<CreditBatchResponse> buildResponseFromEntity(CreditBatch batch) {
        return creditBatchItemRepository.findByBatchId(batch.getId())
            .collectList()
            .map(items -> {
                CreditBatchResponse response = new CreditBatchResponse();
                response.setId(batch.getId().toString());
                response.setBatchReference(batch.getBatchName());
                response.setStatus(batch.getStatus());
                response.setItemsTotal(batch.getTotalItems());
                
                long succeeded = items.stream().filter(i -> "PROCESSED".equals(i.getStatus())).count();
                long failed = items.stream().filter(i -> "FAILED".equals(i.getStatus())).count();
                
                response.setItemsSucceeded((int)succeeded);
                response.setItemsFailed((int)failed);
                response.setCreatedAt(batch.getCreatedAt());
                response.setUpdatedAt(batch.getUpdatedAt());
                
                List<CreditBatchResponse.BatchItemResult> itemResults = items.stream().map(item -> {
                    CreditBatchResponse.BatchItemResult res = new CreditBatchResponse.BatchItemResult();
                    res.setPersonId(item.getUserId().toString());
                    res.setWalletId(null); // Not stored directly in item yet
                    res.setAmount(BigDecimal.valueOf(item.getAmountCents()).divide(BigDecimal.valueOf(100)));
                    res.setStatus(item.getStatus());
                    res.setErrorMessage(item.getErrorMessage());
                    return res;
                }).collect(Collectors.toList());
                
                response.setItems(itemResults);
                return response;
            });
    }

    /**
     * Get batch detail
     */
    public Mono<CreditBatchResponse> getBatchDetail(UUID tenantId, UUID batchId) {
        return creditBatchRepository.findByBatchId(batchId)
            .filter(batch -> batch.getTenantId().equals(tenantId)) // Security check
            .flatMap(this::buildResponseFromEntity)
            .switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "batch not found")));
    }

    /**
     * List batches
     */
    public Mono<CreditBatchListResponse> listBatches(UUID tenantId, UUID employerId, int page, int size) {
        int safePage = Math.max(page, 1);
        int safeSize = Math.min(Math.max(size, 1), 100);
        int offset = (safePage - 1) * safeSize;

        Mono<Long> countMono = (employerId != null) 
            ? creditBatchRepository.countByTenantIdAndEmployerId(tenantId, employerId)
            : creditBatchRepository.countByTenantId(tenantId);
            
        return countMono.flatMap(total -> {
            if (total == 0) {
                CreditBatchListResponse response = new CreditBatchListResponse();
                response.setPage(safePage);
                response.setSize(safeSize);
                response.setTotalElements(0);
                response.setTotalPages(0);
                response.setBatches(List.of());
                return Mono.just(response);
            }
            
            Flux<CreditBatch> batchesFlux = (employerId != null)
                ? creditBatchRepository.findByTenantIdAndEmployerId(tenantId, employerId, offset, safeSize)
                : creditBatchRepository.findByTenantId(tenantId, offset, safeSize);
                
            return batchesFlux.flatMap(this::buildResponseFromEntity)
                .collectList()
                .map(batches -> {
                    CreditBatchListResponse response = new CreditBatchListResponse();
                    response.setPage(safePage);
                    response.setSize(safeSize);
                    response.setTotalElements(total.intValue());
                    response.setTotalPages((int) Math.ceil((double) total / safeSize));
                    response.setBatches(batches);
                    return response;
                });
        });
    }
}
