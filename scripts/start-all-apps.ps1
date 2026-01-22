# Script para iniciar todos os apps em paralelo: Flutter Android + Angular Admin
Write-Host "`n=== 🚀 INICIANDO TODOS OS APPS EM PARALELO ===" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Verificar se serviços estão rodando
Write-Host "[1/4] Verificando serviços backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ User BFF está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ User BFF não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\run-everything-complete.ps1" -ForegroundColor Yellow
    exit 1
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  ✓ Admin BFF está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Admin BFF não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\run-everything-complete.ps1" -ForegroundColor Yellow
    exit 1
}

# Verificar Flutter
Write-Host "`n[2/4] Verificando Flutter..." -ForegroundColor Yellow
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ Flutter encontrado" -ForegroundColor Green
    $devices = flutter devices 2>&1 | Select-String "android"
    if ($devices) {
        Write-Host "  ✓ Dispositivo Android encontrado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Nenhum dispositivo Android encontrado" -ForegroundColor Yellow
        Write-Host "  Você pode usar um emulador Android" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✗ Flutter não encontrado!" -ForegroundColor Red
    exit 1
}

# Verificar Node.js e Angular CLI
Write-Host "`n[3/4] Verificando Node.js e Angular..." -ForegroundColor Yellow
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ Node.js encontrado" -ForegroundColor Green
    if (Get-Command ng -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ Angular CLI encontrado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Angular CLI não encontrado - será instalado" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ Node.js não encontrado!" -ForegroundColor Red
    exit 1
}

# Iniciar Flutter App em background
Write-Host "`n[4/4] Iniciando apps..." -ForegroundColor Yellow
Write-Host "`n📱 Iniciando Flutter App (Android)..." -ForegroundColor Cyan
$flutterJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    cd apps/user_app_flutter
    flutter run
}

Write-Host "  ✓ Flutter App iniciando em background (Job ID: $($flutterJob.Id))" -ForegroundColor Green

# Aguardar um pouco antes de iniciar Angular
Start-Sleep -Seconds 5

# Iniciar Angular Admin
Write-Host "`n🌐 Iniciando Angular Admin..." -ForegroundColor Cyan
Push-Location apps/admin_angular

if (-not (Test-Path "node_modules")) {
    Write-Host "  Instalando dependências..." -ForegroundColor Yellow
    npm install
}

if (-not (Test-Path "node_modules/@angular/cli")) {
    Write-Host "  Instalando Angular CLI localmente..." -ForegroundColor Yellow
    npm install -g @angular/cli
}

Write-Host "  Iniciando servidor Angular na porta 4200..." -ForegroundColor Yellow
$angularJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    cd apps/admin_angular
    ng serve --port 4200 --open
}

Pop-Location

Write-Host "  ✓ Angular Admin iniciando em background (Job ID: $($angularJob.Id))" -ForegroundColor Green

# Aguardar apps iniciarem
Write-Host "`n⏳ Aguardando apps iniciarem (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Resumo
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║           ✅ APPS INICIADOS EM PARALELO! ✅                 ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Flutter App (Android):" -ForegroundColor Cyan
Write-Host "  • Rodando em background (Job ID: $($flutterJob.Id))" -ForegroundColor White
Write-Host "  • Credenciais: user1 / Passw0rd!" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Angular Admin:" -ForegroundColor Cyan
Write-Host "  • URL: http://localhost:4200" -ForegroundColor White
Write-Host "  • Credenciais: admin / admin123" -ForegroundColor White
Write-Host "  • Rodando em background (Job ID: $($angularJob.Id))" -ForegroundColor White
Write-Host ""
Write-Host "📋 Para ver logs:" -ForegroundColor Yellow
Write-Host "  Receive-Job -Id $($flutterJob.Id) -Keep" -ForegroundColor Gray
Write-Host "  Receive-Job -Id $($angularJob.Id) -Keep" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 Para parar:" -ForegroundColor Yellow
Write-Host "  Stop-Job -Id $($flutterJob.Id), $($angularJob.Id)" -ForegroundColor Gray
Write-Host "  Remove-Job -Id $($flutterJob.Id), $($angularJob.Id)" -ForegroundColor Gray
Write-Host ""
