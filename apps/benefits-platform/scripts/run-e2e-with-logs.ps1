# Script master para rodar E2E completo com logs
Write-Host "=== E2E Completo com Logs ===" -ForegroundColor Cyan
Write-Host ""

# Preparar ambiente
Write-Host "[1/3] Preparando ambiente..." -ForegroundColor Yellow
& ".\scripts\prepare-test.ps1"

# Iniciar monitoramento de logs em background
Write-Host "`n[2/3] Iniciando monitoramento de logs..." -ForegroundColor Yellow
Write-Host "  Abrindo terminais para logs..." -ForegroundColor Gray

# Terminal 1: BFF
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; docker logs -f benefits-user-bff" -WindowStyle Normal

# Terminal 2: Keycloak  
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; docker logs -f benefits-keycloak" -WindowStyle Normal

# Terminal 3: Flutter
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; adb logcat -c; adb logcat | Select-String 'LOGIN|API|AUTH|BFF|📱|🌐|🔐'" -WindowStyle Normal

Start-Sleep -Seconds 2

# Iniciar app
Write-Host "`n[3/3] Iniciando app no emulador..." -ForegroundColor Yellow
adb shell am start -n com.benefits.app/.MainActivity 2>&1 | Out-Null

Write-Host "`n=== PRONTO PARA TESTE ===" -ForegroundColor Green
Write-Host ""
Write-Host "✅ 3 terminais abertos com logs:" -ForegroundColor Yellow
Write-Host "   - Terminal 1: Logs do User BFF" -ForegroundColor White
Write-Host "   - Terminal 2: Logs do Keycloak" -ForegroundColor White
Write-Host "   - Terminal 3: Logs do Flutter" -ForegroundColor White
Write-Host ""
Write-Host "📱 App iniciado no emulador" -ForegroundColor Yellow
Write-Host ""
Write-Host "🎯 TESTE AGORA:" -ForegroundColor Cyan
Write-Host "   1. No app, digite: user1 / Passw0rd!" -ForegroundColor White
Write-Host "   2. Clique em 'Entrar'" -ForegroundColor White
Write-Host "   3. Veja os logs aparecerem nos 3 terminais!" -ForegroundColor White
Write-Host "   4. Veja os dados do banco aparecerem no app!" -ForegroundColor White
Write-Host ""
Write-Host "📊 O que você verá nos logs:" -ForegroundColor Yellow
Write-Host "   Flutter: 📱 [LOGIN] → 🔐 [AUTH] → 🌐 [API]" -ForegroundColor Gray
Write-Host "   BFF: 🔵 [BFF] POST /auth/login → GET /me → GET /wallets/summary" -ForegroundColor Gray
Write-Host "   Keycloak: Token requests e responses" -ForegroundColor Gray
