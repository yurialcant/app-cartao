# Script para executar testes de carga com k6
param(
    [int]$Duration = 10,
    [int]$Users = 10,
    [switch]$Spike = $false,
    [string]$KeycloakUrl = "http://localhost:8081",
    [string]$BffUrl = "http://localhost:8080"
)

Write-Host "=== Teste de Carga com k6 ===" -ForegroundColor Cyan
Write-Host ""

# Verificar se k6 está instalado
Write-Host "[1/4] Verificando k6..." -ForegroundColor Yellow
try {
    $k6Version = k6 version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ k6 encontrado: $($k6Version | Select-Object -First 1)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ k6 não encontrado!" -ForegroundColor Red
        Write-Host "`n  Instale k6:" -ForegroundColor Yellow
        Write-Host "    Windows: choco install k6" -ForegroundColor Gray
        Write-Host "    Ou baixe: https://k6.io/docs/getting-started/installation/" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "  ✗ k6 não encontrado!" -ForegroundColor Red
    Write-Host "`n  Instale k6:" -ForegroundColor Yellow
    Write-Host "    Windows: choco install k6" -ForegroundColor Gray
    Write-Host "    Ou baixe: https://k6.io/docs/getting-started/installation/" -ForegroundColor Gray
    exit 1
}

# Verificar serviços
Write-Host "`n[2/4] Verificando serviços..." -ForegroundColor Yellow
try {
    $bffHealth = Invoke-WebRequest -Uri "$BffUrl/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($bffHealth.StatusCode -eq 200) {
        Write-Host "  ✓ User BFF está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ User BFF não está acessível em $BffUrl" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\start.ps1" -ForegroundColor Yellow
    exit 1
}

try {
    $keycloakHealth = Invoke-WebRequest -Uri "$KeycloakUrl/realms/benefits/.well-known/openid-configuration" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($keycloakHealth.StatusCode -eq 200) {
        Write-Host "  ✓ Keycloak está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Keycloak não está acessível em $KeycloakUrl" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\start.ps1" -ForegroundColor Yellow
    exit 1
}

# Preparar variáveis de ambiente
Write-Host "`n[3/4] Configurando teste..." -ForegroundColor Yellow
$env:KEYCLOAK_URL = $KeycloakUrl
$env:BFF_URL = $BffUrl
$env:USERNAME = "user1"
$env:PASSWORD = "Passw0rd!"

Write-Host "  Keycloak: $KeycloakUrl" -ForegroundColor Gray
Write-Host "  BFF: $BffUrl" -ForegroundColor Gray
Write-Host "  Usuário: user1" -ForegroundColor Gray

# Executar teste
Write-Host "`n[4/4] Executando teste de carga..." -ForegroundColor Yellow
Write-Host "  Duração: $Duration minutos" -ForegroundColor Gray
Write-Host "  Usuários: $Users" -ForegroundColor Gray
if ($Spike) {
    Write-Host "  Spike: Habilitado" -ForegroundColor Gray
}

$scriptPath = "infra/k6/load-test.js"
if (-not (Test-Path $scriptPath)) {
    Write-Host "  ✗ Script k6 não encontrado: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "`n  Executando: k6 run $scriptPath" -ForegroundColor Cyan
Write-Host "  (Isso pode levar alguns minutos...)`n" -ForegroundColor Gray

# Executar k6
Push-Location infra/k6
try {
    k6 run load-test.js
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Teste de carga concluído com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "`n⚠ Teste de carga concluído com avisos" -ForegroundColor Yellow
        Write-Host "  Verifique os resultados acima" -ForegroundColor Gray
    }
} catch {
    Write-Host "`n✗ Erro ao executar teste de carga: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host "`n=== Resumo ===" -ForegroundColor Cyan
Write-Host "Teste executado com:" -ForegroundColor Yellow
Write-Host "  - Seed: 1000 transações geradas" -ForegroundColor White
Write-Host "  - Carga: 70% wallet summary, 30% transactions" -ForegroundColor White
Write-Host "  - Thresholds: P95 < 500ms, erro < 1%" -ForegroundColor White
Write-Host "`nPara ver métricas detalhadas, execute:" -ForegroundColor Yellow
Write-Host "  k6 run infra/k6/load-test.js --out json=results.json" -ForegroundColor Gray
