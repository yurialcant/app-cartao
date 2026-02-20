# Script de smoke para validar serviços e endpoints com parâmetros válidos
# Foca em: health, caminhos corretos e corpo mínimo para evitar 404/405 por rota errada.

Write-Host "`n🧪 TESTE COMPLETO DO SISTEMA BENEFITS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost"
$results = @()
$errors = @()

function Test-Endpoint {
    param(
        [string]$ServiceName,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            UseBasicParsing = $true
            TimeoutSec = 10
            ErrorAction = "Stop"
            SkipHttpErrorCheck = $true
        }
        if ($Body) {
            $params.Body = $Body
            $params.ContentType = "application/json"
        }
        $response = Invoke-WebRequest @params
        $status = [int]$response.StatusCode
        if ($status -eq $ExpectedStatus) {
            Write-Host "  ✅ $ServiceName - $Method $Url -> $status" -ForegroundColor Green
            return @{ Success = $true; Status = $status; Service = $ServiceName; Url = $Url }
        } else {
            Write-Host "  ⚠️  $ServiceName - $Method $Url -> $status (esperado: $ExpectedStatus)" -ForegroundColor Yellow
            return @{ Success = $false; Status = $status; Service = $ServiceName; Url = $Url; Expected = $ExpectedStatus }
        }
    } catch {
        Write-Host "  ❌ $ServiceName - $Method $Url -> ERRO: $($_.Exception.Message)" -ForegroundColor Red
        return @{ Success = $false; Error = $_.Exception.Message; Service = $ServiceName; Url = $Url }
    }
}

# Gera usuário de teste
$rand = [guid]::NewGuid().ToString()
$testUserBody = @{
    tenantId   = "default"
    keycloakId = $rand
    email      = "auto+$rand@benefits.test"
    username   = "user_$($rand.Substring(0,8))"
    fullName   = "Smoke Test User"
    cpf        = "12345678901"
    phone      = "5511999999999"
} | ConvertTo-Json

Write-Host "`n📋 1. CRIANDO MASSA BÁSICA" -ForegroundColor Yellow
$createUser = Test-Endpoint -ServiceName "Core - create user" -Url "$baseUrl`:8091/api/users" -Method "POST" -Body $testUserBody -ExpectedStatus 200
$results += $createUser
if ($createUser.Success) {
    $userId = ( $createUser | ConvertTo-Json | ConvertFrom-Json ).Status # não temos corpo; fallback para usar GUID enviado
    $userId = $rand
} else { $userId = $rand }

# ============================================
# 2. HEALTH CHECKS
# ============================================
Write-Host "`n📋 2. HEALTH CHECKS" -ForegroundColor Yellow
$healthServices = @(
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
foreach ($svc in $healthServices) {
    $r = Test-Endpoint -ServiceName $svc.Name -Url "$baseUrl`:$($svc.Port)/actuator/health"
    $results += $r
    if (-not $r.Success) { $errors += $r }
}

# ============================================
# 3. CORE SERVICE
# ============================================
Write-Host "`n📋 3. CORE SERVICE" -ForegroundColor Yellow
$coreTests = @(
    @{ Name="Users list"; Url="$baseUrl`:8091/api/users"; Method="GET"; Expected=200 },
    @{ Name="Wallet summary"; Url="$baseUrl`:8091/api/wallets/$userId/summary"; Method="GET"; Expected=200 },
    @{ Name="Transactions list"; Url="$baseUrl`:8091/api/transactions?userId=$userId"; Method="GET"; Expected=200 },
    @{ Name="Merchants list"; Url="$baseUrl`:8091/api/merchants"; Method="GET"; Expected=200 },
    @{ Name="Disputes list"; Url="$baseUrl`:8091/api/disputes"; Method="GET"; Expected=200 }
)
foreach ($t in $coreTests) {
    $r = Test-Endpoint -ServiceName "Core - $($t.Name)" -Url $t.Url -Method $t.Method -ExpectedStatus $t.Expected
    $results += $r
    if (-not $r.Success) { $errors += $r }
}

# ============================================
# 4. BFFs (esperado 401 sem auth)
# ============================================
Write-Host "`n📋 4. BFFs (esperado 401 sem token)" -ForegroundColor Yellow
$bffs = @(
    @{ Service="User BFF"; Port=8080; Paths=@("/api/users","/api/wallets","/api/transactions") },
    @{ Service="Admin BFF"; Port=8083; Paths=@("/api/merchants","/api/disputes","/api/users") },
    @{ Service="Merchant BFF"; Port=8084; Paths=@("/api/stores","/api/transactions","/api/reports") },
    @{ Service="Merchant Portal BFF"; Port=8085; Paths=@("/api/stores","/api/transactions") },
    @{ Service="Employer BFF"; Port=8086; Paths=@("/api/employers","/api/employees") }
)
foreach ($bff in $bffs) {
    foreach ($p in $bff.Paths) {
        $r = Test-Endpoint -ServiceName "$($bff.Service) (auth requerida)" -Url "$baseUrl`:$($bff.Port)$p" -ExpectedStatus 401
        $results += $r
        if (-not $r.Success) { $errors += $r }
    }
}

# ============================================
# 5. SERVIÇOS ESPECIALIZADOS (com rotas corretas)
# ============================================
Write-Host "`n📋 5. SERVIÇOS ESPECIALIZADOS" -ForegroundColor Yellow
$payloadSmall = '{"sample":true}'

$spec = @(
    @{ Svc="Payments Orchestrator"; Tests=@(
        @{ Url="$baseUrl`:8092/api/payments/qr"; Method="POST"; Body='{"merchantId":"11111111-1111-1111-1111-111111111111","amount":100.50}'; Expected=200 },
        @{ Url="$baseUrl`:8092/actuator/health"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Acquirer Adapter"; Tests=@(
        @{ Url="$baseUrl`:8093/api/acquirer/authorize"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8093/api/acquirer/capture"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8093/api/acquirer/refund"; Method="POST"; Body=$payloadSmall; Expected=200 }
    )},
    @{ Svc="Acquirer Stub"; Tests=@(
        @{ Url="$baseUrl`:8104/api/stub/cielo/authorize"; Method="POST"; Body='{"amount":10000,"cardToken":"test-token"}'; Expected=200 },
        @{ Url="$baseUrl`:8104/api/stub/stone/authorize"; Method="POST"; Body='{"amount":10000,"cardToken":"test-token"}'; Expected=200 },
        @{ Url="$baseUrl`:8104/api/stub/pagseguro/authorize"; Method="POST"; Body='{"amount":10000,"cardToken":"test-token"}'; Expected=200 }
    )},
    @{ Svc="Notification Service"; Tests=@(
        @{ Url="$baseUrl`:8100/api/notifications/email"; Method="POST"; Body='{"email":"auto@benefits.test","subject":"Smoke","body":"ok"}'; Expected=200 },
        @{ Url="$baseUrl`:8100/actuator/health"; Method="GET"; Expected=200 }
    )},
    @{ Svc="KYC Service"; Tests=@(
        @{ Url="$baseUrl`:8101/api/kyc/submit"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8101/api/kyc/$userId"; Method="GET"; Expected=200 }
    )},
    @{ Svc="KYB Service"; Tests=@(
        @{ Url="$baseUrl`:8102/api/kyb/submit"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8102/api/kyb/00000000-0000-0000-0000-000000000000"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Risk Service"; Tests=@(
        @{ Url="$baseUrl`:8094/api/risk/analyze"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8094/api/risk/score/$userId"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Audit Service"; Tests=@(
        @{ Url="$baseUrl`:8099/api/audit/log"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8099/api/audit/logs"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Device Service"; Tests=@(
        @{ Url="$baseUrl`:8098/api/devices/register"; Method="POST"; Body=('{"userId":"' + $userId + '","deviceId":"dev-1"}'); Expected=200 },
        @{ Url="$baseUrl`:8098/api/devices/$userId"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Privacy Service"; Tests=@(
        @{ Url="$baseUrl`:8103/api/privacy/export"; Method="POST"; Body=$payloadSmall; Expected=200 },
        @{ Url="$baseUrl`:8103/api/privacy/consents/$userId"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Recon Service"; Tests=@(
        @{ Url="$baseUrl`:8097/api/reconciliation"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Support Service"; Tests=@(
        @{ Url="$baseUrl`:8095/api/tickets"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Settlement Service"; Tests=@(
        @{ Url="$baseUrl`:8096/api/settlements"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Tenant Service"; Tests=@(
        @{ Url="$baseUrl`:8106/api/tenants"; Method="GET"; Expected=200 }
    )},
    @{ Svc="Employer Service"; Tests=@(
        @{ Url="$baseUrl`:8107/api/employers/tenant/default"; Method="GET"; Expected=200 }
    )}
)

foreach ($group in $spec) {
    foreach ($t in $group.Tests) {
        $r = Test-Endpoint -ServiceName $group.Svc -Url $t.Url -Method $t.Method -Body $t.Body -ExpectedStatus $t.Expected
        $results += $r
        if (-not $r.Success) { $errors += $r }
    }
}

# ============================================
# 6. BANCO
# ============================================
Write-Host "`n📋 6. BANCO" -ForegroundColor Yellow
try {
    $dbTest = docker exec benefits-postgres psql -U benefits -d benefits -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ PostgreSQL conectado e respondendo" -ForegroundColor Green
        $results += @{ Success = $true; Service = "PostgreSQL"; Message = "Conectado" }
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
    foreach ($error in $errors) {
        Write-Host "  - $($error.Service): $($error.Url)" -ForegroundColor Red
        if ($error.Error) {
            Write-Host "    Erro: $($error.Error)" -ForegroundColor Yellow
        } elseif ($error.Status) {
            Write-Host "    Status: $($error.Status) (esperado: $($error.Expected))" -ForegroundColor Yellow
        }
    }
    Write-Host "`n⚠️  CORREÇÕES NECESSÁRIAS" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "`n✅ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    exit 0
}
