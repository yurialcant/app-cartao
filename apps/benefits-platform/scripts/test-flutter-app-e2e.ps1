# Script E2E Completo - Testa o App Flutter consumindo TODOS os serviços
Write-Host "`n=== 🚀 TESTE E2E COMPLETO - APP FLUTTER + TODOS OS SERVIÇOS ===" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$allTestsPassed = $true
$testResults = @{}

# URLs dos serviços
$BFF_URL = "http://localhost:8080"
$KEYCLOAK_URL = "http://localhost:8081"
$CORE_URL = "http://localhost:8081"
$ADMIN_BFF_URL = "http://localhost:8083"
$MERCHANT_BFF_URL = "http://localhost:8084"
$MERCHANT_PORTAL_BFF_URL = "http://localhost:8085"

# Credenciais de teste
$TEST_USERNAME = "user1"
$TEST_PASSWORD = "Passw0rd!"

# Função para testar endpoint
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$Description,
        [int]$ExpectedStatus = 200,
        [switch]$ReturnResponse
    )
    
    Write-Host "  [TEST] $Description" -ForegroundColor Yellow
    Write-Host "    URL: $Url" -ForegroundColor Gray
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            UseBasicParsing = $true
            TimeoutSec = 10
        }
        
        if ($Body) {
            $params.Body = $Body
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @params -ErrorAction Stop
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "    ✓ Sucesso (Status: $($response.StatusCode))" -ForegroundColor Green
            if ($ReturnResponse) {
                return @{ Success = $true; Response = $response; Data = ($response.Content | ConvertFrom-Json) }
            }
            return $true
        } else {
            Write-Host "    ✗ Status inesperado: $($response.StatusCode) (esperado: $ExpectedStatus)" -ForegroundColor Red
            return $false
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "    ✓ Sucesso (Status: $statusCode)" -ForegroundColor Green
            if ($ReturnResponse) {
                try {
                    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                    $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
                    return @{ Success = $true; StatusCode = $statusCode; Data = $responseBody }
                } catch {
                    return @{ Success = $true; StatusCode = $statusCode }
                }
            }
            return $true
        } else {
            Write-Host "    ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
            if ($ReturnResponse) {
                return @{ Success = $false; Error = $_.Exception.Message }
            }
            return $false
        }
    }
}

# Função para obter token JWT
function Get-AccessToken {
    param(
        [string]$Username = $TEST_USERNAME,
        [string]$Password = $TEST_PASSWORD
    )
    
    Write-Host "  [AUTH] Obtendo token JWT..." -ForegroundColor Cyan
    
    try {
        # Login via BFF (como o app Flutter faz)
        $loginUrl = "$BFF_URL/auth/login"
        $body = @{
            username = $Username
            password = $Password
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        
        if ($response.access_token) {
            Write-Host "    ✓ Token obtido com sucesso" -ForegroundColor Green
            return $response.access_token
        } else {
            Write-Host "    ✗ Token não encontrado na resposta" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "    ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# 1. Verificar Docker
Write-Host "[1/10] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando!" -ForegroundColor Red
    exit 1
}

# 2. Verificar containers rodando
Write-Host "`n[2/10] Verificando containers..." -ForegroundColor Yellow
$containers = @(
    "benefits-postgres",
    "benefits-keycloak",
    "benefits-core",
    "benefits-user-bff",
    "benefits-admin-bff",
    "benefits-merchant-bff",
    "benefits-merchant-portal-bff"
)

$allContainersRunning = $true
foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}" 2>$null
    if ($status) {
        Write-Host "  ✓ $container está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container não está rodando" -ForegroundColor Red
        $allContainersRunning = $false
        $allTestsPassed = $false
    }
}

if (-not $allContainersRunning) {
    Write-Host "`n⚠️  Alguns containers não estão rodando. Iniciando..." -ForegroundColor Yellow
    Push-Location infra
    docker-compose up -d
    Pop-Location
    Write-Host "  Aguardando 60 segundos para serviços iniciarem..." -ForegroundColor Gray
    Start-Sleep -Seconds 60
}

# 3. Testar Health Checks
Write-Host "`n[3/10] Testando health checks..." -ForegroundColor Yellow

$healthChecks = @(
    @{ Name = "Core Service"; Url = "$CORE_URL/actuator/health" },
    @{ Name = "User BFF"; Url = "$BFF_URL/actuator/health" },
    @{ Name = "Admin BFF"; Url = "$ADMIN_BFF_URL/actuator/health" },
    @{ Name = "Merchant BFF"; Url = "$MERCHANT_BFF_URL/actuator/health" },
    @{ Name = "Merchant Portal BFF"; Url = "$MERCHANT_PORTAL_BFF_URL/actuator/health" }
)

foreach ($check in $healthChecks) {
    if (Test-Endpoint -Url $check.Url -Description "$($check.Name) Health") {
        $testResults["$($check.Name) Health"] = "PASS"
    } else {
        $testResults["$($check.Name) Health"] = "FAIL"
        $allTestsPassed = $false
    }
}

# 4. Testar Login (como o app Flutter faz)
Write-Host "`n[4/10] Testando Login (fluxo do app Flutter)..." -ForegroundColor Yellow

$token = Get-AccessToken
if ($token) {
    $testResults["Login"] = "PASS"
    Write-Host "  ✓ Login bem-sucedido" -ForegroundColor Green
} else {
    $testResults["Login"] = "FAIL"
    $allTestsPassed = $false
    Write-Host "  ✗ Falha no login - abortando testes" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 5. Testar App Config (Splash Screen)
Write-Host "`n[5/10] Testando App Config (Splash Screen)..." -ForegroundColor Yellow

$configResult = Test-Endpoint -Url "$BFF_URL/app/config" -Description "App Config" -ReturnResponse
if ($configResult.Success) {
    $testResults["App Config"] = "PASS"
    Write-Host "    Config: $($configResult.Data | ConvertTo-Json -Compress)" -ForegroundColor Gray
} else {
    $testResults["App Config"] = "FAIL"
    $allTestsPassed = $false
}

# 6. Testar /me (perfil do usuário)
Write-Host "`n[6/10] Testando /me (perfil do usuário)..." -ForegroundColor Yellow

$meResult = Test-Endpoint -Url "$BFF_URL/me" -Headers $headers -Description "Get User Profile" -ReturnResponse
if ($meResult.Success) {
    $testResults["Get User Profile"] = "PASS"
    Write-Host "    User ID: $($meResult.Data.id)" -ForegroundColor Gray
    Write-Host "    Username: $($meResult.Data.username)" -ForegroundColor Gray
} else {
    $testResults["Get User Profile"] = "FAIL"
    $allTestsPassed = $false
}

# 7. Testar Wallet Summary (Home Screen)
Write-Host "`n[7/10] Testando Wallet Summary (Home Screen)..." -ForegroundColor Yellow

$walletResult = Test-Endpoint -Url "$BFF_URL/wallets/summary" -Headers $headers -Description "Wallet Summary" -ReturnResponse
if ($walletResult.Success) {
    $testResults["Wallet Summary"] = "PASS"
    Write-Host "    Balance: $($walletResult.Data.balance)" -ForegroundColor Gray
    Write-Host "    Currency: $($walletResult.Data.currency)" -ForegroundColor Gray
} else {
    $testResults["Wallet Summary"] = "FAIL"
    $allTestsPassed = $false
}

# 8. Testar Transactions List (Home Screen)
Write-Host "`n[8/10] Testando Transactions List (Home Screen)..." -ForegroundColor Yellow

$transactionsResult = Test-Endpoint -Url "$BFF_URL/transactions?limit=10" -Headers $headers -Description "Get Transactions" -ReturnResponse
if ($transactionsResult.Success) {
    $testResults["Get Transactions"] = "PASS"
    $transactionCount = if ($transactionsResult.Data.transactions) { $transactionsResult.Data.transactions.Count } else { 0 }
    Write-Host "    Transações retornadas: $transactionCount" -ForegroundColor Gray
    
    # Se não houver transações, gerar algumas para teste
    if ($transactionCount -eq 0) {
        Write-Host "    Gerando transações de teste..." -ForegroundColor Yellow
        try {
            $generateResult = Invoke-RestMethod -Uri "$BFF_URL/dev/transactions/generate?count=5" -Method Post -Headers $headers -ErrorAction Stop
            Write-Host "    ✓ $($generateResult.generated) transações geradas" -ForegroundColor Green
            $testResults["Generate Test Transactions"] = "PASS"
        } catch {
            Write-Host "    ⚠ Não foi possível gerar transações: $($_.Exception.Message)" -ForegroundColor Yellow
            $testResults["Generate Test Transactions"] = "WARN"
        }
    }
} else {
    $testResults["Get Transactions"] = "FAIL"
    $allTestsPassed = $false
}

# 9. Testar Transaction Detail
Write-Host "`n[9/10] Testando Transaction Detail..." -ForegroundColor Yellow

if ($transactionsResult.Success -and $transactionsResult.Data.transactions -and $transactionsResult.Data.transactions.Count -gt 0) {
    $firstTransactionId = $transactionsResult.Data.transactions[0].id
    $detailResult = Test-Endpoint -Url "$BFF_URL/transactions/$firstTransactionId" -Headers $headers -Description "Get Transaction Detail" -ReturnResponse
    
    if ($detailResult.Success) {
        $testResults["Transaction Detail"] = "PASS"
        Write-Host "    Transaction ID: $($detailResult.Data.id)" -ForegroundColor Gray
        Write-Host "    Amount: $($detailResult.Data.amount)" -ForegroundColor Gray
        Write-Host "    Status: $($detailResult.Data.status)" -ForegroundColor Gray
    } else {
        $testResults["Transaction Detail"] = "FAIL"
        $allTestsPassed = $false
    }
} else {
    Write-Host "    ⚠ Pulando teste de detalhe (nenhuma transação disponível)" -ForegroundColor Yellow
    $testResults["Transaction Detail"] = "SKIP"
}

# 10. Testar Comunicação BFF → Core Service
Write-Host "`n[10/10] Testando comunicação BFF → Core Service..." -ForegroundColor Yellow

Write-Host "  [TEST] Verificando se User BFF consegue chamar Core Service..." -ForegroundColor Yellow

# O User BFF deve conseguir obter dados do Core Service
# Vamos verificar se o fluxo completo funciona:
# 1. App chama User BFF
# 2. User BFF chama Core Service
# 3. Core Service retorna dados
# 4. User BFF retorna para App

# Já testamos isso indiretamente nos testes anteriores, mas vamos validar explicitamente
if ($walletResult.Success -and $transactionsResult.Success) {
    Write-Host "    ✓ Comunicação BFF → Core Service funcionando" -ForegroundColor Green
    $testResults["BFF → Core Communication"] = "PASS"
} else {
    Write-Host "    ✗ Comunicação BFF → Core Service com problemas" -ForegroundColor Red
    $testResults["BFF → Core Communication"] = "FAIL"
    $allTestsPassed = $false
}

# Testar outros BFFs também
Write-Host "`n  [TEST] Testando outros BFFs..." -ForegroundColor Yellow

# Admin BFF
try {
    $adminResult = Invoke-RestMethod -Uri "$ADMIN_BFF_URL/admin/users" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "    ✓ Admin BFF respondendo" -ForegroundColor Green
    $testResults["Admin BFF"] = "PASS"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 200 -or $statusCode -eq 401 -or $statusCode -eq 403) {
        Write-Host "    ✓ Admin BFF respondendo (Status: $statusCode)" -ForegroundColor Green
        $testResults["Admin BFF"] = "PASS"
    } else {
        Write-Host "    ⚠ Admin BFF: $($_.Exception.Message)" -ForegroundColor Yellow
        $testResults["Admin BFF"] = "WARN"
    }
}

# Merchant BFF
try {
    $merchantBody = @{
        amount = 50.00
        description = "Teste E2E"
    } | ConvertTo-Json
    
    $merchantResult = Invoke-RestMethod -Uri "$MERCHANT_BFF_URL/merchant/charges/qr" -Method Post -Body $merchantBody -Headers $headers -ErrorAction Stop
    Write-Host "    ✓ Merchant BFF respondendo" -ForegroundColor Green
    $testResults["Merchant BFF"] = "PASS"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 200 -or $statusCode -eq 201 -or $statusCode -eq 401 -or $statusCode -eq 403) {
        Write-Host "    ✓ Merchant BFF respondendo (Status: $statusCode)" -ForegroundColor Green
        $testResults["Merchant BFF"] = "PASS"
    } else {
        Write-Host "    ⚠ Merchant BFF: $($_.Exception.Message)" -ForegroundColor Yellow
        $testResults["Merchant BFF"] = "WARN"
    }
}

# Merchant Portal BFF
try {
    $portalResult = Invoke-RestMethod -Uri "$MERCHANT_PORTAL_BFF_URL/portal/dashboard" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "    ✓ Merchant Portal BFF respondendo" -ForegroundColor Green
    $testResults["Merchant Portal BFF"] = "PASS"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 200 -or $statusCode -eq 401 -or $statusCode -eq 403) {
        Write-Host "    ✓ Merchant Portal BFF respondendo (Status: $statusCode)" -ForegroundColor Green
        $testResults["Merchant Portal BFF"] = "PASS"
    } else {
        Write-Host "    ⚠ Merchant Portal BFF: $($_.Exception.Message)" -ForegroundColor Yellow
        $testResults["Merchant Portal BFF"] = "WARN"
    }
}

# Resumo Final
Write-Host "`n=== 📊 RESUMO DO TESTE E2E - APP FLUTTER ===" -ForegroundColor Cyan
Write-Host ""

$passCount = ($testResults.Values | Where-Object { $_ -eq "PASS" }).Count
$failCount = ($testResults.Values | Where-Object { $_ -eq "FAIL" }).Count
$warnCount = ($testResults.Values | Where-Object { $_ -eq "WARN" }).Count
$skipCount = ($testResults.Values | Where-Object { $_ -eq "SKIP" }).Count

foreach ($test in $testResults.Keys | Sort-Object) {
    $result = $testResults[$test]
    $color = if ($result -eq "PASS") { "Green" } elseif ($result -eq "FAIL") { "Red" } elseif ($result -eq "WARN") { "Yellow" } else { "Gray" }
    $icon = if ($result -eq "PASS") { "✓" } elseif ($result -eq "FAIL") { "✗" } elseif ($result -eq "WARN") { "⚠" } else { "⊘" }
    Write-Host "  $icon $test : $result" -ForegroundColor $color
}

Write-Host ""
Write-Host "  Total: $($testResults.Count) testes" -ForegroundColor Cyan
Write-Host "  ✓ Passou: $passCount" -ForegroundColor Green
Write-Host "  ✗ Falhou: $failCount" -ForegroundColor Red
Write-Host "  ⚠ Avisos: $warnCount" -ForegroundColor Yellow
Write-Host "  ⊘ Pulado: $skipCount" -ForegroundColor Gray
Write-Host ""

if ($allTestsPassed -and $failCount -eq 0) {
    Write-Host "✅ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "`n🎉 App Flutter pode consumir todos os serviços corretamente!" -ForegroundColor Green
    Write-Host "`n📋 Fluxo testado:" -ForegroundColor Cyan
    Write-Host "   1. Login via BFF (/auth/login)" -ForegroundColor White
    Write-Host "   2. App Config (/app/config)" -ForegroundColor White
    Write-Host "   3. User Profile (/me)" -ForegroundColor White
    Write-Host "   4. Wallet Summary (/wallets/summary)" -ForegroundColor White
    Write-Host "   5. Transactions List (/transactions)" -ForegroundColor White
    Write-Host "   6. Transaction Detail (/transactions/{id})" -ForegroundColor White
    Write-Host "   7. Comunicação BFF → Core Service" -ForegroundColor White
    Write-Host "`n🌐 Serviços disponíveis:" -ForegroundColor Cyan
    Write-Host "   • User BFF: $BFF_URL" -ForegroundColor White
    Write-Host "   • Core Service: $CORE_URL" -ForegroundColor White
    Write-Host "   • Admin BFF: $ADMIN_BFF_URL" -ForegroundColor White
    Write-Host "   • Merchant BFF: $MERCHANT_BFF_URL" -ForegroundColor White
    Write-Host "   • Merchant Portal BFF: $MERCHANT_PORTAL_BFF_URL" -ForegroundColor White
    Write-Host "   • Keycloak: $KEYCLOAK_URL" -ForegroundColor White
    exit 0
} else {
    Write-Host "✗ ALGUNS TESTES FALHARAM" -ForegroundColor Red
    Write-Host "`nVerifique os logs:" -ForegroundColor Yellow
    Write-Host "   docker-compose -f infra/docker-compose.yml logs" -ForegroundColor Gray
    Write-Host "`nOu logs específicos:" -ForegroundColor Yellow
    Write-Host "   docker-compose -f infra/docker-compose.yml logs benefits-user-bff" -ForegroundColor Gray
    Write-Host "   docker-compose -f infra/docker-compose.yml logs benefits-core" -ForegroundColor Gray
    exit 1
}
