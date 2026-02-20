# Script para Implementar Plano Completo 360º - Sistema White-Label Multi-Tenant
# Este script implementa todas as fases do plano completo de forma sistemática

param(
    [switch]$SkipTests = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:ServicesPath = Join-Path $script:RootPath "services"
$script:AppsPath = Join-Path $script:RootPath "apps"
$script:InfraPath = Join-Path $script:RootPath "infra"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  IMPLEMENTAÇÃO PLANO COMPLETO 360º" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Fase 0: Correções Críticas Pré-requisito
Write-Host "`n[FASE 0] Correções Críticas..." -ForegroundColor Yellow

# 1. Adicionar todos os serviços especializados ao docker-compose.yml
Write-Host "  → Adicionando serviços especializados ao docker-compose.yml..." -ForegroundColor Gray
& "$PSScriptRoot\update-docker-compose-all-services.ps1"

# 2. Verificar e corrigir configurações
Write-Host "  → Verificando configurações..." -ForegroundColor Gray

# Fase 1: Infraestrutura Base
Write-Host "`n[FASE 1] Infraestrutura Base - Logging e Multi-Tenant..." -ForegroundColor Yellow

# 1.1 Logging Estruturado
Write-Host "  → Criando módulo common-logging..." -ForegroundColor Gray
& "$PSScriptRoot\create-common-logging-module.ps1"

# 1.2 Multi-Tenant
Write-Host "  → Criando tenant-service e common-tenant..." -ForegroundColor Gray
& "$PSScriptRoot\create-multitenant-infrastructure.ps1"

# 1.3 Employer Service
Write-Host "  → Criando employer-service..." -ForegroundColor Gray
& "$PSScriptRoot\create-employer-service.ps1"

# Fase 2: Employer Portal
Write-Host "`n[FASE 2] Employer Portal..." -ForegroundColor Yellow

# 2.1 Employer BFF
Write-Host "  → Criando employer-bff..." -ForegroundColor Gray
& "$PSScriptRoot\create-employer-bff.ps1"

# 2.2 Employer Portal Angular
Write-Host "  → Criando Employer Portal Angular..." -ForegroundColor Gray
& "$PSScriptRoot\create-employer-portal-angular.ps1"

# Fase 3: Completar Serviços Especializados
Write-Host "`n[FASE 3] Completar Serviços Especializados..." -ForegroundColor Yellow

# 3.1 Payments Orchestrator
Write-Host "  → Completando Payments Orchestrator..." -ForegroundColor Gray
& "$PSScriptRoot\complete-payments-orchestrator.ps1"

# 3.2 Acquirer Adapter
Write-Host "  → Completando Acquirer Adapter..." -ForegroundColor Gray
& "$PSScriptRoot\complete-acquirer-adapter.ps1"

# 3.3 Settlement e Reconciliação
Write-Host "  → Completando Settlement e Reconciliação..." -ForegroundColor Gray
& "$PSScriptRoot\complete-settlement-recon.ps1"

# 3.4 Disputes Service
Write-Host "  → Criando/completando Disputes Service..." -ForegroundColor Gray
& "$PSScriptRoot\create-complete-disputes-service.ps1"

# 3.5 Risk Service
Write-Host "  → Completando Risk/Fraud Service..." -ForegroundColor Gray
& "$PSScriptRoot\complete-risk-service.ps1"

# 3.6 Support Service
Write-Host "  → Completando Support Service..." -ForegroundColor Gray
& "$PSScriptRoot\complete-support-service.ps1"

# 3.7 Reporting Service
Write-Host "  → Criando Reporting Service..." -ForegroundColor Gray
& "$PSScriptRoot\create-reporting-service.ps1"

# Fase 4: Completar Fluxos E2E
Write-Host "`n[FASE 4] Completar Fluxos E2E..." -ForegroundColor Yellow

# 4.1 Beneficiário
Write-Host "  → Completando jornadas do Beneficiário..." -ForegroundColor Gray
& "$PSScriptRoot\complete-beneficiary-journeys.ps1"

# 4.2 Merchant
Write-Host "  → Completando jornadas do Merchant..." -ForegroundColor Gray
& "$PSScriptRoot\complete-merchant-journeys.ps1"

# 4.3 Employer
Write-Host "  → Completando jornadas do Employer..." -ForegroundColor Gray
& "$PSScriptRoot\complete-employer-journeys.ps1"

# 4.4 Admin
Write-Host "  → Completando jornadas do Admin..." -ForegroundColor Gray
& "$PSScriptRoot\complete-admin-journeys.ps1"

# Fase 5: White-Label e Branding
Write-Host "`n[FASE 5] White-Label e Branding..." -ForegroundColor Yellow
& "$PSScriptRoot\implement-white-label-branding.ps1"

# Fase 6: Integração Completa
Write-Host "`n[FASE 6] Integração Completa..." -ForegroundColor Yellow
& "$PSScriptRoot\complete-integration-all-systems.ps1"

# Fase 7: Observabilidade
Write-Host "`n[FASE 7] Observabilidade..." -ForegroundColor Yellow
& "$PSScriptRoot\complete-observability.ps1"

# Fase 8: Testes E2E
if (-not $SkipTests) {
    Write-Host "`n[FASE 8] Testes E2E..." -ForegroundColor Yellow
    & "$PSScriptRoot\create-complete-e2e-tests.ps1"
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  IMPLEMENTAÇÃO COMPLETA!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host "  1. Revisar mudanças" -ForegroundColor White
Write-Host "  2. Executar: docker-compose up -d --build" -ForegroundColor White
Write-Host "  3. Executar testes E2E" -ForegroundColor White
Write-Host ""
