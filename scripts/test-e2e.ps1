# Script de Teste End-to-End
Write-Host "=== Teste End-to-End do Sistema Benefits ===" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$allTestsPassed = $true

# Função para testar endpoint
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [string]$Description
    )
    
    Write-Host "[TEST] $Description" -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    
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
            Write-Host "  ✓ Sucesso (Status: $($response.StatusCode))" -ForegroundColor Green
            if ($response.Content) {
                try {
                    $json = $response.Content | ConvertFrom-Json
                    Write-Host "  Resposta: $($json | ConvertTo-Json -Compress)" -ForegroundColor Gray
                } catch {
                    Write-Host "  Resposta: $($response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)))..." -ForegroundColor Gray
                }
            }
            return $true
        } else {
            Write-Host "  ✗ Falhou (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 1. Verificar serviços Docker
Write-Host "=== [1/6] Verificando Serviços Docker ===" -ForegroundColor Cyan
$services = @("benefits-postgres", "benefits-keycloak", "benefits-user-bff")
foreach ($service in $services) {
    $container = docker ps --filter "name=$service" --format "{{.Names}}" 2>$null
    if ($container -eq $service) {
        Write-Host "  ✓ $service está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $service não está rodando" -ForegroundColor Red
        $allTestsPassed = $false
    }
}

# 2. Testar PostgreSQL
Write-Host "`n=== [2/6] Testando PostgreSQL ===" -ForegroundColor Cyan
$pgReady = docker exec benefits-postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ PostgreSQL está pronto" -ForegroundColor Green
} else {
    Write-Host "  ✗ PostgreSQL não está pronto" -ForegroundColor Red
    $allTestsPassed = $false
}

# 3. Testar Keycloak
Write-Host "`n=== [3/6] Testando Keycloak ===" -ForegroundColor Cyan

# Aguardar Keycloak estar pronto
Write-Host "  Aguardando Keycloak iniciar..." -ForegroundColor Yellow
$keycloakReady = $false
for ($i = 0; $i -lt 30; $i++) {
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

if ($keycloakReady) {
    Write-Host "  ✓ Keycloak está pronto" -ForegroundColor Green
    
    # Testar endpoint raiz
    Test-Endpoint -Url "http://localhost:8081" -Description "Keycloak - Endpoint raiz" | Out-Null
    
    # Testar health
    Test-Endpoint -Url "http://localhost:8081/health/started" -Description "Keycloak - Health started" | Out-Null
} else {
    Write-Host "  ✗ Keycloak não está pronto (aguardou 60s)" -ForegroundColor Red
    Write-Host "  Verifique os logs: docker-compose logs keycloak" -ForegroundColor Yellow
    $allTestsPassed = $false
}

# 4. Obter Token do Keycloak
Write-Host "`n=== [4/6] Obtendo Token do Keycloak ===" -ForegroundColor Cyan
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
    
    Write-Host "  Fazendo login como user1..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
    
    if ($response.access_token) {
        $token = $response.access_token
        Write-Host "  ✓ Token obtido com sucesso" -ForegroundColor Green
        Write-Host "  Token (primeiros 50 chars): $($token.Substring(0, 50))..." -ForegroundColor Gray
    } else {
        Write-Host "  ✗ Não foi possível obter token" -ForegroundColor Red
        $allTestsPassed = $false
    }
} catch {
    Write-Host "  ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
    $allTestsPassed = $false
}

# 5. Testar User BFF (sem autenticação)
Write-Host "`n=== [5/6] Testando User BFF (Endpoints Públicos) ===" -ForegroundColor Cyan

# Aguardar BFF estar pronto
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
    Write-Host "  ✓ User BFF está pronto" -ForegroundColor Green
    
    # Testar health
    Test-Endpoint -Url "http://localhost:8080/actuator/health" -Description "User BFF - Health check" | Out-Null
    
    # Testar config (sem auth)
    $result = Test-Endpoint -Url "http://localhost:8080/app/config" -Description "User BFF - App Config (sem auth)"
    if (-not $result) { $allTestsPassed = $false }
} else {
    Write-Host "  ✗ User BFF não está pronto (aguardou 40s)" -ForegroundColor Red
    Write-Host "  Verifique os logs: docker-compose logs user-bff" -ForegroundColor Yellow
    $allTestsPassed = $false
}

# 6. Testar User BFF (com autenticação)
Write-Host "`n=== [6/6] Testando User BFF (Endpoints Autenticados) ===" -ForegroundColor Cyan

if ($token) {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # Testar /me
    $result = Test-Endpoint -Url "http://localhost:8080/me" -Headers $headers -Description "User BFF - GET /me"
    if (-not $result) { $allTestsPassed = $false }
    
    # Testar /wallets/summary
    $result = Test-Endpoint -Url "http://localhost:8080/wallets/summary" -Headers $headers -Description "User BFF - GET /wallets/summary"
    if (-not $result) { $allTestsPassed = $false }
    
    # Testar /transactions
    $result = Test-Endpoint -Url "http://localhost:8080/transactions?limit=10" -Headers $headers -Description "User BFF - GET /transactions"
    if (-not $result) { $allTestsPassed = $false }
    
    # Testar /dev/transactions/generate (dev only)
    Write-Host "`n[TEST] Gerando 10 transações de teste..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/dev/transactions/generate?count=10" -Method Post -Headers $headers -ErrorAction Stop
        Write-Host "  ✓ Transações geradas: $($response.generated)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Erro ao gerar transações: $($_.Exception.Message)" -ForegroundColor Red
        $allTestsPassed = $false
    }
    
    # Testar /transactions novamente (deve ter dados agora)
    $result = Test-Endpoint -Url "http://localhost:8080/transactions?limit=5" -Headers $headers -Description "User BFF - GET /transactions (com dados)"
    if (-not $result) { $allTestsPassed = $false }
} else {
    Write-Host "  ⚠ Pulando testes autenticados (token não disponível)" -ForegroundColor Yellow
    $allTestsPassed = $false
}

# Resumo Final
Write-Host "`n=== Resumo do Teste ===" -ForegroundColor Cyan
if ($allTestsPassed) {
    Write-Host "✓ Todos os testes passaram!" -ForegroundColor Green
    Write-Host "`nSistema está pronto para uso:" -ForegroundColor Green
    Write-Host "  - Keycloak: http://localhost:8081" -ForegroundColor White
    Write-Host "  - Keycloak Admin: http://localhost:8081/admin (admin/admin)" -ForegroundColor White
    Write-Host "  - User BFF: http://localhost:8080" -ForegroundColor White
    Write-Host "  - User BFF Health: http://localhost:8080/actuator/health" -ForegroundColor White
    Write-Host "`nPróximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Testar o app Flutter" -ForegroundColor White
    Write-Host "  2. Executar testes de carga com k6" -ForegroundColor White
    exit 0
} else {
    Write-Host "✗ Alguns testes falharam" -ForegroundColor Red
    Write-Host "`nVerifique:" -ForegroundColor Yellow
    Write-Host "  - docker-compose ps" -ForegroundColor White
    Write-Host "  - docker-compose logs" -ForegroundColor White
    exit 1
}
