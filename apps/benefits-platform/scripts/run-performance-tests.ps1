# Script para executar testes de performance

param(
    [Parameter(Mandatory=False)]
    [ValidateSet("load", "stress", "spike")]
    [string] = "load"
)

Write-Host "
╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     ⚡ EXECUTANDO TESTES DE PERFORMANCE ⚡                     ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

C:\Users\gesch\Documents\projeto-lucas = Split-Path -Parent $PSScriptRoot
C:\Users\gesch\Documents\projeto-lucas\infra\k6 = Join-Path $baseDir "infra/k6"

switch ($TestType) {
    "load" {
        Write-Host "Executando teste de carga..." -ForegroundColor Yellow
        k6 run (Join-Path $k6Dir "load-test-complete.js")
    }
    "stress" {
        Write-Host "Executando teste de stress..." -ForegroundColor Yellow
        k6 run (Join-Path $k6Dir "stress-test.js")
    }
    "spike" {
        Write-Host "Executando teste de spike..." -ForegroundColor Yellow
        k6 run (Join-Path $k6Dir "spike-test.js")
    }
}

Write-Host "
✅ Testes de performance concluídos!" -ForegroundColor Green
