package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@FeignClient(name = "benefits-core", url = "${core.service.url:http://benefits-core:8091}")
public interface CoreServiceClient {

    // Wallets
    @GetMapping("/api/wallets/{userId}/summary")
    Map<String, Object> getWalletSummary(
            @PathVariable String userId,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    @PostMapping("/api/wallets/{userId}/balance")
    Map<String, Object> updateWalletBalance(
            @PathVariable String userId,
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    // Transactions
    @GetMapping("/api/transactions")
    Map<String, Object> getTransactions(
            @RequestParam(required = false) String userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestHeader("X-API-Key") String apiKey,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId
    );

    // Users
    @GetMapping("/api/users")
    List<Map<String, Object>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size,
            @RequestHeader("X-API-Key") String apiKey
    );

    @GetMapping("/api/users/{id}")
    Map<String, Object> getUserById(
            @PathVariable String id,
            @RequestHeader("X-API-Key") String apiKey
    );

    @PostMapping("/api/users")
    Map<String, Object> createUser(
            @RequestBody Map<String, Object> user,
            @RequestHeader("X-API-Key") String apiKey
    );

    // Merchants
    @GetMapping("/api/merchants")
    List<Map<String, Object>> getMerchants(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size,
            @RequestHeader("X-API-Key") String apiKey
    );

    @GetMapping("/api/merchants/{id}")
    Map<String, Object> getMerchantById(
            @PathVariable String id,
            @RequestHeader("X-API-Key") String apiKey
    );

    @PostMapping("/api/merchants")
    Map<String, Object> createMerchant(
            @RequestBody Map<String, Object> merchant,
            @RequestHeader("X-API-Key") String apiKey
    );

    // Disputes
    @GetMapping("/api/disputes")
    List<Map<String, Object>> getDisputes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size,
            @RequestHeader("X-API-Key") String apiKey
    );

    @GetMapping("/api/disputes/{id}")
    Map<String, Object> getDisputeById(
            @PathVariable String id,
            @RequestHeader("X-API-Key") String apiKey
    );

    @PostMapping("/api/disputes")
    Map<String, Object> createDispute(
            @RequestBody Map<String, Object> dispute,
            @RequestHeader("X-API-Key") String apiKey
    );
}
