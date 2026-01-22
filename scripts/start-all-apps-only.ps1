# Script para iniciar APENAS os apps (assumindo que serviços Docker já estão rodando)
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 INICIANDO APPS EM TERMINAIS SEPARADOS 🚀             ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$projectRoot = $PSScriptRoot | Split-Path -Parent

# Validar ambiente
Write-Host "[1/5] Validando ambiente..." -ForegroundColor Yellow
& "$PSScriptRoot\validate-and-install-all.ps1" 2>&1 | Out-Null
Write-Host ""

# Angular Admin
Write-Host "[2/5] Iniciando Angular Admin..." -ForegroundColor Yellow
$adminPath = "$projectRoot\apps\admin_angular"
if (Test-Path $adminPath) {
    $adminScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║     🚀 ANGULAR ADMIN - http://localhost:4200 🚀             ║' -ForegroundColor Green
Write-Host '║     Login: admin / admin123                                  ║' -ForegroundColor Green
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Green
Write-Host ''
cd '$adminPath'
npm start
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $adminScript -WindowStyle Normal
    Write-Host "  ✓ Angular Admin iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Angular Merchant Portal
Write-Host "`n[3/5] Iniciando Angular Merchant Portal..." -ForegroundColor Yellow
$merchantPortalPath = "$projectRoot\apps\merchant_portal_angular"
if (Test-Path $merchantPortalPath) {
    $merchantPortalScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║     🚀 MERCHANT PORTAL - http://localhost:4201 🚀           ║' -ForegroundColor Cyan
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host ''
cd '$merchantPortalPath'
npm start
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $merchantPortalScript -WindowStyle Normal
    Write-Host "  ✓ Merchant Portal iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Flutter User App
Write-Host "`n[4/5] Iniciando Flutter User App..." -ForegroundColor Yellow
$flutterUserPath = "$projectRoot\apps\user_app_flutter"
if (Test-Path $flutterUserPath) {
    $flutterUserScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Blue
Write-Host '║     🚀 FLUTTER USER APP 🚀                                  ║' -ForegroundColor Blue
Write-Host '║     Login: user1 / Passw0rd!                                ║' -ForegroundColor Blue
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Blue
Write-Host ''
cd '$flutterUserPath'
flutter run
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterUserScript -WindowStyle Normal
    Write-Host "  ✓ Flutter User App iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Flutter Merchant POS
Write-Host "`n[5/5] Iniciando Flutter Merchant POS..." -ForegroundColor Yellow
$flutterMerchantPath = "$projectRoot\apps\merchant_pos_flutter"
if (Test-Path $flutterMerchantPath) {
    $flutterMerchantScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Magenta
Write-Host '║     🚀 FLUTTER MERCHANT POS 🚀                              ║' -ForegroundColor Magenta
Write-Host '║     Login: merchant1 / Passw0rd!                            ║' -ForegroundColor Magenta
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Magenta
Write-Host ''
cd '$flutterMerchantPath'
flutter run
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterMerchantScript -WindowStyle Normal
    Write-Host "  ✓ Flutter Merchant POS iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ TODOS OS APPS INICIANDO! ✅                          ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 APPS:" -ForegroundColor Cyan
Write-Host "  • Angular Admin: http://localhost:4200" -ForegroundColor White
Write-Host "  • Angular Merchant Portal: http://localhost:4201" -ForegroundColor White
Write-Host "  • Flutter User App: (terminal separado)" -ForegroundColor White
Write-Host "  • Flutter Merchant POS: (terminal separado)" -ForegroundColor White
Write-Host ""
Write-Host "🎯 TODOS OS TERMINAIS ABERTOS! 🚀" -ForegroundColor Green
Write-Host ""
