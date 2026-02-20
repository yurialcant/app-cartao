# start-ops-relay.ps1
# Script para iniciar ops-relay service
# Executar: .\scripts\start-ops-relay.ps1

param(
    [switch]$NoWait,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🚀 [ops-relay] Iniciando ops-relay service..." -ForegroundColor Cyan

# Verificar infraestrutura
Write-Host "`n🔍 Verificando infraestrutura..." -ForegroundColor Yellow

# Verificar Postgres
$pgRunning = docker ps --filter "name=benefits-postgres" --filter "status=running" --format "{{.Names}}"
if (-not $pgRunning) {
    Write-Host "   ❌ Postgres não está rodando. Execute .\scripts\up.ps1 primeiro" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ Postgres OK" -ForegroundColor Green

# Verificar LocalStack
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ LocalStack OK" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  LocalStack não está respondendo corretamente" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  LocalStack não está rodando. Execute .\scripts\up.ps1 e .\scripts\setup-localstack.ps1" -ForegroundColor Yellow
}

# Verificar porta 8095
Write-Host "`n🔍 Verificando porta 8095..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 8095 -ErrorAction SilentlyContinue
if ($portInUse) {
    if ($Force) {
        Write-Host "   ⚠️  Porta 8095 em uso. Matando processo..." -ForegroundColor Yellow
        $process = Get-Process -Id $portInUse.OwningProcess -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Host "   ❌ Porta 8095 já está em uso. Use -Force para matar o processo existente" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ✅ Porta 8095 disponível" -ForegroundColor Green
}

# Compilar ops-relay
Write-Host "`n🔨 Compilando ops-relay..." -ForegroundColor Yellow
try {
    Push-Location $ProjectRoot
    & mvn -pl services/ops-relay clean compile -q -T 4
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Compilação OK" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erro na compilação" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Erro na compilação: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# Criar diretório de logs
$logDir = Join-Path $ProjectRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
$logFile = Join-Path $logDir "ops-relay.log"

# Iniciar ops-relay em background
Write-Host "`n🚀 Iniciando ops-relay na porta 8095..." -ForegroundColor Yellow
try {
    Push-Location "$ProjectRoot\services\ops-relay"
    
    $job = Start-Job -ScriptBlock {
        param($projectRoot, $logFile)
        Set-Location "$projectRoot\services\ops-relay"
        & mvn spring-boot:run -q 2>&1 | Tee-Object -FilePath $logFile
    } -ArgumentList $ProjectRoot, $logFile
    
    Write-Host "   ✅ ops-relay iniciado (Job ID: $($job.Id))" -ForegroundColor Green
    Write-Host "   📝 Logs: $logFile" -ForegroundColor Gray
    
    # Aguardar inicialização
    if (-not $NoWait) {
        Write-Host "`n⏳ Aguardando inicialização (20s)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 20
        
        # Verificar health
        Write-Host "`n🔍 Verificando health..." -ForegroundColor Yellow
        $maxRetries = 10
        $retryCount = 0
        $healthy = $false
        
        while ($retryCount -lt $maxRetries -and -not $healthy) {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8095/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
                if ($response.StatusCode -eq 200) {
                    $health = $response.Content | ConvertFrom-Json
                    if ($health.status -eq "UP") {
                        $healthy = $true
                        Write-Host "   ✅ ops-relay está saudável" -ForegroundColor Green
                    }
                }
            } catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Host "   ⏳ Aguardando... ($retryCount/$maxRetries)" -ForegroundColor Gray
                    Start-Sleep -Seconds 3
                }
            }
        }
        
        if (-not $healthy) {
            Write-Host "   ⚠️  ops-relay pode não estar totalmente inicializado. Verifique os logs: $logFile" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Erro ao iniciar ops-relay: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host "`n🎯 ops-relay iniciado!" -ForegroundColor Green
Write-Host "`n📋 Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Ver logs: Get-Content $logFile -Tail 50 -Wait" -ForegroundColor Gray
Write-Host "   Health: Invoke-WebRequest http://localhost:8095/actuator/health" -ForegroundColor Gray
Write-Host "   DLQ Stats: Invoke-WebRequest http://localhost:8095/api/v1/dlq/stats" -ForegroundColor Gray
Write-Host "   Parar: Stop-Job -Id $($job.Id); Remove-Job -Id $($job.Id)" -ForegroundColor Gray

if (-not $NoWait) {
    Write-Host "`n✅ ops-relay pronto para uso!" -ForegroundColor Green
}
