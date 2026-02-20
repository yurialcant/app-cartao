# Script para expandir Admin BFF com todos os endpoints necessários

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 EXPANDINDO ADMIN BFF COM TODOS OS ENDPOINTS 🚀        ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$adminBffDir = Join-Path $baseDir "services/admin-bff/src/main/java/com/benefits/adminbff"
$controllerDir = Join-Path $adminBffDir "controller"

# Novos controllers a criar
$newControllers = @{
    "MerchantManagementController" = @"
package com.benefits.adminbff.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/admin/merchants")
@RequiredArgsConstructor
public class MerchantManagementController {
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getMerchants(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/merchants");
        return ResponseEntity.ok(Map.of("merchants", java.util.List.of(), "total", 0));
    }
    
    @PostMapping("/{merchantId}/approve")
    public ResponseEntity<Map<String, Object>> approveMerchant(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String merchantId,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] POST /admin/merchants/{}/approve", merchantId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Merchant aprovado"));
    }
    
    @PostMapping("/{merchantId}/kyb/verify")
    public ResponseEntity<Map<String, Object>> verifyKYB(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String merchantId,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] POST /admin/merchants/{}/kyb/verify", merchantId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "KYB verificado"));
    }
}
"@
    
    "ReconciliationController" = @"
package com.benefits.adminbff.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/reconciliation")
@RequiredArgsConstructor
public class ReconciliationController {
    
    @PostMapping("/import")
    public ResponseEntity<Map<String, Object>> importStatement(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] POST /admin/reconciliation/import");
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Extrato importado"));
    }
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getReconciliations(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/reconciliation");
        return ResponseEntity.ok(Map.of("reconciliations", java.util.List.of()));
    }
    
    @PostMapping("/{id}/reconcile")
    public ResponseEntity<Map<String, Object>> reconcile(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String id,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] POST /admin/reconciliation/{}/reconcile", id);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Conciliação processada"));
    }
}
"@
    
    "DisputeController" = @"
package com.benefits.adminbff.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/disputes")
@RequiredArgsConstructor
public class DisputeController {
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getDisputes(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/disputes");
        return ResponseEntity.ok(Map.of("disputes", java.util.List.of()));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getDispute(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String id,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/disputes/{}", id);
        return ResponseEntity.ok(Map.of("disputeId", id, "status", "OPEN"));
    }
    
    @PutMapping("/{id}/resolve")
    public ResponseEntity<Map<String, Object>> resolveDispute(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String id,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] PUT /admin/disputes/{}/resolve", id);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Disputa resolvida"));
    }
}
"@
    
    "RiskController" = @"
package com.benefits.adminbff.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/risk")
@RequiredArgsConstructor
public class RiskController {
    
    @GetMapping("/users/{userId}/score")
    public ResponseEntity<Map<String, Object>> getUserRiskScore(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String userId,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/risk/users/{}/score", userId);
        return ResponseEntity.ok(Map.of("userId", userId, "riskScore", 50, "level", "MEDIUM"));
    }
    
    @PostMapping("/users/{userId}/override")
    public ResponseEntity<Map<String, Object>> overrideRisk(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String userId,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] POST /admin/risk/users/{}/override", userId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Override aplicado"));
    }
}
"@
    
    "SupportManagementController" = @"
package com.benefits.adminbff.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/support")
@RequiredArgsConstructor
public class SupportManagementController {
    
    @GetMapping("/tickets")
    public ResponseEntity<Map<String, Object>> getAllTickets(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/support/tickets");
        return ResponseEntity.ok(Map.of("tickets", java.util.List.of()));
    }
    
    @PutMapping("/tickets/{ticketId}/assign")
    public ResponseEntity<Map<String, Object>> assignTicket(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String ticketId,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] PUT /admin/support/tickets/{}/assign", ticketId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Ticket atribuído"));
    }
    
    @PutMapping("/tickets/{ticketId}/resolve")
    public ResponseEntity<Map<String, Object>> resolveTicket(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String ticketId,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] PUT /admin/support/tickets/{}/resolve", ticketId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Ticket resolvido"));
    }
}
"@
    
    "AuditController" = @"
package com.benefits.adminbff.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/audit")
@RequiredArgsConstructor
public class AuditController {
    
    @GetMapping("/logs")
    public ResponseEntity<Map<String, Object>> getAuditLogs(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String userId,
            @RequestParam(required = false) String resourceType,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/audit/logs");
        return ResponseEntity.ok(Map.of("logs", java.util.List.of(), "total", 0));
    }
    
    @GetMapping("/logs/{resourceType}/{resourceId}")
    public ResponseEntity<Map<String, Object>> getResourceAuditLogs(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String resourceType,
            @PathVariable String resourceId,
            HttpServletRequest request) {
        log.info("🔵 [ADMIN-BFF] GET /admin/audit/logs/{}/{}", resourceType, resourceId);
        return ResponseEntity.ok(Map.of("logs", java.util.List.of()));
    }
}
"@
}

Write-Host "`nCriando novos controllers no Admin BFF..." -ForegroundColor Cyan

foreach ($controllerName in $newControllers.Keys) {
    $controllerPath = Join-Path $controllerDir "$controllerName.java"
    
    if (Test-Path $controllerPath) {
        Write-Host "  ⚠ $controllerName já existe" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  Criando $controllerName..." -ForegroundColor Yellow
    Set-Content -Path $controllerPath -Value $newControllers[$controllerName] -Encoding UTF8
    Write-Host "    ✓ $controllerName criado" -ForegroundColor Green
}

Write-Host "`n✅ Admin BFF expandido com novos endpoints!" -ForegroundColor Green
Write-Host "`n📋 Novos endpoints criados:" -ForegroundColor Yellow
Write-Host "  • /admin/merchants/* - Gestão de merchants (Fluxo 4)" -ForegroundColor White
Write-Host "  • /admin/reconciliation/* - Conciliação (Fluxo 9)" -ForegroundColor White
Write-Host "  • /admin/disputes/* - Disputas (Fluxo 10)" -ForegroundColor White
Write-Host "  • /admin/risk/* - Análise de risco (Fluxo 12)" -ForegroundColor White
Write-Host "  • /admin/support/* - Gestão de tickets (Fluxo 11)" -ForegroundColor White
Write-Host "  • /admin/audit/* - Auditoria (Fluxo 15)" -ForegroundColor White
Write-Host ""
