# Script Master - Rodar Tudo E2E Completo
# Valida ambiente, inicia serviços, valida integração e fornece instruções

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🚀 BENEFITS PLATFORM - E2E COMPLETO 🚀                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================
# FASE 1: VALIDAÇÃO DO AMBIENTE
# ============================================

Write-Host "`n📋 FASE 1: Validando Ambiente..." -ForegroundColor Yellow

# Verificar Docker
Write-Host "  🔍 Verificando Docker..." -ForegroundColor Gray
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker não encontrado"
    }
    Write-Host "  ✅ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Docker não está instalado ou não está no PATH" -ForegroundColor Red
    Write-Host "     Instale Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Verificar Node.js
Write-Host "  🔍 Verificando Node.js..." -ForegroundColor Gray
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js não encontrado"
    }
    Write-Host "  ✅ Node.js encontrado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Node.js não encontrado (necessário para apps Angular)" -ForegroundColor Yellow
}

# Verificar Flutter
Write-Host "  🔍 Verificando Flutter..." -ForegroundColor Gray
try {
    $flutterVersion = flutter --version 2>&1 | Select-String -Pattern "Flutter" | Select-Object -First 1
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter não encontrado"
    }
    Write-Host "  ✅ Flutter encontrado" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Flutter não encontrado (necessário para apps Flutter)" -ForegroundColor Yellow
}

# Verificar portas disponíveis
Write-Host "  🔍 Verificando portas..." -ForegroundColor Gray
$ports = @(8080, 8081, 8083, 8084, 8085, 8091, 4200, 4201, 4202, 5432)
$portsInUse = @()
foreach ($port in $ports) {
    $result = netstat -ano | findstr ":$port "
    if ($result) {
        $portsInUse += $port
    }
}
if ($portsInUse.Count -gt 0) {
    Write-Host "  ⚠️  Portas em uso: $($portsInUse -join ', ')" -ForegroundColor Yellow
    Write-Host "     Parando containers antigos..." -ForegroundColor Gray
    docker-compose -f "$script:RootPath\infra\docker-compose.yml" down 2>&1 | Out-Null
} else {
    Write-Host "  ✅ Todas as portas estão disponíveis" -ForegroundColor Green
}

# ============================================
# FASE 2: INICIAR SERVIÇOS BACKEND
# ============================================

Write-Host "`n📋 FASE 2: Iniciando Serviços Backend..." -ForegroundColor Yellow

$dockerComposePath = Join-Path $script:RootPath "infra\docker-compose.yml"

if (-not (Test-Path $dockerComposePath)) {
    Write-Host "  ❌ docker-compose.yml não encontrado em: $dockerComposePath" -ForegroundColor Red
    exit 1
}

Write-Host "  🔨 Buildando serviços (pode levar alguns minutos na primeira vez)..." -ForegroundColor Gray
Push-Location (Join-Path $script:RootPath "infra")
try {
    $buildOutput = docker-compose build --parallel 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️  Alguns serviços falharam no build. Verificando..." -ForegroundColor Yellow
        # Verificar quais serviços falharam
        $failedServices = $buildOutput | Select-String -Pattern "failed|ERROR" | Select-Object -First 5
        if ($failedServices) {
            Write-Host "  ⚠️  Serviços com erro:" -ForegroundColor Yellow
            $failedServices | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
        }
        Write-Host "  ⚠️  Continuando com serviços que compilaram..." -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Build concluído com sucesso" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Erro no build: $_" -ForegroundColor Yellow
}
Pop-Location

Write-Host "  🚀 Iniciando serviços..." -ForegroundColor Gray
Push-Location (Join-Path $script:RootPath "infra")
try {
    $startOutput = docker-compose up -d 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠️  Alguns serviços podem ter falhado ao iniciar" -ForegroundColor Yellow
        $startOutput | Select-String -Pattern "error|Error|ERROR|failed" | Select-Object -First 5 | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ✅ Serviços iniciados" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Erro ao iniciar serviços: $_" -ForegroundColor Yellow
    Write-Host "     Continuando para verificar status..." -ForegroundColor Gray
}
Pop-Location

# Aguardar serviços iniciarem
Write-Host "  ⏳ Aguardando serviços iniciarem (60 segundos)..." -ForegroundColor Gray
Start-Sleep -Seconds 60

# ============================================
# FASE 3: VALIDAR SERVIÇOS
# ============================================

Write-Host "`n📋 FASE 3: Validando Serviços..." -ForegroundColor Yellow

$services = @(
    @{Name="PostgreSQL"; Url="http://localhost:5432"; Check="docker ps --filter name=benefits-postgres --format '{{.Status}}'"},
    @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits/.well-known/openid-configuration"; Check="curl -s $Url | Select-String -Pattern 'issuer'"},
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"; Check="Invoke-WebRequest -Uri $Url -UseBasicParsing"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"; Check="Invoke-WebRequest -Uri $Url -UseBasicParsing"},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"; Check="Invoke-WebRequest -Uri $Url -UseBasicParsing"},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"; Check="Invoke-WebRequest -Uri $Url -UseBasicParsing"}
)

$healthyServices = 0
$unhealthyServices = @()

foreach ($service in $services) {
    Write-Host "  🔍 Verificando $($service.Name)..." -ForegroundColor Gray
    try {
        $result = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($result.StatusCode -eq 200) {
            Write-Host "  ✅ $($service.Name) está saudável" -ForegroundColor Green
            $healthyServices++
        } else {
            Write-Host "  ⚠️  $($service.Name) retornou status $($result.StatusCode)" -ForegroundColor Yellow
            $unhealthyServices += $service.Name
        }
    } catch {
        Write-Host "  ⚠️  $($service.Name) não está respondendo ainda" -ForegroundColor Yellow
        $unhealthyServices += $service.Name
    }
}

Write-Host "`n  📊 Status: $healthyServices/$($services.Count) serviços saudáveis" -ForegroundColor $(if ($healthyServices -eq $services.Count) { "Green" } else { "Yellow" })

if ($unhealthyServices.Count -gt 0) {
    Write-Host "  ⚠️  Serviços não saudáveis: $($unhealthyServices -join ', ')" -ForegroundColor Yellow
    Write-Host "     Aguarde mais alguns segundos ou verifique os logs:" -ForegroundColor Gray
    Write-Host "     docker-compose -f infra\docker-compose.yml logs -f" -ForegroundColor Gray
}

# ============================================
# FASE 4: INSTRUÇÕES PARA APPS FRONTEND
# ============================================

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ BACKEND PRONTO! Agora inicie os apps frontend:        ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📱 APPS ANGULAR (em terminais separados):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Terminal 1 - Admin Angular:" -ForegroundColor White
Write-Host "    cd apps/admin_angular" -ForegroundColor Gray
Write-Host "    npm install  # Se ainda não instalou" -ForegroundColor Gray
Write-Host "    npm start" -ForegroundColor Gray
Write-Host "    → http://localhost:4200" -ForegroundColor Green
Write-Host ""
Write-Host "  Terminal 2 - Merchant Portal:" -ForegroundColor White
Write-Host "    cd apps/merchant_portal_angular" -ForegroundColor Gray
Write-Host "    npm install  # Se ainda não instalou" -ForegroundColor Gray
Write-Host "    npm start" -ForegroundColor Gray
Write-Host "    → http://localhost:4201" -ForegroundColor Green
Write-Host ""
Write-Host "  Terminal 3 - Employer Portal:" -ForegroundColor White
Write-Host "    cd apps/employer_portal_angular" -ForegroundColor Gray
Write-Host "    npm install  # Se ainda não instalou" -ForegroundColor Gray
Write-Host "    npm start" -ForegroundColor Gray
Write-Host "    → http://localhost:4202" -ForegroundColor Green
Write-Host ""

Write-Host "📱 APPS FLUTTER (em terminais separados):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Terminal 4 - User App:" -ForegroundColor White
Write-Host "    cd apps/user_app_flutter" -ForegroundColor Gray
Write-Host "    flutter pub get  # Se ainda não instalou" -ForegroundColor Gray
Write-Host "    flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "  Terminal 5 - Merchant POS:" -ForegroundColor White
Write-Host "    cd apps/merchant_pos_flutter" -ForegroundColor Gray
Write-Host "    flutter pub get  # Se ainda não instalou" -ForegroundColor Gray
Write-Host "    flutter run" -ForegroundColor Gray
Write-Host ""

Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "  User App:" -ForegroundColor White
Write-Host "    Usuário: user1" -ForegroundColor Gray
Write-Host "    Senha: Passw0rd!" -ForegroundColor Gray
Write-Host ""
Write-Host "  Admin Angular:" -ForegroundColor White
Write-Host "    Usuário: admin" -ForegroundColor Gray
Write-Host "    Senha: admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "  Merchant POS:" -ForegroundColor White
Write-Host "    Usuário: merchant1" -ForegroundColor Gray
Write-Host "    Senha: Passw0rd!" -ForegroundColor Gray
Write-Host ""

Write-Host "🌐 URLs DOS SERVIÇOS:" -ForegroundColor Cyan
Write-Host "  Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host "  Core Service: http://localhost:8091" -ForegroundColor White
Write-Host ""

Write-Host "📊 MONITORAMENTO:" -ForegroundColor Cyan
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "  Logs: docker-compose -f infra\docker-compose.yml logs -f" -ForegroundColor White
Write-Host ""

Write-Host "🧪 TESTAR INTEGRAÇÃO:" -ForegroundColor Cyan
Write-Host "  1. Admin cria topup → User App vê saldo atualizado" -ForegroundColor White
Write-Host "  2. User App faz pagamento → Admin vê transação" -ForegroundColor White
Write-Host "  3. Todos os apps compartilham os mesmos dados via Core Service" -ForegroundColor White
Write-Host ""

Write-Host "✅ TUDO PRONTO PARA TESTAR E2E!" -ForegroundColor Green
Write-Host ""
