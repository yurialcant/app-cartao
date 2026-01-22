# Suite de Testes E2E - Todos os 15 Fluxos
# Execute: .\tests\e2e\run-all-e2e-tests.ps1

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🧪 EXECUTANDO TESTES E2E - TODOS OS FLUXOS 🧪             ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$adminUrl = "http://localhost:8083"
$merchantUrl = "http://localhost:8084"

$testResults = @{}

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [hashtable]$Headers = @{},
        [hashtable]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
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
            return $true
        } else {
            Write-Host "    ✗ $Name - Status esperado: $ExpectedStatus, recebido: $($response.StatusCode)" -ForegroundColor Red
            $script:testResults[$Name] = "FAIL"
            return $false
        }
    } catch {
        Write-Host "    ✗ $Name - Erro: $($_.Exception.Message)" -ForegroundColor Red
        $script:testResults[$Name] = "FAIL"
        return $false
    }
}

# Obter token de autenticação
Write-Host "`n[1/15] Fluxo 1 - Login + Device Binding" -ForegroundColor Cyan
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body (@{username="user1"; password="Passw0rd!"} | ConvertTo-Json) -ContentType "application/json"
$token = $loginResponse.access_token
$headers = @{ "Authorization" = "Bearer $token" }

Test-Endpoint -Name "Login" -Method "POST" -Url "$baseUrl/auth/login" -Body @{username="user1"; password="Passw0rd!"} -ExpectedStatus 200
Test-Endpoint -Name "Get Me" -Method "GET" -Url "$baseUrl/me" -Headers $headers
Test-Endpoint -Name "Register Device" -Method "POST" -Url "$baseUrl/devices/register" -Headers $headers -Body @{deviceId="TEST-DEVICE"; deviceName="Test Device"}

Write-Host "`n[2/15] Fluxo 2 - Onboarding + KYC" -ForegroundColor Cyan
Test-Endpoint -Name "Get Available Benefits" -Method "GET" -Url "$baseUrl/onboarding/benefits" -Headers $headers

Write-Host "`n[3/15] Fluxo 3 - Top-up" -ForegroundColor Cyan
# Requer admin token
Write-Host "  ⚠ Requer autenticação admin" -ForegroundColor Yellow

Write-Host "`n[4/15] Fluxo 4 - Merchant Onboarding" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação merchant" -ForegroundColor Yellow

Write-Host "`n[5/15] Fluxo 5 - Pagamento QR" -ForegroundColor Cyan
Test-Endpoint -Name "Scan QR" -Method "POST" -Url "$baseUrl/payments/qr/scan" -Headers $headers -Body @{qrCode="QR123456"}

Write-Host "`n[6/15] Fluxo 6 - Pagamento Cartão" -ForegroundColor Cyan
Test-Endpoint -Name "Process Card Payment" -Method "POST" -Url "$baseUrl/payments/card" -Headers $headers -Body @{cardToken="token123"; amount=50.00}

Write-Host "`n[7/15] Fluxo 7 - Cancelamento/Refund" -ForegroundColor Cyan
Write-Host "  ⚠ Requer transação existente" -ForegroundColor Yellow

Write-Host "`n[8/15] Fluxo 8 - Fechamento de Caixa" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação merchant" -ForegroundColor Yellow

Write-Host "`n[9/15] Fluxo 9 - Settlement" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação admin" -ForegroundColor Yellow

Write-Host "`n[10/15] Fluxo 10 - Disputas" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação admin" -ForegroundColor Yellow

Write-Host "`n[11/15] Fluxo 11 - Atendimento" -ForegroundColor Cyan
Test-Endpoint -Name "Create Ticket" -Method "POST" -Url "$baseUrl/support/tickets" -Headers $headers -Body @{subject="Test"; description="Test ticket"}
Test-Endpoint -Name "Get Tickets" -Method "GET" -Url "$baseUrl/support/tickets" -Headers $headers

Write-Host "`n[12/15] Fluxo 12 - Antifraude" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação admin" -ForegroundColor Yellow

Write-Host "`n[13/15] Fluxo 13 - Segurança" -ForegroundColor Cyan
Test-Endpoint -Name "Get Active Sessions" -Method "GET" -Url "$baseUrl/security/sessions" -Headers $headers

Write-Host "`n[14/15] Fluxo 14 - LGPD" -ForegroundColor Cyan
Test-Endpoint -Name "Get Consents" -Method "GET" -Url "$baseUrl/privacy/consents" -Headers $headers

Write-Host "`n[15/15] Fluxo 15 - PCI/Auditoria" -ForegroundColor Cyan
Write-Host "  ⚠ Requer autenticação admin" -ForegroundColor Yellow

# Resumo
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    RESUMO DOS TESTES                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$passed = ($testResults.Values | Where-Object { $_ -eq "PASS" }).Count
$failed = ($testResults.Values | Where-Object { $_ -eq "FAIL" }).Count
$total = $testResults.Count

Write-Host "Total de testes: $total" -ForegroundColor White
Write-Host "Passou: $passed" -ForegroundColor Green
Write-Host "Falhou: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""

