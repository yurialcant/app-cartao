# Script para expandir User BFF com todos os endpoints necessários

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 EXPANDINDO USER BFF COM TODOS OS ENDPOINTS 🚀         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$userBffDir = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff"
$controllerDir = Join-Path $userBffDir "controller"

# Novos controllers a criar
$newControllers = @{
    "DeviceController" = @"
package com.benefits.userbff.controller;

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
@RequestMapping("/devices")
@RequiredArgsConstructor
public class DeviceController {
    
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerDevice(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> deviceInfo,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /devices/register - User: {}", userId);
        // TODO: Chamar Device Service
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Device registrado"));
    }
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserDevices(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] GET /devices - User: {}", userId);
        // TODO: Chamar Device Service
        return ResponseEntity.ok(Map.of("devices", java.util.List.of()));
    }
    
    @PutMapping("/{deviceId}/trust")
    public ResponseEntity<Map<String, Object>> trustDevice(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String deviceId,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] PUT /devices/{}/trust - User: {}", deviceId, userId);
        // TODO: Chamar Device Service
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Device confiável"));
    }
}
"@
    
    "PaymentController" = @"
package com.benefits.userbff.controller;

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
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {
    
    @PostMapping("/qr/scan")
    public ResponseEntity<Map<String, Object>> scanQR(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /payments/qr/scan - User: {}", userId);
        // TODO: Chamar Payments Orchestrator
        return ResponseEntity.ok(Map.of("status", "OK", "message", "QR escaneado"));
    }
    
    @PostMapping("/qr/confirm")
    public ResponseEntity<Map<String, Object>> confirmQRPayment(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /payments/qr/confirm - User: {}", userId);
        // TODO: Chamar Payments Orchestrator
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Pagamento confirmado"));
    }
    
    @PostMapping("/card")
    public ResponseEntity<Map<String, Object>> processCardPayment(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /payments/card - User: {}", userId);
        // TODO: Chamar Payments Orchestrator
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Pagamento processado"));
    }
}
"@
    
    "SecurityController" = @"
package com.benefits.userbff.controller;

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
@RequestMapping("/security")
@RequiredArgsConstructor
public class SecurityController {
    
    @PostMapping("/panic-mode")
    public ResponseEntity<Map<String, Object>> activatePanicMode(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /security/panic-mode - User: {}", userId);
        // TODO: Revogar sessões, bloquear tokens
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Modo pânico ativado"));
    }
    
    @GetMapping("/sessions")
    public ResponseEntity<Map<String, Object>> getActiveSessions(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] GET /security/sessions - User: {}", userId);
        // TODO: Listar sessões ativas
        return ResponseEntity.ok(Map.of("sessions", java.util.List.of()));
    }
    
    @DeleteMapping("/sessions/{sessionId}")
    public ResponseEntity<Map<String, Object>> revokeSession(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String sessionId,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] DELETE /security/sessions/{} - User: {}", sessionId, userId);
        // TODO: Revogar sessão
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Sessão revogada"));
    }
}
"@
    
    "SupportController" = @"
package com.benefits.userbff.controller;

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
@RequestMapping("/support")
@RequiredArgsConstructor
public class SupportController {
    
    @PostMapping("/tickets")
    public ResponseEntity<Map<String, Object>> createTicket(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /support/tickets - User: {}", userId);
        // TODO: Chamar Support Service
        return ResponseEntity.ok(Map.of("ticketId", UUID.randomUUID().toString(), "status", "CREATED"));
    }
    
    @GetMapping("/tickets")
    public ResponseEntity<Map<String, Object>> getUserTickets(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] GET /support/tickets - User: {}", userId);
        // TODO: Chamar Support Service
        return ResponseEntity.ok(Map.of("tickets", java.util.List.of()));
    }
    
    @GetMapping("/tickets/{ticketId}")
    public ResponseEntity<Map<String, Object>> getTicket(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String ticketId,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] GET /support/tickets/{} - User: {}", ticketId, userId);
        // TODO: Chamar Support Service
        return ResponseEntity.ok(Map.of("ticketId", ticketId, "status", "OPEN"));
    }
}
"@
    
    "PrivacyController" = @"
package com.benefits.userbff.controller;

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
@RequestMapping("/privacy")
@RequiredArgsConstructor
public class PrivacyController {
    
    @PostMapping("/export")
    public ResponseEntity<Map<String, Object>> exportData(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /privacy/export - User: {}", userId);
        // TODO: Chamar Privacy Service
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Exportação iniciada"));
    }
    
    @PostMapping("/delete")
    public ResponseEntity<Map<String, Object>> deleteData(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] POST /privacy/delete - User: {}", userId);
        // TODO: Chamar Privacy Service
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Exclusão iniciada"));
    }
    
    @GetMapping("/consents")
    public ResponseEntity<Map<String, Object>> getConsents(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String userId = jwt.getSubject();
        log.info("🔵 [BFF] GET /privacy/consents - User: {}", userId);
        // TODO: Chamar Privacy Service
        return ResponseEntity.ok(Map.of("consents", java.util.List.of()));
    }
}
"@
}

Write-Host "`nCriando novos controllers no User BFF..." -ForegroundColor Cyan

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

Write-Host "`n✅ User BFF expandido com novos endpoints!" -ForegroundColor Green
Write-Host "`n📋 Novos endpoints criados:" -ForegroundColor Yellow
Write-Host "  • /devices/* - Gestão de dispositivos (Fluxo 1, 13)" -ForegroundColor White
Write-Host "  • /payments/qr/* - Pagamentos QR (Fluxo 5)" -ForegroundColor White
Write-Host "  • /payments/card - Pagamentos Cartão (Fluxo 6)" -ForegroundColor White
Write-Host "  • /security/* - Segurança e modo pânico (Fluxo 13)" -ForegroundColor White
Write-Host "  • /support/tickets/* - Atendimento (Fluxo 11)" -ForegroundColor White
Write-Host "  • /privacy/* - LGPD (Fluxo 14)" -ForegroundColor White
Write-Host ""
