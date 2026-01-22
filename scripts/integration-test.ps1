# integration-test.ps1 - Integration Tests (Teste de Integração Completa)
# Executar: .\scripts\integration-test.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🔗 [INTEGRATION] Executando testes de integração completa..." -ForegroundColor Cyan

# ============================================
# SETUP - Criar dados de teste
# ============================================
$tenantId = [guid]::NewGuid().ToString()
$employerId = [guid]::NewGuid().ToString()
$personId = [guid]::NewGuid().ToString()
$merchantId = [guid]::NewGuid().ToString()
$terminalId = [guid]::NewGuid().ToString()

Write-Host "Configuração do teste de integração:" -ForegroundColor Yellow
Write-Host "  Tenant ID: $tenantId" -ForegroundColor White
Write-Host "  Employer ID: $employerId" -ForegroundColor White
Write-Host "  Person ID: $personId" -ForegroundColor White
Write-Host "  Merchant ID: $merchantId" -ForegroundColor White
Write-Host "  Terminal ID: $terminalId" -ForegroundColor White

$passedTests = 0
$failedTests = 0

function Test-IntegrationStep {
    param(
        [string]$Name,
        [string]$Description,
        [scriptblock]$TestBlock
    )

    Write-Host "`n🧪 [INTEGRATION TEST] $Name" -ForegroundColor Yellow
    Write-Host "   $Description" -ForegroundColor Gray

    try {
        $result = & $TestBlock
        if ($result) {
            Write-Host "   ✅ PASS" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "   ❌ FAIL" -ForegroundColor Red
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
# FASE 1: SETUP E IDENTIDADE
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 1: SETUP E IDENTIDADE" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Create Person" "Criar pessoa no Identity Service" {
    $personData = @{
        name = "Integration Test User"
        email = "integration@example.com"
        documentNumber = "12345678902"
        birthDate = "1990-05-15"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8087/internal/identity/persons" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $personData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Create Identity Link" "Criar link de identidade (Google OAuth)" {
    $linkData = @{
        personId = $personId
        issuer = "GOOGLE"
        subject = "integration-user-123"
        email = "integration@example.com"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8087/internal/identity/identity-links" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $linkData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Authenticate User" "Autenticar usuário via Identity Service" {
    $authResponse = Invoke-WebRequest -Uri "http://localhost:8087/internal/identity/auth" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/x-www-form-urlencoded" } `
        -Body "issuer=GOOGLE&subject=integration-user-123" `
        -UseBasicParsing `
        -TimeoutSec 10

    $authResponse.StatusCode -eq 200
}

# ============================================
# FASE 2: BENEFÍCIOS E CARTEIRA
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 2: BENEFÍCIOS E CARTEIRA" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Create Wallet" "Criar carteira no Benefits Core" {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/internal/benefits/wallets" `
        -Method POST `
        -Headers @{
            "X-Tenant-Id" = $tenantId
            "X-Employer-Id" = $employerId
            "X-Person-Id" = $personId
            "Content-Type" = "application/json"
        } `
        -Body "{}" `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Credit Wallet" "Creditar valor na carteira" {
    $creditData = @{
        amount = 1000.00
        description = "Initial credit for integration test"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8080/internal/benefits/wallets/$personId/credit" `
        -Method PUT `
        -Headers @{
            "X-Tenant-Id" = $tenantId
            "X-Employer-Id" = $employerId
            "Content-Type" = "application/json"
        } `
        -Body $creditData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

Test-IntegrationStep "Check Wallet Balance" "Verificar saldo da carteira" {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/internal/benefits/wallets/$personId/balance" `
        -Method GET `
        -Headers @{
            "X-Tenant-Id" = $tenantId
            "X-Employer-Id" = $employerId
        } `
        -UseBasicParsing `
        -TimeoutSec 10

    if ($response.StatusCode -eq 200) {
        $balanceData = $response.Content | ConvertFrom-Json
        [math]::Abs($balanceData.balance - 1000.00) -lt 0.01
    } else {
        $false
    }
}

# ============================================
# FASE 3: MERCHANT E TERMINAIS
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 3: MERCHANT E TERMINAIS" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Create Merchant" "Criar merchant no Merchant Service" {
    $merchantData = @{
        merchantId = "INT001"
        name = "Integration Test Merchant"
        businessName = "Integration Corp"
        document = "98765432000199"
        category = "Retail"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8089/internal/merchants/merchants" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $merchantData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Create Terminal" "Criar terminal para o merchant" {
    $terminalData = @{
        merchantId = $merchantId
        terminalId = "TERM001"
        locationName = "Test Location"
        locationAddress = "123 Integration Street"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8089/internal/merchants/terminals" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $terminalData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Terminal Ping" "Registrar ping do terminal" {
    $response = Invoke-WebRequest -Uri "http://localhost:8089/internal/merchants/terminals/$terminalId/ping" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId } `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

# ============================================
# FASE 4: PAGAMENTOS E TRANSAÇÕES
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 4: PAGAMENTOS E TRANSAÇÕES" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Create Transaction" "Criar transação no Payments Orchestrator" {
    $transactionData = @{
        transactionId = "INT-TXN-$(Get-Date -Format 'yyyyMMddHHmmss')"
        personId = $personId
        employerId = $employerId
        amount = 150.75
        description = "Integration test payment"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $transactionData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Authorize Payment" "Autorizar pagamento" {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions/INT-TXN-$(Get-Date -Format 'yyyyMMddHHmmss')/authorize" `
        -Method PUT `
        -Headers @{ "X-Tenant-Id" = $tenantId } `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

Test-IntegrationStep "Complete Payment" "Completar pagamento" {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions/INT-TXN-$(Get-Date -Format 'yyyyMMddHHmmss')/complete" `
        -Method PUT `
        -Headers @{ "X-Tenant-Id" = $tenantId } `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

# ============================================
# FASE 5: DESPESAS E REEMBOLSOS
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 5: DESPESAS E REEMBOLSOS" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Submit Expense" "Submeter despesa via Support BFF" {
    $expenseData = @{
        amount = 85.50
        description = "Client meeting lunch"
        category = "Meals"
        currency = "BRL"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/expenses" `
        -Method POST `
        -Headers @{ "Content-Type" = "application/json" } `
        -Body $expenseData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Approve Expense" "Aprovar despesa" {
    # Primeiro, obter a despesa criada
    $expensesResponse = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/expenses" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 10

    if ($expensesResponse.StatusCode -eq 200) {
        $expenses = $expensesResponse.Content | ConvertFrom-Json
        if ($expenses -and $expenses.Count -gt 0) {
            $expenseId = $expenses[0].id

            $response = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/expenses/$expenseId/status?status=APPROVED" `
                -Method PUT `
                -UseBasicParsing `
                -TimeoutSec 10

            $response.StatusCode -eq 200
        } else {
            $false
        }
    } else {
        $false
    }
}

Test-IntegrationStep "Reimburse Expense" "Reembolsar despesa" {
    # Obter novamente a despesa para reembolso
    $expensesResponse = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/expenses" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 10

    if ($expensesResponse.StatusCode -eq 200) {
        $expenses = $expensesResponse.Content | ConvertFrom-Json
        if ($expenses -and $expenses.Count -gt 0) {
            $expenseId = $expenses[0].id

            $response = Invoke-WebRequest -Uri "http://localhost:8091/internal/expenses/$expenseId/reimburse" `
                -Method PUT `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 10

            $response.StatusCode -eq 200
        } else {
            $false
        }
    } else {
        $false
    }
}

# ============================================
# FASE 6: NOTIFICAÇÕES
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 6: NOTIFICAÇÕES" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Create Notification" "Criar notificação no Notification Service" {
    $notificationData = @{
        userId = $personId
        type = "EXPENSE_REIMBURSED"
        title = "Expense Reimbursed"
        message = "Your expense has been reimbursed successfully"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8092/internal/notifications" `
        -Method POST `
        -Headers @{ "X-Tenant-Id" = $tenantId; "Content-Type" = "application/json" } `
        -Body $notificationData `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 201
}

Test-IntegrationStep "Get User Notifications" "Obter notificações do usuário" {
    $response = Invoke-WebRequest -Uri "http://localhost:8092/internal/notifications?userId=$personId" `
        -Method GET `
        -Headers @{ "X-Tenant-Id" = $tenantId } `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

# ============================================
# FASE 7: BFF INTEGRATION TESTS
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Magenta
Write-Host "FASE 7: BFF INTEGRATION TESTS" -ForegroundColor Magenta
Write-Host ("="*80) -ForegroundColor Magenta

Test-IntegrationStep "Platform BFF Health" "Verificar saúde dos serviços via Platform BFF" {
    $response = Invoke-WebRequest -Uri "http://localhost:8097/api/v1/platform/health/services" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

Test-IntegrationStep "User BFF Profile" "Obter perfil do usuário via User BFF" {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/api/v1/user/profile" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

Test-IntegrationStep "Employer BFF Dashboard" "Obter dashboard via Employer BFF" {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/api/v1/employer/dashboard" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

Test-IntegrationStep "Admin BFF Stats" "Obter estatísticas via Admin BFF" {
    $response = Invoke-WebRequest -Uri "http://localhost:8096/api/v1/admin/stats" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 10

    $response.StatusCode -eq 200
}

# ============================================
# RELATÓRIO FINAL
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Green
Write-Host "INTEGRATION TEST RESULTS" -ForegroundColor Green
Write-Host ("="*80) -ForegroundColor Green

$totalTests = $passedTests + $failedTests
$successRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

Write-Host "`n📊 RESULTADOS GERAIS:" -ForegroundColor Cyan
Write-Host "  ✅ Testes Aprovados: $passedTests" -ForegroundColor Green
Write-Host "  ❌ Testes Reprovados: $failedTests" -ForegroundColor Red
Write-Host "  📈 Taxa de Sucesso: $successRate%" -ForegroundColor Yellow
Write-Host "  🎯 Total de Testes: $totalTests" -ForegroundColor White

Write-Host "`n🔍 COBERTURA DOS TESTES:" -ForegroundColor Cyan
Write-Host "  👤 Identidade e Autenticação" -ForegroundColor White
Write-Host "  💰 Carteira e Benefícios" -ForegroundColor White
Write-Host "  🏪 Merchants e Terminais" -ForegroundColor White
Write-Host "  💳 Pagamentos e Transações" -ForegroundColor White
Write-Host "  📄 Despesas e Reembolsos" -ForegroundColor White
Write-Host "  🔔 Notificações" -ForegroundColor White
Write-Host "  🔗 Integrações BFF" -ForegroundColor White

if ($successRate -ge 95) {
    Write-Host "`n🎉 INTEGRAÇÃO COMPLETA COM SUCESSO!" -ForegroundColor Green
    Write-Host "   Todos os serviços estão funcionando corretamente em conjunto." -ForegroundColor Green
    Write-Host "   Sistema pronto para produção!" -ForegroundColor Green
} elseif ($successRate -ge 80) {
    Write-Host "`n⚠️  INTEGRAÇÃO FUNCIONAL MAS COM PROBLEMAS" -ForegroundColor Yellow
    Write-Host "   Alguns testes falharam. Verificar logs para detalhes." -ForegroundColor Yellow
    Write-Host "   Pode ser necessário ajustes antes da produção." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ INTEGRAÇÃO COM FALHAS CRÍTICAS" -ForegroundColor Red
    Write-Host "   Muitos testes falharam. Revisar implementação." -ForegroundColor Red
    Write-Host "   NÃO recomendado para produção." -ForegroundColor Red
}

Write-Host "`n🏁 Testes de integração concluídos!" -ForegroundColor Cyan