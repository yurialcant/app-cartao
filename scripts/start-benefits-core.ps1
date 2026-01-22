# Script para iniciar benefits-core manualmente
# Uso: .\scripts\start-benefits-core.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🚀 [BENEFITS-CORE] Iniciando benefits-core..." -ForegroundColor Cyan

# Verificar se Maven está disponível
try {
    $mvnVersion = mvn -version 2>&1 | Select-Object -First 1
    Write-Host "✓ Maven encontrado: $mvnVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Maven não encontrado! Instale Maven e tente novamente." -ForegroundColor Red
    exit 1
}

# Verificar se Postgres está rodando
Write-Host "`n🔍 Verificando infraestrutura..." -ForegroundColor Yellow
$pgRunning = docker ps --filter "name=benefits-postgres" --format "{{.Names}}" 2>$null
if (-not $pgRunning) {
    Write-Host "⚠️  Postgres não está rodando!" -ForegroundColor Yellow
    Write-Host "   Execute primeiro: .\scripts\up.ps1" -ForegroundColor Gray
    Write-Host "   Ou: cd infra && docker-compose up -d postgres" -ForegroundColor Gray
} else {
    Write-Host "✓ Postgres está rodando" -ForegroundColor Green
}

# Verificar se porta 8091 está livre
Write-Host "`n🔍 Verificando porta 8091..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 8091 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "⚠️  Porta 8091 já está em uso!" -ForegroundColor Yellow
    Write-Host "   Processo: $($portInUse.OwningProcess)" -ForegroundColor Gray
    Write-Host "   Execute: Stop-Process -Id $($portInUse.OwningProcess) -Force" -ForegroundColor Gray
    $continue = Read-Host "   Deseja continuar mesmo assim? (s/N)"
    if ($continue -ne "s" -and $continue -ne "S") {
        exit 1
    }
} else {
    Write-Host "✓ Porta 8091 está livre" -ForegroundColor Green
}

# Compilar se necessário
Write-Host "`n🔨 Compilando benefits-core..." -ForegroundColor Yellow
Push-Location $ProjectRoot
mvn -pl services/benefits-core clean compile -DskipTests 2>&1 | Tee-Object -Variable compileOutput | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Erro na compilação!" -ForegroundColor Red
    Write-Host $compileOutput -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✓ Compilação concluída" -ForegroundColor Green

# Iniciar benefits-core
Write-Host "`n🚀 Iniciando benefits-core na porta 8091..." -ForegroundColor Cyan
Write-Host "   URL: http://localhost:8091" -ForegroundColor Gray
Write-Host "   Health: http://localhost:8091/actuator/health" -ForegroundColor Gray
Write-Host "   Para parar: Ctrl+C" -ForegroundColor Gray
Write-Host ""

# Salvar PID para referência futura
$pidFile = Join-Path $ProjectRoot "logs\2026-01-18\0015\benefits-core.pid"
$pidDir = Split-Path $pidFile -Parent
if (-not (Test-Path $pidDir)) {
    New-Item -ItemType Directory -Force -Path $pidDir | Out-Null
}

# Iniciar em background e salvar PID
$job = Start-Job -ScriptBlock {
    param($projectRoot)
    Set-Location $projectRoot
    mvn -pl services/benefits-core spring-boot:run 2>&1
} -ArgumentList $ProjectRoot

$job.Id | Out-File -FilePath $pidFile -Encoding utf8
Write-Host "✓ benefits-core iniciado (Job ID: $($job.Id))" -ForegroundColor Green
Write-Host "   PID salvo em: $pidFile" -ForegroundColor Gray

# Aguardar alguns segundos e verificar se iniciou
Write-Host "`n⏳ Aguardando benefits-core iniciar (15 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar health
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "✓ benefits-core está saudável!" -ForegroundColor Green
        Write-Host "   Status: $($healthResponse.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  benefits-core ainda não está respondendo" -ForegroundColor Yellow
    Write-Host "   Aguarde mais alguns segundos e verifique: http://localhost:8091/actuator/health" -ForegroundColor Gray
    Write-Host "   Logs do job: Receive-Job -Id $($job.Id)" -ForegroundColor Gray
}

Write-Host "`n📋 Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Ver logs: Receive-Job -Id $($job.Id)" -ForegroundColor Gray
Write-Host "   Parar: Stop-Job -Id $($job.Id); Remove-Job -Id $($job.Id)" -ForegroundColor Gray
Write-Host "   Health check: Invoke-WebRequest http://localhost:8091/actuator/health" -ForegroundColor Gray

Pop-Location
