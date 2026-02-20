# Script rápido para iniciar o sistema Benefits (assume que já está configurado)
Write-Host "=== Iniciando Sistema Benefits ===" -ForegroundColor Cyan

# Verifica se está no diretório correto
if (-not (Test-Path "infra/docker-compose.yml")) {
    Write-Host "✗ Execute este script da raiz do projeto!" -ForegroundColor Red
    Write-Host "  Ou execute primeiro: .\scripts\setup.ps1" -ForegroundColor Yellow
    exit 1
}

# Verifica se Docker está rodando
try {
    docker ps | Out-Null
} catch {
    Write-Host "✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "  Inicie o Docker Desktop e tente novamente" -ForegroundColor Yellow
    Write-Host "  Ou execute: .\scripts\setup.ps1" -ForegroundColor Yellow
    exit 1
}

# Verifica se containers já estão rodando
$running = docker ps --filter "name=benefits" --format "{{.Names}}" 2>$null
if ($running) {
    Write-Host "✓ Containers já estão rodando:" -ForegroundColor Green
    $running | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    Write-Host "`nPara reiniciar, execute: docker-compose -f infra/docker-compose.yml restart" -ForegroundColor Yellow
    exit 0
}

# Sobe os serviços
Write-Host "`nSubindo serviços..." -ForegroundColor Yellow
cd infra
docker-compose up -d

Write-Host "`n=== Aguardando serviços iniciarem ===" -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Verifica status
Write-Host "`nStatus dos containers:" -ForegroundColor Yellow
docker-compose ps

Write-Host "`n=== Verificando saúde dos serviços ===" -ForegroundColor Cyan

# PostgreSQL
Write-Host "`nPostgreSQL..." -ForegroundColor Yellow
$pgHealth = docker-compose exec -T postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PostgreSQL está rodando" -ForegroundColor Green
} else {
    Write-Host "✗ PostgreSQL não está respondendo" -ForegroundColor Red
}

# Keycloak
Write-Host "`nKeycloak..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health/ready" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Keycloak está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Keycloak ainda está iniciando (pode levar até 60s)" -ForegroundColor Yellow
}

# User BFF
Write-Host "`nUser BFF..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ User BFF está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ User BFF ainda está iniciando (pode levar até 40s)" -ForegroundColor Yellow
}

Write-Host "`n=== URLs dos Serviços ===" -ForegroundColor Cyan
Write-Host "PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "Keycloak Admin: http://localhost:8081/admin" -ForegroundColor White
Write-Host "User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "User BFF Health: http://localhost:8080/actuator/health" -ForegroundColor White

Write-Host "`n=== Para ver logs ===" -ForegroundColor Cyan
Write-Host "docker-compose -f infra/docker-compose.yml logs -f [servico]" -ForegroundColor White
Write-Host "Exemplo: docker-compose -f infra/docker-compose.yml logs -f user-bff" -ForegroundColor Gray

cd ..

