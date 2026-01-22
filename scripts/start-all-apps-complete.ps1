# Script para iniciar TODOS os apps e abrir no navegador
# PRIMEIRO VALIDA E INSTALA TUDO, DEPOIS INICIA OS APPS

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 INICIANDO TODOS OS APPS 🚀                           ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Validar ambiente ANTES de iniciar
Write-Host "[0/5] Validando ambiente local..." -ForegroundColor Yellow
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$scriptPath\validate-and-install-all.ps1"
Write-Host ""

# 1. Angular Admin
Write-Host "[1/4] Iniciando Angular Admin..." -ForegroundColor Yellow
$adminPath = "apps\admin_angular"
if (Test-Path $adminPath) {
    # Verificar se node_modules existe
    if (-not (Test-Path "$adminPath\node_modules")) {
        Write-Host "  → Instalando dependências primeiro..." -ForegroundColor Cyan
        Push-Location $adminPath
        npm install
        Pop-Location
    }
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\$adminPath'; Write-Host '🚀 Angular Admin iniciando...' -ForegroundColor Green; Write-Host 'Acesse: http://localhost:4200' -ForegroundColor Cyan; Write-Host 'Login: admin / admin123' -ForegroundColor Yellow; npm start" -WindowStyle Normal
    Start-Sleep -Seconds 3
    Write-Host "  ✓ Angular Admin iniciando em nova janela" -ForegroundColor Green
    Start-Job -ScriptBlock { Start-Sleep -Seconds 35; Start-Process "http://localhost:4200" } | Out-Null
} else {
    Write-Host "  ✗ Diretório não encontrado: $adminPath" -ForegroundColor Red
}

# 2. Angular Merchant Portal
Write-Host "`n[2/4] Iniciando Angular Merchant Portal..." -ForegroundColor Yellow
$merchantPortalPath = "apps\merchant_portal_angular"
if (Test-Path $merchantPortalPath) {
    # Verificar se node_modules existe
    if (-not (Test-Path "$merchantPortalPath\node_modules")) {
        Write-Host "  → Instalando dependências primeiro..." -ForegroundColor Cyan
        Push-Location $merchantPortalPath
        npm install
        Pop-Location
    }
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\$merchantPortalPath'; Write-Host '🚀 Merchant Portal iniciando...' -ForegroundColor Green; Write-Host 'Acesse: http://localhost:4201' -ForegroundColor Cyan; npm start" -WindowStyle Normal
    Start-Sleep -Seconds 3
    Write-Host "  ✓ Merchant Portal iniciando" -ForegroundColor Green
    Start-Job -ScriptBlock { Start-Sleep -Seconds 40; Start-Process "http://localhost:4201" } | Out-Null
} else {
    Write-Host "  ⚠ Merchant Portal não configurado ainda" -ForegroundColor Yellow
}

# 3. Flutter User App
Write-Host "`n[3/4] Preparando Flutter User App..." -ForegroundColor Yellow
$flutterUserPath = "apps\user_app_flutter"
if (Test-Path $flutterUserPath) {
    # Verificar se pubspec.lock existe (dependências instaladas)
    if (-not (Test-Path "$flutterUserPath\pubspec.lock")) {
        Write-Host "  → Instalando dependências primeiro..." -ForegroundColor Cyan
        Push-Location $flutterUserPath
        flutter pub get
        Pop-Location
    }
    
    Write-Host "  ✓ Flutter User App pronto" -ForegroundColor Green
    Write-Host "  → Execute: cd apps/user_app_flutter && flutter run" -ForegroundColor Gray
} else {
    Write-Host "  ✗ Diretório não encontrado: $flutterUserPath" -ForegroundColor Red
}

# 4. Flutter Merchant POS
Write-Host "`n[4/4] Preparando Flutter Merchant POS..." -ForegroundColor Yellow
$flutterMerchantPath = "apps\merchant_pos_flutter"
if (Test-Path $flutterMerchantPath) {
    # Verificar se pubspec.lock existe (dependências instaladas)
    if (-not (Test-Path "$flutterMerchantPath\pubspec.lock")) {
        Write-Host "  → Instalando dependências primeiro..." -ForegroundColor Cyan
        Push-Location $flutterMerchantPath
        flutter pub get
        Pop-Location
    }
    
    Write-Host "  ✓ Flutter Merchant POS pronto" -ForegroundColor Green
    Write-Host "  → Execute: cd apps/merchant_pos_flutter && flutter run" -ForegroundColor Gray
} else {
    Write-Host "  ✗ Diretório não encontrado: $flutterMerchantPath" -ForegroundColor Red
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ TODOS OS APPS INICIANDO! ✅                          ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 APPS:" -ForegroundColor Cyan
Write-Host "  • Angular Admin: http://localhost:4200 (abrindo em 35s)" -ForegroundColor White
Write-Host "  • Angular Merchant Portal: http://localhost:4201 (abrindo em 40s)" -ForegroundColor White
Write-Host "  • Flutter User App: Execute 'cd apps/user_app_flutter && flutter run'" -ForegroundColor Yellow
Write-Host "  • Flutter Merchant POS: Execute 'cd apps/merchant_pos_flutter && flutter run'" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "  • User: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  • Admin: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "📝 TESTE O FLUXO:" -ForegroundColor Yellow
Write-Host "  1. Admin Angular → Criar topup para user1" -ForegroundColor White
Write-Host "  2. User App Flutter → Ver saldo atualizado" -ForegroundColor White
Write-Host "  3. User App Flutter → Fazer pagamento" -ForegroundColor White
Write-Host "  4. Admin Angular → Ver nova transação" -ForegroundColor White
Write-Host ""
Write-Host "🎯 TUDO PRONTO! 🚀" -ForegroundColor Green
Write-Host ""
