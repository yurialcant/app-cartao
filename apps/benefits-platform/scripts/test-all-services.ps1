# Script para testar todos os serviços
Write-Host "=== Testando Todos os Serviços ===" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$allPassed = $true

function Test-Service {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$Port
    )
    
    Write-Host "`n[TEST] $ServiceName (porta $Port)..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $ServiceName está respondendo" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ $ServiceName retornou status $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ✗ $ServiceName não está respondendo: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Verificar containers
Write-Host "`n[1/6] Verificando containers..." -ForegroundColor Yellow
$containers = @(
    "benefits-postgres",
    "benefits-keycloak",
    "benefits-core",
    "benefits-user-bff",
    "benefits-admin-bff",
    "benefits-merchant-bff",
    "benefits-merchant-portal-bff"
)

foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}" 2>$null
    if ($status) {
        Write-Host "  ✓ $container está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container não está rodando" -ForegroundColor Red
        $allPassed = $false
    }
}

# Testar serviços
Write-Host "`n[2/6] Testando Core Service..." -ForegroundColor Yellow
if (-not (Test-Service "Core Service" "http://localhost:8081/actuator/health" 8081)) {
    $allPassed = $false
}

Write-Host "`n[3/6] Testando User BFF..." -ForegroundColor Yellow
if (-not (Test-Service "User BFF" "http://localhost:8080/actuator/health" 8080)) {
    $allPassed = $false
}

Write-Host "`n[4/6] Testando Admin BFF..." -ForegroundColor Yellow
if (-not (Test-Service "Admin BFF" "http://localhost:8083/actuator/health" 8083)) {
    $allPassed = $false
}

Write-Host "`n[5/6] Testando Merchant BFF..." -ForegroundColor Yellow
if (-not (Test-Service "Merchant BFF" "http://localhost:8084/actuator/health" 8084)) {
    $allPassed = $false
}

Write-Host "`n[6/6] Testando Merchant Portal BFF..." -ForegroundColor Yellow
if (-not (Test-Service "Merchant Portal BFF" "http://localhost:8085/actuator/health" 8085)) {
    $allPassed = $false
}

# Resumo
Write-Host "`n=== Resumo ===" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ Todos os serviços estão funcionando!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Alguns serviços falharam" -ForegroundColor Red
    Write-Host "`nVerifique os logs:" -ForegroundColor Yellow
    Write-Host "  docker-compose -f infra/docker-compose.yml logs" -ForegroundColor Gray
    exit 1
}
