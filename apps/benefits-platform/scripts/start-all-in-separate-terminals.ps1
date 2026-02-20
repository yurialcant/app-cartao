# Script Master para iniciar TUDO em terminais separados
# Valida ambiente, inicia serviços Docker e abre cada app em seu próprio terminal

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 INICIANDO TUDO EM TERMINAIS SEPARADOS 🚀             ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$projectRoot = $PSScriptRoot | Split-Path -Parent

# ============================================================================
# 1. VALIDAR E INSTALAR AMBIENTE
# ============================================================================
Write-Host "[1/6] Validando e instalando ambiente..." -ForegroundColor Yellow
& "$PSScriptRoot\validate-and-install-all.ps1"
Write-Host ""

# ============================================================================
# 2. VERIFICAR E INICIAR DOCKER
# ============================================================================
Write-Host "[2/6] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando. Iniciando..." -ForegroundColor Red
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
    Write-Host "  → Aguardando Docker iniciar (30 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
}

# ============================================================================
# 3. SUBIR SERVIÇOS DOCKER
# ============================================================================
Write-Host "`n[3/6] Subindo serviços Docker..." -ForegroundColor Yellow
Push-Location "$projectRoot\infra"
try {
    docker-compose up -d --build 2>&1 | Out-Null
    Write-Host "  ✓ Serviços Docker iniciados" -ForegroundColor Green
    Write-Host "  → Aguardando serviços iniciarem (30 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
} catch {
    Write-Host "  ⚠ Erro ao iniciar serviços Docker" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# ============================================================================
# 4. CRIAR TABELAS E DADOS
# ============================================================================
Write-Host "`n[4/6] Criando tabelas e dados..." -ForegroundColor Yellow
if (Test-Path "$projectRoot\infra\sql\create-all-tables.sql") {
    Get-Content "$projectRoot\infra\sql\create-all-tables.sql" | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Tabelas criadas" -ForegroundColor Green
}

# Criar seed completo prévio
if (Test-Path "$projectRoot\scripts\seed-complete-previous.ps1") {
    & "$projectRoot\scripts\seed-complete-previous.ps1" 2>&1 | Out-Null
    Write-Host "  ✓ Seed completo criado" -ForegroundColor Green
} elseif (Test-Path "$projectRoot\scripts\create-shared-data-all-apps.ps1") {
    & "$projectRoot\scripts\create-shared-data-all-apps.ps1" 2>&1 | Out-Null
    Write-Host "  ✓ Dados compartilhados criados" -ForegroundColor Green
}

# ============================================================================
# 5. ABRIR TERMINAL PARA ANGULAR ADMIN
# ============================================================================
Write-Host "`n[5/6] Iniciando Angular Admin em terminal separado..." -ForegroundColor Yellow
$adminPath = "$projectRoot\apps\admin_angular"
if (Test-Path $adminPath) {
    $adminScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║                                                              ║' -ForegroundColor Green
Write-Host '║     🚀 ANGULAR ADMIN - http://localhost:4200 🚀             ║' -ForegroundColor Green
Write-Host '║                                                              ║' -ForegroundColor Green
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Green
Write-Host ''
Write-Host 'Login: admin / admin123' -ForegroundColor Yellow
Write-Host ''
cd '$adminPath'
npm start
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $adminScript -WindowStyle Normal
    Write-Host "  ✓ Angular Admin iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "  ✗ Diretório não encontrado: $adminPath" -ForegroundColor Red
}

# ============================================================================
# 6. ABRIR TERMINAL PARA ANGULAR MERCHANT PORTAL
# ============================================================================
Write-Host "`n[6/6] Iniciando Angular Merchant Portal em terminal separado..." -ForegroundColor Yellow
$merchantPortalPath = "$projectRoot\apps\merchant_portal_angular"
if (Test-Path $merchantPortalPath) {
    $merchantPortalScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║                                                              ║' -ForegroundColor Cyan
Write-Host '║     🚀 MERCHANT PORTAL - http://localhost:4201 🚀           ║' -ForegroundColor Cyan
Write-Host '║                                                              ║' -ForegroundColor Cyan
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host ''
cd '$merchantPortalPath'
npm start
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $merchantPortalScript -WindowStyle Normal
    Write-Host "  ✓ Merchant Portal iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "  ⚠ Merchant Portal não configurado ainda" -ForegroundColor Yellow
}

# ============================================================================
# 7. ABRIR TERMINAL PARA FLUTTER USER APP
# ============================================================================
Write-Host "`n[7/6] Preparando Flutter User App..." -ForegroundColor Yellow
$flutterUserPath = "$projectRoot\apps\user_app_flutter"
if (Test-Path $flutterUserPath) {
    $flutterUserScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Blue
Write-Host '║                                                              ║' -ForegroundColor Blue
Write-Host '║     🚀 FLUTTER USER APP 🚀                                  ║' -ForegroundColor Blue
Write-Host '║                                                              ║' -ForegroundColor Blue
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Blue
Write-Host ''
Write-Host 'Login: user1 / Passw0rd!' -ForegroundColor Yellow
Write-Host ''
cd '$flutterUserPath'
flutter run
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterUserScript -WindowStyle Normal
    Write-Host "  ✓ Flutter User App iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "  ✗ Diretório não encontrado: $flutterUserPath" -ForegroundColor Red
}

# ============================================================================
# 8. ABRIR TERMINAL PARA FLUTTER MERCHANT POS
# ============================================================================
Write-Host "`n[8/6] Preparando Flutter Merchant POS..." -ForegroundColor Yellow
$flutterMerchantPath = "$projectRoot\apps\merchant_pos_flutter"
if (Test-Path $flutterMerchantPath) {
    $flutterMerchantScript = @"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Magenta
Write-Host '║                                                              ║' -ForegroundColor Magenta
Write-Host '║     🚀 FLUTTER MERCHANT POS 🚀                              ║' -ForegroundColor Magenta
Write-Host '║                                                              ║' -ForegroundColor Magenta
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Magenta
Write-Host ''
Write-Host 'Login: merchant1 / Passw0rd!' -ForegroundColor Yellow
Write-Host ''
cd '$flutterMerchantPath'
flutter run
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterMerchantScript -WindowStyle Normal
    Write-Host "  ✓ Flutter Merchant POS iniciando em nova janela" -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "  ✗ Diretório não encontrado: $flutterMerchantPath" -ForegroundColor Red
}

# ============================================================================
# RESUMO FINAL
# ============================================================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ TUDO INICIANDO EM TERMINAIS SEPARADOS! ✅             ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 APPS INICIANDO:" -ForegroundColor Cyan
Write-Host "  • Angular Admin: http://localhost:4200 (terminal separado)" -ForegroundColor White
Write-Host "  • Angular Merchant Portal: http://localhost:4201 (terminal separado)" -ForegroundColor White
Write-Host "  • Flutter User App: (terminal separado)" -ForegroundColor White
Write-Host "  • Flutter Merchant POS: (terminal separado)" -ForegroundColor White
Write-Host ""
Write-Host "🔧 SERVIÇOS DOCKER:" -ForegroundColor Cyan
Write-Host "  • PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "  • Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  • Core Service: http://localhost:8091" -ForegroundColor White
Write-Host "  • User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  • Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  • Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host ""
Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "  • User: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  • Admin: admin / admin123" -ForegroundColor White
Write-Host "  • Merchant: merchant1 / Passw0rd!" -ForegroundColor White
Write-Host ""
Write-Host "📝 TESTE O FLUXO COMPLETO:" -ForegroundColor Yellow
Write-Host "  1. Admin Angular → Criar topup para user1" -ForegroundColor White
Write-Host "  2. User App Flutter → Ver saldo atualizado" -ForegroundColor White
Write-Host "  3. User App Flutter → Fazer pagamento" -ForegroundColor White
Write-Host "  4. Admin Angular → Ver nova transação" -ForegroundColor White
Write-Host ""
Write-Host "🎯 TODOS OS TERMINAIS ABERTOS! 🚀" -ForegroundColor Green
Write-Host ""
