# Script para validar que tudo está funcionando

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     ✅ VALIDANDO SISTEMA COMPLETO ✅                          ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$validationResults = @{}
$totalChecks = 0
$passedChecks = 0

function Validate-Service {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatus = 200
    )
    
    $script:totalChecks++
    Write-Host "  Verificando $Name..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "    ✓ $Name está funcionando" -ForegroundColor Green
            $script:validationResults[$Name] = "OK"
            $script:passedChecks++
            return $true
        } else {
            Write-Host "    ✗ $Name retornou status $($response.StatusCode)" -ForegroundColor Red
            $script:validationResults[$Name] = "FAIL"
            return $false
        }
    } catch {
        Write-Host "    ✗ $Name não está acessível: $($_.Exception.Message)" -ForegroundColor Red
        $script:validationResults[$Name] = "FAIL"
        return $false
    }
}

function Validate-File {
    param(
        [string]$Name,
        [string]$Path
    )
    
    $script:totalChecks++
    Write-Host "  Verificando $Name..." -ForegroundColor Yellow
    
    if (Test-Path $Path) {
        Write-Host "    ✓ $Name existe" -ForegroundColor Green
        $script:validationResults[$Name] = "OK"
        $script:passedChecks++
        return $true
    } else {
        Write-Host "    ✗ $Name não encontrado" -ForegroundColor Red
        $script:validationResults[$Name] = "FAIL"
        return $false
    }
}

# Validar serviços
Write-Host "`n[1/5] Validando Serviços Backend" -ForegroundColor Cyan
Validate-Service -Name "User BFF" -Url "http://localhost:8080/actuator/health"
Validate-Service -Name "Admin BFF" -Url "http://localhost:8083/actuator/health"
Validate-Service -Name "Merchant BFF" -Url "http://localhost:8084/actuator/health"
Validate-Service -Name "Core Service" -Url "http://localhost:8091/actuator/health"
Validate-Service -Name "Keycloak" -Url "http://localhost:8081/realms/benefits" -ExpectedStatus 200

# Validar arquivos críticos
Write-Host "`n[2/5] Validando Arquivos Críticos" -ForegroundColor Cyan
Validate-File -Name "Docker Compose" -Path (Join-Path $baseDir "infra/docker-compose.yml")
Validate-File -Name "Testes E2E" -Path (Join-Path $baseDir "tests/e2e/run-complete-e2e-tests.ps1")
Validate-File -Name "Documentação LGPD" -Path (Join-Path $baseDir "docs/compliance/lgpd.md")
Validate-File -Name "Documentação PCI" -Path (Join-Path $baseDir "docs/compliance/pci.md")

# Validar estrutura Angular
Write-Host "`n[3/5] Validando Apps Frontend" -ForegroundColor Cyan
Validate-File -Name "Angular Admin" -Path (Join-Path $baseDir "apps/admin_angular/src/main.ts")
Validate-File -Name "Angular Merchant Portal" -Path (Join-Path $baseDir "apps/merchant_portal_angular/src/main.ts")
Validate-File -Name "Flutter User App" -Path (Join-Path $baseDir "apps/user_app_flutter/lib/main.dart")
Validate-File -Name "Flutter Merchant POS" -Path (Join-Path $baseDir "apps/merchant_pos_flutter/lib/main.dart")

# Validar observabilidade
Write-Host "`n[4/5] Validando Observabilidade" -ForegroundColor Cyan
Validate-File -Name "Prometheus Config" -Path (Join-Path $baseDir "infra/prometheus/prometheus.yml")
Validate-File -Name "Observability Docs" -Path (Join-Path $baseDir "docs/ops/observability.md")

# Validar CI/CD
Write-Host "`n[5/5] Validando CI/CD" -ForegroundColor Cyan
Validate-File -Name "CI Pipeline" -Path (Join-Path $baseDir ".github/workflows/build.yml")
Validate-File -Name "CD Pipeline" -Path (Join-Path $baseDir ".github/workflows/cd.yml")

# Resumo
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    RESUMO DA VALIDAÇÃO                         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Total de verificações: $totalChecks" -ForegroundColor White
Write-Host "Passou: $passedChecks" -ForegroundColor Green
Write-Host "Falhou: $($totalChecks - $passedChecks)" -ForegroundColor $(if (($totalChecks - $passedChecks) -eq 0) { "Green" } else { "Red" })
Write-Host "Taxa de sucesso: $([math]::Round(($passedChecks / $totalChecks) * 100, 2))%" -ForegroundColor $(if (($totalChecks - $passedChecks) -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if (($totalChecks - $passedChecks) -eq 0) {
    Write-Host "✅ Sistema 100% validado e funcionando!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠ Algumas verificações falharam. Verifique os itens acima." -ForegroundColor Yellow
    exit 1
}
