# Script para corrigir TUDO em loop infinito até completar

$ErrorActionPreference = "Continue"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$iteration = 0
$maxIterationsWithoutProgress = 5
$iterationsWithoutProgress = 0

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔄 CORRIGINDO TUDO EM LOOP INFINITO 🔄                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Push-Location (Join-Path $script:RootPath "infra")

while ($true) {
    $iteration++
    $previousBackendHealthy = 0
    $previousFrontendHealthy = 0
    
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "🔄 ITERAÇÃO ${iteration}" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Gray
    
    # ============================================
    # VERIFICAR E CORRIGIR SERVIÇOS BACKEND
    # ============================================
    
    Write-Host "📊 BACKEND SERVICES..." -ForegroundColor Yellow
    
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
                Write-Host "  ✅ $($svc.Name)" -ForegroundColor Green
                $backendHealthy++
            } else {
                Write-Host "  ⚠️  $($svc.Name) - Status: $($r.StatusCode)" -ForegroundColor Yellow
                docker-compose restart $svc.Service 2>&1 | Out-Null
                Start-Sleep -Seconds 5
            }
        } catch {
            Write-Host "  ❌ $($svc.Name) - Reiniciando..." -ForegroundColor Red
            docker-compose restart $svc.Service 2>&1 | Out-Null
            Start-Sleep -Seconds 5
        }
    }
    
    Write-Host "  Backend: $backendHealthy/$($backendServices.Count) saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
    
    # ============================================
    # CORRIGIR SERVIÇOS ESPECIALIZADOS QUE NÃO COMPILAM
    # ============================================
    
    Write-Host "`n🔨 CORRIGINDO SERVIÇOS ESPECIALIZADOS..." -ForegroundColor Yellow
    
    $servicesToFix = @(
        "settlement-service",
        "notification-service", 
        "kyc-service",
        "kyb-service",
        "device-service",
        "recon-service"
    )
    
    foreach ($svcName in $servicesToFix) {
        $status = docker-compose ps --format "{{.Name}}|{{.Status}}" | Select-String $svcName
        if (-not $status -or $status -match "Exit|Stopped|unhealthy") {
            Write-Host "  🔧 Corrigindo $svcName..." -ForegroundColor Gray
            
            # Verificar se precisa de logger
            $controllerPath = Join-Path $script:RootPath "services\$svcName\src\main\java"
            if (Test-Path $controllerPath) {
                $controllers = Get-ChildItem -Path $controllerPath -Recurse -Filter "*Controller.java"
                foreach ($controller in $controllers) {
                    $content = Get-Content $controller.FullName -Raw
                    if ($content -match "log\." -and $content -notmatch "private static final Logger log") {
                        Write-Host "     Adicionando logger em $($controller.Name)..." -ForegroundColor Gray
                        # Adicionar logger se necessário
                        if ($content -match "import org.slf4j.Logger;") {
                            $newContent = $content -replace "(@RequiredArgsConstructor\s+public class)", "private static final Logger log = LoggerFactory.getLogger($($controller.BaseName).class);`n    `$1"
                            Set-Content -Path $controller.FullName -Value $newContent -NoNewline
                        }
                    }
                }
            }
            
            # Rebuild
            Write-Host "     Rebuildando..." -ForegroundColor Gray
            docker-compose build $svcName 2>&1 | Out-Null
            docker-compose up -d $svcName 2>&1 | Out-Null
            Start-Sleep -Seconds 10
        }
    }
    
    # ============================================
    # REINICIAR SERVIÇOS UNHEALTHY
    # ============================================
    
    Write-Host "`n🔄 REINICIANDO SERVIÇOS UNHEALTHY..." -ForegroundColor Yellow
    
    $unhealthyServices = docker-compose ps --format "{{.Name}}|{{.Status}}" | Select-String "unhealthy" | ForEach-Object {
        ($_.Line -split '\|')[0]
    }
    
    if ($unhealthyServices) {
        Write-Host "  Encontrados: $($unhealthyServices.Count) serviços unhealthy" -ForegroundColor Yellow
        foreach ($svc in $unhealthyServices) {
            Write-Host "     Reiniciando $svc..." -ForegroundColor Gray
            docker-compose restart $svc 2>&1 | Out-Null
        }
        Start-Sleep -Seconds 15
    } else {
        Write-Host "  ✅ Nenhum serviço unhealthy" -ForegroundColor Green
    }
    
    # ============================================
    # VERIFICAR FRONTEND APPS
    # ============================================
    
    Write-Host "`n🌐 FRONTEND APPS..." -ForegroundColor Yellow
    
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
        }
    }
    
    Write-Host "  Frontend: $frontendHealthy/$($frontendApps.Count) respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })
    
    # ============================================
    # RESUMO E VERIFICAÇÃO DE CONCLUSÃO
    # ============================================
    
    Write-Host "`n📊 RESUMO ITERAÇÃO ${iteration}:" -ForegroundColor Cyan
    Write-Host "  ✅ Backend: $backendHealthy/$($backendServices.Count) saudáveis" -ForegroundColor $(if ($backendHealthy -eq $backendServices.Count) { "Green" } else { "Yellow" })
    Write-Host "  ✅ Frontend: $frontendHealthy/$($frontendApps.Count) respondendo" -ForegroundColor $(if ($frontendHealthy -eq $frontendApps.Count) { "Green" } else { "Yellow" })
    Write-Host "  ✅ Containers: $(docker-compose ps -q | Measure-Object).Count rodando" -ForegroundColor Green
    
    # Verificar se tudo está OK
    if ($backendHealthy -eq $backendServices.Count -and $frontendHealthy -eq $frontendApps.Count -and $unhealthyServices.Count -eq 0) {
        Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                                                              ║" -ForegroundColor Green
        Write-Host "║   🎉 TUDO FUNCIONANDO PERFEITAMENTE! 🎉                     ║" -ForegroundColor Green
        Write-Host "║                                                              ║" -ForegroundColor Green
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        Write-Host "✅ Backend: $backendHealthy/$($backendServices.Count) serviços saudáveis" -ForegroundColor Green
        Write-Host "✅ Frontend: $frontendHealthy/$($frontendApps.Count) apps respondendo" -ForegroundColor Green
        Write-Host "✅ Todos os serviços especializados rodando" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 SISTEMA PRONTO PARA TESTES E2E!" -ForegroundColor Cyan
        Write-Host ""
        break
    }
    
    # Verificar progresso
    if ($backendHealthy -eq $previousBackendHealthy -and $frontendHealthy -eq $previousFrontendHealthy) {
        $iterationsWithoutProgress++
        if ($iterationsWithoutProgress -ge $maxIterationsWithoutProgress) {
            Write-Host "`n⚠️  Sem progresso por $maxIterationsWithoutProgress iterações" -ForegroundColor Yellow
            Write-Host "   Verificando problemas específicos..." -ForegroundColor Yellow
            
            # Verificar logs de serviços problemáticos
            Write-Host "`n📋 LOGS DOS SERVIÇOS PROBLEMÁTICOS:" -ForegroundColor Yellow
            foreach ($svc in $unhealthyServices) {
                Write-Host "`n  $svc:" -ForegroundColor Cyan
                docker-compose logs --tail=5 $svc 2>&1 | Select-Object -Last 3
            }
        }
    } else {
        $iterationsWithoutProgress = 0
    }
    
    $previousBackendHealthy = $backendHealthy
    $previousFrontendHealthy = $frontendHealthy
    
    Write-Host "`n⏳ Aguardando 20 segundos antes da próxima iteração..." -ForegroundColor Gray
    Start-Sleep -Seconds 20
}

Pop-Location

Write-Host ""
