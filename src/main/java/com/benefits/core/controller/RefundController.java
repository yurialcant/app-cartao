package com.benefits.core.controller;

import com.benefits.core.dto.RefundRequest;
import com.benefits.core.dto.RefundResponse;
import com.benefits.core.service.RefundService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Refund Controller
 *
 * REST endpoints for refund operations (F07)
 */
@RestController
@RequestMapping("/internal/refunds")
public class RefundController {

    private static final Logger log = LoggerFactory.getLogger(RefundController.class);

    private final RefundService refundService;

    public RefundController(RefundService refundService) {
        this.refundService = refundService;
    }

    /**
     * POST /internal/refunds
     *
     * Process a refund request
     *
     * Headers required:
     * - X-Tenant-Id: UUID (from JWT)
     */
    @PostMapping
    public Mono<ResponseEntity<RefundResponse>> processRefund(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestBody RefundRequest request) {

        log.info("[F07] ===== POST /internal/refunds REQUEST RECEIVED =====");
        log.info("[F07] Headers received - X-Tenant-Id: {}", tenantIdHeader);
        log.info("[F07] Request body - Person: {}, Wallet: {}, OriginalTx: {}, Amount: {}, IdempotencyKey: {}",
                request.getPersonId(), request.getWalletId(), request.getOriginalTransactionId(),
                request.getAmount(), request.getIdempotencyKey());
        log.info("[F07] Calling refundService.processRefund()...");

        // For testing: if header is not present, use from body
        UUID finalTenantId;
        try {
            finalTenantId = tenantIdHeader != null ? UUID.fromString(tenantIdHeader) : request.getTenantId();
        } catch (IllegalArgumentException e) {
            log.error("[F07] Invalid tenant ID format: {}", tenantIdHeader);
            RefundResponse errorResponse = RefundResponse.declined("invalid_tenant_id", "Invalid tenant ID format");
            return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse));
        }

        log.info("[F07] Using tenant ID: {}", finalTenantId);

        return refundService.processRefund(finalTenantId, request)
                .doOnNext(response -> log.info("[F07] Refund service returned: {}", response))
                .map(response -> {
                    if ("APPROVED".equals(response.getStatus())) {
                        log.info("[F07] Returning 200 OK with APPROVED response");
                        return ResponseEntity.ok(response);
                    } else {
                        log.info("[F07] Returning 402 PAYMENT REQUIRED with {} response", response.getStatus());
                        return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(response);
                    }
                })
                .doOnError(error -> log.error("[F07] Error in refund flow: {}", error.getMessage(), error))
                .onErrorResume(error -> {
                    log.error("[F07] Refund error: {}", error.getMessage(), error);
                    RefundResponse errorResponse = RefundResponse.declined("internal_error",
                                                                           "Internal server error");
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
                });
    }

    /**
     * GET /internal/refunds/{id}
     *
     * Get refund status by ID
     */
    @GetMapping("/{id}")
    public Mono<ResponseEntity<RefundResponse>> getRefundStatus(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID id) {

        log.info("[F07] ===== GET /internal/refunds/{} REQUEST RECEIVED =====", id);
        log.info("[F07] Tenant ID header: {}", tenantIdHeader);

        UUID tenantId;
        try {
            tenantId = tenantIdHeader != null ? UUID.fromString(tenantIdHeader) : null;
        } catch (IllegalArgumentException e) {
            log.error("[F07] Invalid tenant ID format: {}", tenantIdHeader);
            RefundResponse errorResponse = RefundResponse.declined("invalid_tenant_id", "Invalid tenant ID format");
            return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse));
        }

        return refundService.getRefundStatus(tenantId, id)
                .map(response -> {
                    if ("APPROVED".equals(response.getStatus())) {
                        return ResponseEntity.ok(response);
                    } else {
                        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
                    }
                })
                .doOnError(error -> log.error("[F07] Error getting refund status: {}", error.getMessage(), error))
                .onErrorResume(error -> {
                    log.error("[F07] Get refund status error: {}", error.getMessage(), error);
                    RefundResponse errorResponse = RefundResponse.declined("internal_error",
                                                                           "Internal server error");
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
                });
    }

    /**
     * POST /internal/refunds/test/request - Test endpoint with RefundRequest
     */
    @PostMapping("/test/request")
    public Mono<ResponseEntity<String>> testRefundRequest(@RequestBody RefundRequest request) {
        log.info("[F07] Test endpoint called with request: {}", request);
        return Mono.just(ResponseEntity.ok("RefundRequest received successfully: " + request.getIdempotencyKey()));
    }

    /**
     * POST /internal/refunds/test/process - Test endpoint identical to processRefund
     */
    @PostMapping("/test/process")
    public Mono<ResponseEntity<RefundResponse>> testProcessRefund(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestBody RefundRequest request) {

        log.info("[F07] ===== TEST POST /internal/refunds/test/process REQUEST RECEIVED =====");
        log.info("[F07] Headers received - X-Tenant-Id: {}", tenantIdHeader);
        log.info("[F07] Request body - Person: {}, Wallet: {}, OriginalTx: {}, Amount: {}, IdempotencyKey: {}",
                request.getPersonId(), request.getWalletId(), request.getOriginalTransactionId(),
                request.getAmount(), request.getIdempotencyKey());

        // For testing: if header is not present, use from body
        UUID finalTenantId;
        try {
            finalTenantId = tenantIdHeader != null ? UUID.fromString(tenantIdHeader) : request.getTenantId();
        } catch (IllegalArgumentException e) {
            log.error("[F07] Invalid tenant ID format: {}", tenantIdHeader);
            RefundResponse errorResponse = RefundResponse.declined("invalid_tenant_id", "Invalid tenant ID format");
            return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse));
        }

        log.info("[F07] Using tenant ID: {}", finalTenantId);
        log.info("[F07] This is a test endpoint - returning success without calling service");

        RefundResponse testResponse = RefundResponse.declined("test_success", "Test endpoint worked correctly");
        return Mono.just(ResponseEntity.ok(testResponse));
    }

    /**
     * POST /internal/refunds/test/simple - Simple test endpoint
     */
    @PostMapping("/test/simple")
    public Mono<ResponseEntity<String>> testSimple() {
        log.info("[F07] Simple test endpoint called");
        return Mono.just(ResponseEntity.ok("Refund test successful"));
    }
}