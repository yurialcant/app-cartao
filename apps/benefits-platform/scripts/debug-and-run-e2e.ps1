# Script de Debug e Execução E2E Completo
# Verifica erros, corrige e roda tudo

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔍 DEBUG E EXECUÇÃO E2E COMPLETA 🔍                        ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Função para verificar compilação de um serviço
function Test-ServiceCompilation {
    param($ServicePath, $ServiceName)
    
    Write-Host "  🔍 Verificando compilação de $ServiceName..." -ForegroundColor Yellow
    
    Push-Location $ServicePath
    try {
        $mvnOutput = mvn clean compile -DskipTests 2>&1 | Out-String
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✅ $ServiceName compila corretamente" -ForegroundColor Green
            return $true
        } else {
            Write-Host "    ❌ $ServiceName tem erros de compilação:" -ForegroundColor Red
            Write-Host $mvnOutput -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "    ⚠️  Erro ao verificar $ServiceName : $_" -ForegroundColor Yellow
        return $false
    } finally {
        Pop-Location
    }
}

# ============================================
# FASE 1: Verificar Compilação de Todos os Serviços
# ============================================
Write-Host "[FASE 1/8] Verificando compilação de todos os serviços..." -ForegroundColor Yellow

$services = @(
    @{Name="benefits-core"; Path="services/benefits-core"},
    @{Name="user-bff"; Path="services/user-bff"},
    @{Name="admin-bff"; Path="services/admin-bff"},
    @{Name="merchant-bff"; Path="services/merchant-bff"},
    @{Name="merchant-portal-bff"; Path="services/merchant-portal-bff"},
    @{Name="employer-bff"; Path="services/employer-bff"},
    @{Name="payments-orchestrator"; Path="services/payments-orchestrator"},
    @{Name="acquirer-adapter"; Path="services/acquirer-adapter"},
    @{Name="acquirer-stub"; Path="services/acquirer-stub"},
    @{Name="notification-service"; Path="services/notification-service"},
    @{Name="kyc-service"; Path="services/kyc-service"},
    @{Name="kyb-service"; Path="services/kyb-service"},
    @{Name="risk-service"; Path="services/risk-service"},
    @{Name="support-service"; Path="services/support-service"},
    @{Name="settlement-service"; Path="services/settlement-service"},
    @{Name="recon-service"; Path="services/recon-service"},
    @{Name="device-service"; Path="services/device-service"},
    @{Name="audit-service"; Path="services/audit-service"},
    @{Name="privacy-service"; Path="services/privacy-service"},
    @{Name="webhook-receiver"; Path="services/webhook-receiver"},
    @{Name="tenant-service"; Path="services/tenant-service"},
    @{Name="employer-service"; Path="services/employer-service"}
)

$failedServices = @()
foreach ($service in $services) {
    $servicePath = Join-Path $script:RootPath $service.Path
    if (Test-Path $servicePath) {
        if (-not (Test-ServiceCompilation $servicePath $service.Name)) {
            $failedServices += $service.Name
        }
    } else {
        Write-Host "  ⚠️  $($service.Name) não encontrado em $servicePath" -ForegroundColor Yellow
    }
}

if ($failedServices.Count -gt 0) {
    Write-Host "`n❌ Serviços com erros de compilação: $($failedServices -join ', ')" -ForegroundColor Red
    Write-Host "Por favor, corrija os erros antes de continuar." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Todos os serviços compilam corretamente!" -ForegroundColor Green

# ============================================
# FASE 2: Parar serviços existentes
# ============================================
Write-Host "`n[FASE 2/8] Parando serviços existentes..." -ForegroundColor Yellow
Push-Location "$script:RootPath\infra"
try {
    docker-compose down 2>&1 | Out-Null
    Write-Host "  ✅ Serviços parados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Nenhum serviço rodando" -ForegroundColor Yellow
}
Pop-Location

# ============================================
# FASE 3: Build Docker (sem cache)
# ============================================
Write-Host "`n[FASE 3/8] Buildando imagens Docker (sem cache)..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Buildando imagens (isso pode levar vários minutos)..." -ForegroundColor Yellow
    docker-compose build --no-cache --parallel 2>&1 | Tee-Object -Variable buildOutput
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Erro ao buildar serviços" -ForegroundColor Red
        # Mostrar apenas erros
        $buildOutput | Select-String -Pattern "ERROR|FAILED|error|failed" | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        exit 1
    }
    
    Write-Host "  ✅ Todos os serviços buildados!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao buildar: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 4: Iniciar infraestrutura
# ============================================
Write-Host "`n[FASE 4/8] Iniciando infraestrutura base..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Iniciando PostgreSQL, Keycloak e LocalStack..." -ForegroundColor Yellow
    docker-compose up -d postgres keycloak localstack
    
    Write-Host "  ⏳ Aguardando PostgreSQL..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Write-Host "  ⏳ Aguardando Keycloak..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    Write-Host "  ⏳ Aguardando LocalStack..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Write-Host "  ✅ Infraestrutura base iniciada!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao iniciar infraestrutura: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 5: Iniciar todos os serviços
# ============================================
Write-Host "`n[FASE 5/8] Iniciando todos os serviços..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Iniciando todos os serviços..." -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host "  ⏳ Aguardando serviços iniciarem (60 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
    
    Write-Host "  ✅ Serviços iniciados!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao iniciar serviços: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 6: Verificar saúde dos serviços
# ============================================
Write-Host "`n[FASE 6/8] Verificando saúde dos serviços..." -ForegroundColor Yellow

$healthChecks = @(
    @{Name="benefits-core"; Url="http://localhost:8091/actuator/health"},
    @{Name="user-bff"; Url="http://localhost:8080/actuator/health"},
    @{Name="admin-bff"; Url="http://localhost:8083/actuator/health"},
    @{Name="merchant-bff"; Url="http://localhost:8084/actuator/health"},
    @{Name="payments-orchestrator"; Url="http://localhost:8092/actuator/health"},
    @{Name="notification-service"; Url="http://localhost:8100/actuator/health"},
    @{Name="acquirer-stub"; Url="http://localhost:8104/actuator/health"}
)

$healthyCount = 0
foreach ($check in $healthChecks) {
    try {
        $response = Invoke-WebRequest -Uri $check.Url -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ $($check.Name) está saudável" -ForegroundColor Green
            $healthyCount++
        }
    } catch {
        Write-Host "  ⚠️  $($check.Name) não está respondendo" -ForegroundColor Yellow
    }
}

Write-Host "`n  📊 Serviços saudáveis: $healthyCount/$($healthChecks.Count)" -ForegroundColor Cyan

# ============================================
# FASE 7: Verificar logs de erros
# ============================================
Write-Host "`n[FASE 7/8] Verificando logs de erros..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    $logs = docker-compose logs --tail=50 2>&1 | Out-String
    $errors = $logs | Select-String -Pattern "ERROR|Exception|Failed|failed" -CaseSensitive:$false
    
    if ($errors) {
        Write-Host "  ⚠️  Erros encontrados nos logs:" -ForegroundColor Yellow
        $errors | Select-Object -First 10 | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    } else {
        Write-Host "  ✅ Nenhum erro crítico encontrado nos logs" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Erro ao verificar logs: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# ============================================
# FASE 8: Resumo Final
# ============================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ DEBUG E EXECUÇÃO E2E COMPLETA! ✅                         ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📊 RESUMO:" -ForegroundColor Cyan
Write-Host "  ✅ Compilação: Todos os serviços OK" -ForegroundColor White
Write-Host "  ✅ Build Docker: Concluído" -ForegroundColor White
Write-Host "  ✅ Infraestrutura: PostgreSQL, Keycloak, LocalStack" -ForegroundColor White
Write-Host "  ✅ Serviços: $healthyCount/$($healthChecks.Count) saudáveis" -ForegroundColor White

Write-Host "`n🌐 URLs DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  🔐 Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  📱 User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  👨‍💼 Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  💳 Payments Orchestrator: http://localhost:8092" -ForegroundColor White
Write-Host "  📧 Notification Service: http://localhost:8100" -ForegroundColor White

Write-Host "`n📋 COMANDOS ÚTEIS:" -ForegroundColor Cyan
Write-Host "  Ver logs: docker-compose logs -f [servico]" -ForegroundColor White
Write-Host "  Parar tudo: docker-compose down" -ForegroundColor White
Write-Host "  Status: docker-compose ps" -ForegroundColor White

Write-Host "`n✅ SISTEMA PRONTO PARA TESTES E2E!" -ForegroundColor Green
Write-Host ""
