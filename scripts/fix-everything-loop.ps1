# Script para corrigir tudo que falta em loop até completar

$ErrorActionPreference = "Continue"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$maxIterations = 10
$iteration = 0

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔄 CORRIGINDO TUDO EM LOOP ATÉ COMPLETAR 🔄              ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Push-Location (Join-Path $script:RootPath "infra")

while ($iteration -lt $maxIterations) {
    $iteration++
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "🔄 ITERAÇÃO $iteration/$maxIterations" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Gray
    
    $allFixed = $true
    
    # ============================================
    # VERIFICAR SERVIÇOS BACKEND
    # ============================================
    
    Write-Host "📊 Verificando serviços backend..." -ForegroundColor Yellow
    
    $backendServices = @(
        @{Name="User BFF"; Url="http://localhost:8080/actuator/health"; Port=8080; Service="user-bff"},
        @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"; Port=8083; Service="admin-bff"},
        @{Name="Core Service"; Url="http://localhost:8091/actuator/health"; Port=8091; Service="benefits-core"},
        @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"; Port=8084; Service="merchant-bff"},
        @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits/.well-known/openid-configuration"; Port=8081; Service="keycloak"}
    )
    
    $backendHealthy = 0
    foreach ($svc in $backendServices) {
        try {
            $r = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($r.StatusCode -eq 200) {
                Write-Host "  ✅ $($svc.Name) - Saudável" -ForegroundColor Green
                $backendHealthy++
            } else {
                Write-Host "  ⚠️  $($svc.Name) - Status: $($r.StatusCode)" -ForegroundColor Yellow
                $allFixed = $false
                Write-Host "     Reiniciando serviço..." -ForegroundColor Gray
                docker-compose restart $svc.Service 2>&1 | Out-Null
            }
        } catch {
            Write-Host "  ❌ $($svc.Name) - Não responde" -ForegroundColor Red
            $allFixed = $false
            Write-Host "     Reiniciando serviço..." -ForegroundColor Gray
            docker-compose restart $svc.Service 2>&1 | Out-Null
        }
    }
    
    Write-Host "  Backend: $backendHealthy/$($backendServices.Count) saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
    
    # ============================================
    # VERIFICAR SERVIÇOS ESPECIALIZADOS UNHEALTHY
    # ============================================
    
    Write-Host "`n📋 Verificando serviços especializados..." -ForegroundColor Yellow
    
    $unhealthyServices = docker-compose ps --format "{{.Name}}|{{.Status}}" | Select-String "unhealthy" | ForEach-Object {
        $parts = $_.Line -split '\|'
        $parts[0]
    }
    
    if ($unhealthyServices) {
        Write-Host "  ⚠️  Serviços unhealthy encontrados: $($unhealthyServices -join ', ')" -ForegroundColor Yellow
        $allFixed = $false
        
        foreach ($svc in $unhealthyServices) {
            Write-Host "     Reiniciando $svc..." -ForegroundColor Gray
            docker-compose restart $svc 2>&1 | Out-Null
        }
    } else {
        Write-Host "  ✅ Todos os serviços especializados saudáveis" -ForegroundColor Green
    }
    
    # ============================================
    # VERIFICAR FRONTEND APPS
    # ============================================
    
    Write-Host "`n🌐 Verificando apps Angular..." -ForegroundColor Yellow
    
    $frontendApps = @(
        @{Name="Admin Angular"; Url="http://localhost:4200"; Port=4200},
        @{Name="Merchant Portal"; Url="http://localhost:4201"; Port=4201}
    )
    
    $frontendHealthy = 0
    foreach ($app in $frontendApps) {
        try {
            $r = Invoke-WebRequest -Uri $app.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            Write-Host "  ✅ $($app.Name) - Respondendo" -ForegroundColor Green
            $frontendHealthy++
        } catch {
            Write-Host "  ⏳ $($app.Name) - Ainda compilando..." -ForegroundColor Yellow
            # Apps Angular podem estar compilando, não é erro crítico
        }
    }
    
    Write-Host "  Frontend: $frontendHealthy/$($frontendApps.Count) respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })
    
    # ============================================
    # VERIFICAR DOCKER CONTAINERS
    # ============================================
    
    Write-Host "`n🐳 Verificando containers Docker..." -ForegroundColor Yellow
    
    $containers = docker-compose ps --format "{{.Name}}|{{.Status}}" | Where-Object { $_ -notmatch "NAME" }
    $stoppedContainers = $containers | Where-Object { $_ -match "Exit|Stopped|Restarting" }
    
    if ($stoppedContainers) {
        Write-Host "  ⚠️  Containers parados encontrados" -ForegroundColor Yellow
        $allFixed = $false
        
        foreach ($container in $stoppedContainers) {
            $name = ($container -split '\|')[0]
            Write-Host "     Reiniciando $name..." -ForegroundColor Gray
            docker-compose up -d $name 2>&1 | Out-Null
        }
    } else {
        Write-Host "  ✅ Todos os containers rodando" -ForegroundColor Green
    }
    
    # ============================================
    # VERIFICAR COMPILAÇÃO DE SERVIÇOS
    # ============================================
    
    Write-Host "`n🔨 Verificando serviços que precisam rebuild..." -ForegroundColor Yellow
    
    $servicesToRebuild = @(
        "privacy-service",
        "settlement-service",
        "recon-service",
        "device-service",
        "notification-service",
        "kyc-service",
        "kyb-service"
    )
    
    $needsRebuild = @()
    foreach ($svc in $servicesToRebuild) {
        $status = docker-compose ps --format "{{.Name}}|{{.Status}}" | Select-String $svc
        if (-not $status -or $status -match "Exit|Stopped") {
            $needsRebuild += $svc
        }
    }
    
    if ($needsRebuild.Count -gt 0) {
        Write-Host "  ⚠️  Serviços que precisam rebuild: $($needsRebuild -join ', ')" -ForegroundColor Yellow
        $allFixed = $false
        
        foreach ($svc in $needsRebuild) {
            Write-Host "     Rebuildando $svc..." -ForegroundColor Gray
            docker-compose build $svc 2>&1 | Out-Null
            docker-compose up -d $svc 2>&1 | Out-Null
        }
    } else {
        Write-Host "  ✅ Todos os serviços compilados" -ForegroundColor Green
    }
    
    # ============================================
    # RESUMO DA ITERAÇÃO
    # ============================================
    
    Write-Host "`n📊 RESUMO ITERAÇÃO ${iteration}:" -ForegroundColor Cyan
    Write-Host "  Backend: $backendHealthy/$($backendServices.Count) saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
    Write-Host "  Frontend: $frontendHealthy/$($frontendApps.Count) respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })
    Write-Host "  Containers: $($containers.Count - $stoppedContainers.Count)/$($containers.Count) rodando" -ForegroundColor $(if ($stoppedContainers.Count -eq 0) { "Green" } else { "Yellow" })
    
    # Verificar se tudo está OK
    if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -eq $frontendApps.Count -and $stoppedContainers.Count -eq 0 -and $needsRebuild.Count -eq 0) {
        Write-Host "`n🎉 TUDO FUNCIONANDO PERFEITAMENTE!" -ForegroundColor Green
        break
    }
    
    if ($iteration -lt $maxIterations) {
        Write-Host "`n⏳ Aguardando 30 segundos antes da próxima iteração..." -ForegroundColor Gray
        Start-Sleep -Seconds 30
    }
}

Pop-Location

# ============================================
# VALIDAÇÃO FINAL
# ============================================

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $(if ($allFixed) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($allFixed) { "Green" } else { "Yellow" })
Write-Host "║   📊 VALIDAÇÃO FINAL 📊                                     ║" -ForegroundColor $(if ($allFixed) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($allFixed) { "Green" } else { "Yellow" })
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $(if ($allFixed) { "Green" } else { "Yellow" })

Write-Host "`n✅ Backend: $backendHealthy/$($backendServices.Count) serviços saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
Write-Host "✅ Frontend: $frontendHealthy/$($frontendApps.Count) apps respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })

if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -eq $frontendApps.Count) {
    Write-Host "`n🎉 SISTEMA COMPLETO E FUNCIONANDO!" -ForegroundColor Green
    Write-Host "`n🚀 PRONTO PARA TESTES E2E!" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠️  ALGUNS COMPONENTES AINDA PRECISAM DE ATENÇÃO" -ForegroundColor Yellow
    Write-Host "   Execute novamente: .\scripts\fix-everything-loop.ps1" -ForegroundColor Gray
}

Write-Host ""
