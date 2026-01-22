# Script para iniciar Flutter App e Angular Admin em paralelo
Write-Host "`n=== 🚀 INICIANDO FLUTTER APP E ANGULAR ADMIN ===" -ForegroundColor Cyan
Write-Host ""

# Verificar serviços
Write-Host "[1/3] Verificando serviços backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ User BFF está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ User BFF não está rodando!" -ForegroundColor Red
    Write-Host "  Execute primeiro: .\scripts\run-everything-complete.ps1" -ForegroundColor Yellow
    exit 1
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Admin BFF está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Admin BFF não está rodando!" -ForegroundColor Red
    exit 1
}

# Iniciar Flutter App
Write-Host "`n[2/3] Iniciando Flutter App no Android..." -ForegroundColor Yellow
Write-Host "  Isso pode levar alguns minutos para compilar..." -ForegroundColor Gray
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\..\apps\user_app_flutter'; flutter run" -WindowStyle Normal
Write-Host "  ✓ Flutter App iniciando em nova janela" -ForegroundColor Green

# Preparar Angular Admin
Write-Host "`n[3/3] Preparando Angular Admin..." -ForegroundColor Yellow
$angularPath = "$PSScriptRoot\..\apps\admin_angular"

if (-not (Test-Path "$angularPath\angular.json")) {
    Write-Host "  Criando projeto Angular..." -ForegroundColor Gray
    Push-Location $angularPath
    ng new . --routing --style=css --skip-git --skip-install 2>&1 | Out-Null
    Pop-Location
    Write-Host "  ✓ Projeto Angular criado" -ForegroundColor Green
}

if (-not (Test-Path "$angularPath\node_modules")) {
    Write-Host "  Instalando dependências Angular..." -ForegroundColor Gray
    Push-Location $angularPath
    npm install 2>&1 | Out-Null
    Pop-Location
    Write-Host "  ✓ Dependências instaladas" -ForegroundColor Green
}

Write-Host "  Iniciando servidor Angular..." -ForegroundColor Gray
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$angularPath'; npm start" -WindowStyle Normal
Write-Host "  ✓ Angular Admin iniciando em nova janela" -ForegroundColor Green

# Resumo
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║        ✅ APPS INICIADOS EM JANELAS SEPARADAS! ✅            ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📱 FLUTTER APP (ANDROID):" -ForegroundColor Cyan
Write-Host "  • Janela PowerShell aberta com Flutter" -ForegroundColor White
Write-Host "  • Aguarde compilar e abrir no Android" -ForegroundColor White
Write-Host "  • Credenciais: user1 / Passw0rd!" -ForegroundColor White
Write-Host ""
Write-Host "🌐 ANGULAR ADMIN:" -ForegroundColor Cyan
Write-Host "  • URL: http://localhost:4200" -ForegroundColor White
Write-Host "  • Janela PowerShell aberta com Angular" -ForegroundColor White
Write-Host "  • Credenciais: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Yellow
Write-Host "  Flutter App: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  Angular Admin: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Yellow
Write-Host "  Angular Admin: http://localhost:4200" -ForegroundColor White
Write-Host "  Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  User BFF: http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "💡 Os apps estão rodando em janelas separadas." -ForegroundColor Gray
Write-Host "   Você pode fechar esta janela sem problemas." -ForegroundColor Gray
Write-Host ""
