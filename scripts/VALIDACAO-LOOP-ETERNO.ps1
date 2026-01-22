# ================================================================
# VALIDAÇÃO COMPLETA DO SISTEMA - LOOP ETERNO
# ================================================================
# Este script roda todos os testes e validações em loop até ser parado
# Valida: Docker, Compilação, Seeds, APIs, Integração, E2E

param(
    [int]$LoopMinutes = 360,  # Rodar por 360 minutos (6 horas)
    [int]$DelayBetweenLoops = 60  # Delay em segundos entre cada loop completo
)

$ErrorActionPreference = "Continue"
$startTime = Get-Date
$endTime = $startTime.AddMinutes($LoopMinutes)
$loopCount = 0

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "INICIANDO VALIDAÇÃO COMPLETA EM LOOP" -ForegroundColor Cyan
Write-Host "Início: $startTime" -ForegroundColor Cyan
Write-Host "Término previsto: $endTime" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

function Write-Section {
    param([string]$Title)
    Write-Host "`n=====================================================================" -ForegroundColor Yellow
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Test-DockerServices {
    Write-Section "VALIDANDO DOCKER SERVICES"
    
    try {
        $services = docker ps --format "{{.Names}}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Failure "Docker não está rodando"
            return $false
        }
        
        $requiredServices = @(
            "benefits-postgres",
            "benefits-keycloak",
            "benefits-core",
            "benefits-user-bff",
            "benefits-admin-bff",
            "benefits-merchant-bff",
            "benefits-employer-bff"
        )
        
        $allRunning = $true
        foreach ($service in $requiredServices) {
            if ($services -contains $service) {
                Write-Success "$service está rodando"
            } else {
                Write-Failure "$service NÃO está rodando"
                $allRunning = $false
            }
        }
        
        return $allRunning
    }
    catch {
        Write-Failure "Erro ao verificar serviços Docker: $_"
        return $false
    }
}

function Test-JavaCompilation {
    Write-Section "VALIDANDO COMPILAÇÃO JAVA"
    
    $services = @(
        "services/benefits-core",
        "services/user-bff",
        "services/admin-bff",
        "services/merchant-bff",
        "services/employer-bff",
        "services/notification-service",
        "services/risk-service",
        "services/support-service",
        "services/privacy-service",
        "services/webhook-receiver"
    )
    
    $allCompiled = $true
    foreach ($service in $services) {
        $servicePath = Join-Path $PSScriptRoot "..\$service"
        if (Test-Path $servicePath) {
            Write-Info "Compilando $service..."
            Push-Location $servicePath
            
            $output = mvn clean compile -DskipTests 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "$service compilado com sucesso"
            } else {
                Write-Failure "$service falhou na compilação"
                Write-Host $output -ForegroundColor Red
                $allCompiled = $false
            }
            
            Pop-Location
        } else {
            Write-Failure "Serviço $service não encontrado"
            $allCompiled = $false
        }
    }
    
    return $allCompiled
}

function Test-HealthEndpoints {
    Write-Section "VALIDANDO HEALTH ENDPOINTS"
    
    $endpoints = @(
        @{ Name = "Benefits Core"; Url = "http://localhost:8091/actuator/health" },
        @{ Name = "User BFF"; Url = "http://localhost:8080/actuator/health" },
        @{ Name = "Admin BFF"; Url = "http://localhost:8083/actuator/health" },
        @{ Name = "Merchant BFF"; Url = "http://localhost:8084/actuator/health" },
        @{ Name = "Employer BFF"; Url = "http://localhost:8086/actuator/health" },
        @{ Name = "Notification Service"; Url = "http://localhost:8100/actuator/health" },
        @{ Name = "Risk Service"; Url = "http://localhost:8094/actuator/health" },
        @{ Name = "Support Service"; Url = "http://localhost:8095/actuator/health" },
        @{ Name = "Privacy Service"; Url = "http://localhost:8103/actuator/health" }
    )
    
    $allHealthy = $true
    foreach ($endpoint in $endpoints) {
        try {
            $response = Invoke-RestMethod -Uri $endpoint.Url -Method Get -TimeoutSec 5
            if ($response.status -eq "UP") {
                Write-Success "$($endpoint.Name) está HEALTHY"
            } else {
                Write-Failure "$($endpoint.Name) status: $($response.status)"
                $allHealthy = $false
            }
        }
        catch {
            Write-Failure "$($endpoint.Name) não está respondendo"
            $allHealthy = $false
        }
    }
    
    return $allHealthy
}

function Test-DatabaseSeeds {
    Write-Section "VALIDANDO DATABASE SEEDS"
    
    try {
        # Test if tables exist and have data
        $queries = @(
            @{ Table = "tenants"; Expected = 2 },
            @{ Table = "users"; Expected = 5 },
            @{ Table = "wallets"; Expected = 10 },
            @{ Table = "cards"; Expected = 7 },
            @{ Table = "merchants"; Expected = 3 },
            @{ Table = "transactions"; Expected = 6 }
        )
        
        $allValid = $true
        foreach ($query in $queries) {
            $count = docker exec benefits-postgres psql -U benefits -d benefits -t -c "SELECT COUNT(*) FROM $($query.Table);" 2>&1
            if ($LASTEXITCODE -eq 0) {
                $count = [int]$count.Trim()
                if ($count -ge $query.Expected) {
                    Write-Success "Tabela $($query.Table): $count registros (esperado >= $($query.Expected))"
                } else {
                    Write-Failure "Tabela $($query.Table): $count registros (esperado >= $($query.Expected))"
                    $allValid = $false
                }
            } else {
                Write-Failure "Erro ao consultar tabela $($query.Table)"
                $allValid = $false
            }
        }
        
        return $allValid
    }
    catch {
        Write-Failure "Erro ao validar seeds: $_"
        return $false
    }
}

function Test-APIIntegration {
    Write-Section "VALIDANDO INTEGRAÇÃO DAS APIs"
    
    try {
        # Test User BFF -> Benefits Core integration
        Write-Info "Testando User BFF -> Benefits Core..."
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/users/user-001" -Method Get -TimeoutSec 10
        if ($response.id -eq "user-001") {
            Write-Success "User BFF está integrado com Benefits Core"
        } else {
            Write-Failure "User BFF integração falhou"
        }
        
        # Test Risk Service assessment
        Write-Info "Testando Risk Service..."
        $riskPayload = @{
            tenantId = "tenant-001"
            transactionId = "test-txn-001"
            userId = "user-001"
            merchantId = "merchant-001"
            amount = 100.0
            ipAddress = "192.168.1.1"
            deviceFingerprint = "test-device"
            location = "São Paulo"
        } | ConvertTo-Json
        
        $riskResponse = Invoke-RestMethod -Uri "http://localhost:8094/api/risk/assess" -Method Post -Body $riskPayload -ContentType "application/json" -TimeoutSec 10
        if ($riskResponse.riskScore -ne $null) {
            Write-Success "Risk Service está funcionando (Score: $($riskResponse.riskScore))"
        } else {
            Write-Failure "Risk Service falhou"
        }
        
        return $true
    }
    catch {
        Write-Failure "Erro na validação de integração: $_"
        return $false
    }
}

function Test-E2EFlows {
    Write-Section "VALIDANDO FLUXOS E2E"
    
    try {
        # E2E: Create Notification
        Write-Info "Testando fluxo de Notificação..."
        $notificationPayload = @{
            tenantId = "tenant-001"
            userId = "user-001"
            templateCode = "TRANSACTION_CONFIRMED"
            channel = "SMS"
            recipient = "+5511999990001"
            variables = @{
                amount = "100.00"
                merchant_name = "Test Merchant"
                balance = "1500.00"
            }
        } | ConvertTo-Json
        
        $notifResponse = Invoke-RestMethod -Uri "http://localhost:8100/api/notifications/send" -Method Post -Body $notificationPayload -ContentType "application/json" -TimeoutSec 10
        if ($notifResponse.status -eq "SENT") {
            Write-Success "Fluxo de Notificação funcionando"
        } else {
            Write-Failure "Fluxo de Notificação falhou"
        }
        
        # E2E: Create Support Ticket
        Write-Info "Testando fluxo de Support..."
        $ticketPayload = @{
            tenantId = "tenant-001"
            userId = "user-001"
            userName = "João Silva"
            userEmail = "joao.silva@alpha.com"
            subject = "Teste Automático"
            description = "Ticket criado por teste E2E"
            category = "TECHNICAL"
            priority = "MEDIUM"
        } | ConvertTo-Json
        
        $ticketResponse = Invoke-RestMethod -Uri "http://localhost:8095/api/support/tickets" -Method Post -Body $ticketPayload -ContentType "application/json" -TimeoutSec 10
        if ($ticketResponse.ticketNumber -like "TICK-*") {
            Write-Success "Fluxo de Support funcionando (Ticket: $($ticketResponse.ticketNumber))"
        } else {
            Write-Failure "Fluxo de Support falhou"
        }
        
        return $true
    }
    catch {
        Write-Failure "Erro na validação E2E: $_"
        return $false
    }
}

# ================================================================
# LOOP PRINCIPAL
# ================================================================

while ((Get-Date) -lt $endTime) {
    $loopCount++
    $currentTime = Get-Date
    $elapsedMinutes = [math]::Round(($currentTime - $startTime).TotalMinutes, 2)
    $remainingMinutes = [math]::Round(($endTime - $currentTime).TotalMinutes, 2)
    
    Write-Host "`n`n" -ForegroundColor Magenta
    Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║               LOOP #$loopCount - $currentTime               ║" -ForegroundColor Magenta
    Write-Host "║   Tempo decorrido: $elapsedMinutes min | Restante: $remainingMinutes min    ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    
    # Resultados do loop
    $results = @{
        Docker = Test-DockerServices
        Compilation = Test-JavaCompilation
        Health = Test-HealthEndpoints
        Seeds = Test-DatabaseSeeds
        Integration = Test-APIIntegration
        E2E = Test-E2EFlows
    }
    
    # Summary
    Write-Section "RESUMO DO LOOP #$loopCount"
    $totalTests = $results.Count
    $passedTests = ($results.Values | Where-Object { $_ -eq $true }).Count
    $failedTests = $totalTests - $passedTests
    
    Write-Host "Total de testes: $totalTests" -ForegroundColor White
    Write-Host "Passou: $passedTests" -ForegroundColor Green
    Write-Host "Falhou: $failedTests" -ForegroundColor Red
    
    if ($failedTests -eq 0) {
        Write-Host "`n🎉 TODOS OS TESTES PASSARAM! 🎉`n" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  ALGUNS TESTES FALHARAM ⚠️`n" -ForegroundColor Yellow
    }
    
    # Delay antes do próximo loop
    if ((Get-Date) -lt $endTime) {
        Write-Info "Aguardando $DelayBetweenLoops segundos até próximo loop..."
        Start-Sleep -Seconds $DelayBetweenLoops
    }
}

Write-Host "`n`n=====================================================================" -ForegroundColor Cyan
Write-Host "VALIDAÇÃO COMPLETA FINALIZADA" -ForegroundColor Cyan
Write-Host "Total de loops executados: $loopCount" -ForegroundColor Cyan
Write-Host "Tempo total: $([math]::Round(((Get-Date) - $startTime).TotalMinutes, 2)) minutos" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
