# Script de validação completa do sistema E2E

$ErrorActionPreference = "Continue"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔍 VALIDAÇÃO COMPLETA DO SISTEMA E2E 🔍                   ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================
# BACKEND SERVICES
# ============================================

Write-Host "📊 BACKEND SERVICES:" -ForegroundColor Yellow
$backendServices = @(
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"; Port=8080},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"; Port=8083},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"; Port=8091},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"; Port=8084},
    @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits/.well-known/openid-configuration"; Port=8081}
)

$backendHealthy = 0
foreach ($svc in $backendServices) {
    try {
        $r = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($r.StatusCode -eq 200) {
            Write-Host "  ✅ $($svc.Name) (porta $($svc.Port)) - Saudável" -ForegroundColor Green
            $backendHealthy++
        }
    } catch {
        Write-Host "  ⚠️  $($svc.Name) (porta $($svc.Port)) - Não responde" -ForegroundColor Yellow
    }
}

Write-Host "`n  Status Backend: $backendHealthy/$($backendServices.Count) serviços saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })

# ============================================
# FRONTEND APPS
# ============================================

Write-Host "`n🌐 FRONTEND APPS:" -ForegroundColor Yellow
$frontendApps = @(
    @{Name="Admin Angular"; Url="http://localhost:4200"; Port=4200},
    @{Name="Merchant Portal"; Url="http://localhost:4201"; Port=4201}
)

$frontendHealthy = 0
foreach ($app in $frontendApps) {
    try {
        $r = Invoke-WebRequest -Uri $app.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Host "  ✅ $($app.Name) (porta $($app.Port)) - Respondendo" -ForegroundColor Green
        $frontendHealthy++
    } catch {
        Write-Host "  ⏳ $($app.Name) (porta $($app.Port)) - Ainda compilando..." -ForegroundColor Yellow
    }
}

Write-Host "`n  Status Frontend: $frontendHealthy/$($frontendApps.Count) apps respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })

# ============================================
# FLUTTER DEVICES
# ============================================

Write-Host "`n📱 FLUTTER DEVICES:" -ForegroundColor Yellow
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $devicesOutput = flutter devices 2>&1
    $deviceLines = $devicesOutput | Select-String -Pattern "device|emulator|connected" -CaseSensitive:$false
    
    if ($deviceLines -and ($deviceLines.Count -gt 0)) {
        Write-Host "  ✅ Dispositivos encontrados:" -ForegroundColor Green
        $deviceLines | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
    } else {
        Write-Host "  ⚠️  Nenhum dispositivo Android conectado" -ForegroundColor Yellow
        Write-Host "     Para conectar:" -ForegroundColor Gray
        Write-Host "     - Conecte dispositivo via USB e ative USB Debugging" -ForegroundColor Gray
        Write-Host "     - Ou inicie um emulador Android" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠️  Flutter não encontrado no PATH" -ForegroundColor Yellow
}

# ============================================
# DOCKER CONTAINERS
# ============================================

Write-Host "`n🐳 DOCKER CONTAINERS:" -ForegroundColor Yellow
Push-Location (Join-Path $script:RootPath "infra")
$containers = docker-compose ps --format "table {{.Name}}\t{{.Status}}" 2>&1
if ($LASTEXITCODE -eq 0) {
    $containerLines = $containers | Select-Object -First 15
    $containerLines | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "  ⚠️  Erro ao verificar containers Docker" -ForegroundColor Yellow
}
Pop-Location

# ============================================
# RESUMO FINAL
# ============================================

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -gt 0) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -gt 0) { "Green" } else { "Yellow" })
Write-Host "║   📊 RESUMO DA VALIDAÇÃO 📊                                 ║" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -gt 0) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -gt 0) { "Green" } else { "Yellow" })
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -gt 0) { "Green" } else { "Yellow" })

Write-Host "`n✅ Backend: $backendHealthy/$($backendServices.Count) serviços saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
Write-Host "✅ Frontend: $frontendHealthy/$($frontendApps.Count) apps respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })

if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -gt 0) {
    Write-Host "`n🎉 SISTEMA PRONTO PARA TESTES E2E!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🧪 TESTAR AGORA:" -ForegroundColor Cyan
    Write-Host "  1. Abra http://localhost:4200 no navegador" -ForegroundColor White
    Write-Host "  2. Login: admin / admin123" -ForegroundColor Gray
    Write-Host "  3. Crie um topup para testar integração" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "`n⚠️  ALGUNS SERVIÇOS AINDA ESTÃO INICIANDO" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔧 AÇÕES:" -ForegroundColor Cyan
    if ($backendHealthy -lt $backendServices.Count) {
        Write-Host "  - Verifique logs: docker-compose -f infra\docker-compose.yml logs -f" -ForegroundColor White
    }
    if ($frontendHealthy -lt $frontendApps.Count) {
        Write-Host "  - Aguarde mais alguns segundos para apps Angular compilarem" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "📄 Documentação completa: docs\STATUS-FINAL-E2E.md" -ForegroundColor Cyan
Write-Host ""
