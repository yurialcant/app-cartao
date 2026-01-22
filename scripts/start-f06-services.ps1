# start-f06-services.ps1 - Inicia serviços para testar F06 POS Authorize
# Executar: .\scripts\start-f06-services.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🚀 [F06] Iniciando serviços para teste F06 POS Authorize..." -ForegroundColor Cyan

# Verificar infraestrutura
Write-Host "`n🔍 [F06] Verificando infraestrutura..." -ForegroundColor Yellow
$pgRunning = docker ps --filter "name=benefits-postgres" --filter "status=running" --format "{{.Names}}"

if (-not $pgRunning) {
    Write-Host "   ❌ Postgres não está rodando. Execute .\scripts\up.ps1 primeiro" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Infraestrutura OK" -ForegroundColor Green

# Compilar serviços
Write-Host "`n🔨 [F06] Compilando serviços..." -ForegroundColor Yellow
try {
    Push-Location $ProjectRoot
    & mvn compile -q -T 4
    Write-Host "   ✅ Compilação OK" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro na compilação: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# Iniciar benefits-core
Write-Host "`n🏦 [F06] Iniciando benefits-core..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\start-benefits-core.ps1"
    Start-Sleep -Seconds 5  # Aguardar inicialização

    # Verificar se está respondendo
    $response = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits" -Headers @{ "X-Tenant-Id" = "550e8400-e29b-41d4-a716-446655440000" } -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ benefits-core OK (porta 8091)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ benefits-core não respondeu corretamente" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Erro ao iniciar benefits-core: $_" -ForegroundColor Red
    exit 1
}

# Iniciar pos-bff
Write-Host "`n📱 [F06] Iniciando pos-bff..." -ForegroundColor Yellow
try {
    # Compilar e iniciar pos-bff
    Push-Location "$ProjectRoot\bffs\pos-bff"
    & mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8086" -q > "$ProjectRoot\logs\f06-pos-bff.log" 2>&1 &
    $posBffJob = $LASTEXITCODE

    Start-Sleep -Seconds 10  # Aguardar inicialização

    # Verificar se está respondendo
    $response = Invoke-WebRequest -Uri "http://localhost:8086/api/v1/pos/test" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ pos-bff OK (porta 8086)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ pos-bff não respondeu corretamente" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Erro ao iniciar pos-bff: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host "`n🎯 [F06] Serviços prontos para testes!" -ForegroundColor Green
Write-Host "`n📋 Comandos úteis:" -ForegroundColor Cyan
Write-Host "   Testar: .\scripts\smoke.ps1" -ForegroundColor Gray
Write-Host "   Logs benefits-core: Receive-Job -Id <job-id>" -ForegroundColor Gray
Write-Host "   Logs pos-bff: Get-Content .\logs\f06-pos-bff.log -Tail 50" -ForegroundColor Gray
Write-Host "   Parar: .\scripts\stop-f06-services.ps1" -ForegroundColor Gray

Write-Host "`n🚀 Execute .\scripts\smoke.ps1 para testar F06!" -ForegroundColor Green