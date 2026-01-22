# Script para iniciar todos os serviços E2E (assumindo que já estão buildados)

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🚀 INICIANDO TODOS OS SERVIÇOS E2E 🚀                     ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Função para aguardar serviço ficar saudável
function Wait-ForService {
    param($Url, $ServiceName, $MaxAttempts = 30)
    
    Write-Host "  ⏳ Aguardando $ServiceName..." -ForegroundColor Yellow
    $attempt = 0
    
    while ($attempt -lt $MaxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "  ✅ $ServiceName está saudável!" -ForegroundColor Green
                return $true
            }
        } catch {
            # Serviço ainda não está pronto
        }
        
        $attempt++
        Start-Sleep -Seconds 2
    }
    
    Write-Host "  ⚠️  $ServiceName não ficou saudável após $MaxAttempts tentativas" -ForegroundColor Yellow
    return $false
}

# ============================================
# FASE 1: Parar serviços existentes
# ============================================
Write-Host "[FASE 1/5] Parando serviços existentes..." -ForegroundColor Yellow
Push-Location "$script:RootPath\infra"
try {
    docker-compose down 2>&1 | Out-Null
    Write-Host "  ✅ Serviços parados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Nenhum serviço rodando" -ForegroundColor Yellow
}
Pop-Location

# ============================================
# FASE 2: Iniciar infraestrutura base
# ============================================
Write-Host "`n[FASE 2/5] Iniciando infraestrutura base..." -ForegroundColor Yellow
Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Iniciando PostgreSQL, Keycloak e LocalStack..." -ForegroundColor Yellow
    docker-compose up -d postgres keycloak localstack
    
    Write-Host "  ⏳ Aguardando PostgreSQL..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Write-Host "  ⏳ Aguardando Keycloak..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Write-Host "  ✅ Infraestrutura base iniciada!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao iniciar infraestrutura: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 3: Iniciar todos os serviços
# ============================================
Write-Host "`n[FASE 3/5] Iniciando todos os serviços..." -ForegroundColor Yellow
Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Iniciando todos os serviços (isso pode levar alguns minutos)..." -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host "  ⏳ Aguardando serviços iniciarem (aguarde 30 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    Write-Host "  ✅ Serviços iniciados!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao iniciar serviços: $_" -ForegroundColor Red
    Write-Host "  💡 Tente buildar primeiro: docker-compose build" -ForegroundColor Yellow
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 4: Verificar saúde dos serviços
# ============================================
Write-Host "`n[FASE 4/5] Verificando saúde dos serviços..." -ForegroundColor Yellow

$services = @(
    @{Name="benefits-core"; Url="http://localhost:8091/actuator/health"},
    @{Name="user-bff"; Url="http://localhost:8080/actuator/health"},
    @{Name="admin-bff"; Url="http://localhost:8083/actuator/health"},
    @{Name="merchant-bff"; Url="http://localhost:8084/actuator/health"},
    @{Name="payments-orchestrator"; Url="http://localhost:8092/actuator/health"},
    @{Name="acquirer-stub"; Url="http://localhost:8104/actuator/health"},
    @{Name="notification-service"; Url="http://localhost:8100/actuator/health"}
)

$healthyServices = 0
foreach ($service in $services) {
    if (Wait-ForService $service.Url $service.Name 15) {
        $healthyServices++
    }
}

Write-Host "`n  📊 Serviços saudáveis: $healthyServices/$($services.Count)" -ForegroundColor Cyan

# ============================================
# FASE 5: Iniciar Apps Angular (se disponível)
# ============================================
Write-Host "`n[FASE 5/5] Preparando aplicações Angular..." -ForegroundColor Yellow

$angularApps = @(
    @{Name="Admin Angular"; Path="apps/admin_angular"; Port=4200},
    @{Name="Merchant Portal Angular"; Path="apps/merchant_portal_angular"; Port=4201},
    @{Name="Employer Portal Angular"; Path="apps/employer_portal_angular"; Port=4202}
)

foreach ($app in $angularApps) {
    $appPath = Join-Path $script:RootPath $app.Path
    if (Test-Path $appPath) {
        Write-Host "  💡 Para iniciar $($app.Name):" -ForegroundColor Cyan
        Write-Host "     cd $($app.Path)" -ForegroundColor White
        Write-Host "     npm install (se necessário)" -ForegroundColor White
        Write-Host "     ng serve --port $($app.Port)" -ForegroundColor White
    }
}

# ============================================
# RESUMO FINAL
# ============================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ SERVIÇOS INICIADOS! ✅                                 ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "🌐 URLs DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  🔐 Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  📱 User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  👨‍💼 Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  🏪 Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host "  💳 Payments Orchestrator: http://localhost:8092" -ForegroundColor White
Write-Host "  📧 Notification Service: http://localhost:8100" -ForegroundColor White
Write-Host "  🏦 Acquirer Stub: http://localhost:8104" -ForegroundColor White

Write-Host "`n📱 PARA RODAR OS APPS FLUTTER:" -ForegroundColor Cyan
Write-Host "  cd apps/user_app_flutter && flutter run" -ForegroundColor White
Write-Host "  cd apps/merchant_pos_flutter && flutter run" -ForegroundColor White

Write-Host "`n📋 COMANDOS ÚTEIS:" -ForegroundColor Cyan
Write-Host "  Ver logs: docker-compose logs -f [servico]" -ForegroundColor White
Write-Host "  Parar tudo: docker-compose down" -ForegroundColor White
Write-Host "  Status: docker-compose ps" -ForegroundColor White

Write-Host "`n✅ TUDO PRONTO PARA TESTAR OS FLUXOS E2E!" -ForegroundColor Green
Write-Host ""
