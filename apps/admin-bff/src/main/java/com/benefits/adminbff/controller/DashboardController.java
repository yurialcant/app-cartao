package com.benefits.adminbff.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class DashboardController {
    
    private static final Logger log = LoggerFactory.getLogger(DashboardController.class);
    
    @GetMapping("/dashboard")
    public Mono<Map<String, Object>> getDashboard() {
        log.info("GET /api/admin/dashboard");
        Map<String, Object> data = new HashMap<>();
        data.put("totalUsers", 1250);
        data.put("activeUsers", 1180);
        data.put("totalMerchants", 85);
        data.put("activeMerchants", 78);
        data.put("totalTransactions", 15420);
        data.put("totalVolume", 2450000.00);
        data.put("pendingDisputes", 12);
        data.put("openTickets", 8);
        data.put("riskAlerts", 3);
        
        return Mono.just(Map.of("success", true, "data", data));
    }
    
    @GetMapping("/stats")
    public Mono<Map<String, Object>> getStats() {
        log.info("GET /api/admin/stats");
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of(
                "users", Map.of("total", 1250, "active", 1180),
                "merchants", Map.of("total", 85, "active", 78),
                "transactions", Map.of("today", 245, "week", 1325),
                "volume", Map.of("today", 45000.00, "week", 285000.00)
            )
        ));
    }
    
    @GetMapping("/audit/{entityType}/{entityId}")
    public Mono<Map<String, Object>> getEntityAuditLog(
            @PathVariable String entityType, @PathVariable String entityId) {
        log.info("GET /api/admin/audit/{}/{}", entityType, entityId);
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(Map.of("id", UUID.randomUUID().toString(), "entityType", entityType, "action", "UPDATE"))
        ));
    }
    
    @GetMapping("/audit/user/{userId}")
    public Mono<Map<String, Object>> getUserAuditLog(
            @PathVariable String userId, @RequestParam(defaultValue = "7") int daysBack) {
        log.info("GET /api/admin/audit/user/{}", userId);
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(Map.of("id", UUID.randomUUID().toString(), "userId", userId, "action", "LOGIN"))
        ));
    }
    
    @GetMapping("/alerts/{tenantId}")
    public Mono<Map<String, Object>> getActiveAlerts(@PathVariable String tenantId) {
        log.info("GET /api/admin/alerts/{}", tenantId);
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(Map.of("id", UUID.randomUUID().toString(), "tenantId", tenantId, "type", "RISK"))
        ));
    }
    
    @PostMapping("/alerts")
    public Mono<Map<String, Object>> createAlert(@RequestBody Map<String, Object> alert) {
        log.info("POST /api/admin/alerts");
        Map<String, Object> created = new HashMap<>(alert);
        created.put("id", UUID.randomUUID().toString());
        return Mono.just(Map.of("success", true, "data", created));
    }
    
    @PutMapping("/alerts/{alertId}/resolve")
    public Mono<Map<String, Object>> resolveAlert(
            @PathVariable String alertId, @RequestBody Map<String, Object> resolution) {
        log.info("PUT /api/admin/alerts/{}/resolve", alertId);
        return Mono.just(Map.of("success", true, "data", Map.of("id", alertId, "status", "RESOLVED")));
    }
    
    @GetMapping("/config/{tenantId}/{configKey}")
    public Mono<Map<String, Object>> getConfig(
            @PathVariable String tenantId, @PathVariable String configKey) {
        log.info("GET /api/admin/config/{}/{}", tenantId, configKey);
        return Mono.just(Map.of("success", true, "data", Map.of("tenantId", tenantId, "key", configKey)));
    }
    
    @GetMapping("/config/{tenantId}")
    public Mono<Map<String, Object>> getTenantConfigs(@PathVariable String tenantId) {
        log.info("GET /api/admin/config/{}", tenantId);
        return Mono.just(Map.of("success", true, "data", List.of(Map.of("tenantId", tenantId, "key", "max_limit"))));
    }
    
    @PostMapping("/config")
    public Mono<Map<String, Object>> setConfig(@RequestBody Map<String, Object> config) {
        log.info("POST /api/admin/config");
        Map<String, Object> saved = new HashMap<>(config);
        saved.put("updatedAt", LocalDateTime.now().toString());
        return Mono.just(Map.of("success", true, "data", saved));
    }
    
    @DeleteMapping("/config/{tenantId}/{configKey}")
    public Mono<Void> deleteConfig(@PathVariable String tenantId, @PathVariable String configKey) {
        log.info("DELETE /api/admin/config/{}/{}", tenantId, configKey);
        return Mono.empty();
    }
}
