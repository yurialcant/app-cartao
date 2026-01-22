package com.benefits.paymentsorchestrator.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@FeignClient(name = "benefits-core", url = "${core.service.url:http://benefits-core:8091}")
public interface CoreServiceClient {

    @PostMapping("/api/charge-intents")
    Map<String, Object> createChargeIntent(
            @RequestBody Map<String, Object> chargeIntent,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @GetMapping("/api/charge-intents/{id}")
    Map<String, Object> getChargeIntent(
            @PathVariable UUID id,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @PostMapping("/api/charge-intents/{id}/confirm")
    Map<String, Object> confirmChargeIntent(
            @PathVariable UUID id,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @PostMapping("/api/payments")
    Map<String, Object> createPayment(
            @RequestBody Map<String, Object> payment,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @GetMapping("/api/payments/{id}")
    Map<String, Object> getPayment(
            @PathVariable UUID id,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @PostMapping("/api/payments/{id}/authorize")
    Map<String, Object> authorizePayment(
            @PathVariable UUID id,
            @RequestBody Map<String, Object> authRequest,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @PostMapping("/api/payments/{id}/capture")
    Map<String, Object> capturePayment(
            @PathVariable UUID id,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );
}
