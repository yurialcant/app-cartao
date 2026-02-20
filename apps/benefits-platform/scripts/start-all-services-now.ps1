# Script para iniciar todos os serviços que compilam corretamente

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🚀 INICIANDO TODOS OS SERVIÇOS 🚀                         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Push-Location (Join-Path $script:RootPath "infra")

# Serviços principais (críticos)
Write-Host "📋 Iniciando serviços principais..." -ForegroundColor Yellow
docker-compose up -d postgres keycloak benefits-core user-bff admin-bff merchant-bff merchant-portal-bff localstack 2>&1 | Out-Null

Write-Host "  ✅ Serviços principais iniciados" -ForegroundColor Green

# Aguardar serviços principais iniciarem
Write-Host "  ⏳ Aguardando serviços principais (30 segundos)..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Serviços especializados que compilam corretamente
Write-Host "`n📋 Iniciando serviços especializados..." -ForegroundColor Yellow
$specializedServices = @(
    "payments-orchestrator",
    "acquirer-stub",
    "webhook-receiver",
    "audit-service",
    "support-service",
    "risk-service"
)

foreach ($service in $specializedServices) {
    Write-Host "  🔄 Iniciando $service..." -ForegroundColor Gray
    docker-compose up -d $service 2>&1 | Out-Null
}

Write-Host "  ✅ Serviços especializados iniciados" -ForegroundColor Green

# Aguardar mais um pouco
Write-Host "  ⏳ Aguardando serviços especializados (20 segundos)..." -ForegroundColor Gray
Start-Sleep -Seconds 20

# Verificar status
Write-Host "`n📊 Status dos serviços:" -ForegroundColor Cyan
docker-compose ps --format "table {{.Name}}\t{{.Status}}" | Select-Object -First 20

# Verificar saúde dos principais
Write-Host "`n🔍 Verificando saúde dos serviços principais..." -ForegroundColor Cyan
$services = @(
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"}
)

$healthy = 0
foreach ($svc in $services) {
    try {
        $r = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($r.StatusCode -eq 200) {
            Write-Host "  ✅ $($svc.Name) - Saudável" -ForegroundColor Green
            $healthy++
        }
    } catch {
        Write-Host "  ⚠️  $($svc.Name) - Aguardando..." -ForegroundColor Yellow
    }
}

Write-Host "`n✅ $healthy/$($services.Count) serviços principais saudáveis" -ForegroundColor $(if ($healthy -eq $services.Count) { "Green" } else { "Yellow" })

Pop-Location

Write-Host "`n🚀 Próximo passo: Iniciar apps frontend!" -ForegroundColor Cyan
Write-Host "  Ver instruções em: docs\RUN-E2E-COMPLETO-GUIA.md" -ForegroundColor Gray
Write-Host ""
