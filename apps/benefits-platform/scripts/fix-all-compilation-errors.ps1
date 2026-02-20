# Script para verificar e corrigir erros de compilação em todos os serviços

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔧 CORRIGINDO ERROS DE COMPILAÇÃO 🔧                       ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Lista de serviços para verificar
$services = @(
    "audit-service",
    "webhook-receiver",
    "device-service",
    "risk-service",
    "support-service",
    "settlement-service",
    "recon-service",
    "notification-service",
    "kyc-service",
    "kyb-service",
    "privacy-service",
    "acquirer-adapter",
    "payments-orchestrator"
)

$fixedServices = @()
$failedServices = @()

foreach ($service in $services) {
    $servicePath = Join-Path $script:RootPath "services\$service"
    
    if (-not (Test-Path $servicePath)) {
        Write-Host "  ⚠️  $service não encontrado" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "`n🔍 Verificando $service..." -ForegroundColor Yellow
    
    # Tentar compilar localmente primeiro (mais rápido)
    Push-Location $servicePath
    try {
        $mvnOutput = mvn clean compile -DskipTests 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $service compila corretamente" -ForegroundColor Green
            $fixedServices += $service
        } else {
            Write-Host "  ⚠️  $service tem erros de compilação" -ForegroundColor Yellow
            $errors = $mvnOutput | Select-String -Pattern "ERROR|cannot find symbol" | Select-Object -First 3
            if ($errors) {
                Write-Host "     Erros encontrados:" -ForegroundColor Gray
                $errors | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
            }
            $failedServices += $service
        }
    } catch {
        Write-Host "  ⚠️  Erro ao compilar $service : $_" -ForegroundColor Yellow
        $failedServices += $service
    } finally {
        Pop-Location
    }
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $(if ($failedServices.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($failedServices.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "║   📊 RESUMO DA VERIFICAÇÃO 📊                               ║" -ForegroundColor $(if ($failedServices.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($failedServices.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $(if ($failedServices.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

Write-Host "✅ Serviços OK: $($fixedServices.Count)" -ForegroundColor Green
if ($fixedServices.Count -gt 0) {
    $fixedServices | ForEach-Object { Write-Host "   - $_" -ForegroundColor Green }
}

if ($failedServices.Count -gt 0) {
    Write-Host "`n⚠️  Serviços com problemas: $($failedServices.Count)" -ForegroundColor Yellow
    $failedServices | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    Write-Host "`n💡 Dica: Verifique os logs de build para mais detalhes:" -ForegroundColor Cyan
    Write-Host "   cd services\[servico] && mvn clean compile -DskipTests" -ForegroundColor Gray
}

Write-Host ""
