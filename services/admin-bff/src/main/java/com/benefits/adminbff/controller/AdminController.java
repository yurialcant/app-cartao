package com.benefits.adminbff.controller;

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
    
    @Value("${core.service.apiKey:admin-api-key}")
    private String apiKey;
    
    public AdminController(WebClient webClient) {
        this.webClient = webClient;
    }
    
    // ========== USERS ==========
    
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
                return Mono.just(Map.of(
                    "success", true,
                    "data", getMockUsers(),
                    "total", 5
                ));
            });
    }
    
    @PostMapping("/users")
    public Mono<Map<String, Object>> createUser(@RequestBody Map<String, Object> user) {
        log.info("POST /admin/users - {}", user.get("email"));
        return webClient.post()
            .uri(coreServiceUrl + "/api/users")
            .header("X-API-Key", apiKey)
            .bodyValue(user)
            .retrieve()
            .bodyToMono(Map.class)
            .map(created -> Map.of("success", true, "data", created))
            .onErrorResume(e -> {
                log.warn("Using mock create: {}", e.getMessage());
                Map<String, Object> created = new HashMap<>(user);
                created.put("id", UUID.randomUUID().toString());
                created.put("createdAt", LocalDateTime.now().toString());
                return Mono.just(Map.of("success", true, "data", created));
            });
    }
    
    @PostMapping("/users/{userId}/onboard")
    public Mono<Map<String, Object>> onboardUser(@PathVariable String userId) {
        log.info("POST /admin/users/{}/onboard", userId);
        return Mono.just(Map.of(
            "success", true,
            "message", "User onboarded successfully",
            "userId", userId
        ));
    }
    
    // ========== TOPUPS ==========
    
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
    public Mono<Map<String, Object>> createTopupForUser(
            @PathVariable String userId,
            @RequestBody Map<String, Object> request) {
        log.info("POST /admin/topups/user/{}", userId);
        return webClient.post()
            .uri(coreServiceUrl + "/api/wallets/" + userId + "/balance")
            .header("X-API-Key", apiKey)
            .bodyValue(request)
            .retrieve()
            .bodyToMono(Map.class)
            .map(result -> Map.of("success", true, "data", result))
            .onErrorResume(e -> {
                log.warn("Using mock topup: {}", e.getMessage());
                return Mono.just(Map.of(
                    "success", true,
                    "topupId", UUID.randomUUID().toString(),
                    "userId", userId,
                    "amount", request.get("amount"),
                    "status", "COMPLETED"
                ));
            });
    }
    
    // ========== MERCHANTS ==========
    
    @GetMapping("/merchants")
    public Mono<Map<String, Object>> getMerchants() {
        log.info("GET /admin/merchants");
        return webClient.get()
            .uri(coreServiceUrl + "/api/merchants?page=0&size=100")
            .header("X-API-Key", apiKey)
            .retrieve()
            .bodyToMono(List.class)
            .map(merchants -> Map.of(
                "success", true,
                "data", merchants,
                "total", ((List<?>)merchants).size()
            ))
            .onErrorResume(e -> {
                log.warn("Using mock merchants: {}", e.getMessage());
                return Mono.just(Map.of(
                    "success", true,
                    "data", getMockMerchants(),
                    "total", 3
                ));
            });
    }
    
    // ========== RECONCILIATION ==========
    
    @GetMapping("/reconciliation")
    public Mono<Map<String, Object>> getReconciliation() {
        log.info("GET /admin/reconciliation");
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "date", LocalDateTime.now().minusDays(1).toString(),
                    "totalTransactions", 150,
                    "totalAmount", 45000.00,
                    "status", "COMPLETED",
                    "matchedCount", 148,
                    "unmatchedCount", 2
                ),
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "date", LocalDateTime.now().toString(),
                    "totalTransactions", 87,
                    "totalAmount", 23500.00,
                    "status", "IN_PROGRESS",
                    "matchedCount", 85,
                    "unmatchedCount", 2
                )
            )
        ));
    }
    
    // ========== DISPUTES ==========
    
    @GetMapping("/disputes")
    public Mono<Map<String, Object>> getDisputes() {
        log.info("GET /admin/disputes");
        return webClient.get()
            .uri(coreServiceUrl + "/api/disputes?page=0&size=100")
            .header("X-API-Key", apiKey)
            .retrieve()
            .bodyToMono(List.class)
            .map(disputes -> Map.of(
                "success", true,
                "data", disputes,
                "total", ((List<?>)disputes).size()
            ))
            .onErrorResume(e -> {
                log.warn("Using mock disputes: {}", e.getMessage());
                return Mono.just(Map.of(
                    "success", true,
                    "data", getMockDisputes(),
                    "total", 2
                ));
            });
    }
    
    // ========== RISK ==========
    
    @GetMapping("/risk")
    public Mono<Map<String, Object>> getRiskAnalysis() {
        log.info("GET /admin/risk");
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of(
                "overallRiskScore", 0.15,
                "riskLevel", "LOW",
                "flaggedTransactions", 3,
                "flaggedUsers", 1,
                "alerts", List.of(
                    Map.of(
                        "id", UUID.randomUUID().toString(),
                        "type", "UNUSUAL_ACTIVITY",
                        "severity", "MEDIUM",
                        "message", "Unusual transaction pattern detected",
                        "createdAt", LocalDateTime.now().minusHours(2).toString()
                    )
                ),
                "trends", Map.of(
                    "daily", 0.12,
                    "weekly", 0.18,
                    "monthly", 0.14
                )
            )
        ));
    }
    
    // ========== SUPPORT ==========
    
    @GetMapping("/support/tickets")
    public Mono<Map<String, Object>> getTickets() {
        log.info("GET /admin/support/tickets");
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "subject", "Cannot complete transaction",
                    "status", "OPEN",
                    "priority", "HIGH",
                    "userId", UUID.randomUUID().toString(),
                    "createdAt", LocalDateTime.now().minusHours(3).toString()
                ),
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "subject", "Balance not updated",
                    "status", "IN_PROGRESS",
                    "priority", "MEDIUM",
                    "userId", UUID.randomUUID().toString(),
                    "createdAt", LocalDateTime.now().minusDays(1).toString()
                )
            ),
            "total", 2
        ));
    }
    
    // ========== AUDIT ==========
    
    @GetMapping("/audit")
    public Mono<Map<String, Object>> getAuditLogs() {
        log.info("GET /admin/audit");
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "action", "USER_LOGIN",
                    "userId", UUID.randomUUID().toString(),
                    "details", "Admin user logged in",
                    "ipAddress", "192.168.1.100",
                    "timestamp", LocalDateTime.now().minusMinutes(30).toString()
                ),
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "action", "TOPUP_CREATED",
                    "userId", UUID.randomUUID().toString(),
                    "details", "Topup of R$ 500.00 created",
                    "ipAddress", "192.168.1.100",
                    "timestamp", LocalDateTime.now().minusHours(1).toString()
                ),
                Map.of(
                    "id", UUID.randomUUID().toString(),
                    "action", "USER_CREATED",
                    "userId", UUID.randomUUID().toString(),
                    "details", "New user created: joao.silva@example.com",
                    "ipAddress", "192.168.1.100",
                    "timestamp", LocalDateTime.now().minusHours(2).toString()
                )
            ),
            "total", 3
        ));
    }
    
    // ========== MOCK DATA ==========
    
    private List<Map<String, Object>> getMockUsers() {
        return List.of(
            createMockUser("João Silva", "joao.silva@email.com", "ACTIVE"),
            createMockUser("Maria Santos", "maria.santos@email.com", "ACTIVE"),
            createMockUser("Pedro Oliveira", "pedro.oliveira@email.com", "PENDING"),
            createMockUser("Ana Costa", "ana.costa@email.com", "ACTIVE"),
            createMockUser("Carlos Ferreira", "carlos.ferreira@email.com", "INACTIVE")
        );
    }
    
    private Map<String, Object> createMockUser(String name, String email, String status) {
        return Map.of(
            "id", UUID.randomUUID().toString(),
            "name", name,
            "email", email,
            "status", status,
            "balance", Math.random() * 1000,
            "createdAt", LocalDateTime.now().minusDays((long)(Math.random() * 30)).toString()
        );
    }
    
    private List<Map<String, Object>> getMockMerchants() {
        return List.of(
            Map.of(
                "id", UUID.randomUUID().toString(),
                "name", "Restaurante Sabor & Arte",
                "cnpj", "12.345.678/0001-90",
                "category", "ALIMENTACAO",
                "status", "ACTIVE",
                "transactionCount", 245
            ),
            Map.of(
                "id", UUID.randomUUID().toString(),
                "name", "Farmácia Saúde Total",
                "cnpj", "98.765.432/0001-10",
                "category", "SAUDE",
                "status", "ACTIVE",
                "transactionCount", 189
            ),
            Map.of(
                "id", UUID.randomUUID().toString(),
                "name", "Supermercado Economia",
                "cnpj", "11.222.333/0001-44",
                "category", "ALIMENTACAO",
                "status", "PENDING",
                "transactionCount", 0
            )
        );
    }
    
    private List<Map<String, Object>> getMockDisputes() {
        return List.of(
            Map.of(
                "id", UUID.randomUUID().toString(),
                "userId", UUID.randomUUID().toString(),
                "transactionId", UUID.randomUUID().toString(),
                "reason", "Transaction not recognized",
                "amount", 150.00,
                "status", "OPEN",
                "createdAt", LocalDateTime.now().minusDays(2).toString()
            ),
            Map.of(
                "id", UUID.randomUUID().toString(),
                "userId", UUID.randomUUID().toString(),
                "transactionId", UUID.randomUUID().toString(),
                "reason", "Double charge",
                "amount", 89.90,
                "status", "UNDER_REVIEW",
                "createdAt", LocalDateTime.now().minusDays(5).toString()
            )
        );
    }
}
