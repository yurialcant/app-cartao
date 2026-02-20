# Script final para corrigir TUDO em loop até completar

$ErrorActionPreference = "Continue"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$iteration = 0

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔄 CORRIGINDO TUDO EM LOOP INFINITO 🔄                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Push-Location (Join-Path $script:RootPath "infra")

while ($true) {
    $iteration++
    
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "🔄 ITERAÇÃO ${iteration}" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Gray
    
    # ============================================
    # VERIFICAR SERVIÇOS BACKEND PRINCIPAIS
    # ============================================
    
    Write-Host "📊 BACKEND PRINCIPAL..." -ForegroundColor Yellow
    
    $backendServices = @(
        @{Name="User BFF"; Url="http://localhost:8080/actuator/health"; Service="user-bff"},
        @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"; Service="admin-bff"},
        @{Name="Core Service"; Url="http://localhost:8091/actuator/health"; Service="benefits-core"},
        @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"; Service="merchant-bff"},
        @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits/.well-known/openid-configuration"; Service="keycloak"}
    )
    
    $backendHealthy = 0
    foreach ($svc in $backendServices) {
        try {
            $r = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($r.StatusCode -eq 200) {
                Write-Host "  ✅ $($svc.Name)" -ForegroundColor Green
                $backendHealthy++
            } else {
                Write-Host "  ⚠️  $($svc.Name) - Reiniciando..." -ForegroundColor Yellow
                docker-compose restart $svc.Service 2>&1 | Out-Null
                Start-Sleep -Seconds 5
            }
        } catch {
            Write-Host "  ❌ $($svc.Name) - Reiniciando..." -ForegroundColor Red
            docker-compose restart $svc.Service 2>&1 | Out-Null
            Start-Sleep -Seconds 5
        }
    }
    
    Write-Host "  Status: $backendHealthy/$($backendServices.Count) saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
    
    # ============================================
    # GARANTIR QUE TODOS OS CONTAINERS ESTÃO RODANDO
    # ============================================
    
    Write-Host "`n🐳 VERIFICANDO CONTAINERS..." -ForegroundColor Yellow
    
    $allContainers = docker-compose ps -q
    $runningContainers = docker-compose ps -q --filter "status=running"
    $stoppedContainers = docker-compose ps -q --filter "status=exited"
    
    if ($stoppedContainers) {
        Write-Host "  ⚠️  Containers parados encontrados, reiniciando..." -ForegroundColor Yellow
        docker-compose up -d 2>&1 | Out-Null
        Start-Sleep -Seconds 10
    } else {
        Write-Host "  ✅ Todos os containers rodando" -ForegroundColor Green
    }
    
    # ============================================
    # VERIFICAR FRONTEND APPS
    # ============================================
    
    Write-Host "`n🌐 FRONTEND APPS..." -ForegroundColor Yellow
    
    $frontendApps = @(
        @{Name="Admin Angular"; Url="http://localhost:4200"},
        @{Name="Merchant Portal"; Url="http://localhost:4201"}
    )
    
    $frontendHealthy = 0
    foreach ($app in $frontendApps) {
        try {
            $r = Invoke-WebRequest -Uri $app.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            Write-Host "  ✅ $($app.Name) - Respondendo" -ForegroundColor Green
            $frontendHealthy++
        } catch {
            Write-Host "  ⏳ $($app.Name) - Ainda compilando..." -ForegroundColor Yellow
        }
    }
    
    Write-Host "  Status: $frontendHealthy/$($frontendApps.Count) respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })
    
    # ============================================
    # RESUMO E VERIFICAÇÃO DE CONCLUSÃO
    # ============================================
    
    Write-Host "`n📊 RESUMO:" -ForegroundColor Cyan
    Write-Host "  ✅ Backend: $backendHealthy/$($backendServices.Count) saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
    Write-Host "  ✅ Frontend: $frontendHealthy/$($frontendApps.Count) respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })
    Write-Host "  ✅ Containers: $(docker-compose ps -q | Measure-Object).Count rodando" -ForegroundColor Green
    
    # Verificar se tudo está OK
    if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -eq $frontendApps.Count) {
        Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                                                              ║" -ForegroundColor Green
        Write-Host "║   🎉 TUDO FUNCIONANDO PERFEITAMENTE! 🎉                     ║" -ForegroundColor Green
        Write-Host "║                                                              ║" -ForegroundColor Green
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        Write-Host "✅ Backend: $backendHealthy/$($backendServices.Count) serviços saudáveis" -ForegroundColor Green
        Write-Host "✅ Frontend: $frontendHealthy/$($frontendApps.Count) apps respondendo" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 SISTEMA PRONTO PARA TESTES E2E!" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📋 URLs:" -ForegroundColor Cyan
        Write-Host "  🌐 Admin Angular: http://localhost:4200 (admin/admin123)" -ForegroundColor White
        Write-Host "  🌐 Merchant Portal: http://localhost:4201 (merchant1/Passw0rd!)" -ForegroundColor White
        Write-Host "  🔧 User BFF: http://localhost:8080" -ForegroundColor White
        Write-Host "  🔧 Admin BFF: http://localhost:8083" -ForegroundColor White
        Write-Host "  🔧 Core Service: http://localhost:8091" -ForegroundColor White
        Write-Host ""
        break
    }
    
    Write-Host "`n⏳ Aguardando 15 segundos antes da próxima iteração..." -ForegroundColor Gray
    Start-Sleep -Seconds 15
}

Pop-Location

Write-Host ""
