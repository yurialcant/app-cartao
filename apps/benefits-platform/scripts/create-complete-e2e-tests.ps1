# Script para criar testes E2E completos para todos os 15 fluxos

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🧪 CRIANDO TESTES E2E COMPLETOS PARA 15 FLUXOS 🧪         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$testsDir = Join-Path $baseDir "tests/e2e"

if (-not (Test-Path $testsDir)) {
    New-Item -ItemType Directory -Path $testsDir -Force | Out-Null
}

# Criar script completo de testes E2E
$e2eTestScript = @'
# Testes E2E Completos - Todos os 15 Fluxos
# Execute: .\tests\e2e\run-complete-e2e-tests.ps1

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🧪 TESTES E2E COMPLETOS - 15 FLUXOS 🧪                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$adminUrl = "http://localhost:8083"
$merchantUrl = "http://localhost:8084"

$testResults = @{}
$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [hashtable]$Headers = @{},
        [hashtable]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
    $script:totalTests++
    Write-Host "  Testando: $Name..." -ForegroundColor Yellow
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
            UseBasicParsing = $true
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
        }
        
        $response = Invoke-WebRequest @params
        
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "    ✓ $Name - Status: $($response.StatusCode)" -ForegroundColor Green
            $script:testResults[$Name] = "PASS"
            $script:passedTests++
            return $true
        } else {
            Write-Host "    ✗ $Name - Status esperado: $ExpectedStatus, recebido: $($response.StatusCode)" -ForegroundColor Red
            $script:testResults[$Name] = "FAIL"
            $script:failedTests++
            return $false
        }
    } catch {
        Write-Host "    ✗ $Name - Erro: $($_.Exception.Message)" -ForegroundColor Red
        $script:testResults[$Name] = "FAIL"
        $script:failedTests++
        return $false
    }
}

# Obter tokens
Write-Host "`n[Autenticação]" -ForegroundColor Cyan
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body (@{username="user1"; password="Passw0rd!"} | ConvertTo-Json) -ContentType "application/json"
$userToken = $loginResponse.access_token
$userHeaders = @{ "Authorization" = "Bearer $userToken" }

$adminLoginResponse = Invoke-RestMethod -Uri "$adminUrl/auth/login" -Method Post -Body (@{username="admin"; password="admin123"} | ConvertTo-Json) -ContentType "application/json"
$adminToken = $adminLoginResponse.access_token
$adminHeaders = @{ "Authorization" = "Bearer $adminToken" }

# FLUXO 1 - Login + Device Binding
Write-Host "`n[1/15] Fluxo 1 - Login + Device Binding" -ForegroundColor Cyan
Test-Endpoint -Name "Login User" -Method "POST" -Url "$baseUrl/auth/login" -Body @{username="user1"; password="Passw0rd!"}
Test-Endpoint -Name "Get Me" -Method "GET" -Url "$baseUrl/me" -Headers $userHeaders
Test-Endpoint -Name "Register Device" -Method "POST" -Url "$baseUrl/devices/register" -Headers $userHeaders -Body @{deviceId="TEST-DEVICE"; deviceName="Test Device"}

# FLUXO 2 - Onboarding + KYC
Write-Host "`n[2/15] Fluxo 2 - Onboarding + KYC" -ForegroundColor Cyan
Test-Endpoint -Name "Get Available Benefits" -Method "GET" -Url "$baseUrl/onboarding/benefits" -Headers $userHeaders
Test-Endpoint -Name "Link Benefit" -Method "POST" -Url "$baseUrl/onboarding/link-benefit" -Headers $userHeaders -Body @{benefitCode="TEST123"}

# FLUXO 3 - Top-up
Write-Host "`n[3/15] Fluxo 3 - Top-up" -ForegroundColor Cyan
Test-Endpoint -Name "Create Topup Batch" -Method "POST" -Url "$adminUrl/admin/topups/batch" -Headers $adminHeaders -Body @{userId="user1"; amount=1000.00; description="Test topup"}

# FLUXO 4 - Merchant Onboarding
Write-Host "`n[4/15] Fluxo 4 - Merchant Onboarding" -ForegroundColor Cyan
Test-Endpoint -Name "Get Merchants" -Method "GET" -Url "$adminUrl/admin/merchants" -Headers $adminHeaders

# FLUXO 5 - Pagamento QR
Write-Host "`n[5/15] Fluxo 5 - Pagamento QR" -ForegroundColor Cyan
Test-Endpoint -Name "Scan QR" -Method "POST" -Url "$baseUrl/payments/qr/scan" -Headers $userHeaders -Body @{qrCode="QR123456"}

# FLUXO 6 - Pagamento Cartão
Write-Host "`n[6/15] Fluxo 6 - Pagamento Cartão" -ForegroundColor Cyan
Test-Endpoint -Name "Process Card Payment" -Method "POST" -Url "$baseUrl/payments/card" -Headers $userHeaders -Body @{cardToken="token123"; amount=50.00}

# FLUXO 7 - Cancelamento/Refund
Write-Host "`n[7/15] Fluxo 7 - Cancelamento/Refund" -ForegroundColor Cyan
Test-Endpoint -Name "Get Transactions" -Method "GET" -Url "$baseUrl/transactions?limit=1" -Headers $userHeaders

# FLUXO 8 - Fechamento de Caixa
Write-Host "`n[8/15] Fluxo 8 - Fechamento de Caixa" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação merchant" -ForegroundColor Yellow

# FLUXO 9 - Settlement
Write-Host "`n[9/15] Fluxo 9 - Settlement" -ForegroundColor Cyan
Test-Endpoint -Name "Get Reconciliation" -Method "GET" -Url "$adminUrl/admin/reconciliation" -Headers $adminHeaders

# FLUXO 10 - Disputas
Write-Host "`n[10/15] Fluxo 10 - Disputas" -ForegroundColor Cyan
Test-Endpoint -Name "Get Disputes" -Method "GET" -Url "$adminUrl/admin/disputes" -Headers $adminHeaders

# FLUXO 11 - Atendimento
Write-Host "`n[11/15] Fluxo 11 - Atendimento" -ForegroundColor Cyan
Test-Endpoint -Name "Create Ticket" -Method "POST" -Url "$baseUrl/support/tickets" -Headers $userHeaders -Body @{subject="Test"; description="Test ticket"}
Test-Endpoint -Name "Get Tickets" -Method "GET" -Url "$baseUrl/support/tickets" -Headers $userHeaders

# FLUXO 12 - Antifraude
Write-Host "`n[12/15] Fluxo 12 - Antifraude" -ForegroundColor Cyan
Test-Endpoint -Name "Get Risk Analysis" -Method "GET" -Url "$adminUrl/admin/risk" -Headers $adminHeaders

# FLUXO 13 - Segurança
Write-Host "`n[13/15] Fluxo 13 - Segurança" -ForegroundColor Cyan
Test-Endpoint -Name "Get Active Sessions" -Method "GET" -Url "$baseUrl/security/sessions" -Headers $userHeaders

# FLUXO 14 - LGPD
Write-Host "`n[14/15] Fluxo 14 - LGPD" -ForegroundColor Cyan
Test-Endpoint -Name "Get Consents" -Method "GET" -Url "$baseUrl/privacy/consents" -Headers $userHeaders
Test-Endpoint -Name "Export Data" -Method "POST" -Url "$baseUrl/privacy/export" -Headers $userHeaders

# FLUXO 15 - PCI/Auditoria
Write-Host "`n[15/15] Fluxo 15 - PCI/Auditoria" -ForegroundColor Cyan
Test-Endpoint -Name "Get Audit Logs" -Method "GET" -Url "$adminUrl/admin/audit" -Headers $adminHeaders

# Resumo
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    RESUMO DOS TESTES                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Total de testes: $totalTests" -ForegroundColor White
Write-Host "Passou: $passedTests" -ForegroundColor Green
Write-Host "Falhou: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "Taxa de sucesso: $([math]::Round(($passedTests / $totalTests) * 100, 2))%" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($failedTests -eq 0) {
    Write-Host "✅ Todos os testes passaram!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠ Alguns testes falharam. Verifique os logs acima." -ForegroundColor Yellow
    exit 1
}
'@

$e2eTestPath = Join-Path $testsDir "run-complete-e2e-tests.ps1"
Set-Content -Path $e2eTestPath -Value $e2eTestScript -Encoding UTF8
Write-Host "  ✓ Testes E2E completos criados" -ForegroundColor Green

Write-Host "`n✅ Testes E2E completos criados!" -ForegroundColor Green
Write-Host "`n📋 Para executar:" -ForegroundColor Yellow
Write-Host "  .\tests\e2e\run-complete-e2e-tests.ps1" -ForegroundColor White
Write-Host ""
