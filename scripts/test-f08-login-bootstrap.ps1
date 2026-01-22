# Script para testar F08 Login + Bootstrap - Validação E2E
# Executar: .\scripts\test-f08-login-bootstrap.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🔥 [F08] Executando testes de validação E2E F08 Login + Bootstrap..." -ForegroundColor Cyan

$passedTests = 0
$failedTests = 0
$tenantId = "550e8400-e29b-41d4-a716-446655440000"
$userId = "550e8400-e29b-41d4-a716-446655440100"

# Test 1: Login endpoint
Write-Host "`n🧪 [TEST] F08 Login - User Authentication" -ForegroundColor Yellow

$loginJson = @{
    "username" = "lucas@origami.com"
    "password" = "password123"
    "tenantId" = $tenantId
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/v1/auth/login" `
        -Method POST `
        -Headers @{ "Content-Type" = "application/json" } `
        -Body $loginJson `
        -UseBasicParsing

    if ($loginResponse.StatusCode -eq 200) {
        $loginData = $loginResponse.Content | ConvertFrom-Json
        if ($loginData.accessToken -and $loginData.tokenType) {
            Write-Host "   ✅ PASS - Login successful, token returned" -ForegroundColor Green
            Write-Host "   Token Type: $($loginData.tokenType)" -ForegroundColor Gray
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Login response missing token data" -ForegroundColor Red
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Status $($loginResponse.StatusCode)" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# Test 2: Catalog endpoint
Write-Host "`n🧪 [TEST] F08 Catalog - Bootstrap Configuration" -ForegroundColor Yellow

try {
    $catalogResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/v1/catalog" `
        -Headers @{ "X-Tenant-Id" = $tenantId; "X-User-Id" = $userId } `
        -UseBasicParsing

    if ($catalogResponse.StatusCode -eq 200) {
        $catalogData = $catalogResponse.Content | ConvertFrom-Json
        if ($catalogData.tenant_id -and $catalogData.branding -and $catalogData.modules) {
            Write-Host "   ✅ PASS - Catalog returned successfully" -ForegroundColor Green
            Write-Host "   Tenant: $($catalogData.tenant_id)" -ForegroundColor Gray
            Write-Host "   Modules: $($catalogData.modules.Count)" -ForegroundColor Gray
            Write-Host "   Wallets: $($catalogData.wallet_definitions.Count)" -ForegroundColor Gray
            $passedTests++
        } else {
            Write-Host "   ❌ FAIL - Catalog response incomplete" -ForegroundColor Red
            $failedTests++
        }
    } else {
        Write-Host "   ❌ FAIL - Status $($catalogResponse.StatusCode)" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# Test 3: Wallets endpoint
Write-Host "`n🧪 [TEST] F08 Wallets - User Wallet List" -ForegroundColor Yellow

try {
    $walletsResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/v1/wallets" `
        -Headers @{ "X-Tenant-Id" = $tenantId; "X-User-Id" = $userId } `
        -UseBasicParsing

    if ($walletsResponse.StatusCode -eq 200) {
        $walletsData = $walletsResponse.Content | ConvertFrom-Json
        Write-Host "   ✅ PASS - Wallets endpoint responded" -ForegroundColor Green
        Write-Host "   Response: $($walletsResponse.Content)" -ForegroundColor Gray
        $passedTests++
    } else {
        Write-Host "   ❌ FAIL - Status $($walletsResponse.StatusCode)" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# Test 4: Statement endpoint
Write-Host "`n🧪 [TEST] F08 Statement - Wallet Statement" -ForegroundColor Yellow

$walletId = "550e8400-e29b-41d4-a716-446655440200"  # Lucas MEAL wallet

try {
    $statementResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/v1/wallets/$walletId/statement" `
        -Headers @{ "X-Tenant-Id" = $tenantId; "X-User-Id" = $userId } `
        -UseBasicParsing

    if ($statementResponse.StatusCode -eq 200) {
        $statementData = $statementResponse.Content | ConvertFrom-Json
        Write-Host "   ✅ PASS - Statement endpoint responded" -ForegroundColor Green
        Write-Host "   Response: $($statementResponse.Content)" -ForegroundColor Gray
        $passedTests++
    } else {
        Write-Host "   ❌ FAIL - Status $($statementResponse.StatusCode)" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# Summary
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES F08" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

$totalTests = $passedTests + $failedTests
$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`n✅ PASSED: $passedTests" -ForegroundColor Green
Write-Host "❌ FAILED: $failedTests" -ForegroundColor Red
Write-Host "📊 TOTAL:  $totalTests" -ForegroundColor Cyan
Write-Host "📈 PASS RATE: $passRate%" -ForegroundColor $(if ($passRate -ge 100) { "Green" } else { "Yellow" })

if ($failedTests -eq 0) {
    Write-Host "`n🎉 [F08] Todos os testes passaram! F08 Login + Bootstrap está funcional." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  [F08] Alguns testes falharam. Revise os logs acima." -ForegroundColor Yellow
    exit 1
}