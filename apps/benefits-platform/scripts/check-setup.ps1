# Script de Verificação do Ambiente
Write-Host "=== Verificando Ambiente Benefits ===" -ForegroundColor Cyan

# Verifica Docker
Write-Host "`n[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker não encontrado! Instale o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Verifica Docker Compose
Write-Host "`n[2/5] Verificando Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "✓ Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker Compose não encontrado!" -ForegroundColor Red
    exit 1
}

# Verifica portas
Write-Host "`n[3/5] Verificando portas..." -ForegroundColor Yellow
$ports = @(5432, 8080, 8081)
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "⚠ Porta $port está em uso" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Porta $port disponível" -ForegroundColor Green
    }
}

# Verifica estrutura de arquivos
Write-Host "`n[4/5] Verificando estrutura de arquivos..." -ForegroundColor Yellow
$requiredFiles = @(
    "infra/docker-compose.yml",
    "infra/keycloak/realm-benefits.json",
    "services/user-bff/pom.xml",
    "services/user-bff/Dockerfile",
    "apps/user_app_flutter/pubspec.yaml"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $file" -ForegroundColor Green
    } else {
        Write-Host "✗ $file não encontrado!" -ForegroundColor Red
    }
}

# Verifica containers
Write-Host "`n[5/5] Verificando containers..." -ForegroundColor Yellow
$containers = docker ps -a --filter "name=benefits" --format "{{.Names}}" 2>$null
if ($containers) {
    Write-Host "Containers encontrados:" -ForegroundColor Cyan
    $containers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
} else {
    Write-Host "Nenhum container benefits encontrado" -ForegroundColor Gray
}

Write-Host "`n=== Verificação Completa ===" -ForegroundColor Cyan
Write-Host "Para subir o sistema, execute:" -ForegroundColor Yellow
Write-Host "  cd infra" -ForegroundColor White
Write-Host "  docker-compose up -d" -ForegroundColor White

