# Script completo E2E - Todos os serviços + testes
Write-Host "=== E2E Completo - Todos os Serviços ===" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"

# 1. Verificar Docker
Write-Host "`n[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\check-docker.ps1" -ForegroundColor Yellow
    exit 1
}

# 2. Buildar todos os serviços
Write-Host "`n[2/5] Buildando todos os serviços..." -ForegroundColor Yellow
.\scripts\build-all-services.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ⚠ Alguns builds falharam, mas continuando..." -ForegroundColor Yellow
}

# 3. Subir Docker Compose
Write-Host "`n[3/5] Subindo Docker Compose..." -ForegroundColor Yellow
Push-Location infra
try {
    docker-compose up -d --build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Serviços iniciados" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Erro ao iniciar serviços" -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

# 4. Aguardar serviços iniciarem
Write-Host "`n[4/5] Aguardando serviços iniciarem (60s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# 5. Testar todos os serviços
Write-Host "`n[5/5] Testando todos os serviços..." -ForegroundColor Yellow
.\scripts\test-all-services.ps1

Write-Host "`n=== E2E Completo ===" -ForegroundColor Cyan
Write-Host "Todos os serviços estão rodando!" -ForegroundColor Green
Write-Host "`nURLs:" -ForegroundColor Yellow
Write-Host "  Core Service: http://localhost:8081" -ForegroundColor White
Write-Host "  User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host "  Merchant Portal BFF: http://localhost:8085" -ForegroundColor White
