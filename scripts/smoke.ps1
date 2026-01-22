# smoke.ps1 - Smoke Tests (Validação Rápida)
# Executar: .\scripts\smoke.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🔥 [SMOKE] Executando smoke tests..." -ForegroundColor Cyan

# #region agent log
try {
    Invoke-WebRequest -Uri 'http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033' -Method POST -ContentType 'application/json' -Body (@{
        sessionId = 'debug-session'
        runId = 'system-verification'
        hypothesisId = 'H3'
        location = 'smoke.ps1:8'
        message = 'Smoke tests starting'
        data = @{script = 'smoke.ps1'; tests = 'infrastructure'}
        timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    } | ConvertTo-Json) -UseBasicParsing
} catch {}
# #endregion

$passedTests = 0
$failedTests = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$ExpectedStatus = "200"
    )
    
    Write-Host "`n🧪 [TEST] $Name" -ForegroundColor Yellow
    Write-Host "   URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        
        if ($response.StatusCode -eq [int]$ExpectedStatus) {
            Write-Host "   ✅ PASS - Status $($response.StatusCode)" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "   ❌ FAIL - Status $($response.StatusCode) (esperado $ExpectedStatus)" -ForegroundColor Red
            $script:failedTests++
            return $false
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
        return $false
    }
}

function Test-Database {
    param(
        [string]$Name,
        [string]$Query,
        [int]$ExpectedCount
    )

    Write-Host "`n🧪 [TEST] $Name" -ForegroundColor Yellow
    Write-Host "   Query: $Query" -ForegroundColor Gray

    try {
        $result = docker exec benefits-postgres psql -U benefits -d benefits -t -c "$Query" 2>&1
        # Handle array output and trim whitespace
        if ($result -is [array]) {
            $result = $result -join ""
        }
        $count = [int]($result.Trim())

        if ($count -ge $ExpectedCount) {
            Write-Host "   ✅ PASS - Encontrado $count registros (esperado >= $ExpectedCount)" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "   ❌ FAIL - Encontrado $count registros (esperado >= $ExpectedCount)" -ForegroundColor Red
            $script:failedTests++
            return $false
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
        return $false
    }
}

# ============================================
# 1. INFRAESTRUTURA
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "CATEGORIA: Infraestrutura Docker" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

Test-Endpoint -Name "Postgres Health" -Url "http://localhost:5432" -ExpectedStatus "52"  # Connection refused é esperado via HTTP
# Vamos testar via docker inspect ao invés
Write-Host "`n🧪 [TEST] Postgres Container Health" -ForegroundColor Yellow
$pgHealth = docker inspect --format='{{.State.Health.Status}}' benefits-postgres 2>$null
if ($pgHealth -eq "healthy") {
    Write-Host "   ✅ PASS - Postgres está healthy" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "   ❌ FAIL - Postgres status: $pgHealth" -ForegroundColor Red
    $failedTests++
}

Write-Host "`n🧪 [TEST] Redis Container Health" -ForegroundColor Yellow
$redisHealth = docker inspect --format='{{.State.Health.Status}}' benefits-redis 2>$null
if ($redisHealth -eq "healthy") {
    Write-Host "   ✅ PASS - Redis está healthy" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "   ❌ FAIL - Redis status: $redisHealth" -ForegroundColor Red
    $failedTests++
}

# ============================================
# 2. DATABASE SEEDS
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "CATEGORIA: Database Seeds" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

Test-Database -Name "Tenant ORIGAMI existe" `
    -Query "SELECT COUNT(*) FROM tenants WHERE slug = 'origami'" `
    -ExpectedCount 1

Test-Database -Name "Usuários de teste existem" `
    -Query "SELECT COUNT(*) FROM users WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid" `
    -ExpectedCount 3

Test-Database -Name "Wallets criadas" `
    -Query "SELECT COUNT(*) FROM wallets WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid" `
    -ExpectedCount 6

Test-Database -Name "Ledger entries existem" `
    -Query "SELECT COUNT(*) FROM ledger_entry WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid" `
    -ExpectedCount 7

# ============================================
# 3. SERVIÇOS (se estiverem rodando)
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "CATEGORIA: Serviços Java (opcional)" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

Test-Endpoint -Name "user-bff Health" -Url "http://localhost:8080/actuator/health"
Test-Endpoint -Name "user-bff Auth Test" -Url "http://localhost:8080/api/v1/auth/test"

# ============================================
# 4. F05 CREDIT BATCH (benefits-core)
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "CATEGORIA: F05 Credit Batch (benefits-core)" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

# Test if benefits-core is running
Write-Host "`n🧪 [TEST] benefits-core Health" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ PASS - benefits-core is healthy" -ForegroundColor Green
        $passedTests++

        # F05 Credit Batch Tests
        # UUIDs dos seeds (01-tenant-origami.sql e 02-users-wallets.sql)
        $tenantId = "550e8400-e29b-41d4-a716-446655440000"  # Origami tenant
        # Nota: employer_id pode não existir no seed ainda, usando um UUID válido para teste
        # Se falhar, pode ser necessário criar employer no seed primeiro
        $employerId = "550e8400-e29b-41d4-a716-446655440001"  # Employer (pode precisar criar no seed)
        $personId = "550e8400-e29b-41d4-a716-446655440100"  # Lucas (user do seed)
        $walletId = "550e8400-e29b-41d4-a716-446655440200"  # Lucas MEAL wallet
        $idempotencyKey = "smoke-test-" + (Get-Date -Format "yyyyMMddHHmmss")

        # Test 1: Submit Credit Batch
        Write-Host "`n🧪 [TEST] F05 Submit Credit Batch" -ForegroundColor Yellow
        Write-Host "   Tenant: $tenantId" -ForegroundColor Gray
        Write-Host "   Person: $personId (Lucas)" -ForegroundColor Gray
        Write-Host "   Wallet: $walletId (MEAL)" -ForegroundColor Gray
        
        $batchBody = @{
            batch_reference = "Smoke Test Batch $(Get-Date -Format 'yyyyMMddHHmmss')"
            items = @(
                @{
                    person_id = $personId
                    wallet_id = $walletId
                    amount = 100.50
                    description = "Smoke test credit - MEAL wallet"
                }
            )
        } | ConvertTo-Json -Depth 10

        try {
            $submitResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits" `
                -Method POST `
                -Headers @{
                    "X-Tenant-Id" = $tenantId
                    "X-Employer-Id" = $employerId
                    "X-Person-Id" = $personId
                    "X-Idempotency-Key" = $idempotencyKey
                    "Content-Type" = "application/json"
                } `
                -Body $batchBody `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($submitResponse.StatusCode -eq 201) {
                Write-Host "   ✅ PASS - Credit batch submitted successfully" -ForegroundColor Green
                $passedTests++

                # Extract batch ID from response
                $responseData = $submitResponse.Content | ConvertFrom-Json
                $batchId = $responseData.id

                # Test 2: Get Credit Batch
                Write-Host "`n🧪 [TEST] F05 Get Credit Batch" -ForegroundColor Yellow
                try {
                    $getResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits/$batchId" `
                        -Headers @{ "X-Tenant-Id" = $tenantId } `
                        -UseBasicParsing `
                        -TimeoutSec 5

                    if ($getResponse.StatusCode -eq 200) {
                        Write-Host "   ✅ PASS - Credit batch retrieved successfully" -ForegroundColor Green
                        $passedTests++
                    } else {
                        Write-Host "   ❌ FAIL - Status $($getResponse.StatusCode)" -ForegroundColor Red
                        $failedTests++
                    }
                } catch {
                    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
                    $failedTests++
                }

                # Test 3: List Credit Batches
                Write-Host "`n🧪 [TEST] F05 List Credit Batches" -ForegroundColor Yellow
                try {
                    $listResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits?page=1`&size=10" `
                        -Headers @{ "X-Tenant-Id" = $tenantId } `
                        -UseBasicParsing `
                        -TimeoutSec 5

                    if ($listResponse.StatusCode -eq 200) {
                        Write-Host "   ✅ PASS - Credit batches listed successfully" -ForegroundColor Green
                        $passedTests++
                    } else {
                        Write-Host "   ❌ FAIL - Status $($listResponse.StatusCode)" -ForegroundColor Red
                        $failedTests++
                    }
                } catch {
                    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
                    $failedTests++
                }

            } else {
                Write-Host "   ❌ FAIL - Status $($submitResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }

    } else {
        Write-Host "   ⚠️  SKIP - benefits-core not running (Status $($response.StatusCode))" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  SKIP - benefits-core not running ($($_.Exception.Message))" -ForegroundColor Yellow
}

# ============================================
# F06 POS Authorize (benefits-core + pos-bff)
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "CATEGORIA: F06 POS Authorize (benefits-core + pos-bff)" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

# Test F06: POS Authorize - Approved
Write-Host "`n🧪 [TEST] F06 POS Authorize - Approved" -ForegroundColor Yellow
try {
    $posBffRunning = $false
    $benefitsCoreRunning = $false

    # Check if pos-bff is running
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/pos/test" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) { $posBffRunning = $true }
    } catch { }

    # Check if benefits-core is running
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits" -Headers @{ "X-Tenant-Id" = $tenantId } -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) { $benefitsCoreRunning = $true }
    } catch { }

    if ($posBffRunning -and $benefitsCoreRunning) {
        # Test 1: POS Authorize - Approved (sufficient balance)
        Write-Host "`n🧪 [TEST] F06 POS Authorize - Sufficient Balance" -ForegroundColor Yellow

        $authorizeJson = @{
            "terminalId" = "TERM001"
            "merchantId" = "MERCH001"
            "personId" = "550e8400-e29b-41d4-a716-446655440001"
            "walletId" = "550e8400-e29b-41d4-a716-446655440200"
            "amount" = 50.00
            "description" = "Smoke test POS authorization"
            "idempotencyKey" = "smoke-test-pos-001"
        } | ConvertTo-Json

        try {
            $authResponse = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/pos/authorize" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
                -Body $authorizeJson `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($authResponse.StatusCode -eq 200) {
                $responseData = $authResponse.Content | ConvertFrom-Json
                if ($responseData.status -eq "APPROVED") {
                    Write-Host "   ✅ PASS - POS authorization approved" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Expected APPROVED, got $($responseData.status)" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Status $($authResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }

        # Test 2: POS Authorize - Insufficient Funds
        Write-Host "`n🧪 [TEST] F06 POS Authorize - Insufficient Funds" -ForegroundColor Yellow

        $insufficientJson = @{
            "terminalId" = "TERM001"
            "merchantId" = "MERCH001"
            "personId" = "550e8400-e29b-41d4-a716-446655440001"
            "walletId" = "550e8400-e29b-41d4-a716-446655440200"
            "amount" = 5000.00  # Much higher than balance
            "description" = "Smoke test insufficient funds"
            "idempotencyKey" = "smoke-test-pos-002"
        } | ConvertTo-Json

        try {
            $authResponse = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/pos/authorize" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
                -Body $insufficientJson `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($authResponse.StatusCode -eq 400) {
                $responseData = $authResponse.Content | ConvertFrom-Json
                if ($responseData.status -eq "DECLINED" -and $responseData.errorCode -eq "insufficient_funds") {
                    Write-Host "   ✅ PASS - Insufficient funds correctly declined" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Expected DECLINED/insufficient_funds" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Expected 400, got $($authResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }

        # Test 3: POS Authorize - Invalid Terminal
        Write-Host "`n🧪 [TEST] F06 POS Authorize - Invalid Terminal" -ForegroundColor Yellow

        $invalidTerminalJson = @{
            "terminalId" = "INVALID_TERM"
            "merchantId" = "MERCH001"
            "personId" = "550e8400-e29b-41d4-a716-446655440001"
            "walletId" = "550e8400-e29b-41d4-a716-446655440200"
            "amount" = 10.00
            "description" = "Smoke test invalid terminal"
            "idempotencyKey" = "smoke-test-pos-003"
        } | ConvertTo-Json

        try {
            $authResponse = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/pos/authorize" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
                -Body $invalidTerminalJson `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($authResponse.StatusCode -eq 400) {
                $responseData = $authResponse.Content | ConvertFrom-Json
                if ($responseData.status -eq "DECLINED" -and $responseData.errorCode -eq "invalid_terminal") {
                    Write-Host "   ✅ PASS - Invalid terminal correctly declined" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Expected DECLINED/invalid_terminal" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Expected 400, got $($authResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }

    } else {
        $services = @()
        if (-not $posBffRunning) { $services += "pos-bff" }
        if (-not $benefitsCoreRunning) { $services += "benefits-core" }
        Write-Host "   ⚠️  SKIP - $($services -join ' and ') not running" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  SKIP - F06 services not available ($($_.Exception.Message))" -ForegroundColor Yellow
}

# ============================================
# F07 Refund (benefits-core)
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "CATEGORIA: F07 Refund (benefits-core)" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

# Test F07: Refund - Approved
Write-Host "`n🧪 [TEST] F07 Refund - Approved" -ForegroundColor Yellow
try {
    # Check if benefits-core is running
    $benefitsCoreRunning = $false
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) { $benefitsCoreRunning = $true }
    } catch { }

    if ($benefitsCoreRunning) {
        # Test 1: Refund - Approved (valid wallet and transaction)
        Write-Host "`n🧪 [TEST] F07 Refund - Valid Refund" -ForegroundColor Yellow

        $refundJson = @{
            "personId" = "550e8400-e29b-41d4-a716-446655440001"  # Lucas
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
                -TimeoutSec 10

            if ($refundResponse.StatusCode -eq 200) {
                $responseData = $refundResponse.Content | ConvertFrom-Json
                if ($responseData.status -eq "APPROVED") {
                    Write-Host "   ✅ PASS - Refund approved successfully" -ForegroundColor Green
                    $passedTests++
                    
                    # Store refund ID for GET test
                    $script:refundId = $responseData.refundId
                } else {
                    Write-Host "   ❌ FAIL - Expected APPROVED, got $($responseData.status)" -ForegroundColor Red
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

        # Test 2: Refund - Idempotency (same key should return same refund)
        Write-Host "`n🧪 [TEST] F07 Refund - Idempotency" -ForegroundColor Yellow

        try {
            $refundResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
                -Body $refundJson `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($refundResponse.StatusCode -eq 200) {
                $responseData = $refundResponse.Content | ConvertFrom-Json
                if ($responseData.status -eq "APPROVED" -and $responseData.refundId -eq $script:refundId) {
                    Write-Host "   ✅ PASS - Idempotency working (same refund returned)" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Idempotency failed (different refund returned)" -ForegroundColor Red
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

        # Test 3: Get Refund Status
        if ($script:refundId) {
            Write-Host "`n🧪 [TEST] F07 Refund - Get Status" -ForegroundColor Yellow

            try {
                $getResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds/$($script:refundId)" `
                    -Method GET `
                    -Headers @{ "X-Tenant-Id" = $tenantId } `
                    -UseBasicParsing `
                    -TimeoutSec 10

                if ($getResponse.StatusCode -eq 200) {
                    $responseData = $getResponse.Content | ConvertFrom-Json
                    if ($responseData.status -eq "APPROVED" -and $responseData.refundId -eq $script:refundId) {
                        Write-Host "   ✅ PASS - Refund status retrieved successfully" -ForegroundColor Green
                        $passedTests++
                    } else {
                        Write-Host "   ❌ FAIL - Invalid refund data returned" -ForegroundColor Red
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
            "personId" = "550e8400-e29b-41d4-a716-446655440001"
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
                -TimeoutSec 10

            if ($refundResponse.StatusCode -eq 402) {
                $responseData = $refundResponse.Content | ConvertFrom-Json
                if ($responseData.status -eq "DECLINED" -and $responseData.errorCode -eq "invalid_wallet") {
                    Write-Host "   ✅ PASS - Invalid wallet correctly declined" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Expected DECLINED/invalid_wallet" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Expected 402, got $($refundResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            # Expected to fail for invalid wallet
            if ($_.Exception.Response.StatusCode -eq 402) {
                Write-Host "   ✅ PASS - Invalid wallet correctly declined (402)" -ForegroundColor Green
                $passedTests++
            } else {
                Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
                $failedTests++
            }
        }

    } else {
        Write-Host "   ⚠️  SKIP - benefits-core not running" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  SKIP - F07 services not available ($($_.Exception.Message))" -ForegroundColor Yellow
}

# ============================================================
# CATEGORIA: F09 Expense Reimbursement (benefits-core)
# ============================================================

if ($testBenefitsCore) {
    Write-Host "`n🔄 [F09] Testing Expense Reimbursement..." -ForegroundColor Magenta

    $tenantId = "550e8400-e29b-41d4-a716-446655440000"
    $personId = "550e8400-e29b-41d4-a716-446655440001"
    $employerId = "550e8400-e29b-41d4-a716-446655440003"

    # Test 1: Submit expense
    Write-Host "`n🧪 [TEST] F09 Expense - Submit" -ForegroundColor Yellow

    $expenseJson = @{
        "title" = "Viagem São Paulo"
        "description" = "Viagem de negócio"
        "amount" = 1250.50
        "currency" = "BRL"
        "category" = "TRAVEL"
        "receipts" = @(
            @{
                "filename" = "recibo_hotel.pdf"
                "contentType" = "application/pdf"
                "fileSize" = 2048576
            }
        )
    } | ConvertTo-Json -Depth 10

    try {
        $expenseResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/expenses" `
            -Method POST `
            -Headers @{
                "X-Tenant-Id" = $tenantId
                "X-Person-Id" = $personId
                "X-Employer-Id" = $employerId
                "Content-Type" = "application/json"
                "Idempotency-Key" = "smoke-test-expense-001"
            } `
            -Body $expenseJson `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($expenseResponse.StatusCode -eq 201) {
            $expenseData = $expenseResponse.Content | ConvertFrom-Json
            if ($expenseData.expenseId -and $expenseData.status -eq "PENDING") {
                Write-Host "   ✅ PASS - Expense submitted successfully" -ForegroundColor Green
                $passedTests++
                $script:expenseId = $expenseData.expenseId
            } else {
                Write-Host "   ❌ FAIL - Invalid expense response" -ForegroundColor Red
                $failedTests++
            }
        } else {
            Write-Host "   ❌ FAIL - Status $($expenseResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # Test 2: Get expense details
    if ($script:expenseId) {
        Write-Host "`n🧪 [TEST] F09 Expense - Get Details" -ForegroundColor Yellow

        try {
            $getResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/expenses/$($script:expenseId)" `
                -Method GET `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($getResponse.StatusCode -eq 200) {
                $expenseData = $getResponse.Content | ConvertFrom-Json
                if ($expenseData.expenseId -eq $script:expenseId -and $expenseData.title -eq "Viagem São Paulo") {
                    Write-Host "   ✅ PASS - Expense details retrieved" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Invalid expense data" -ForegroundColor Red
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

    # Test 3: Approve expense
    if ($script:expenseId) {
        Write-Host "`n🧪 [TEST] F09 Expense - Approve" -ForegroundColor Yellow

        try {
            $approveResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/expenses/$($script:expenseId)/approve" `
                -Method PUT `
                -Headers @{
                    "X-Tenant-Id" = $tenantId
                    "X-Person-Id" = "550e8400-e29b-41d4-a716-446655440002"  # Approver
                } `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($approveResponse.StatusCode -eq 200) {
                $approvedData = $approveResponse.Content | ConvertFrom-Json
                if ($approvedData.status -eq "APPROVED") {
                    Write-Host "   ✅ PASS - Expense approved successfully" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Expense not approved" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Status $($approveResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # Test 4: Reimburse expense
    if ($script:expenseId) {
        Write-Host "`n🧪 [TEST] F09 Expense - Reimburse" -ForegroundColor Yellow

        try {
            $reimburseResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/expenses/$($script:expenseId)/reimburse" `
                -Method PUT `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($reimburseResponse.StatusCode -eq 200) {
                $reimbursedData = $reimburseResponse.Content | ConvertFrom-Json
                if ($reimbursedData.status -eq "REIMBURSED") {
                    Write-Host "   ✅ PASS - Expense reimbursed successfully" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Expense not reimbursed" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Status $($reimburseResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # F09 section end
}

# ============================================
# F10: IDENTITY SERVICE TESTS
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "F10: IDENTITY SERVICE TESTS" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

if ($testIdentity) {
    Write-Host "`n🔐 [F10] Testing Identity Service..." -ForegroundColor Cyan

    # Test 1: Create person
    Write-Host "`n🧪 [TEST] F10 Identity - Create Person" -ForegroundColor Yellow

    try {
        $personData = @{
            name = "Test User"
            email = "test@example.com"
            documentNumber = "12345678901"
            birthDate = "1990-01-01"
        } | ConvertTo-Json

        $personResponse = Invoke-WebRequest -Uri "http://localhost:8087/internal/identity/persons" `
            -Method POST `
            -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
            -Body $personData `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($personResponse.StatusCode -eq 201) {
            $personData = $personResponse.Content | ConvertFrom-Json
            $script:personId = $personData.id
            Write-Host "   ✅ PASS - Person created: $($script:personId)" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($personResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # Test 2: Create identity link
    if ($script:personId) {
        Write-Host "`n🧪 [TEST] F10 Identity - Create Identity Link" -ForegroundColor Yellow

        try {
            $linkData = @{
                personId = $script:personId
                issuer = "GOOGLE"
                subject = "google-user-123"
                email = "test@example.com"
            } | ConvertTo-Json

            $linkResponse = Invoke-WebRequest -Uri "http://localhost:8087/internal/identity/identity-links" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
                -Body $linkData `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($linkResponse.StatusCode -eq 201) {
                Write-Host "   ✅ PASS - Identity link created" -ForegroundColor Green
                $passedTests++
            } else {
                Write-Host "   ❌ FAIL - Status $($linkResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # Test 3: Authenticate user
    Write-Host "`n🧪 [TEST] F10 Identity - Authenticate User" -ForegroundColor Yellow

    try {
        $authResponse = Invoke-WebRequest -Uri "http://localhost:8087/internal/identity/auth" `
            -Method POST `
            -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/x-www-form-urlencoded" } `
            -Body "issuer=GOOGLE&subject=google-user-123" `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($authResponse.StatusCode -eq 200) {
            Write-Host "   ✅ PASS - User authenticated successfully" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($authResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # F10 section end
}

# ============================================
# F11: MERCHANT SERVICE TESTS
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "F11: MERCHANT SERVICE TESTS" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

if ($testMerchant) {
    Write-Host "`n🏪 [F11] Testing Merchant Service..." -ForegroundColor Cyan

    # Test 1: Create merchant
    Write-Host "`n🧪 [TEST] F11 Merchant - Create Merchant" -ForegroundColor Yellow

    try {
        $merchantData = @{
            merchantId = "TEST001"
            name = "Test Merchant"
            businessName = "Test Business Ltda"
            document = "12345678000123"
            category = "Retail"
        } | ConvertTo-Json

        $merchantResponse = Invoke-WebRequest -Uri "http://localhost:8089/internal/merchants/merchants" `
            -Method POST `
            -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
            -Body $merchantData `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($merchantResponse.StatusCode -eq 201) {
            $merchantData = $merchantResponse.Content | ConvertFrom-Json
            $script:merchantId = $merchantData.id
            Write-Host "   ✅ PASS - Merchant created: $($script:merchantId)" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($merchantResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # Test 2: Create terminal
    if ($script:merchantId) {
        Write-Host "`n🧪 [TEST] F11 Merchant - Create Terminal" -ForegroundColor Yellow

        try {
            $terminalData = @{
                merchantId = $script:merchantId
                terminalId = "TERM999"
                locationName = "Test Location"
                locationAddress = "123 Test Street"
            } | ConvertTo-Json

            $terminalResponse = Invoke-WebRequest -Uri "http://localhost:8089/internal/merchants/terminals" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
                -Body $terminalData `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($terminalResponse.StatusCode -eq 201) {
                $terminalData = $terminalResponse.Content | ConvertFrom-Json
                $script:terminalId = $terminalData.id
                Write-Host "   ✅ PASS - Terminal created: $($script:terminalId)" -ForegroundColor Green
                $passedTests++
            } else {
                Write-Host "   ❌ FAIL - Status $($terminalResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # Test 3: Record terminal ping
    if ($script:terminalId) {
        Write-Host "`n🧪 [TEST] F11 Merchant - Terminal Ping" -ForegroundColor Yellow

        try {
            $pingResponse = Invoke-WebRequest -Uri "http://localhost:8089/internal/merchants/terminals/$($script:terminalId)/ping" `
                -Method POST `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($pingResponse.StatusCode -eq 200) {
                Write-Host "   ✅ PASS - Terminal ping recorded" -ForegroundColor Green
                $passedTests++
            } else {
                Write-Host "   ❌ FAIL - Status $($pingResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # F11 section end
}

# ============================================
# F12: PAYMENTS ORCHESTRATOR TESTS
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "F12: PAYMENTS ORCHESTRATOR TESTS" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

if ($testPayments) {
    Write-Host "`n💳 [F12] Testing Payments Orchestrator..." -ForegroundColor Cyan

    # Test 1: Create transaction
    Write-Host "`n🧪 [TEST] F12 Payments - Create Transaction" -ForegroundColor Yellow

    try {
        $transactionData = @{
            transactionId = "TXN-$(Get-Date -Format 'yyyyMMddHHmmss')"
            personId = $personId
            employerId = $employerId
            amount = 250.50
            description = "Test payment"
        } | ConvertTo-Json

        $transactionResponse = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions" `
            -Method POST `
            -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
            -Body $transactionData `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($transactionResponse.StatusCode -eq 201) {
            $transactionData = $transactionResponse.Content | ConvertFrom-Json
            $script:transactionId = $transactionData.id
            Write-Host "   ✅ PASS - Transaction created: $($script:transactionId)" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($transactionResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # Test 2: Authorize payment
    if ($script:transactionId) {
        Write-Host "`n🧪 [TEST] F12 Payments - Authorize Payment" -ForegroundColor Yellow

        try {
            $authResponse = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions/$($script:transactionId)/authorize" `
                -Method PUT `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($authResponse.StatusCode -eq 200) {
                $authData = $authResponse.Content | ConvertFrom-Json
                if ($authData.status -eq "AUTHORIZED") {
                    Write-Host "   ✅ PASS - Payment authorized" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Payment not authorized" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Status $($authResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # Test 3: Complete payment
    if ($script:transactionId) {
        Write-Host "`n🧪 [TEST] F12 Payments - Complete Payment" -ForegroundColor Yellow

        try {
            $completeResponse = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions/$($script:transactionId)/complete" `
                -Method PUT `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 10

            if ($completeResponse.StatusCode -eq 200) {
                $completeData = $completeResponse.Content | ConvertFrom-Json
                if ($completeData.status -eq "COMPLETED") {
                    Write-Host "   ✅ PASS - Payment completed" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "   ❌ FAIL - Payment not completed" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "   ❌ FAIL - Status $($completeResponse.StatusCode)" -ForegroundColor Red
                $failedTests++
            }
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
            $failedTests++
        }
    }

    # F12 section end
}

# ============================================
# F13: NOTIFICATION SERVICE TESTS
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "F13: NOTIFICATION SERVICE TESTS" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

if ($testNotifications) {
    Write-Host "`n🔔 [F13] Testing Notification Service..." -ForegroundColor Cyan

    # Test 1: Create notification
    Write-Host "`n🧪 [TEST] F13 Notifications - Create Notification" -ForegroundColor Yellow

    try {
        $notificationData = @{
            userId = $personId
            type = "EXPENSE_APPROVED"
            title = "Expense Approved"
            message = "Your expense has been approved for reimbursement"
        } | ConvertTo-Json

        $notificationResponse = Invoke-WebRequest -Uri "http://localhost:8092/internal/notifications" `
            -Method POST `
            -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
            -Body $notificationData `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($notificationResponse.StatusCode -eq 201) {
            Write-Host "   ✅ PASS - Notification created" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($notificationResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # Test 2: Get user notifications
    Write-Host "`n🧪 [TEST] F13 Notifications - Get User Notifications" -ForegroundColor Yellow

    try {
        $getResponse = Invoke-WebRequest -Uri "http://localhost:8092/internal/notifications?userId=$personId" `
            -Method GET `
            -Headers @{ "X-Tenant-Id" = $tenantId } `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($getResponse.StatusCode -eq 200) {
            Write-Host "   ✅ PASS - Notifications retrieved" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($getResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # F13 section end
}

# ============================================
# F14: BFF INTEGRATION TESTS
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "F14: BFF INTEGRATION TESTS" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

if ($testBFFs) {
    Write-Host "`n🔗 [F14] Testing BFF Integrations..." -ForegroundColor Cyan

    # Test 1: Platform BFF - Services Health
    Write-Host "`n🧪 [TEST] F14 BFF - Platform Services Health" -ForegroundColor Yellow

    try {
        $healthResponse = Invoke-WebRequest -Uri "http://localhost:8097/api/v1/platform/health/services" `
            -Method GET `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($healthResponse.StatusCode -eq 200) {
            Write-Host "   ✅ PASS - Services health check successful" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($healthResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # Test 2: Support BFF - Submit Expense
    Write-Host "`n🧪 [TEST] F14 BFF - Support Expense Submission" -ForegroundColor Yellow

    try {
        $expenseData = @{
            amount = 75.50
            description = "Client meeting lunch"
            category = "Meals"
            currency = "BRL"
        } | ConvertTo-Json

        $expenseResponse = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/expenses" `
            -Method POST `
            -Headers @{ "Content-Type" = "application/json" } `
            -Body $expenseData `
            -UseBasicParsing `
            -TimeoutSec 10

        if ($expenseResponse.StatusCode -eq 201) {
            Write-Host "   ✅ PASS - Expense submitted via BFF" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Status $($expenseResponse.StatusCode)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $failedTests++
    }

    # F14 section end
}

# ============================================
# RESUMO
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

$totalTests = $passedTests + $failedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`n✅ PASSED: $passedTests" -ForegroundColor Green
Write-Host "❌ FAILED: $failedTests" -ForegroundColor Red
Write-Host "📊 TOTAL:  $totalTests" -ForegroundColor Cyan
Write-Host "📈 PASS RATE: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } else { "Yellow" })

if ($failedTests -eq 0) {
    Write-Host "`n🎉 [SMOKE] Todos os testes passaram!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  [SMOKE] Alguns testes falharam. Revise os logs acima." -ForegroundColor Yellow
    exit 1
}
