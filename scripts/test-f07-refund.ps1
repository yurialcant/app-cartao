# Script para testar F07 Refund - Validação E2E
# Executar: .\scripts\test-f07-refund.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🔥 [F07] Executando testes de validação E2E F07 Refund..." -ForegroundColor Cyan

$passedTests = 0
$failedTests = 0
$tenantId = "550e8400-e29b-41d4-a716-446655440000"

# Check if benefits-core is running using test endpoint
$benefitsCoreRunning = $false
try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds/test/simple" -Method POST -UseBasicParsing -TimeoutSec 5
    if ($testResponse.StatusCode -eq 200) {
        $benefitsCoreRunning = $true
        Write-Host "✓ benefits-core está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ benefits-core não está respondendo" -ForegroundColor Red
    Write-Host "  Detalhes: $($_.Exception.Message)" -ForegroundColor Gray
}

if (-not $benefitsCoreRunning) {
    Write-Host "⚠️  benefits-core não está rodando. Tentando iniciar..." -ForegroundColor Yellow

    # Kill any existing processes
    Get-Process -Name java -ErrorActionSilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue

    # Start benefits-core
    Write-Host "🚀 Iniciando benefits-core..." -ForegroundColor Cyan
    $startScript = Join-Path $PSScriptRoot "start-benefits-core.ps1"
    if (Test-Path $startScript) {
        & $startScript
        Start-Sleep -Seconds 20
    } else {
        Write-Host "❌ Script start-benefits-core.ps1 não encontrado" -ForegroundColor Red
        exit 1
    }

    # Verify again
    try {
        $testResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds/test/simple" -Method POST -UseBasicParsing -TimeoutSec 5
        if ($testResponse.StatusCode -eq 200) {
            $benefitsCoreRunning = $true
            Write-Host "✓ benefits-core iniciado com sucesso" -ForegroundColor Green
        } else {
            Write-Host "❌ benefits-core ainda não está respondendo (status: $($testResponse.StatusCode))" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Falha ao iniciar benefits-core: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Test 1: Refund - Approved (valid wallet and transaction)
Write-Host "`n🧪 [TEST] F07 Refund - Valid Refund" -ForegroundColor Yellow

$refundJson = @{
    "personId" = "550e8400-e29b-41d4-a716-446655440100"  # Lucas (correct personId)
    "walletId" = "550e8400-e29b-41d4-a716-446655440200"  # MEAL wallet
    "originalTransactionId" = "AUTH001-ORIGINAL-12345"
    "amount" = 25.00
    "reason" = "Cliente solicitou cancelamento"
    "idempotencyKey" = "smoke-test-refund-001"
} | ConvertTo-Json

try {
    $refundResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $refundJson `
        -UseBasicParsing `
        -TimeoutSec 30

    if ($refundResponse.StatusCode -eq 200) {
        $responseData = $refundResponse.Content | ConvertFrom-Json
        if ($responseData.status -eq "APPROVED") {
            Write-Host "   ✅ PASS - Refund approved successfully" -ForegroundColor Green
            Write-Host "   Refund ID: $($responseData.refundId)" -ForegroundColor Gray
            $passedTests++
            
            # Store refund ID for GET test
            $script:refundId = $responseData.refundId
        } else {
            Write-Host "   ❌ FAIL - Expected APPROVED, got $($responseData.status)" -ForegroundColor Red
            Write-Host "   Response: $($refundResponse.Content)" -ForegroundColor Gray
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Status $($refundResponse.StatusCode)" -ForegroundColor Red
        Write-Host "   Response: $($refundResponse.Content)" -ForegroundColor Gray
        $failedTests++
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object.System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Response Body: $responseBody" -ForegroundColor Gray
        } catch {
            Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Gray
        }
    }
    $failedTests++
}

# Test 2: Refund - Idempotency (same key should return same refund)
if ($script:refundId) {
    Write-Host "`n🧪 [TEST] F07 Refund - Idempotency" -ForegroundColor Yellow

    try {
        $refundResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds" `
            -Method POST `
            -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
            -Body $refundJson `
            -UseBasicParsing `
            -TimeoutSec 30

        if ($refundResponse.StatusCode -eq 200) {
            $responseData = $refundResponse.Content | ConvertFrom-Json
            if ($responseData.status -eq "APPROVED" -and $responseData.refundId -eq $script:refundId) {
                Write-Host "   ✅ PASS - Idempotency working (same refund returned)" -ForegroundColor Green
                $passedTests++
            } else {
                Write-Host "   ❌ FAIL - Idempotency failed (different refund returned)" -ForegroundColor Red
                Write-Host "   Expected ID: $($script:refundId)" -ForegroundColor Gray
                Write-Host "   Got ID: $($responseData.refundId)" -ForegroundColor Gray
                $failedTests++
            }
        } else {
            Write-Host "   ❌ FAIL - Status $($refundResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }
}

# Test 3: Get Refund Status
if ($script:refundId) {
    Write-Host "`n🧪 [TEST] F07 Refund - Get Status" -ForegroundColor Yellow

    try {
        $getResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds/$($script:refundId)" `
            -Method GET `
            -Headers @{ "X-Tenant-Id" = $tenantId } `
            -UseBasicParsing `
            -TimeoutSec 30

        if ($getResponse.StatusCode -eq 200) {
            $responseData = $getResponse.Content | ConvertFrom-Json
            if ($responseData.status -eq "APPROVED" -and $responseData.refundId -eq $script:refundId) {
                Write-Host "   ✅ PASS - Refund status retrieved successfully" -ForegroundColor Green
                $passedTests++
            } else {
                Write-Host "   ❌ FAIL - Invalid refund data returned" -ForegroundColor Red
                Write-Host "   Response: $($getResponse.Content)" -ForegroundColor Gray
                $failedTests++
            }
        } else {
            Write-Host "   ❌ FAIL - Status $($getResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }
}

# Test 4: Refund - Invalid Wallet
Write-Host "`n🧪 [TEST] F07 Refund - Invalid Wallet" -ForegroundColor Yellow

            $invalidWalletJson = @{
                "personId" = "550e8400-e29b-41d4-a716-446655440100"
                "walletId" = "00000000-0000-0000-0000-000000000000"  # Invalid wallet
    "originalTransactionId" = "AUTH002-ORIGINAL-67890"
    "amount" = 10.00
    "reason" = "Test invalid wallet"
    "idempotencyKey" = "smoke-test-refund-002"
} | ConvertTo-Json

try {
    $refundResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $invalidWalletJson `
        -UseBasicParsing `
        -TimeoutSec 30

    if ($refundResponse.StatusCode -eq 402) {
        $responseData = $refundResponse.Content | ConvertFrom-Json
        if ($responseData.status -eq "DECLINED" -and $responseData.errorCode -eq "invalid_wallet") {
            Write-Host "   ✅ PASS - Invalid wallet correctly declined" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Expected DECLINED/invalid_wallet" -ForegroundColor Red
            Write-Host "   Response: $($refundResponse.Content)" -ForegroundColor Gray
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Expected 402, got $($refundResponse.StatusCode)" -ForegroundColor Red
        Write-Host "   Response: $($refundResponse.Content)" -ForegroundColor Gray
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
                $reader = New-Object.System.IO.StreamReader($stream)
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
Write-Host "RESUMO DOS TESTES F07" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

$totalTests = $passedTests + $failedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`n✅ PASSED: $passedTests" -ForegroundColor Green
Write-Host "❌ FAILED: $failedTests" -ForegroundColor Red
Write-Host "📊 TOTAL:  $totalTests" -ForegroundColor Cyan
Write-Host "📈 PASS RATE: $passRate%" -ForegroundColor $(if ($passRate -ge 100) { "Green" } else { "Yellow" })

if ($failedTests -eq 0) {
    Write-Host "`n🎉 [F07] Todos os testes passaram! F07 Refund está funcional." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  [F07] Alguns testes falharam. Revise os logs acima." -ForegroundColor Yellow
    exit 1
}