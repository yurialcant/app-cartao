# Script para criar massa de dados de teste no PostgreSQL
Write-Host "=== Criando Massa de Dados de Teste ===" -ForegroundColor Cyan

# Obter token do Keycloak
Write-Host "`n[1/3] Obtendo token do Keycloak..." -ForegroundColor Yellow
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
    
    if (-not $tokenResponse.access_token) {
        Write-Host "  ✗ Falha ao obter token" -ForegroundColor Red
        exit 1
    }
    
    $token = $tokenResponse.access_token
    Write-Host "  ✓ Token obtido" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Criar wallet inicial
Write-Host "`n[2/3] Criando wallet inicial..." -ForegroundColor Yellow
try {
    # Primeiro, vamos garantir que o wallet existe fazendo uma chamada que cria se não existir
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $walletUrl = "http://localhost:8080/wallets/summary"
    $walletResponse = Invoke-RestMethod -Uri $walletUrl -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "  ✓ Wallet verificado/criado" -ForegroundColor Green
    Write-Host "  Saldo atual: R$ $($walletResponse.balance)" -ForegroundColor Gray
} catch {
    Write-Host "  ⚠ Erro ao verificar wallet: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Gerar transações de teste
Write-Host "`n[3/3] Gerando transações de teste..." -ForegroundColor Yellow
try {
    $generateUrl = "http://localhost:8080/dev/transactions/generate?count=50"
    $generateResponse = Invoke-RestMethod -Uri $generateUrl -Method Post -Headers $headers -ErrorAction Stop
    
    Write-Host "  ✓ $($generateResponse.generated) transações geradas!" -ForegroundColor Green
    
    # Verificar saldo atualizado
    Start-Sleep -Seconds 2
    $walletResponse = Invoke-RestMethod -Uri $walletUrl -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "  Saldo atualizado: R$ $($walletResponse.balance)" -ForegroundColor Gray
    
    # Listar algumas transações
    $transactionsUrl = "http://localhost:8080/transactions?limit=5"
    $transactionsResponse = Invoke-RestMethod -Uri $transactionsUrl -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "`n  Últimas transações:" -ForegroundColor Cyan
    foreach ($tx in $transactionsResponse.items) {
        $type = $tx.type
        $amount = [math]::Round($tx.amount, 2)
        $merchant = $tx.merchant
        $date = $tx.createdAt
        Write-Host "    - $type | R$ $amount | $merchant | $date" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✗ Erro ao gerar transações: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Massa de Dados Criada com Sucesso! ===" -ForegroundColor Green
Write-Host "`nAgora você pode testar o app Flutter:" -ForegroundColor Yellow
Write-Host "  1. Abra o app no emulador" -ForegroundColor White
Write-Host "  2. Clique em 'Entrar'" -ForegroundColor White
Write-Host "  3. Faça login com: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  4. Veja o saldo e as transações!" -ForegroundColor White
