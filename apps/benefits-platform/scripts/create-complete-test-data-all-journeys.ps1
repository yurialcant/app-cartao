# Script para criar massa de dados completa para TODAS as jornadas E2E

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:ScriptsPath = $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   📊 CRIANDO MASSA DE DADOS COMPLETA - TODAS AS JORNADAS 📊  ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Executar script SQL completo
$sqlScript = Join-Path $script:RootPath "scripts\seed-database-complete-all-journeys.sql"
if (Test-Path $sqlScript) {
    Write-Host "  → Executando script SQL completo..." -ForegroundColor Gray
    # Executar via psql ou docker exec
    docker exec -i benefits-postgres psql -U benefits -d benefits < $sqlScript
    Write-Host "  ✅ Massa de dados criada!" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Script SQL não encontrado, criando..." -ForegroundColor Yellow
    # Criar script SQL completo
    & "$script:ScriptsPath\generate-complete-test-data-sql.ps1"
}

Write-Host "`n✅ Massa de dados completa criada para todas as jornadas!" -ForegroundColor Green
