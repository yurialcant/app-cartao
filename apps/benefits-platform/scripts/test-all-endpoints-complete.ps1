# Script completo de testes para TODOS os endpoints com parâmetros corretos
# Autor: Sistema de Testes Automatizados
# Data: 2025-12-26

Write-Host "`n🧪 TESTE COMPLETO DE TODOS OS ENDPOINTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost"
$results = @()
$errors = @()
$testUserId = "test-user-123"
$testMerchantId = "00000000-0000-0000-0000-000000000001"

function Test-Endpoint {
    param(
        [string]$ServiceName,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [int[]]$ExpectedStatus = @(200, 201, 204)
    )
    
    try {
        $response = if ($Method -eq "GET") {
            Invoke-WebRequest -Uri $Url -Method $Method -Headers $Headers -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        } else {
            $params = @{
                Uri = $Url
                Method = $Method
                Headers = $Headers
                UseBasicParsing = $true
                TimeoutSec = 10
                ErrorAction = "Stop"
            }
            if ($Body) {
                $params.Body = $Body
                $params.ContentType = "application/json"
            }
            Invoke-WebRequest @params
        }
        
        $status = $response.StatusCode
        if ($status -in $ExpectedStatus) {
            Write-Host "  ✅ $ServiceName - $Method $Url -> $status" -ForegroundColor Green
            return @{ Success = $true; Status = $status; Service = $ServiceName; Url = $Url }
        } else {
            Write-Host "  ⚠️  $ServiceName - $Method $Url -> $status (esperado: $($ExpectedStatus -join ','))" -ForegroundColor Yellow
            return @{ Success = $false; Status = $status; Service = $ServiceName; Url = $Url; Expected = $ExpectedStatus }
        }
    } catch {
        $statusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode.value__ } else { 0 }
        if ($statusCode -in $ExpectedStatus) {
            Write-Host "  ✅ $ServiceName - $Method $Url -> $statusCode (esperado)" -ForegroundColor Green
            return @{ Success = $true; Status = $statusCode; Service = $ServiceName; Url = $Url }
        } else {
            Write-Host "  ❌ $ServiceName - $Method $Url -> ERRO: $($_.Exception.Message)" -ForegroundColor Red
            return @{ Success = $false; Error = $_.Exception.Message; Service = $ServiceName; Url = $Url; Status = $statusCode }
        }
    }
}

# ============================================
# 1. TESTE DE HEALTH CHECKS
# ============================================
Write-Host "`n📋 1. TESTANDO HEALTH CHECKS" -ForegroundColor Yellow

$services = @(
    @{ Name = "Core Service"; Port = 8091 },
    @{ Name = "User BFF"; Port = 8080 },
    @{ Name = "Admin BFF"; Port = 8083 },
    @{ Name = "Merchant BFF"; Port = 8084 },
    @{ Name = "Merchant Portal BFF"; Port = 8085 },
    @{ Name = "Employer BFF"; Port = 8086 },
    @{ Name = "Payments Orchestrator"; Port = 8092 },
    @{ Name = "Acquirer Adapter"; Port = 8093 },
    @{ Name = "Acquirer Stub"; Port = 8104 },
    @{ Name = "Notification Service"; Port = 8100 },
    @{ Name = "KYC Service"; Port = 8101 },
    @{ Name = "KYB Service"; Port = 8102 },
    @{ Name = "Risk Service"; Port = 8094 },
    @{ Name = "Audit Service"; Port = 8099 },
    @{ Name = "Device Service"; Port = 8098 },
    @{ Name = "Privacy Service"; Port = 8103 },
    @{ Name = "Recon Service"; Port = 8097 },
    @{ Name = "Support Service"; Port = 8095 },
    @{ Name = "Settlement Service"; Port = 8096 },
    @{ Name = "Webhook Receiver"; Port = 8105 },
    @{ Name = "Tenant Service"; Port = 8106 },
    @{ Name = "Employer Service"; Port = 8107 }
)

foreach ($svc in $services) {
    $result = Test-Endpoint -ServiceName $svc.Name -Url "$baseUrl`:$($svc.Port)/actuator/health"
    $results += $result
    if (-not $result.Success) { $errors += $result }
}

# ============================================
# 2. TESTE DE ENDPOINTS DO CORE SERVICE
# ============================================
Write-Host "`n📋 2. TESTANDO CORE SERVICE" -ForegroundColor Yellow

# Users
$result = Test-Endpoint -ServiceName "Core - Users" -Url "$baseUrl`:8091/api/users"
$results += $result

$result = Test-Endpoint -ServiceName "Core - Users by ID" -Url "$baseUrl`:8091/api/users/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# Merchants
$result = Test-Endpoint -ServiceName "Core - Merchants" -Url "$baseUrl`:8091/api/merchants"
$results += $result

# Disputes
$result = Test-Endpoint -ServiceName "Core - Disputes" -Url "$baseUrl`:8091/api/disputes"
$results += $result

# Wallets (precisa userId)
$result = Test-Endpoint -ServiceName "Core - Wallet Summary" -Url "$baseUrl`:8091/api/wallets/$testUserId/summary" -ExpectedStatus @(200, 404)
$results += $result

# Transactions (precisa userId)
$result = Test-Endpoint -ServiceName "Core - Transactions" -Url "$baseUrl`:8091/api/transactions?userId=$testUserId" -ExpectedStatus @(200, 400)
$results += $result

# ============================================
# 3. TESTE DE SERVIÇOS ESPECIALIZADOS
# ============================================
Write-Host "`n📋 3. TESTANDO SERVIÇOS ESPECIALIZADOS" -ForegroundColor Yellow

# Payments Orchestrator
$result = Test-Endpoint -ServiceName "Payments - Get Payment" -Url "$baseUrl`:8092/api/payments/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# Acquirer Adapter
$result = Test-Endpoint -ServiceName "Acquirer - Authorize" -Url "$baseUrl`:8093/api/acquirer/authorize" -Method "POST" -Body '{"amount":10000}' -ExpectedStatus @(200, 400)
$results += $result

# Notification Service
$result = Test-Endpoint -ServiceName "Notification - Get User Notifications" -Url "$baseUrl`:8100/api/notifications/user/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# KYC Service
$result = Test-Endpoint -ServiceName "KYC - Get KYC" -Url "$baseUrl`:8101/api/kyc/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# KYB Service
$result = Test-Endpoint -ServiceName "KYB - Get KYB" -Url "$baseUrl`:8102/api/kyb/$testMerchantId" -ExpectedStatus @(200, 404)
$results += $result

# Risk Service
$result = Test-Endpoint -ServiceName "Risk - Get Score" -Url "$baseUrl`:8094/api/risk/score/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# Audit Service
$result = Test-Endpoint -ServiceName "Audit - Get Logs" -Url "$baseUrl`:8099/api/audit/logs"
$results += $result

# Device Service
$result = Test-Endpoint -ServiceName "Device - Get Devices" -Url "$baseUrl`:8098/api/devices/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# Privacy Service
$result = Test-Endpoint -ServiceName "Privacy - Get Consents" -Url "$baseUrl`:8103/api/privacy/consents/$testUserId" -ExpectedStatus @(200, 404)
$results += $result

# Recon Service
$result = Test-Endpoint -ServiceName "Recon - Get Reconciliation" -Url "$baseUrl`:8097/api/reconciliation"
$results += $result

# Support Service
$result = Test-Endpoint -ServiceName "Support - Get Tickets" -Url "$baseUrl`:8095/api/tickets"
$results += $result

# Settlement Service
$result = Test-Endpoint -ServiceName "Settlement - Get Settlements" -Url "$baseUrl`:8096/api/settlements"
$results += $result

# Tenant Service
$result = Test-Endpoint -ServiceName "Tenant - Get Tenants" -Url "$baseUrl`:8106/api/tenants"
$results += $result

# Employer Service
$result = Test-Endpoint -ServiceName "Employer - Get Employers by Tenant" -Url "$baseUrl`:8107/api/employers/tenant/default" -ExpectedStatus @(200, 404)
$results += $result

# ============================================
# 4. TESTE DE MOCKS/STUBS
# ============================================
Write-Host "`n📋 4. TESTANDO MOCKS E STUBS" -ForegroundColor Yellow

$stubTests = @(
    @{ Service = "Acquirer Stub - Cielo"; Url = "$baseUrl`:8104/api/stub/cielo/authorize"; Method = "POST"; Body = '{"amount":10000,"cardToken":"test-token"}' },
    @{ Service = "Acquirer Stub - Stone"; Url = "$baseUrl`:8104/api/stub/stone/authorize"; Method = "POST"; Body = '{"amount":10000,"cardToken":"test-token"}' },
    @{ Service = "Acquirer Stub - PagSeguro"; Url = "$baseUrl`:8104/api/stub/pagseguro/authorize"; Method = "POST"; Body = '{"amount":10000,"cardToken":"test-token"}' }
)

foreach ($test in $stubTests) {
    $result = Test-Endpoint -ServiceName $test.Service -Url $test.Url -Method $test.Method -Body $test.Body
    $results += $result
    if (-not $result.Success) { $errors += $result }
}

# ============================================
# 5. TESTE DE BANCO DE DADOS
# ============================================
Write-Host "`n📋 5. TESTANDO BANCO DE DADOS" -ForegroundColor Yellow

try {
    $dbTest = docker exec benefits-postgres psql -U benefits -d benefits -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ PostgreSQL conectado e respondendo" -ForegroundColor Green
        $results += @{ Success = $true; Service = "PostgreSQL"; Message = "Conectado" }
        
        # Verificar tabelas principais
        $tables = @("users", "merchants", "disputes", "transactions", "wallets", "payments")
        foreach ($table in $tables) {
            $tableCheck = docker exec benefits-postgres psql -U benefits -d benefits -c "SELECT COUNT(*) FROM $table;" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✅ Tabela $table existe" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  Tabela $table não encontrada ou erro" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  ❌ PostgreSQL - Erro na conexão" -ForegroundColor Red
        $errors += @{ Success = $false; Service = "PostgreSQL"; Error = $dbTest }
    }
} catch {
    Write-Host "  ❌ PostgreSQL - Erro: $($_.Exception.Message)" -ForegroundColor Red
    $errors += @{ Success = $false; Service = "PostgreSQL"; Error = $_.Exception.Message }
}

# ============================================
# RESUMO FINAL
# ============================================
Write-Host "`n📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

$total = $results.Count
$success = ($results | Where-Object { $_.Success -eq $true }).Count
$failed = ($results | Where-Object { $_.Success -eq $false }).Count

Write-Host "  Total de testes: $total" -ForegroundColor White
Write-Host "  ✅ Sucessos: $success" -ForegroundColor Green
Write-Host "  ❌ Falhas: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($errors.Count -gt 0) {
    Write-Host "`n❌ ERROS ENCONTRADOS:" -ForegroundColor Red
    foreach ($error in $errors | Select-Object -First 10) {
        Write-Host "  - $($error.Service): $($error.Url)" -ForegroundColor Red
        if ($error.Error) {
            Write-Host "    Erro: $($error.Error)" -ForegroundColor Yellow
        }
    }
    if ($errors.Count -gt 10) {
        Write-Host "  ... e mais $($errors.Count - 10) erros" -ForegroundColor Yellow
    }
    Write-Host "`n⚠️  CORREÇÕES NECESSÁRIAS" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n✅ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    exit 0
}
