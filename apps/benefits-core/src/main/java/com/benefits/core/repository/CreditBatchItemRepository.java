package com.benefits.core.repository;

import com.benefits.core.entity.CreditBatchItem;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Repository for credit_batch_items table.
 */
@Repository
public interface CreditBatchItemRepository extends R2dbcRepository<CreditBatchItem, UUID> {

    Flux<CreditBatchItem> findByBatchId(UUID batchId);

    Mono<Long> countByBatchId(UUID batchId);

    Flux<CreditBatchItem> findByBatchIdAndStatus(UUID batchId, String status);
}