# Script completo para testar o fluxo E2E com logs
Write-Host "=== Teste Completo do Fluxo E2E ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar serviços
Write-Host "[1/5] Verificando serviços..." -ForegroundColor Yellow
$services = @("benefits-postgres", "benefits-keycloak", "benefits-user-bff")
$allRunning = $true

foreach ($service in $services) {
    $container = docker ps --filter "name=$service" --format "{{.Names}}" 2>$null
    if ($container -eq $service) {
        Write-Host "  ✓ $service está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $service não está rodando" -ForegroundColor Red
        $allRunning = $false
    }
}

if (-not $allRunning) {
    Write-Host "`n⚠ Alguns serviços não estão rodando. Execute:" -ForegroundColor Yellow
    Write-Host "  .\scripts\start.ps1" -ForegroundColor White
    exit 1
}

# 2. Criar massa de dados
Write-Host "`n[2/5] Criando massa de dados..." -ForegroundColor Yellow
& ".\scripts\create-test-data.ps1"

# 3. Verificar emulador
Write-Host "`n[3/5] Verificando emulador Android..." -ForegroundColor Yellow
$devices = adb devices 2>&1 | Select-String "device$"
if ($devices) {
    Write-Host "  ✓ Emulador conectado: $($devices -replace '\s+device$', '')" -ForegroundColor Green
} else {
    Write-Host "  ✗ Nenhum emulador conectado!" -ForegroundColor Red
    Write-Host "  Inicie um emulador Android e tente novamente" -ForegroundColor Yellow
    exit 1
}

# 4. Instalar/Atualizar app
Write-Host "`n[4/5] Instalando app Flutter..." -ForegroundColor Yellow
$apkPath = "apps\user_app_flutter\build\app\outputs\flutter-apk\app-debug.apk"
if (Test-Path $apkPath) {
    adb install -r $apkPath 2>&1 | Out-Null
    Write-Host "  ✓ App instalado/atualizado" -ForegroundColor Green
} else {
    Write-Host "  ⚠ APK não encontrado, compilando..." -ForegroundColor Yellow
    Push-Location "apps\user_app_flutter"
    flutter build apk --debug 2>&1 | Out-Null
    Pop-Location
    adb install -r $apkPath 2>&1 | Out-Null
    Write-Host "  ✓ App compilado e instalado" -ForegroundColor Green
}

# 5. Iniciar app e monitorar logs
Write-Host "`n[5/5] Iniciando app e preparando logs..." -ForegroundColor Yellow
adb shell am start -n com.benefits.app/.MainActivity 2>&1 | Out-Null
Write-Host "  ✓ App iniciado" -ForegroundColor Green

Write-Host "`n=== INSTRUÇÕES PARA TESTE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. No app Flutter (emulador):" -ForegroundColor Yellow
Write-Host "   - Clique no botão 'Entrar'" -ForegroundColor White
Write-Host "   - Faça login com: user1 / Passw0rd!" -ForegroundColor White
Write-Host ""
Write-Host "2. Para ver logs do Flutter (execute em outro terminal):" -ForegroundColor Yellow
Write-Host "   adb logcat | Select-String 'LOGIN|API|AUTH|BFF|KC'" -ForegroundColor White
Write-Host ""
Write-Host "3. Para ver logs do User BFF:" -ForegroundColor Yellow
Write-Host "   docker logs -f benefits-user-bff" -ForegroundColor White
Write-Host ""
Write-Host "4. Para ver logs do Keycloak:" -ForegroundColor Yellow
Write-Host "   docker logs -f benefits-keycloak" -ForegroundColor White
Write-Host ""
Write-Host "=== TESTE PRONTO! ===" -ForegroundColor Green
