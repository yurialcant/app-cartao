package com.benefits.employerbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "benefits-core", url = "${core.service.url:http://benefits-core:8091}")
public interface CoreServiceClient {
    
    @PostMapping("/api/wallets/{userId}/balance")
    Map<String, Object> updateWalletBalance(
            @PathVariable String userId,
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );
    
    @GetMapping("/api/wallets/{userId}/summary")
    Map<String, Object> getWalletSummary(
            @PathVariable String userId,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );
}


