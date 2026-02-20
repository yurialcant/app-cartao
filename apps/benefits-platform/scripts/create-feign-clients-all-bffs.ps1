# Script para criar Feign Clients em todos os BFFs para comunicação com serviços especializados

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔗 CRIANDO FEIGN CLIENTS NOS BFFs 🔗                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot

# Mapeamento de BFFs para serviços que precisam consumir
$bffServices = @{
    "user-bff" = @(
        @{Service="device-service"; Port=8098; Client="DeviceServiceClient"},
        @{Service="risk-service"; Port=8094; Client="RiskServiceClient"},
        @{Service="support-service"; Port=8095; Client="SupportServiceClient"},
        @{Service="notification-service"; Port=8100; Client="NotificationServiceClient"},
        @{Service="payments-orchestrator"; Port=8092; Client="PaymentServiceClient"},
        @{Service="privacy-service"; Port=8103; Client="PrivacyServiceClient"}
    )
    "admin-bff" = @(
        @{Service="kyc-service"; Port=8101; Client="KycServiceClient"},
        @{Service="kyb-service"; Port=8102; Client="KybServiceClient"},
        @{Service="settlement-service"; Port=8096; Client="SettlementServiceClient"},
        @{Service="recon-service"; Port=8097; Client="ReconciliationServiceClient"},
        @{Service="support-service"; Port=8095; Client="SupportServiceClient"},
        @{Service="risk-service"; Port=8094; Client="RiskServiceClient"},
        @{Service="audit-service"; Port=8099; Client="AuditServiceClient"}
    )
    "merchant-bff" = @(
        @{Service="payments-orchestrator"; Port=8092; Client="PaymentServiceClient"},
        @{Service="acquirer-adapter"; Port=8093; Client="AcquirerServiceClient"},
        @{Service="risk-service"; Port=8094; Client="RiskServiceClient"}
    )
}

function Create-FeignClient {
    param(
        [string]$BffDir,
        [string]$ServiceName,
        [int]$Port,
        [string]$ClientName
    )
    
    $clientDir = Join-Path $BffDir "src/main/java/com/benefits/$($BffDir.Split('\')[-1].Replace('-', ''))/client"
    
    if (-not (Test-Path $clientDir)) {
        New-Item -ItemType Directory -Path $clientDir -Force | Out-Null
    }
    
    $packageName = $BffDir.Split('\')[-1].Replace('-', '')
    $serviceUrl = "`${$ServiceName.Replace('-', '')}.service.url:http://$ServiceName`:$Port"
    
    $clientContent = @"
package com.benefits.$packageName.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "$ServiceName", url = "$serviceUrl")
public interface $ClientName {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}
"@
    
    $clientPath = Join-Path $clientDir "$ClientName.java"
    if (-not (Test-Path $clientPath)) {
        Set-Content -Path $clientPath -Value $clientContent -Encoding UTF8
        Write-Host "    ✓ $ClientName criado" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ $ClientName já existe" -ForegroundColor Yellow
    }
}

Write-Host "`nCriando Feign Clients..." -ForegroundColor Cyan

foreach ($bffName in $bffServices.Keys) {
    $bffDir = Join-Path $baseDir "services/$bffName"
    
    if (-not (Test-Path $bffDir)) {
        Write-Host "  ⚠ $bffName não encontrado" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "`n  Criando Feign Clients para $bffName..." -ForegroundColor Yellow
    
    foreach ($serviceConfig in $bffServices[$bffName]) {
        Create-FeignClient -BffDir $bffDir -ServiceName $serviceConfig.Service -Port $serviceConfig.Port -ClientName $serviceConfig.Client
    }
}

Write-Host "`n✅ Feign Clients criados com sucesso!" -ForegroundColor Green
Write-Host ""
