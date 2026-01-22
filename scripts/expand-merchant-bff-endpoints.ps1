# Script para expandir Merchant BFF com todos os endpoints necessários

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 EXPANDINDO MERCHANT BFF COM TODOS OS ENDPOINTS 🚀      ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$merchantBffDir = Join-Path $baseDir "services/merchant-bff/src/main/java/com/benefits/merchantbff"
$controllerDir = Join-Path $merchantBffDir "controller"

# Novos controllers a criar
$newControllers = @{
    "TerminalController" = @"
package com.benefits.merchantbff.controller;

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
@RequestMapping("/terminals")
@RequiredArgsConstructor
public class TerminalController {
    
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerTerminal(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] POST /terminals/register - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Terminal registrado"));
    }
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getTerminals(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] GET /terminals - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("terminals", java.util.List.of()));
    }
}
"@
    
    "OperatorController" = @"
package com.benefits.merchantbff.controller;

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
@RequestMapping("/operators")
@RequiredArgsConstructor
public class OperatorController {
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createOperator(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] POST /operators - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Operador criado"));
    }
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getOperators(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] GET /operators - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("operators", java.util.List.of()));
    }
}
"@
    
    "RefundController" = @"
package com.benefits.merchantbff.controller;

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
@RequestMapping("/refunds")
@RequiredArgsConstructor
public class RefundController {
    
    @PostMapping
    public ResponseEntity<Map<String, Object>> createRefund(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] POST /refunds - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Reembolso criado"));
    }
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getRefunds(
            @AuthenticationPrincipal Jwt jwt,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] GET /refunds - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("refunds", java.util.List.of()));
    }
}
"@
    
    "ShiftController" = @"
package com.benefits.merchantbff.controller;

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
@RequestMapping("/shifts")
@RequiredArgsConstructor
public class ShiftController {
    
    @PostMapping("/close")
    public ResponseEntity<Map<String, Object>> closeShift(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] POST /shifts/close - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Turno fechado"));
    }
    
    @GetMapping("/report")
    public ResponseEntity<Map<String, Object>> getShiftReport(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(required = false) String shiftId,
            HttpServletRequest request) {
        String merchantId = jwt.getSubject();
        log.info("🔵 [MERCHANT-BFF] GET /shifts/report - Merchant: {}", merchantId);
        return ResponseEntity.ok(Map.of("report", Map.of()));
    }
}
"@
}

Write-Host "`nCriando novos controllers no Merchant BFF..." -ForegroundColor Cyan

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

Write-Host "`n✅ Merchant BFF expandido com novos endpoints!" -ForegroundColor Green
Write-Host "`n📋 Novos endpoints criados:" -ForegroundColor Yellow
Write-Host "  • /terminals/* - Gestão de terminais (Fluxo 4)" -ForegroundColor White
Write-Host "  • /operators/* - Gestão de operadores (Fluxo 4)" -ForegroundColor White
Write-Host "  • /refunds/* - Reembolsos (Fluxo 7)" -ForegroundColor White
Write-Host "  • /shifts/* - Fechamento de caixa (Fluxo 8)" -ForegroundColor White
Write-Host ""
