# Script para build e deploy local de todos os serviços

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🐳 BUILD E DEPLOY LOCAL - TODOS OS SERVIÇOS 🐳            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "  → Parando containers existentes..." -ForegroundColor Gray
docker-compose -f "$script:RootPath\infra\docker-compose.yml" down

Write-Host "  → Build de todos os serviços..." -ForegroundColor Gray
docker-compose -f "$script:RootPath\infra\docker-compose.yml" build --no-cache

Write-Host "  → Iniciando todos os serviços..." -ForegroundColor Gray
docker-compose -f "$script:RootPath\infra\docker-compose.yml" up -d

Write-Host "`n✅ Build e deploy local concluído!" -ForegroundColor Green
Write-Host "  Aguarde alguns segundos para todos os serviços iniciarem..." -ForegroundColor Yellow
