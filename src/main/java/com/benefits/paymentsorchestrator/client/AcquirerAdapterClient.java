package com.benefits.paymentsorchestrator.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@FeignClient(name = "acquirer-adapter", url = "${acquireradapter.service.url:http://acquirer-adapter:8093}")
public interface AcquirerAdapterClient {
    
    @PostMapping("/api/acquirer/authorize")
    Map<String, Object> authorize(
            @RequestBody Map<String, Object> authorizationRequest,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );
    
    @PostMapping("/api/acquirer/capture")
    Map<String, Object> capture(
            @RequestBody Map<String, Object> captureRequest,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );
    
    @PostMapping("/api/acquirer/refund")
    Map<String, Object> refund(
            @RequestBody Map<String, Object> refundRequest,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );
}
