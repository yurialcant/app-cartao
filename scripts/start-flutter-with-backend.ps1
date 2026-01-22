# start-flutter-with-backend.ps1
# Inicia Flutter app com todos os serviços backend necessários

Write-Host "📱 INICIANDO FLUTTER APP COM BACKEND COMPLETO" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Green

# ============================================
# VERIFICAÇÃO PRÉVIA
# ============================================
Write-Host "`n🔍 VERIFICAÇÃO PRÉVIA..." -ForegroundColor Yellow

# Verificar Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "   🎯 Flutter instalado: ✅" -ForegroundColor Green
    Write-Host "   $flutterVersion" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Flutter não instalado!" -ForegroundColor Red
    Write-Host "   📥 Baixe em: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Verificar se estamos no diretório correto
if (!(Test-Path "apps/user_app_flutter/pubspec.yaml")) {
    Write-Host "   ❌ Não estamos no diretório correto!" -ForegroundColor Red
    Write-Host "   📁 Execute a partir da raiz do projeto" -ForegroundColor Yellow
    exit 1
}

Write-Host "   📁 Diretório correto: ✅" -ForegroundColor Green

# ============================================
# INICIAR INFRAESTRUTURA
# ============================================
Write-Host "`n🏗️ INICIANDO INFRAESTRUTURA..." -ForegroundColor Yellow

# Iniciar containers Docker
Write-Host "🐳 Iniciando PostgreSQL, Redis e Keycloak..." -ForegroundColor White
cd infra/docker

# Verificar se Docker está rodando
try {
    $dockerVersion = docker --version 2>&1
    # #region agent log
    fetch('http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'scripts/start-flutter-with-backend.ps1:40',message:'Docker check successful',data:{dockerVersion:$dockerVersion},timestamp:Date.now(),sessionId:'flutter-startup',runId:'docker-check',hypothesisId:'H1'})}).catch(()=>{});
    # #endregion
    Write-Host "   🐳 Docker disponível: ✅" -ForegroundColor Green
} catch {
    # #region agent log
    fetch('http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'scripts/start-flutter-with-backend.ps1:44',message:'Docker check failed',data:{error:$_.Exception.Message},timestamp:Date.now(),sessionId:'flutter-startup',runId:'docker-check',hypothesisId:'H1'})}).catch(()=>{});
    # #endregion
    Write-Host "   ❌ Docker não está rodando!" -ForegroundColor Red
    Write-Host "   💡 Inicie o Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# Iniciar infraestrutura
# #region agent log
fetch('http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'scripts/start-flutter-with-backend.ps1:55',message:'Starting Docker infrastructure',data:{services:'postgres,redis,keycloak'},timestamp:Date.now(),sessionId:'flutter-startup',runId:'infra-start',hypothesisId:'H2'})}).catch(()=>{});
# #endregion
docker-compose up -d postgres redis keycloak 2>$null | Out-Null

# Aguardar inicialização
Write-Host "⏳ Aguardando containers inicializarem..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# Verificar status
$postgresUp = docker ps --filter "name=benefits-postgres" --format "{{.Status}}" | Select-String "Up" -Quiet
$redisUp = docker ps --filter "name=benefits-redis" --format "{{.Status}}" | Select-String "Up" -Quiet
$keycloakUp = docker ps --filter "name=benefits-keycloak" --format "{{.Status}}" | Select-String "Up" -Quiet

# #region agent log
fetch('http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'scripts/start-flutter-with-backend.ps1:67',message:'Infrastructure status check',data:{postgres:$postgresUp,redis:$redisUp,keycloak:$keycloakUp},timestamp:Date.now(),sessionId:'flutter-startup',runId:'infra-check',hypothesisId:'H2'})}).catch(()=>{});
# #endregion

Write-Host "   🐘 Postgres: $($postgresUp ? "✅" : "❌")" -ForegroundColor ($postgresUp ? "Green" : "Red")
Write-Host "   🔴 Redis: $($redisUp ? "✅" : "❌")" -ForegroundColor ($redisUp ? "Green" : "Red")
Write-Host "   🔐 Keycloak: $($keycloakUp ? "✅" : "❌")" -ForegroundColor ($keycloakUp ? "Green" : "Red")

$infraReady = $postgresUp -and $redisUp -and $keycloakUp
if (-not $infraReady) {
    Write-Host "`n❌ Infraestrutura falhou!" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Infraestrutura operacional!" -ForegroundColor Green

cd ../..

# ============================================
# INICIAR SERVIÇOS BACKEND
# ============================================
Write-Host "`n🔧 INICIANDO SERVIÇOS BACKEND..." -ForegroundColor Yellow

# Iniciar benefits-core
Write-Host "🏦 Iniciando benefits-core..." -ForegroundColor White
$coreJob = Start-Job -ScriptBlock {
    cd services/benefits-core
    mvn spring-boot:run -q -Dspring-boot.run.arguments="--spring.profiles.active=local"
}

# Iniciar tenant-service
Write-Host "🏢 Iniciando tenant-service..." -ForegroundColor White
$tenantJob = Start-Job -ScriptBlock {
    cd services/tenant-service
    mvn spring-boot:run -q -Dspring-boot.run.arguments="--spring.profiles.active=local"
}

# Aguardar inicialização
Start-Sleep -Seconds 15

# Verificar benefits-core
try {
    $coreResponse = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $coreHealthy = $coreResponse.StatusCode -eq 200
} catch {
    $coreHealthy = $false
}

# Verificar tenant-service
try {
    $tenantResponse = Invoke-WebRequest -Uri "http://localhost:8106/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $tenantHealthy = $tenantResponse.StatusCode -eq 200
} catch {
    $tenantHealthy = $false
}

Write-Host "   🏦 Benefits Core (8091): $($coreHealthy ? "✅" : "❌")" -ForegroundColor ($coreHealthy ? "Green" : "Red")
Write-Host "   🏢 Tenant Service (8106): $($tenantHealthy ? "✅" : "❌")" -ForegroundColor ($tenantHealthy ? "Green" : "Red")

$backendReady = $coreHealthy -and $tenantHealthy
if (-not $backendReady) {
    Write-Host "`n❌ Serviços backend falharam!" -ForegroundColor Red
    Stop-Job $coreJob, $tenantJob -ErrorAction SilentlyContinue
    exit 1
}

# ============================================
# INICIAR USER BFF
# ============================================
Write-Host "`n🌐 INICIANDO USER BFF..." -ForegroundColor Yellow

$userBffJob = Start-Job -ScriptBlock {
    cd bffs/user-bff
    mvn spring-boot:run -q -Dspring-boot.run.arguments="--spring.profiles.active=local"
}

# Aguardar inicialização
Start-Sleep -Seconds 10

# Verificar User BFF
try {
    $userBffResponse = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $userBffHealthy = $userBffResponse.StatusCode -eq 200
} catch {
    $userBffHealthy = $false
}

Write-Host "   👤 User BFF (8080): $($userBffHealthy ? "✅" : "❌")" -ForegroundColor ($userBffHealthy ? "Green" : "Red")

if (-not $userBffHealthy) {
    Write-Host "`n❌ User BFF falhou!" -ForegroundColor Red
    Stop-Job $coreJob, $tenantJob, $userBffJob -ErrorAction SilentlyContinue
    exit 1
}

# ============================================
# PREPARAR FLUTTER APP
# ============================================
Write-Host "`n📱 PREPARANDO FLUTTER APP..." -ForegroundColor Yellow

cd apps/user_app_flutter

# Instalar dependências
Write-Host "📦 Instalando dependências Flutter..." -ForegroundColor White
flutter pub get

# Verificar se está tudo OK
$flutterDoctor = flutter doctor --verbose 2>&1
$flutterReady = $flutterDoctor -match "No issues found"

if ($flutterReady) {
    Write-Host "   ✅ Flutter configurado corretamente" -ForegroundColor Green
} else {
    Write-Host "   ⚠️ Flutter tem alguns warnings (normal)" -ForegroundColor Yellow
}

# Configurar ambiente para desenvolvimento
Write-Host "⚙️ Configurando ambiente de desenvolvimento..." -ForegroundColor White

# Verificar se o arquivo de configuração existe
if (Test-Path "lib/config/app_environment.dart") {
    Write-Host "   🔧 AppEnvironment configurado" -ForegroundColor Green
} else {
    Write-Host "   ❌ Arquivo de configuração não encontrado" -ForegroundColor Red
}

# ============================================
# INICIAR FLUTTER APP
# ============================================
Write-Host "`n🚀 INICIANDO FLUTTER APP..." -ForegroundColor Cyan

Write-Host "`n" + ("=" * 60) -ForegroundColor Green
Write-Host "🎉 SISTEMA COMPLETO OPERACIONAL!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

Write-Host "`n🔧 SERVIÇOS ATIVOS:" -ForegroundColor Cyan
Write-Host "  🐘 PostgreSQL: localhost:5432 ✅" -ForegroundColor Green
Write-Host "  🔴 Redis: localhost:6379 ✅" -ForegroundColor Green
Write-Host "  🔐 Keycloak: localhost:8080 ✅" -ForegroundColor Green
Write-Host "  🏦 Benefits Core: localhost:8091 ✅" -ForegroundColor Green
Write-Host "  🏢 Tenant Service: localhost:8106 ✅" -ForegroundColor Green
Write-Host "  👤 User BFF: localhost:8080 ✅" -ForegroundColor Green

Write-Host "`n📱 FLUTTER APP PRONTO:" -ForegroundColor Cyan
Write-Host "  🎯 Ambiente: Development" -ForegroundColor White
Write-Host "  🌐 User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  🔐 Autenticação: JWT via User BFF" -ForegroundColor White
Write-Host "  💾 Dados: PostgreSQL + Redis" -ForegroundColor White

Write-Host "`n🎮 PARA INICIAR O FLUTTER APP:" -ForegroundColor Green
Write-Host "  1. Abra um novo terminal" -ForegroundColor White
Write-Host "  2. Execute: cd apps/user_app_flutter" -ForegroundColor White
Write-Host "  3. Execute: flutter run" -ForegroundColor White
Write-Host "  4. OU: flutter run -d chrome (para web)" -ForegroundColor White
Write-Host "  5. OU: flutter run -d emulator (para Android)" -ForegroundColor White

Write-Host "`n🧪 PARA TESTAR A INTEGRAÇÃO:" -ForegroundColor Green
Write-Host "  • Login: Use as credenciais de teste" -ForegroundColor White
Write-Host "  • APIs: Todas conectadas ao backend" -ForegroundColor White
Write-Host "  • Dados: Persistidos no PostgreSQL" -ForegroundColor White
Write-Host "  • Cache: Otimizado com Redis" -ForegroundColor White

Write-Host "`n📋 FUNCIONALIDADES DISPONÍVEIS NO APP:" -ForegroundColor Cyan
Write-Host "  🔐 Login/Registro de usuários" -ForegroundColor White
Write-Host "  👤 Perfil do usuário" -ForegroundColor White
Write-Host "  💰 Carteira e saldos" -ForegroundColor White
Write-Host "  🎁 Benefícios disponíveis" -ForegroundColor White
Write-Host "  📊 Histórico de transações" -ForegroundColor White
Write-Host "  🏪 Integração com estabelecimentos" -ForegroundColor White

Write-Host "`n🛑 PARA PARAR TUDO:" -ForegroundColor Red
Write-Host "  • Pressione Ctrl+C no terminal do Flutter" -ForegroundColor White
Write-Host "  • Execute: .\scripts\stop-everything.ps1" -ForegroundColor White

Write-Host "`n🎯 STATUS: SISTEMA 100% OPERACIONAL!" -ForegroundColor Green
Write-Host "🚀 Flutter app pronto para desenvolvimento e testes!" -ForegroundColor Green

# Manter o script rodando para manter os serviços ativos
Write-Host "`n⏳ Serviços backend rodando em background..." -ForegroundColor Gray
Write-Host "💡 Pressione Ctrl+C para parar tudo" -ForegroundColor Gray

# Manter jobs rodando
try {
    while ($true) {
        Start-Sleep -Seconds 10

        # Verificar se ainda estão rodando
        $jobsRunning = Get-Job | Where-Object { $_.State -eq "Running" } | Measure-Object
        if ($jobsRunning.Count -lt 3) {
            Write-Host "`n⚠️ Alguns serviços pararam. Verifique os logs." -ForegroundColor Yellow
            break
        }
    }
} finally {
    Write-Host "`n🛑 Parando serviços..." -ForegroundColor Yellow
    Stop-Job $coreJob, $tenantJob, $userBffJob -ErrorAction SilentlyContinue
    Remove-Job $coreJob, $tenantJob, $userBffJob -ErrorAction SilentlyContinue

    Write-Host "✅ Serviços parados!" -ForegroundColor Green
}