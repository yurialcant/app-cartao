package com.benefits.userbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

import java.util.Map;

@FeignClient(name = "payments-orchestrator", url = "${payments.service.url:http://benefits-payments-orchestrator:8082}")
public interface PaymentServiceClient {

    @PostMapping("/api/payments/qr")
    Map<String, Object> createQRPayment(@RequestBody Map<String, Object> request,
                                       @RequestHeader("X-Tenant-Id") String tenantId,
                                       @RequestHeader("X-API-Key") String apiKey);

    @PostMapping("/api/payments/scan-qr")
    Map<String, Object> scanQR(@RequestBody Map<String, Object> request);
}