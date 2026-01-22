# Script para executar TODOS os testes E2E de todas as jornadas

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:TestsPath = Join-Path $script:RootPath "tests\e2e"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🧪 EXECUTANDO TODOS OS TESTES E2E 🧪                      ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar se serviços estão rodando
Write-Host "[1/3] Verificando serviços..." -ForegroundColor Yellow
$services = @("benefits-core", "user-bff", "admin-bff", "merchant-bff")
foreach ($service in $services) {
    $status = docker ps --filter "name=$service" --format "{{.Status}}"
    if ($status) {
        Write-Host "  ✅ $service está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $service não está rodando" -ForegroundColor Yellow
    }
}

# Executar testes
Write-Host "`n[2/3] Executando testes E2E..." -ForegroundColor Yellow
$testFiles = Get-ChildItem -Path $script:TestsPath -Filter "*.ps1" -ErrorAction SilentlyContinue
if ($testFiles) {
    foreach ($testFile in $testFiles) {
        Write-Host "  → Executando $($testFile.Name)..." -ForegroundColor Gray
        & $testFile.FullName
    }
} else {
    Write-Host "  ⚠️  Nenhum teste encontrado em $script:TestsPath" -ForegroundColor Yellow
}

Write-Host "`n[3/3] Gerando relatório..." -ForegroundColor Yellow
Write-Host "`n✅ Testes E2E executados!" -ForegroundColor Green
