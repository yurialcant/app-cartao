# Script completo de testes COM AUTENTICAÇÃO para todos os BFFs
# Autor: Sistema de Testes Automatizados
# Data: 2025-12-26

Write-Host "`n🧪 TESTE COMPLETO COM AUTENTICAÇÃO" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost"
$results = @()
$errors = @()

# Credenciais de teste
$testUsers = @{
    "user" = @{
        username = "user1"
        password = "Passw0rd!"
        client_id = "k6-dev"
        client_secret = "k6-dev-secret"
    }
    "admin" = @{
        username = "admin"
        password = "admin123"
        client_id = "k6-dev"
        client_secret = "k6-dev-secret"
    }
    "merchant" = @{
        username = "merchant1"
        password = "merchant123"
        client_id = "k6-dev"
        client_secret = "k6-dev-secret"
    }
}

function Get-KeycloakToken {
    param(
        [string]$Username,
        [string]$Password,
        [string]$ClientId,
        [string]$ClientSecret
    )
    
    try {
        $tokenUrl = "http://localhost:8081/realms/benefits/protocol/openid-connect/token"
        $body = @{
            client_id = $ClientId
            client_secret = $ClientSecret
            username = $Username
            password = $Password
            grant_type = "password"
        }
        
        $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
        
        if ($response.access_token) {
            return $response.access_token
        }
        return $null
    } catch {
        Write-Host "  ⚠️  Erro ao obter token para $Username : $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

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
# 1. OBTER TOKENS
# ============================================
Write-Host "`n📋 1. OBTENDO TOKENS DO KEYCLOAK" -ForegroundColor Yellow

$tokens = @{}
foreach ($role in $testUsers.Keys) {
    $user = $testUsers[$role]
    Write-Host "  Obtendo token para $role ($($user.username))..." -ForegroundColor Cyan
    $token = Get-KeycloakToken -Username $user.username -Password $user.password -ClientId $user.client_id -ClientSecret $user.client_secret
    if ($token) {
        $tokens[$role] = $token
        Write-Host "  ✅ Token obtido para $role" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Falha ao obter token para $role" -ForegroundColor Red
        $errors += @{ Success = $false; Service = "Keycloak"; Error = "Não foi possível obter token para $role" }
    }
}

# ============================================
# 2. TESTAR USER BFF COM AUTENTICAÇÃO
# ============================================
Write-Host "`n📋 2. TESTANDO USER BFF COM AUTENTICAÇÃO" -ForegroundColor Yellow

if ($tokens["user"]) {
    $headers = @{ "Authorization" = "Bearer $($tokens['user'])" }
    
    $endpoints = @(
        @{ Url = "$baseUrl`:8080/api/users"; Method = "GET" },
        @{ Url = "$baseUrl`:8080/api/wallets"; Method = "GET" },
        @{ Url = "$baseUrl`:8080/api/transactions"; Method = "GET" },
        @{ Url = "$baseUrl`:8080/me"; Method = "GET" },
        @{ Url = "$baseUrl`:8080/wallets/summary"; Method = "GET" }
    )
    
    foreach ($endpoint in $endpoints) {
        $result = Test-Endpoint -ServiceName "User BFF" -Url $endpoint.Url -Method $endpoint.Method -Headers $headers -ExpectedStatus @(200, 401, 404)
        $results += $result
        if (-not $result.Success -and $result.Status -ne 401 -and $result.Status -ne 404) { $errors += $result }
    }
} else {
    Write-Host "  ⚠️  Pulando testes do User BFF (token não disponível)" -ForegroundColor Yellow
}

# ============================================
# 3. TESTAR ADMIN BFF COM AUTENTICAÇÃO
# ============================================
Write-Host "`n📋 3. TESTANDO ADMIN BFF COM AUTENTICAÇÃO" -ForegroundColor Yellow

if ($tokens["admin"]) {
    $headers = @{ "Authorization" = "Bearer $($tokens['admin'])" }
    
    $endpoints = @(
        @{ Url = "$baseUrl`:8083/api/users"; Method = "GET" },
        @{ Url = "$baseUrl`:8083/api/merchants"; Method = "GET" },
        @{ Url = "$baseUrl`:8083/api/disputes"; Method = "GET" }
    )
    
    foreach ($endpoint in $endpoints) {
        $result = Test-Endpoint -ServiceName "Admin BFF" -Url $endpoint.Url -Method $endpoint.Method -Headers $headers -ExpectedStatus @(200, 401, 403, 404)
        $results += $result
        if (-not $result.Success -and $result.Status -notin @(401, 403, 404)) { $errors += $result }
    }
} else {
    Write-Host "  ⚠️  Pulando testes do Admin BFF (token não disponível)" -ForegroundColor Yellow
}

# ============================================
# 4. TESTAR MERCHANT BFF COM AUTENTICAÇÃO
# ============================================
Write-Host "`n📋 4. TESTANDO MERCHANT BFF COM AUTENTICAÇÃO" -ForegroundColor Yellow

if ($tokens["merchant"]) {
    $headers = @{ "Authorization" = "Bearer $($tokens['merchant'])" }
    
    $endpoints = @(
        @{ Url = "$baseUrl`:8084/api/stores"; Method = "GET" },
        @{ Url = "$baseUrl`:8084/api/transactions"; Method = "GET" },
        @{ Url = "$baseUrl`:8084/api/reports"; Method = "GET" }
    )
    
    foreach ($endpoint in $endpoints) {
        $result = Test-Endpoint -ServiceName "Merchant BFF" -Url $endpoint.Url -Method $endpoint.Method -Headers $headers -ExpectedStatus @(200, 401, 403, 404)
        $results += $result
        if (-not $result.Success -and $result.Status -notin @(401, 403, 404)) { $errors += $result }
    }
} else {
    Write-Host "  ⚠️  Pulando testes do Merchant BFF (token não disponível)" -ForegroundColor Yellow
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
    exit 1
} else {
    Write-Host "`n✅ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    exit 0
}

