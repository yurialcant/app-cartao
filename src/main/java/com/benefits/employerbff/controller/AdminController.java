package com.benefits.employerbff.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/admin")
public class AdminController {
    
    private static final Logger log = LoggerFactory.getLogger(AdminController.class);
    
    private final WebClient webClient;
    
    @Value("${core.service.url:http://benefits-core:8091}")
    private String coreServiceUrl;
    
    @Value("${employer.service.url:http://employer-service:8107}")
    private String employerServiceUrl;
    
    @Value("${core.service.apiKey:core-service-secret-key}")
    private String apiKey;
    
    public AdminController(WebClient webClient) {
        this.webClient = webClient;
    }
    
    @GetMapping("/users")
    public Mono<Map<String, Object>> getUsers() {
        log.info("GET /admin/users");
        return webClient.get()
            .uri(coreServiceUrl + "/api/users?page=0&size=100")
            .header("X-API-Key", apiKey)
            .retrieve()
            .bodyToMono(List.class)
            .map(users -> Map.of(
                "success", true,
                "data", users,
                "total", ((List<?>)users).size()
            ))
            .onErrorResume(e -> {
                log.warn("Using mock users: {}", e.getMessage());
                return Mono.just(Map.of("success", true, "data", getMockEmployees(), "total", 3));
            });
    }
    
    @PostMapping("/users")
    public Mono<Map<String, Object>> createUser(@RequestBody Map<String, Object> user) {
        log.info("POST /admin/users - {}", user.get("email"));
        Map<String, Object> created = new HashMap<>(user);
        created.put("id", UUID.randomUUID().toString());
        created.put("createdAt", LocalDateTime.now().toString());
        return Mono.just(Map.of("success", true, "data", created));
    }
    
    @PostMapping("/users/{userId}/onboard")
    public Mono<Map<String, Object>> onboardUser(@PathVariable String userId) {
        log.info("POST /admin/users/{}/onboard", userId);
        return Mono.just(Map.of("success", true, "message", "User onboarded", "userId", userId));
    }
    
    @PostMapping("/topups/batch")
    public Mono<Map<String, Object>> createTopupBatch(@RequestBody Map<String, Object> batch) {
        log.info("POST /admin/topups/batch");
        return Mono.just(Map.of(
            "success", true,
            "batchId", UUID.randomUUID().toString(),
            "processedCount", batch.getOrDefault("count", 0),
            "status", "PROCESSING"
        ));
    }
    
    @PostMapping("/topups/user/{userId}")
    public Mono<Map<String, Object>> createTopupForUser(@PathVariable String userId, @RequestBody Map<String, Object> request) {
        log.info("POST /admin/topups/user/{}", userId);
        return Mono.just(Map.of(
            "success", true,
            "topupId", UUID.randomUUID().toString(),
            "userId", userId,
            "amount", request.get("amount"),
            "status", "COMPLETED"
        ));
    }
    
    @GetMapping("/merchants")
    public Mono<Map<String, Object>> getMerchants() {
        log.info("GET /admin/merchants");
        return webClient.get()
            .uri(coreServiceUrl + "/api/merchants?page=0&size=100")
            .header("X-API-Key", apiKey)
            .retrieve()
            .bodyToMono(List.class)
            .map(merchants -> Map.of("success", true, "data", merchants, "total", ((List<?>)merchants).size()))
            .onErrorResume(e -> Mono.just(Map.of("success", true, "data", List.of(), "total", 0)));
    }
    
    @GetMapping("/reconciliation")
    public Mono<Map<String, Object>> getReconciliation() {
        log.info("GET /admin/reconciliation");
        return Mono.just(Map.of("success", true, "data", List.of()));
    }
    
    @GetMapping("/disputes")
    public Mono<Map<String, Object>> getDisputes() {
        log.info("GET /admin/disputes");
        return Mono.just(Map.of("success", true, "data", List.of(), "total", 0));
    }
    
    @GetMapping("/risk")
    public Mono<Map<String, Object>> getRiskAnalysis() {
        log.info("GET /admin/risk");
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of("overallRiskScore", 0.1, "riskLevel", "LOW", "flaggedTransactions", 0)
        ));
    }
    
    @GetMapping("/support/tickets")
    public Mono<Map<String, Object>> getTickets() {
        log.info("GET /admin/support/tickets");
        return Mono.just(Map.of("success", true, "data", List.of(), "total", 0));
    }
    
    @GetMapping("/audit")
    public Mono<Map<String, Object>> getAuditLogs() {
        log.info("GET /admin/audit");
        return Mono.just(Map.of("success", true, "data", List.of(), "total", 0));
    }
    
    private List<Map<String, Object>> getMockEmployees() {
        return List.of(
            Map.of("id", UUID.randomUUID().toString(), "name", "João Silva", "email", "joao@empresa.com", "department", "TI", "status", "ACTIVE"),
            Map.of("id", UUID.randomUUID().toString(), "name", "Maria Santos", "email", "maria@empresa.com", "department", "RH", "status", "ACTIVE"),
            Map.of("id", UUID.randomUUID().toString(), "name", "Pedro Costa", "email", "pedro@empresa.com", "department", "Financeiro", "status", "ACTIVE")
        );
    }
}
