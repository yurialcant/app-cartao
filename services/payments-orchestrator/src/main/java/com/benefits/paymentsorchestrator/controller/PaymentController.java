package com.benefits.paymentsorchestrator.controller;

import com.benefits.paymentsorchestrator.service.PaymentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);
    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/qr")
    public ResponseEntity<Map<String, Object>> createQRPayment(
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {

        log.info("🔵 [PAYMENTS-ORCHESTRATOR] POST /api/payments/qr - Request-ID: {} - Idempotency-Key: {}", requestId, idempotencyKey);

        UUID merchantId = UUID.fromString(requestBody.get("merchantId").toString());
        BigDecimal amount = new BigDecimal(requestBody.get("amount").toString());

        Map<String, Object> result = paymentService.createQRPayment(merchantId, amount, tenantId, idempotencyKey);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/qr/confirm")
    public ResponseEntity<Map<String, Object>> confirmQRPayment(
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {

        log.info("🔵 [PAYMENTS-ORCHESTRATOR] POST /api/payments/qr/confirm - Request-ID: {}", requestId);

        Object chargeIntentIdObj = requestBody.get("chargeIntentId");
        if (chargeIntentIdObj == null) {
            throw new IllegalArgumentException("chargeIntentId is required");
        }
        UUID chargeIntentId = UUID.fromString(chargeIntentIdObj.toString());

        Object userIdObj = requestBody.get("userId");
        if (userIdObj == null) {
            throw new IllegalArgumentException("userId is required");
        }
        String userId = userIdObj.toString();
        
        Map<String, Object> result = paymentService.confirmQRPayment(chargeIntentId, userId, tenantId, idempotencyKey);
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/card")
    public ResponseEntity<Map<String, Object>> processCardPayment(
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] POST /api/payments/card - Request-ID: {}", requestId);
        
        UUID merchantId = UUID.fromString(requestBody.get("merchantId").toString());
        String cardToken = requestBody.get("cardToken").toString();
        BigDecimal amount = new BigDecimal(requestBody.get("amount").toString());
        
        Map<String, Object> result = paymentService.processCardPayment(merchantId, cardToken, amount, tenantId, idempotencyKey);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getPayment(
            @PathVariable String id,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] GET /api/payments/{} - Request-ID: {}", id, requestId);

        try {
            UUID paymentId = UUID.fromString(id);
            Map<String, Object> result = paymentService.getPaymentStatus(paymentId, tenantId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            log.warn("🔵 [PAYMENTS-ORCHESTRATOR] Invalid UUID format: {}", id);
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Invalid payment ID format",
                "message", "Payment ID must be a valid UUID"
            ));
        } catch (Exception e) {
            log.error("🔵 [PAYMENTS-ORCHESTRATOR] Error getting payment: {}", e.getMessage());
            return ResponseEntity.status(500).body(Map.of(
                "error", "Internal server error",
                "message", e.getMessage()
            ));
        }
    }
}
