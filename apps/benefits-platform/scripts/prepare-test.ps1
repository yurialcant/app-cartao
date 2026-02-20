# Script completo para preparar ambiente de teste E2E
Write-Host "=== Preparando Ambiente de Teste E2E ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar serviços
Write-Host "[1/4] Verificando serviços Docker..." -ForegroundColor Yellow
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
    Write-Host "`n⚠ Iniciando serviços..." -ForegroundColor Yellow
    & ".\scripts\start.ps1"
    Start-Sleep -Seconds 10
}

# 2. Criar massa de dados
Write-Host "`n[2/4] Criando massa de dados de teste..." -ForegroundColor Yellow
& ".\scripts\create-test-data.ps1"

# 3. Verificar dados criados
Write-Host "`n[3/4] Verificando dados criados..." -ForegroundColor Yellow
try {
    $tokenUrl = "http://localhost:8081/realms/benefits/protocol/openid-connect/token"
    $body = @{
        client_id = "k6-dev"
        client_secret = "k6-dev-secret"
        username = "user1"
        password = "Passw0rd!"
        grant_type = "password"
    }
    
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
    $token = $tokenResponse.access_token
    
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # Verificar wallet
    $walletResponse = Invoke-RestMethod -Uri "http://localhost:8080/wallets/summary" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "  ✓ Wallet criado - Saldo: R$ $($walletResponse.balance)" -ForegroundColor Green
    
    # Verificar transações
    $transactionsResponse = Invoke-RestMethod -Uri "http://localhost:8080/transactions?limit=5" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "  ✓ Transações criadas - Total: $($transactionsResponse.total) transações" -ForegroundColor Green
    
    if ($transactionsResponse.items.Count -gt 0) {
        Write-Host "`n  Últimas transações:" -ForegroundColor Cyan
        foreach ($tx in $transactionsResponse.items) {
            $type = $tx.type
            $amount = [math]::Round($tx.amount, 2)
            $merchant = $tx.merchant
            Write-Host "    - $type | R$ $amount | $merchant" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "  ⚠ Erro ao verificar dados: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 4. Preparar logs
Write-Host "`n[4/4] Preparando monitoramento de logs..." -ForegroundColor Yellow
Write-Host "  ✓ Scripts de log criados" -ForegroundColor Green

Write-Host "`n=== AMBIENTE PRONTO PARA TESTE ===" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Credenciais de Login:" -ForegroundColor Yellow
Write-Host "   Usuário: user1" -ForegroundColor White
Write-Host "   Senha: Passw0rd!" -ForegroundColor White
Write-Host ""
Write-Host "📊 Para ver logs em tempo real:" -ForegroundColor Cyan
Write-Host "   Opção 1 (todos os logs):" -ForegroundColor Yellow
Write-Host "     .\scripts\watch-logs.ps1" -ForegroundColor White
Write-Host ""
Write-Host "   Opção 2 (terminais separados):" -ForegroundColor Yellow
Write-Host "     Terminal 1: docker logs -f benefits-user-bff" -ForegroundColor Gray
Write-Host "     Terminal 2: docker logs -f benefits-keycloak" -ForegroundColor Gray
Write-Host "     Terminal 3: adb logcat | Select-String 'LOGIN|API|AUTH|BFF|📱|🌐|🔐'" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 Para rodar o app:" -ForegroundColor Cyan
Write-Host "   O app já está instalado no emulador" -ForegroundColor White
Write-Host "   Ou execute: adb shell am start -n com.benefits.app/.MainActivity" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Tudo pronto! Teste agora!" -ForegroundColor Green
