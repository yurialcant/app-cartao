# Script para iniciar APENAS os serviços Docker (sem apps)
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🐳 INICIANDO SERVIÇOS DOCKER 🐳                         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$projectRoot = $PSScriptRoot | Split-Path -Parent

# Verificar Docker
Write-Host "[1/4] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando. Iniciando..." -ForegroundColor Red
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
    Write-Host "  → Aguardando Docker iniciar (30 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
}

# Subir serviços
Write-Host "`n[2/4] Subindo serviços Docker..." -ForegroundColor Yellow
Push-Location "$projectRoot\infra"
try {
    docker-compose up -d --build
    Write-Host "  ✓ Serviços Docker iniciados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erro ao iniciar serviços Docker" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Aguardar serviços iniciarem
Write-Host "`n[3/4] Aguardando serviços iniciarem (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Criar tabelas e dados
Write-Host "`n[4/4] Criando tabelas e dados..." -ForegroundColor Yellow
if (Test-Path "$projectRoot\infra\sql\create-all-tables.sql") {
    Get-Content "$projectRoot\infra\sql\create-all-tables.sql" | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Tabelas criadas" -ForegroundColor Green
}

if (Test-Path "$projectRoot\scripts\create-shared-data-all-apps.ps1") {
    & "$projectRoot\scripts\create-shared-data-all-apps.ps1" 2>&1 | Out-Null
    Write-Host "  ✓ Dados compartilhados criados" -ForegroundColor Green
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ SERVIÇOS DOCKER INICIADOS! ✅                        ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 SERVIÇOS RODANDO:" -ForegroundColor Cyan
Write-Host "  • PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "  • Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  • Core Service: http://localhost:8091" -ForegroundColor White
Write-Host "  • User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  • Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  • Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Para iniciar os apps, execute:" -ForegroundColor Yellow
Write-Host "   .\scripts\start-all-apps-complete.ps1" -ForegroundColor Gray
Write-Host ""
