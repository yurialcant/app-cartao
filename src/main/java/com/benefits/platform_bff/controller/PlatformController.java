package com.benefits.platform_bff.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/platform")
public class PlatformController {

    private static final Logger log = LoggerFactory.getLogger(PlatformController.class);

    @GetMapping("/tenants")
    public Mono<ResponseEntity<List<Map<String, Object>>>> getTenants() {
        log.info("[Platform] Getting all tenants");

        // In a real implementation, this would call tenant-service
        return Mono.just(ResponseEntity.ok(List.of(
            Map.of("id", "550e8400-e29b-41d4-a716-446655440000", "name", "Default Tenant", "status", "ACTIVE")
        )));
    }

    @GetMapping("/stats")
    public Mono<ResponseEntity<Map<String, Object>>> getPlatformStats() {
        log.info("[Platform] Getting platform statistics");

        // In a real implementation, this would aggregate stats from all services
        return Mono.just(ResponseEntity.ok(Map.of(
            "totalTenants", 1,
            "totalUsers", 3,
            "totalTransactions", 1500,
            "activeServices", 13
        )));
    }

    @GetMapping("/audit/events")
    public Mono<ResponseEntity<List<Map<String, Object>>>> getAuditEvents(
            @RequestParam(defaultValue = "10") int limit) {
        log.info("[Platform] Getting recent audit events");

        // In a real implementation, this would call audit-service
        return Mono.just(ResponseEntity.ok(List.of(
            Map.of("eventType", "USER_LOGIN", "timestamp", "2026-01-18T17:00:00Z", "severity", "INFO")
        )));
    }

    @GetMapping("/health/services")
    public Mono<ResponseEntity<Map<String, Object>>> getServicesHealth() {
        log.info("[Platform] Getting services health status");

        // In a real implementation, this would check all services health
        return Mono.just(ResponseEntity.ok(Map.of(
            "benefits-core", "UP",
            "tenant-service", "UP",
            "identity-service", "UP",
            "payments-orchestrator", "UP",
            "merchant-service", "UP",
            "support-service", "UP",
            "audit-service", "UP",
            "notification-service", "UP",
            "recon-service", "UP",
            "settlement-service", "UP",
            "privacy-service", "UP",
            "billing-service", "UP",
            "ops-relay", "UP"
        )));
    }
}