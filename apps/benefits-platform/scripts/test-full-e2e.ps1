# Script Completo de Teste End-to-End - Valida TUDO
Write-Host "=== Teste Completo End-to-End - Sistema Benefits ===" -ForegroundColor Cyan
Write-Host "Validando todos os componentes de ponta a ponta...`n" -ForegroundColor Gray

$ErrorActionPreference = "Continue"
$allTestsPassed = $true
$testResults = @{}

# Função para marcar teste
function Test-Passed {
    param([string]$TestName)
    Write-Host "  ✓ $TestName" -ForegroundColor Green
    $script:testResults[$TestName] = "PASSED"
}

function Test-Failed {
    param([string]$TestName, [string]$Reason = "")
    Write-Host "  ✗ $TestName" -ForegroundColor Red
    if ($Reason) {
        Write-Host "    Razão: $Reason" -ForegroundColor Yellow
    }
    $script:testResults[$TestName] = "FAILED"
    $script:allTestsPassed = $false
}

# Função para testar endpoint HTTP
function Test-HttpEndpoint {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$Description
    )
    
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
        
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
            return @{ Success = $true; StatusCode = $response.StatusCode; Content = $response.Content }
        } else {
            return @{ Success = $false; StatusCode = $response.StatusCode; Error = "Status $($response.StatusCode)" }
        }
    } catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# ============================================
# 1. VERIFICAR DOCKER E SERVIÇOS
# ============================================
Write-Host "=== [1/8] Verificando Docker e Serviços ===" -ForegroundColor Cyan

# Docker
try {
    docker ps | Out-Null
    Test-Passed "Docker está rodando"
} catch {
    Test-Failed "Docker está rodando" "Docker não está acessível"
    Write-Host "  Execute: .\scripts\check-docker.ps1" -ForegroundColor Yellow
    exit 1
}

# Containers
$services = @("benefits-postgres", "benefits-keycloak", "benefits-user-bff")
foreach ($service in $services) {
    $container = docker ps --filter "name=$service" --format "{{.Names}}" 2>$null
    if ($container -eq $service) {
        Test-Passed "$service está rodando"
    } else {
        Test-Failed "$service está rodando"
    }
}

# ============================================
# 2. TESTAR POSTGRESQL
# ============================================
Write-Host "`n=== [2/8] Testando PostgreSQL ===" -ForegroundColor Cyan
$pgReady = docker exec benefits-postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Test-Passed "PostgreSQL está pronto"
} else {
    Test-Failed "PostgreSQL está pronto"
}

# ============================================
# 3. TESTAR KEYCLOAK
# ============================================
Write-Host "`n=== [3/8] Testando Keycloak ===" -ForegroundColor Cyan

# Aguardar Keycloak (pode levar até 90s)
Write-Host "  Aguardando Keycloak iniciar..." -ForegroundColor Yellow
$keycloakReady = $false
for ($i = 0; $i -lt 45; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/health/started" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

# Verificar se Keycloak está funcionando mesmo sem healthcheck
$keycloakWorking = $false
try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:8081/realms/benefits/.well-known/openid-configuration" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($testResponse.StatusCode -eq 200) {
        $keycloakWorking = $true
    }
} catch {
    # Ignora erro
}

if ($keycloakReady -or $keycloakWorking) {
    Test-Passed "Keycloak está pronto"
    
    # Testar endpoint raiz
    $result = Test-HttpEndpoint -Url "http://localhost:8081" -Description "Keycloak raiz"
    if ($result.Success) {
        Test-Passed "Keycloak endpoint raiz responde"
    } else {
        Test-Failed "Keycloak endpoint raiz responde"
    }
} else {
    Test-Failed "Keycloak está pronto" "Aguardou 90s mas não ficou pronto"
    Write-Host "  Verifique: docker logs benefits-keycloak" -ForegroundColor Yellow
}

# ============================================
# 4. OBTER TOKEN DO KEYCLOAK
# ============================================
Write-Host "`n=== [4/8] Obtendo Token do Keycloak ===" -ForegroundColor Cyan
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
        Test-Passed "Token obtido do Keycloak"
        Write-Host "  Token (primeiros 50 chars): $($token.Substring(0, 50))..." -ForegroundColor Gray
    } else {
        Test-Failed "Token obtido do Keycloak"
    }
} catch {
    Test-Failed "Token obtido do Keycloak" $_.Exception.Message
}

# ============================================
# 5. TESTAR USER BFF (ENDPOINTS PÚBLICOS)
# ============================================
Write-Host "`n=== [5/8] Testando User BFF (Endpoints Públicos) ===" -ForegroundColor Cyan

# Aguardar BFF
Write-Host "  Aguardando User BFF iniciar..." -ForegroundColor Yellow
$bffReady = $false
for ($i = 0; $i -lt 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $bffReady = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if ($bffReady) {
    Test-Passed "User BFF está pronto"
    
    # Health check
    $result = Test-HttpEndpoint -Url "http://localhost:8080/actuator/health" -Description "Health check"
    if ($result.Success) {
        Test-Passed "GET /actuator/health"
    } else {
        Test-Failed "GET /actuator/health"
    }
    
    # App config (sem auth)
    $result = Test-HttpEndpoint -Url "http://localhost:8080/app/config" -Description "App config"
    if ($result.Success) {
        Test-Passed "GET /app/config (sem auth)"
        try {
            $config = $result.Content | ConvertFrom-Json
            if ($config.minAppVersion -and $config.apiVersion) {
                Test-Passed "App config tem estrutura válida"
            }
        } catch {
            Test-Failed "App config tem estrutura válida"
        }
    } else {
        Test-Failed "GET /app/config (sem auth)"
    }
} else {
    Test-Failed "User BFF está pronto" "Aguardou 40s mas não ficou pronto"
}

# ============================================
# 6. TESTAR USER BFF (ENDPOINTS AUTENTICADOS)
# ============================================
Write-Host "`n=== [6/8] Testando User BFF (Endpoints Autenticados) ===" -ForegroundColor Cyan

if ($token) {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # GET /me
    $result = Test-HttpEndpoint -Url "http://localhost:8080/me" -Headers $headers -Description "GET /me"
    if ($result.Success) {
        Test-Passed "GET /me"
        try {
            $user = $result.Content | ConvertFrom-Json
            if ($user.username -eq "user1") {
                Test-Passed "GET /me retorna usuário correto"
            }
        } catch {
            Test-Failed "GET /me retorna JSON válido"
        }
    } else {
        Test-Failed "GET /me"
    }
    
    # GET /wallets/summary
    $result = Test-HttpEndpoint -Url "http://localhost:8080/wallets/summary" -Headers $headers -Description "GET /wallets/summary"
    if ($result.Success) {
        Test-Passed "GET /wallets/summary"
        try {
            $wallet = $result.Content | ConvertFrom-Json
            if ($wallet.balance -ne $null -and $wallet.currency) {
                Test-Passed "GET /wallets/summary retorna estrutura válida"
            }
        } catch {
            Test-Failed "GET /wallets/summary retorna JSON válido"
        }
    } else {
        Test-Failed "GET /wallets/summary"
    }
    
    # GET /transactions
    $result = Test-HttpEndpoint -Url "http://localhost:8080/transactions?limit=10" -Headers $headers -Description "GET /transactions"
    if ($result.Success) {
        Test-Passed "GET /transactions"
        try {
            $transactions = $result.Content | ConvertFrom-Json
            if ($transactions.items -ne $null) {
                Test-Passed "GET /transactions retorna estrutura válida"
            }
        } catch {
            Test-Failed "GET /transactions retorna JSON válido"
        }
    } else {
        Test-Failed "GET /transactions"
    }
    
    # POST /dev/transactions/generate
    Write-Host "`n  Testando geração de transações..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/dev/transactions/generate?count=10" -Method Post -Headers $headers -ErrorAction Stop
        if ($response.generated -eq 10) {
            Test-Passed "POST /dev/transactions/generate (10 transações)"
        } else {
            Test-Failed "POST /dev/transactions/generate" "Esperado 10, recebido $($response.generated)"
        }
    } catch {
        Test-Failed "POST /dev/transactions/generate" $_.Exception.Message
    }
    
    # Verificar se transações foram criadas
    Start-Sleep -Seconds 2
    $result = Test-HttpEndpoint -Url "http://localhost:8080/transactions?limit=5" -Headers $headers -Description "GET /transactions (com dados)"
    if ($result.Success) {
        try {
            $transactions = $result.Content | ConvertFrom-Json
            if ($transactions.items.Count -gt 0) {
                Test-Passed "Transações foram criadas corretamente"
            } else {
                Test-Failed "Transações foram criadas corretamente" "Lista vazia"
            }
        } catch {
            Test-Failed "Verificar transações criadas"
        }
    }
} else {
    Write-Host "  ⚠ Pulando testes autenticados (token não disponível)" -ForegroundColor Yellow
    Test-Failed "Token disponível para testes autenticados"
}

# ============================================
# 7. VERIFICAR FLUTTER
# ============================================
Write-Host "`n=== [7/8] Verificando Flutter ===" -ForegroundColor Cyan

# Verificar se Flutter está instalado
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    if ($flutterVersion -match "Flutter") {
        Test-Passed "Flutter está instalado"
        Write-Host "  $flutterVersion" -ForegroundColor Gray
    } else {
        Test-Failed "Flutter está instalado"
    }
} catch {
    Test-Failed "Flutter está instalado" "Flutter não encontrado no PATH"
    Write-Host "  Instale Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
}

# Verificar estrutura do projeto Flutter
if (Test-Path "apps/user_app_flutter/pubspec.yaml") {
    Test-Passed "Projeto Flutter existe"
    
    # Verificar dependências
    Push-Location apps/user_app_flutter
    try {
        $pubGet = flutter pub get 2>&1
        if ($LASTEXITCODE -eq 0) {
            Test-Passed "Flutter pub get executado com sucesso"
        } else {
            Test-Failed "Flutter pub get executado com sucesso"
        }
    } catch {
        Test-Failed "Flutter pub get executado com sucesso" $_.Exception.Message
    } finally {
        Pop-Location
    }
} else {
    Test-Failed "Projeto Flutter existe"
}

# Verificar arquivos principais do Flutter
$flutterFiles = @(
    "apps/user_app_flutter/lib/main.dart",
    "apps/user_app_flutter/lib/services/auth_service.dart",
    "apps/user_app_flutter/lib/services/api_service.dart",
    "apps/user_app_flutter/lib/screens/splash_screen.dart",
    "apps/user_app_flutter/lib/screens/login_screen.dart",
    "apps/user_app_flutter/lib/screens/home_screen.dart"
)

foreach ($file in $flutterFiles) {
    if (Test-Path $file) {
        Test-Passed "Arquivo Flutter existe: $(Split-Path $file -Leaf)"
    } else {
        Test-Failed "Arquivo Flutter existe: $(Split-Path $file -Leaf)"
    }
}

# ============================================
# 8. VERIFICAR K6 (OPCIONAL)
# ============================================
Write-Host "`n=== [8/8] Verificando k6 (Opcional) ===" -ForegroundColor Cyan

try {
    $k6Version = k6 version 2>&1 | Select-Object -First 1
    if ($k6Version -match "k6") {
        Test-Passed "k6 está instalado"
        Write-Host "  $k6Version" -ForegroundColor Gray
        
        # Verificar script de teste
        if (Test-Path "infra/k6/load-test.js") {
            Test-Passed "Script k6 existe"
        } else {
            Test-Failed "Script k6 existe"
        }
    } else {
        Write-Host "  ⚠ k6 não está instalado (opcional)" -ForegroundColor Yellow
        Write-Host "    Instale: https://k6.io/docs/getting-started/installation/" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ k6 não está instalado (opcional)" -ForegroundColor Yellow
}

# ============================================
# RESUMO FINAL
# ============================================
Write-Host "`n=== Resumo do Teste Completo ===" -ForegroundColor Cyan
Write-Host ""

$passed = ($testResults.Values | Where-Object { $_ -eq "PASSED" }).Count
$failed = ($testResults.Values | Where-Object { $_ -eq "FAILED" }).Count
$total = $testResults.Count

Write-Host "Total de testes: $total" -ForegroundColor White
Write-Host "Passou: $passed" -ForegroundColor Green
Write-Host "Falhou: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($allTestsPassed) {
    Write-Host "`n✓ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "`nSistema está pronto para uso:" -ForegroundColor Green
    Write-Host "  - PostgreSQL: localhost:5432" -ForegroundColor White
    Write-Host "  - Keycloak: http://localhost:8081" -ForegroundColor White
    Write-Host "  - Keycloak Admin: http://localhost:8081/admin (admin/admin)" -ForegroundColor White
    Write-Host "  - User BFF: http://localhost:8080" -ForegroundColor White
    Write-Host "  - User BFF Health: http://localhost:8080/actuator/health" -ForegroundColor White
    
    Write-Host "`nPróximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Testar o app Flutter:" -ForegroundColor White
    Write-Host "     cd apps/user_app_flutter" -ForegroundColor Gray
    Write-Host "     flutter run" -ForegroundColor Gray
    Write-Host "  2. Executar testes de carga com k6:" -ForegroundColor White
    Write-Host "     k6 run infra/k6/load-test.js" -ForegroundColor Gray
    
    exit 0
} else {
    Write-Host "`n✗ ALGUNS TESTES FALHARAM" -ForegroundColor Red
    Write-Host "`nTestes que falharam:" -ForegroundColor Yellow
    foreach ($test in $testResults.GetEnumerator() | Where-Object { $_.Value -eq "FAILED" }) {
        Write-Host "  - $($test.Key)" -ForegroundColor Red
    }
    
    Write-Host "`nVerifique:" -ForegroundColor Yellow
    Write-Host "  - docker-compose ps" -ForegroundColor White
    Write-Host "  - docker-compose logs" -ForegroundColor White
    Write-Host "  - docs/run/troubleshooting.md" -ForegroundColor White
    
    exit 1
}
