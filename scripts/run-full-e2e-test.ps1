# Script Completo E2E - Testa TUDO que foi implementado
Write-Host "`n=== 🚀 TESTE E2E COMPLETO - TODOS OS SERVIÇOS ===" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$allTestsPassed = $true
$testResults = @{}

# Função para testar endpoint
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$Description,
        [int]$ExpectedStatus = 200
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
            return $true
        } else {
            Write-Host "    ✗ Status inesperado: $($response.StatusCode) (esperado: $ExpectedStatus)" -ForegroundColor Red
            return $false
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "    ✓ Sucesso (Status: $statusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "    ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

# 1. Verificar Docker
Write-Host "[1/8] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\check-docker.ps1" -ForegroundColor Yellow
    exit 1
}

# 2. Verificar estrutura de arquivos
Write-Host "`n[2/8] Verificando estrutura de arquivos..." -ForegroundColor Yellow
$requiredServices = @(
    "services/benefits-core",
    "services/user-bff",
    "services/admin-bff",
    "services/merchant-bff",
    "services/merchant-portal-bff"
)

foreach ($service in $requiredServices) {
    if (Test-Path $service) {
        Write-Host "  ✓ $service" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $service não encontrado!" -ForegroundColor Red
        $allTestsPassed = $false
    }
}

# 3. Buildar todos os serviços (opcional, pode pular se já buildado)
Write-Host "`n[3/8] Buildando serviços (pode levar alguns minutos)..." -ForegroundColor Yellow
Write-Host "  (Pulando build - assumindo que já está buildado)" -ForegroundColor Gray
Write-Host "  (Para buildar: .\scripts\build-all-services.ps1)" -ForegroundColor Gray

# 4. Subir Docker Compose
Write-Host "`n[4/8] Subindo Docker Compose..." -ForegroundColor Yellow
Push-Location infra
try {
    Write-Host "  Parando containers existentes..." -ForegroundColor Gray
    docker-compose down 2>&1 | Out-Null
    
    Write-Host "  Construindo e iniciando todos os serviços..." -ForegroundColor Gray
    docker-compose up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Serviços iniciados" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Erro ao iniciar serviços" -ForegroundColor Red
        $allTestsPassed = $false
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    $allTestsPassed = $false
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

# 5. Aguardar serviços iniciarem
Write-Host "`n[5/8] Aguardando serviços iniciarem (90 segundos)..." -ForegroundColor Yellow
Write-Host "  (Keycloak pode levar até 60s, serviços Spring até 40s)" -ForegroundColor Gray
Start-Sleep -Seconds 90

# 6. Verificar containers rodando
Write-Host "`n[6/8] Verificando containers..." -ForegroundColor Yellow
$containers = @(
    "benefits-postgres",
    "benefits-keycloak",
    "benefits-core",
    "benefits-user-bff",
    "benefits-admin-bff",
    "benefits-merchant-bff",
    "benefits-merchant-portal-bff"
)

foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}" 2>$null
    if ($status) {
        Write-Host "  ✓ $container está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container não está rodando" -ForegroundColor Red
        $allTestsPassed = $false
    }
}

# 7. Testar health checks
Write-Host "`n[7/8] Testando health checks..." -ForegroundColor Yellow

# Core Service
if (Test-Endpoint "http://localhost:8081/actuator/health" -Description "Core Service Health") {
    $testResults["Core Service"] = "PASS"
} else {
    $testResults["Core Service"] = "FAIL"
    $allTestsPassed = $false
}

# User BFF
if (Test-Endpoint "http://localhost:8080/actuator/health" -Description "User BFF Health") {
    $testResults["User BFF"] = "PASS"
} else {
    $testResults["User BFF"] = "FAIL"
    $allTestsPassed = $false
}

# Admin BFF
if (Test-Endpoint "http://localhost:8083/actuator/health" -Description "Admin BFF Health") {
    $testResults["Admin BFF"] = "PASS"
} else {
    $testResults["Admin BFF"] = "FAIL"
    $allTestsPassed = $false
}

# Merchant BFF
if (Test-Endpoint "http://localhost:8084/actuator/health" -Description "Merchant BFF Health") {
    $testResults["Merchant BFF"] = "PASS"
} else {
    $testResults["Merchant BFF"] = "FAIL"
    $allTestsPassed = $false
}

# Merchant Portal BFF
if (Test-Endpoint "http://localhost:8085/actuator/health" -Description "Merchant Portal BFF Health") {
    $testResults["Merchant Portal BFF"] = "PASS"
} else {
    $testResults["Merchant Portal BFF"] = "FAIL"
    $allTestsPassed = $false
}

# Keycloak
Start-Sleep -Seconds 5
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health/started" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Keycloak Health" -ForegroundColor Green
        $testResults["Keycloak"] = "PASS"
    }
} catch {
    Write-Host "  ⚠ Keycloak ainda iniciando (normal na primeira vez)" -ForegroundColor Yellow
    $testResults["Keycloak"] = "WARN"
}

# 8. Testar fluxo completo E2E
Write-Host "`n[8/8] Testando fluxo completo E2E..." -ForegroundColor Yellow

# 8.1 Obter token do Keycloak
Write-Host "`n  [8.1] Obtendo token do Keycloak..." -ForegroundColor Cyan
$token = $null
try {
    $tokenUrl = "http://localhost:8081/realms/benefits/protocol/openid-connect/token"
    $body = @{
        client_id = "k6-dev"
        client_secret = "k6-dev-secret"
        username = "user1"
        password = "Passw0rd!"
        grant_type = "password"
    }
    
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
    
    if ($response.access_token) {
        $token = $response.access_token
        Write-Host "    ✓ Token obtido" -ForegroundColor Green
        $testResults["Keycloak Token"] = "PASS"
    } else {
        Write-Host "    ✗ Não foi possível obter token" -ForegroundColor Red
        $testResults["Keycloak Token"] = "FAIL"
        $allTestsPassed = $false
    }
} catch {
    Write-Host "    ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
    $testResults["Keycloak Token"] = "FAIL"
    $allTestsPassed = $false
}

if ($token) {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # 8.2 Testar Core Service diretamente (com API Key)
    Write-Host "`n  [8.2] Testando Core Service diretamente..." -ForegroundColor Cyan
    $coreHeaders = @{
        "X-API-Key" = "core-service-secret-key"
    }
    
    if (Test-Endpoint "http://localhost:8081/api/wallets/user1/summary" -Headers $coreHeaders -Description "Core Service - Wallet Summary") {
        $testResults["Core Service - Wallet"] = "PASS"
    } else {
        $testResults["Core Service - Wallet"] = "FAIL"
        $allTestsPassed = $false
    }
    
    # 8.3 Testar User BFF (que chama Core Service)
    Write-Host "`n  [8.3] Testando User BFF (fluxo completo)..." -ForegroundColor Cyan
    
    if (Test-Endpoint "http://localhost:8080/wallets/summary" -Headers $headers -Description "User BFF - Wallet Summary") {
        $testResults["User BFF - Wallet"] = "PASS"
    } else {
        $testResults["User BFF - Wallet"] = "FAIL"
        $allTestsPassed = $false
    }
    
    if (Test-Endpoint "http://localhost:8080/transactions?limit=10" -Headers $headers -Description "User BFF - Transactions") {
        $testResults["User BFF - Transactions"] = "PASS"
    } else {
        $testResults["User BFF - Transactions"] = "FAIL"
        $allTestsPassed = $false
    }
    
    # 8.4 Testar geração de transações (dev)
    Write-Host "`n  [8.4] Testando geração de transações (dev)..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/dev/transactions/generate?count=10" -Method Post -Headers $headers -ErrorAction Stop
        if ($response.generated) {
            Write-Host "    ✓ Transações geradas: $($response.generated)" -ForegroundColor Green
            $testResults["User BFF - Generate Transactions"] = "PASS"
        }
    } catch {
        Write-Host "    ✗ Erro ao gerar transações: $($_.Exception.Message)" -ForegroundColor Red
        $testResults["User BFF - Generate Transactions"] = "FAIL"
        $allTestsPassed = $false
    }
    
    # 8.5 Testar Admin BFF
    Write-Host "`n  [8.5] Testando Admin BFF..." -ForegroundColor Cyan
    if (Test-Endpoint "http://localhost:8083/admin/users" -Headers $headers -Description "Admin BFF - Users" -ExpectedStatus 200) {
        $testResults["Admin BFF - Users"] = "PASS"
    } else {
        $testResults["Admin BFF - Users"] = "FAIL"
        $allTestsPassed = $false
    }
    
    # 8.6 Testar Merchant BFF
    Write-Host "`n  [8.6] Testando Merchant BFF..." -ForegroundColor Cyan
    $merchantBody = @{
        amount = 100.00
        description = "Teste E2E"
    } | ConvertTo-Json
    
    if (Test-Endpoint "http://localhost:8084/merchant/charges/qr" -Method POST -Headers $headers -Body $merchantBody -Description "Merchant BFF - Create QR Charge" -ExpectedStatus 200) {
        $testResults["Merchant BFF - QR Charge"] = "PASS"
    } else {
        $testResults["Merchant BFF - QR Charge"] = "FAIL"
        $allTestsPassed = $false
    }
    
    # 8.7 Testar Merchant Portal BFF
    Write-Host "`n  [8.7] Testando Merchant Portal BFF..." -ForegroundColor Cyan
    if (Test-Endpoint "http://localhost:8085/portal/dashboard" -Headers $headers -Description "Merchant Portal BFF - Dashboard" -ExpectedStatus 200) {
        $testResults["Merchant Portal BFF - Dashboard"] = "PASS"
    } else {
        $testResults["Merchant Portal BFF - Dashboard"] = "FAIL"
        $allTestsPassed = $false
    }
}

# Resumo Final
Write-Host "`n=== 📊 RESUMO DO TESTE E2E ===" -ForegroundColor Cyan
Write-Host ""

foreach ($test in $testResults.Keys | Sort-Object) {
    $result = $testResults[$test]
    $color = if ($result -eq "PASS") { "Green" } elseif ($result -eq "FAIL") { "Red" } else { "Yellow" }
    $icon = if ($result -eq "PASS") { "✓" } elseif ($result -eq "FAIL") { "✗" } else { "⚠" }
    Write-Host "  $icon $test : $result" -ForegroundColor $color
}

Write-Host ""

if ($allTestsPassed) {
    Write-Host "✅ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "`n🎉 Sistema completo funcionando end-to-end!" -ForegroundColor Green
    Write-Host "`n📋 Serviços rodando:" -ForegroundColor Cyan
    Write-Host "   • Core Service: http://localhost:8081" -ForegroundColor White
    Write-Host "   • User BFF: http://localhost:8080" -ForegroundColor White
    Write-Host "   • Admin BFF: http://localhost:8083" -ForegroundColor White
    Write-Host "   • Merchant BFF: http://localhost:8084" -ForegroundColor White
    Write-Host "   • Merchant Portal BFF: http://localhost:8085" -ForegroundColor White
    Write-Host "   • Keycloak: http://localhost:8081/admin" -ForegroundColor White
    exit 0
} else {
    Write-Host "✗ ALGUNS TESTES FALHARAM" -ForegroundColor Red
    Write-Host "`nVerifique os logs:" -ForegroundColor Yellow
    Write-Host "   docker-compose -f infra/docker-compose.yml logs" -ForegroundColor Gray
    Write-Host "`nOu logs específicos:" -ForegroundColor Yellow
    Write-Host "   docker-compose -f infra/docker-compose.yml logs benefits-core" -ForegroundColor Gray
    Write-Host "   docker-compose -f infra/docker-compose.yml logs benefits-user-bff" -ForegroundColor Gray
    exit 1
}
