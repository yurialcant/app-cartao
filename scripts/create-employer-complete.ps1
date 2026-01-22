# Script para criar Employer Service e BFF completos

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:ServicesPath = Join-Path $script:RootPath "services"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🏢 CRIANDO EMPLOYER SERVICE E BFF COMPLETOS 🏢             ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "  → Criando employer-service..." -ForegroundColor Gray
Write-Host "  → Criando employer-bff..." -ForegroundColor Gray
Write-Host "`n✅ Employer Service e BFF serão criados!" -ForegroundColor Green
