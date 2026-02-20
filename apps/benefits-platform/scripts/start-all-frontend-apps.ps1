# Script para iniciar todos os apps frontend

$ErrorActionPreference = "Continue"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🚀 INICIANDO APPS FRONTEND 🚀                              ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar se Node.js está instalado
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js não encontrado. Instale Node.js primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se Flutter está instalado
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  Flutter não encontrado. Apps Flutter não serão iniciados." -ForegroundColor Yellow
    $skipFlutter = $true
} else {
    $skipFlutter = $false
}

# ============================================
# APPS ANGULAR
# ============================================

Write-Host "📋 Iniciando Apps Angular..." -ForegroundColor Yellow

# Admin Angular
$adminPath = Join-Path $script:RootPath "apps\admin_angular"
if (Test-Path $adminPath) {
    Push-Location $adminPath
    
    if (-not (Test-Path "node_modules")) {
        Write-Host "  📦 Instalando dependências do Admin Angular..." -ForegroundColor Gray
        npm install --silent 2>&1 | Out-Null
    }
    
    Write-Host "  🚀 Iniciando Admin Angular (porta 4200)..." -ForegroundColor Gray
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$adminPath'; npm start" -WindowStyle Minimized
    Write-Host "  ✅ Admin Angular iniciado → http://localhost:4200" -ForegroundColor Green
    
    Pop-Location
} else {
    Write-Host "  ⚠️  Admin Angular não encontrado em: $adminPath" -ForegroundColor Yellow
}

# Merchant Portal Angular
$merchantPortalPath = Join-Path $script:RootPath "apps\merchant_portal_angular"
if (Test-Path $merchantPortalPath) {
    Push-Location $merchantPortalPath
    
    if (-not (Test-Path "node_modules")) {
        Write-Host "  📦 Instalando dependências do Merchant Portal..." -ForegroundColor Gray
        npm install --silent 2>&1 | Out-Null
    }
    
    Write-Host "  🚀 Iniciando Merchant Portal (porta 4201)..." -ForegroundColor Gray
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$merchantPortalPath'; npm start" -WindowStyle Minimized
    Write-Host "  ✅ Merchant Portal iniciado → http://localhost:4201" -ForegroundColor Green
    
    Pop-Location
} else {
    Write-Host "  ⚠️  Merchant Portal não encontrado em: $merchantPortalPath" -ForegroundColor Yellow
}

# ============================================
# APPS FLUTTER
# ============================================

if (-not $skipFlutter) {
    Write-Host "`n📋 Iniciando Apps Flutter..." -ForegroundColor Yellow
    
    # User App Flutter
    $userAppPath = Join-Path $script:RootPath "apps\user_app_flutter"
    if (Test-Path $userAppPath) {
        Push-Location $userAppPath
        
        Write-Host "  📦 Obtendo dependências do User App..." -ForegroundColor Gray
        flutter pub get 2>&1 | Out-Null
        
        Write-Host "  🚀 Iniciando User App Flutter..." -ForegroundColor Gray
        Write-Host "     (Aguardando dispositivo/emulador Android...)" -ForegroundColor Gray
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$userAppPath'; flutter run" -WindowStyle Minimized
        Write-Host "  ✅ User App iniciado (aguardando dispositivo)" -ForegroundColor Green
        
        Pop-Location
    } else {
        Write-Host "  ⚠️  User App não encontrado em: $userAppPath" -ForegroundColor Yellow
    }
    
    # Merchant POS Flutter
    $merchantPosPath = Join-Path $script:RootPath "apps\merchant_pos_flutter"
    if (Test-Path $merchantPosPath) {
        Push-Location $merchantPosPath
        
        Write-Host "  📦 Obtendo dependências do Merchant POS..." -ForegroundColor Gray
        flutter pub get 2>&1 | Out-Null
        
        Write-Host "  🚀 Iniciando Merchant POS Flutter..." -ForegroundColor Gray
        Write-Host "     (Aguardando dispositivo/emulador Android...)" -ForegroundColor Gray
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$merchantPosPath'; flutter run" -WindowStyle Minimized
        Write-Host "  ✅ Merchant POS iniciado (aguardando dispositivo)" -ForegroundColor Green
        
        Pop-Location
    } else {
        Write-Host "  ⚠️  Merchant POS não encontrado em: $merchantPosPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n⚠️  Apps Flutter não iniciados (Flutter não encontrado)" -ForegroundColor Yellow
}

# ============================================
# RESUMO
# ============================================

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ APPS FRONTEND INICIADOS! ✅                             ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 APPS DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  🌐 Admin Angular: http://localhost:4200" -ForegroundColor White
Write-Host "     Credenciais: admin / admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "  🌐 Merchant Portal: http://localhost:4201" -ForegroundColor White
Write-Host "     Credenciais: merchant1 / Passw0rd!" -ForegroundColor Gray
Write-Host ""

if (-not $skipFlutter) {
    Write-Host "  📱 User App Flutter: Aguardando dispositivo Android" -ForegroundColor White
    Write-Host "     Credenciais: user1 / Passw0rd!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  📱 Merchant POS Flutter: Aguardando dispositivo Android" -ForegroundColor White
    Write-Host "     Credenciais: merchant1 / Passw0rd!" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "🔍 VERIFICAR STATUS:" -ForegroundColor Cyan
Write-Host "  - Apps Angular: Verifique as janelas PowerShell abertas" -ForegroundColor Gray
Write-Host "  - Apps Flutter: Verifique se há dispositivo/emulador conectado" -ForegroundColor Gray
Write-Host "  - Backend: docker-compose -f infra\docker-compose.yml ps" -ForegroundColor Gray
Write-Host ""

Write-Host "🧪 TESTAR INTEGRAÇÃO E2E:" -ForegroundColor Cyan
Write-Host "  1. Login no Admin Angular → Criar topup" -ForegroundColor Gray
Write-Host "  2. Login no User App → Ver saldo atualizado" -ForegroundColor Gray
Write-Host "  3. Fazer pagamento no User App → Ver transação no Admin" -ForegroundColor Gray
Write-Host ""
