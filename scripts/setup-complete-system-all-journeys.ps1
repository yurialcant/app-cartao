# Script Master: Setup Completo do Sistema - Todas as Jornadas E2E
# Este script configura TUDO: ambiente, serviços, testes, massa de dados, integração completa

param(
    [switch]$SkipBuild = $false,
    [switch]$SkipTests = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:ServicesPath = Join-Path $script:RootPath "services"
$script:AppsPath = Join-Path $script:RootPath "apps"
$script:InfraPath = Join-Path $script:RootPath "infra"
$script:ScriptsPath = $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🚀 SETUP COMPLETO - TODAS AS JORNADAS E2E 🚀              ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Fase 0: Verificar Pré-requisitos
Write-Host "`n[FASE 0] Verificando Pré-requisitos..." -ForegroundColor Yellow
& "$script:ScriptsPath\validate-and-install-all.ps1"

# Fase 1: Criar Módulos Comuns (Logging + Multi-Tenant)
Write-Host "`n[FASE 1] Criando Módulos Comuns..." -ForegroundColor Yellow
& "$script:ScriptsPath\create-common-modules.ps1"

# Fase 2: Criar Employer Service e BFF
Write-Host "`n[FASE 2] Criando Employer Service e BFF..." -ForegroundColor Yellow
& "$script:ScriptsPath\create-employer-complete.ps1"

# Fase 3: Completar Todos os Serviços Especializados
Write-Host "`n[FASE 3] Completando Serviços Especializados..." -ForegroundColor Yellow
& "$script:ScriptsPath\complete-all-specialized-services.ps1"

# Fase 4: Criar Massa de Dados Completa
Write-Host "`n[FASE 4] Criando Massa de Dados Completa..." -ForegroundColor Yellow
& "$script:ScriptsPath\create-complete-test-data-all-journeys.ps1"

# Fase 5: Configurar Docker Compose Completo
Write-Host "`n[FASE 5] Configurando Docker Compose..." -ForegroundColor Yellow
& "$script:ScriptsPath\setup-docker-compose-complete.ps1"

# Fase 6: Criar Testes E2E Completos
if (-not $SkipTests) {
    Write-Host "`n[FASE 6] Criando Testes E2E Completos..." -ForegroundColor Yellow
    & "$script:ScriptsPath\create-complete-e2e-tests-all-journeys.ps1"
}

# Fase 7: Build e Deploy Local
if (-not $SkipBuild) {
    Write-Host "`n[FASE 7] Build e Deploy Local..." -ForegroundColor Yellow
    & "$script:ScriptsPath\build-and-deploy-all-local.ps1"
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ SETUP COMPLETO FINALIZADO! ✅                          ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos Passos:" -ForegroundColor Cyan
Write-Host "  1. docker-compose up -d --build" -ForegroundColor White
Write-Host "  2. Aguardar todos os serviços iniciarem" -ForegroundColor White
Write-Host "  3. Executar: .\scripts\run-all-e2e-tests.ps1" -ForegroundColor White
Write-Host "  4. Acessar apps e testar manualmente" -ForegroundColor White
Write-Host ""
