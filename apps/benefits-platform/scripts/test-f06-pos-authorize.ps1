# test-f06-pos-authorize.ps1 - Test F06 POS Authorize E2E
# Executar: .\scripts\test-f06-pos-authorize.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🔥 [F06] Executando testes de validação E2E F06 POS Authorize..." -ForegroundColor Cyan

$passedTests = 0
$failedTests = 0
$tenantId = "550e8400-e29b-41d4-a716-446655440000"

# Test 1: POS Authorize - Approved (valid wallet with sufficient balance)
Write-Host "`n🧪 [TEST] F06 POS Authorize - Approved" -ForegroundColor Yellow

$authorizeJson = @{
    "personId" = "550e8400-e29b-41d4-a716-446655440100"  # Lucas
    "walletId" = "550e8400-e29b-41d4-a716-446655440200"  # MEAL wallet (has ~R$ 334.50 balance)
    "merchantId" = "550e8400-e29b-41d4-a716-446655440001"  # Merchant from seeds
    "terminalId" = "550e8400-e29b-41d4-a716-446655440011"  # Terminal from seeds
    "amount" = 25.00
    "description" = "Compra - Restaurante Teste"
} | ConvertTo-Json

try {
    $authorizeResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/authorize" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $authorizeJson `
        -UseBasicParsing `
        -TimeoutSec 30

    if ($authorizeResponse.StatusCode -eq 200) {
        $responseData = $authorizeResponse.Content | ConvertFrom-Json
        if ($responseData.status -eq "APPROVED") {
            Write-Host "   ✅ PASS - Authorization approved successfully" -ForegroundColor Green
            Write-Host "   Authorization Code: $($responseData.authorizationCode)" -ForegroundColor Gray
            $passedTests++

            # Store authorization code for GET test
            $script:authCode = $responseData.authorizationCode
        } else {
            Write-Host "   ❌ FAIL - Expected APPROVED, got $($responseData.status)" -ForegroundColor Red
            Write-Host "   Response: $($authorizeResponse.Content)" -ForegroundColor Gray
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Status $($authorizeResponse.StatusCode)" -ForegroundColor Red
        if ($authorizeResponse.Content) {
            try {
                $responseData = $authorizeResponse.Content | ConvertFrom-Json
                Write-Host "   Response Body: $($responseData | ConvertTo-Json)" -ForegroundColor Gray
            } catch {
                Write-Host "   Raw Response: $($authorizeResponse.Content)" -ForegroundColor Gray
            }
        }
        $failedTests++
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Response Body: $responseBody" -ForegroundColor Gray
        } catch {
            Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Gray
        }
    }
    $failedTests++
}

# Test 2: POS Authorize - Insufficient Balance
Write-Host "`n🧪 [TEST] F06 POS Authorize - Insufficient Balance" -ForegroundColor Yellow

$largeAmountJson = @{
    "personId" = "550e8400-e29b-41d4-a716-446655440100"  # Lucas
    "walletId" = "550e8400-e29b-41d4-a716-446655440201"  # FOOD wallet (has ~R$ 271.10 balance)
    "merchantId" = "550e8400-e29b-41d4-a716-446655440001"  # Merchant from seeds
    "terminalId" = "550e8400-e29b-41d4-a716-446655440011"  # Terminal from seeds
    "amount" = 500.00  # More than available balance
    "description" = "Compra grande - Deve falhar"
} | ConvertTo-Json

try {
    $authorizeResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/authorize" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $largeAmountJson `
        -UseBasicParsing `
        -TimeoutSec 30

    if ($authorizeResponse.StatusCode -eq 402) {
        $responseData = $authorizeResponse.Content | ConvertFrom-Json
        if ($responseData.status -eq "DECLINED" -and $responseData.errorCode -eq "insufficient_balance") {
            Write-Host "   ✅ PASS - Insufficient balance correctly declined" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Expected DECLINED/insufficient_balance" -ForegroundColor Red
            Write-Host "   Response: $($authorizeResponse.Content)" -ForegroundColor Gray
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Expected 402, got $($authorizeResponse.StatusCode)" -ForegroundColor Red
        Write-Host "   Response: $($authorizeResponse.Content)" -ForegroundColor Gray
        $failedTests++
    }
} catch {
    # Expected to fail for insufficient balance
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 402) {
        Write-Host "   ✅ PASS - Insufficient balance correctly declined (402)" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $responseBody = $reader.ReadToEnd()
                Write-Host "   Response Body: $responseBody" -ForegroundColor Gray
            } catch {
                Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Gray
            }
        }
        $failedTests++
    }
}

# Test 3: POS Authorize - Invalid Wallet
Write-Host "`n🧪 [TEST] F06 POS Authorize - Invalid Wallet" -ForegroundColor Yellow

$invalidWalletJson = @{
    "personId" = "550e8400-e29b-41d4-a716-446655440100"  # Lucas
    "walletId" = "00000000-0000-0000-0000-000000000000"  # Invalid wallet
    "merchantId" = "550e8400-e29b-41d4-a716-446655440001"  # Merchant from seeds
    "terminalId" = "550e8400-e29b-41d4-a716-446655440011"  # Terminal from seeds
    "amount" = 10.00
    "description" = "Test invalid wallet"
} | ConvertTo-Json

try {
    $authorizeResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/authorize" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $invalidWalletJson `
        -UseBasicParsing `
        -TimeoutSec 30

    if ($authorizeResponse.StatusCode -eq 402) {
        $responseData = $authorizeResponse.Content | ConvertFrom-Json
        if ($responseData.status -eq "DECLINED" -and $responseData.errorCode -eq "invalid_wallet") {
            Write-Host "   ✅ PASS - Invalid wallet correctly declined" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Expected DECLINED/invalid_wallet" -ForegroundColor Red
            Write-Host "   Response: $($authorizeResponse.Content)" -ForegroundColor Gray
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Expected 402, got $($authorizeResponse.StatusCode)" -ForegroundColor Red
        Write-Host "   Response: $($authorizeResponse.Content)" -ForegroundColor Gray
        $failedTests++
    }
} catch {
    # Expected to fail for invalid wallet
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 402) {
        Write-Host "   ✅ PASS - Invalid wallet correctly declined (402)" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $responseBody = $reader.ReadToEnd()
                Write-Host "   Response Body: $responseBody" -ForegroundColor Gray
            } catch {
                Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Gray
            }
        }
        $failedTests++
    }
}

# Summary
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES F06" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

$totalTests = $passedTests + $failedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`n✅ PASSED: $passedTests" -ForegroundColor Green
Write-Host "❌ FAILED: $failedTests" -ForegroundColor Red
Write-Host "📊 TOTAL:  $totalTests" -ForegroundColor Cyan
Write-Host "📈 PASS RATE: $passRate%" -ForegroundColor $(if ($passRate -ge 100) { "Green" } else { "Yellow" })

if ($failedTests -eq 0) {
    Write-Host "`n🎉 [F06] Todos os testes passaram! F06 POS Authorize está funcional." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  [F06] Alguns testes falharam. Revise os logs acima." -ForegroundColor Yellow
    exit 1
}