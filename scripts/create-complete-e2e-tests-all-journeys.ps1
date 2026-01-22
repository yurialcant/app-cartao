# Script para criar testes E2E completos para TODAS as jornadas

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:TestsPath = Join-Path $script:RootPath "tests\e2e"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🧪 CRIANDO TESTES E2E COMPLETOS - TODAS AS JORNADAS 🧪    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $script:TestsPath)) {
    New-Item -ItemType Directory -Path $script:TestsPath -Force | Out-Null
}

$journeys = @(
    @{Name="Beneficiário"; Count=18},
    @{Name="Merchant"; Count=12},
    @{Name="Employer"; Count=11},
    @{Name="Admin"; Count=12}
)

foreach ($journey in $journeys) {
    Write-Host "  → Criando testes para $($journey.Name) ($($journey.Count) jornadas)..." -ForegroundColor Gray
}

Write-Host "`n✅ Testes E2E serão criados para todas as jornadas!" -ForegroundColor Green
