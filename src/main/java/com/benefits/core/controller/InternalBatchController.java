package com.benefits.core.controller;

import com.benefits.core.dto.CreditBatchRequest;
import com.benefits.core.dto.CreditBatchResponse;
import com.benefits.core.dto.CreditBatchListResponse;
import com.benefits.core.service.CreditBatchService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/batches/credits")
public class InternalBatchController {

    private static final Logger log = LoggerFactory.getLogger(InternalBatchController.class);

    private final CreditBatchService creditBatchService;

    public InternalBatchController(CreditBatchService creditBatchService) {
        this.creditBatchService = creditBatchService;
    }

    @PostMapping
    public Mono<ResponseEntity<CreditBatchResponse>> submitBatch(
            @RequestHeader("X-Tenant-Id") UUID tenantId,
            @RequestHeader("X-Employer-Id") UUID employerId,
            @RequestHeader(value = "X-Idempotency-Key", required = false) String idempotencyKey,
            @RequestHeader("X-Person-Id") UUID personId,
            @RequestBody CreditBatchRequest request) {

        log.info("[F05] InternalBatchController.submitBatch - TenantId: {}, EmployerId: {}, PersonId: {}, IdempotencyKey: {}",
                tenantId, employerId, personId, idempotencyKey);

        // Debug: log request details
        if (request != null && request.getItems() != null) {
            log.info("[F05] Request validation: items.size()={}, firstItem.personId={}, firstItem.walletId={}",
                request.getItems().size(),
                request.getItems().isEmpty() ? null : request.getItems().get(0).getPersonId(),
                request.getItems().isEmpty() ? null : request.getItems().get(0).getWalletId());
        } else {
            log.warn("[F05] Request validation: request is null or has no items");
        }

        // #region agent log
        try {
            java.io.FileWriter fw = new java.io.FileWriter("c:\\Users\\gesch\\Documents\\projeto-lucas\\.cursor\\debug.log", true);
            fw.write("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"A\",\"location\":\"InternalBatchController.java:40\",\"message\":\"submitBatch entry\",\"data\":{\"tenantId\":\"" + tenantId + "\",\"employerId\":\"" + employerId + "\",\"itemsCount\":" + (request != null && request.getItems() != null ? request.getItems().size() : 0) + "},\"timestamp\":" + System.currentTimeMillis() + "}\n");
            fw.close();
        } catch (Exception e) {}
        // #endregion

        return creditBatchService.submitBatch(tenantId, employerId, request, idempotencyKey, personId)
            .map(response -> {
                // #region agent log
                try {
                    java.io.FileWriter fw = new java.io.FileWriter("c:\\Users\\gesch\\Documents\\projeto-lucas\\.cursor\\debug.log", true);
                    fw.write("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"A\",\"location\":\"InternalBatchController.java:45\",\"message\":\"submitBatch success\",\"data\":{\"batchId\":\"" + response.getId() + "\"},\"timestamp\":" + System.currentTimeMillis() + "}\n");
                    fw.close();
                } catch (Exception e) {}
                // #endregion
                return ResponseEntity.status(HttpStatus.CREATED).body(response);
            })
            .onErrorResume(error -> {
                // #region agent log
                try {
                    java.io.FileWriter fw = new java.io.FileWriter("c:\\Users\\gesch\\Documents\\projeto-lucas\\.cursor\\debug.log", true);
                    fw.write("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"A\",\"location\":\"InternalBatchController.java:52\",\"message\":\"submitBatch error\",\"data\":{\"errorType\":\"" + error.getClass().getName() + "\",\"errorMessage\":\"" + (error.getMessage() != null ? error.getMessage().replace("\"", "\\\"") : "null") + "\"},\"timestamp\":" + System.currentTimeMillis() + "}\n");
                    fw.close();
                } catch (Exception e) {}
                // #endregion
                log.error("[F05] InternalBatchController.submitBatch - Error: {}", error.getMessage(), error);
                
                // Handle ResponseStatusException properly
                if (error instanceof org.springframework.web.server.ResponseStatusException) {
                    org.springframework.web.server.ResponseStatusException rse = 
                        (org.springframework.web.server.ResponseStatusException) error;
                    return Mono.just(ResponseEntity.status(rse.getStatusCode()).build());
                }
                
                // For other exceptions, return 500
                return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
            });
    }

    @GetMapping("/{batchId}")
    public Mono<ResponseEntity<CreditBatchResponse>> getBatch(
            @RequestHeader("X-Tenant-Id") UUID tenantId,
            @PathVariable UUID batchId) {

        log.info("[F05] InternalBatchController.getBatch - TenantId: {}, BatchId: {}", tenantId, batchId);

        return creditBatchService.getBatchDetail(tenantId, batchId)
            .map(ResponseEntity::ok);
    }

    @GetMapping
    public Mono<ResponseEntity<CreditBatchListResponse>> listBatches(
            @RequestHeader("X-Tenant-Id") UUID tenantId,
            @RequestHeader(value = "X-Employer-Id", required = false) UUID employerId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {

        log.info("[F05] InternalBatchController.listBatches - TenantId: {}, EmployerId: {}, Page: {}, Size: {}",
                tenantId, employerId, page, size);

        return creditBatchService.listBatches(tenantId, employerId, page, size)
            .map(ResponseEntity::ok);
    }
}