# Script para implementar controllers básicos em cada serviço especializado

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🎯 IMPLEMENTANDO CONTROLLERS BÁSICOS NOS SERVIÇOS 🎯     ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$servicesDir = Join-Path $baseDir "services"

# Mapeamento de serviços para controllers
$serviceControllers = @{
    "payments-orchestrator" = @{
        Name = "PaymentController"
        Endpoints = @("POST /api/payments/qr", "POST /api/payments/card", "GET /api/payments/{id}")
    }
    "acquirer-adapter" = @{
        Name = "AcquirerController"
        Endpoints = @("POST /api/acquirer/authorize", "POST /api/acquirer/capture", "POST /api/acquirer/refund")
    }
    "risk-service" = @{
        Name = "RiskController"
        Endpoints = @("POST /api/risk/analyze", "POST /api/risk/step-up", "GET /api/risk/score/{userId}")
    }
    "support-service" = @{
        Name = "TicketController"
        Endpoints = @("POST /api/tickets", "GET /api/tickets", "GET /api/tickets/{id}", "PUT /api/tickets/{id}")
    }
    "settlement-service" = @{
        Name = "SettlementController"
        Endpoints = @("POST /api/settlements/calculate", "GET /api/settlements", "POST /api/settlements/{id}/process")
    }
    "recon-service" = @{
        Name = "ReconciliationController"
        Endpoints = @("POST /api/reconciliation/import", "GET /api/reconciliation", "POST /api/reconciliation/{id}/reconcile")
    }
    "device-service" = @{
        Name = "DeviceController"
        Endpoints = @("POST /api/devices/register", "GET /api/devices/{userId}", "PUT /api/devices/{id}/trust")
    }
    "audit-service" = @{
        Name = "AuditController"
        Endpoints = @("POST /api/audit/log", "GET /api/audit/logs", "GET /api/audit/logs/{resourceType}/{resourceId}")
    }
    "notification-service" = @{
        Name = "NotificationController"
        Endpoints = @("POST /api/notifications/send", "GET /api/notifications/{userId}", "PUT /api/notifications/{id}/read")
    }
    "kyc-service" = @{
        Name = "KycController"
        Endpoints = @("POST /api/kyc/submit", "GET /api/kyc/{userId}", "PUT /api/kyc/{id}/verify")
    }
    "kyb-service" = @{
        Name = "KybController"
        Endpoints = @("POST /api/kyb/submit", "GET /api/kyb/{merchantId}", "PUT /api/kyb/{id}/verify")
    }
    "privacy-service" = @{
        Name = "PrivacyController"
        Endpoints = @("POST /api/privacy/export", "POST /api/privacy/delete", "GET /api/privacy/consents/{userId}")
    }
    "acquirer-stub" = @{
        Name = "StubController"
        Endpoints = @("POST /api/stub/cielo/authorize", "POST /api/stub/stone/authorize", "POST /api/stub/webhook")
    }
    "webhook-receiver" = @{
        Name = "WebhookController"
        Endpoints = @("POST /api/webhooks/cielo", "POST /api/webhooks/stone", "GET /api/webhooks")
    }
}

function Create-BasicController {
    param(
        [string]$ServiceName,
        [string]$ControllerName,
        [array]$Endpoints
    )
    
    $serviceDir = Join-Path $servicesDir $ServiceName
    $packageName = $ServiceName.Replace('-', '')
    $controllerDir = Join-Path $serviceDir "src/main/java/com/benefits/$packageName/controller"
    
    if (-not (Test-Path $controllerDir)) {
        New-Item -ItemType Directory -Path $controllerDir -Force | Out-Null
    }
    
    $endpointsCode = ""
    foreach ($endpoint in $Endpoints) {
        $parts = $endpoint -split " "
        $method = $parts[0]
        $path = $parts[1]
        
        $pathVar = $path -replace "\{[^}]+\}", "{id}"
        $pathVar = $pathVar -replace "/", ""
        $pathVar = $pathVar -replace "api", ""
        $pathVar = $pathVar -replace "\{id\}", ""
        
        $methodName = switch ($method) {
            "GET" { "get" }
            "POST" { "create" }
            "PUT" { "update" }
            "DELETE" { "delete" }
            default { "handle" }
        }
        
        $methodName += ($pathVar -split "-" | ForEach-Object { 
            $_.Substring(0,1).ToUpper() + $_.Substring(1) 
        }) -join ""
        
        if ($path -match "\{id\}") {
            $endpointsCode += @"
    
    @$method("$path")
    public ResponseEntity<Map<String, Object>> $methodName(
            @PathVariable String id,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [$($ServiceName.ToUpper())] $method $path - Request-ID: {}", requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "id", id,
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }
"@
        } else {
            $endpointsCode += @"
    
    @$method("$path")
    public ResponseEntity<Map<String, Object>> $methodName(
            @RequestBody(required = false) Map<String, Object> body,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [$($ServiceName.ToUpper())] $method $path - Request-ID: {}", requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }
"@
        }
    }
    
    $controllerContent = @"
package com.benefits.$packageName.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class $ControllerName {
$endpointsCode
}
"@
    
    $controllerPath = Join-Path $controllerDir "$ControllerName.java"
    if (-not (Test-Path $controllerPath)) {
        Set-Content -Path $controllerPath -Value $controllerContent -Encoding UTF8
        Write-Host "    ✓ $ControllerName criado" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ $ControllerName já existe" -ForegroundColor Yellow
    }
}

Write-Host "`nCriando controllers básicos..." -ForegroundColor Cyan

foreach ($service in $serviceControllers.Keys) {
    $config = $serviceControllers[$service]
    Write-Host "  Criando $($config.Name) para $service..." -ForegroundColor Yellow
    Create-BasicController -ServiceName $service -ControllerName $config.Name -Endpoints $config.Endpoints
}

Write-Host "`n✅ Controllers básicos criados com sucesso!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Implementar lógica de negócio em cada controller" -ForegroundColor White
Write-Host "  2. Criar serviços para cada controller" -ForegroundColor White
Write-Host "  3. Adicionar validações e tratamento de erros" -ForegroundColor White
Write-Host ""
