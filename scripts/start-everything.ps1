# start-everything.ps1 - Inicia Todo o Sistema para Testes Manuais
# Executar: .\scripts\start-everything.ps1

Write-Host "🚀 [START-EVERYTHING] Iniciando sistema completo para testes manuais..." -ForegroundColor Cyan

# #region agent log
try {
    Invoke-WebRequest -Uri 'http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033' -Method POST -ContentType 'application/json' -Body (@{
        sessionId = 'debug-session'
        runId = 'full-system-startup'
        hypothesisId = 'START'
        location = 'start-everything.ps1:5'
        message = 'Full system startup initiated'
        data = @{script = 'start-everything.ps1'; action = 'start_all'}
        timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    } | ConvertTo-Json) -UseBasicParsing
} catch {}
# #endregion

# ============================================
# FASE 1: INFRAESTRUTURA
# ============================================
Write-Host "`n🏗️  [FASE 1] Iniciando Infraestrutura..." -ForegroundColor Yellow

Write-Host "🐳 Iniciando Docker containers..." -ForegroundColor White
cd infra/docker
docker-compose up -d postgres redis
cd ../..

Write-Host "⏳ Aguardando infraestrutura ficar pronta..." -ForegroundColor White
Start-Sleep -Seconds 10

# Verificar se containers estão rodando
$postgresStatus = docker ps --filter "name=benefits-postgres" --format "{{.Status}}" | Select-Object -First 1
$redisStatus = docker ps --filter "name=benefits-redis" --format "{{.Status}}" | Select-Object -First 1

if ($postgresStatus -and $redisStatus) {
    Write-Host "✅ Infraestrutura OK - Postgres: $postgresStatus | Redis: $redisStatus" -ForegroundColor Green
} else {
    Write-Host "❌ Problema na infraestrutura" -ForegroundColor Red
    exit 1
}

# ============================================
# FASE 2: SEEDS DO BANCO
# ============================================
Write-Host "`n🌱 [FASE 2] Aplicando Seeds do Banco..." -ForegroundColor Yellow

Write-Host "📊 Aplicando seeds..." -ForegroundColor White
# Aqui seria o comando para aplicar seeds - por enquanto simulado
Write-Host "✅ Seeds aplicados (simulado)" -ForegroundColor Green

# ============================================
# FASE 3: SERVIÇOS CORE
# ============================================
Write-Host "`n🔧 [FASE 3] Iniciando Serviços Core..." -ForegroundColor Yellow

$services = @(
    @{Name = "benefits-core"; Port = "8091"; Path = "services/benefits-core"},
    @{Name = "tenant-service"; Port = "8092"; Path = "services/tenant-service"},
    @{Name = "identity-service"; Port = "8087"; Path = "services/identity-service"},
    @{Name = "payments-orchestrator"; Port = "8088"; Path = "services/payments-orchestrator"},
    @{Name = "merchant-service"; Port = "8089"; Path = "services/merchant-service"}
)

$runningServices = @()

foreach ($service in $services) {
    Write-Host "🚀 Iniciando $($service.Name) na porta $($service.Port)..." -ForegroundColor White

    try {
        $job = Start-Job -ScriptBlock {
            param($path, $name)
            Set-Location $path
            mvn spring-boot:run -q
        } -ArgumentList $service.Path, $service.Name

        $runningServices += @{Name = $service.Name; Job = $job; Port = $service.Port}

        Write-Host "✅ $($service.Name) iniciado em background" -ForegroundColor Green
        Start-Sleep -Seconds 5
    } catch {
        Write-Host "⚠️  $($service.Name) falhou ao iniciar: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ============================================
# FASE 4: BFFs
# ============================================
Write-Host "`n🌐 [FASE 4] Iniciando BFFs..." -ForegroundColor Yellow

$bffs = @(
    @{Name = "user-bff"; Port = "8080"; Path = "services/user-bff"},
    @{Name = "employer-bff"; Port = "8083"; Path = "services/employer-bff"},
    @{Name = "support-bff"; Port = "8086"; Path = "services/support-bff"},
    @{Name = "platform-bff"; Port = "8097"; Path = "services/platform-bff"},
    @{Name = "admin-bff"; Port = "8099"; Path = "services/admin-bff"}
)

foreach ($bff in $bffs) {
    Write-Host "🚀 Iniciando $($bff.Name) na porta $($bff.Port)..." -ForegroundColor White

    try {
        $job = Start-Job -ScriptBlock {
            param($path, $name)
            Set-Location $bff.Path
            mvn spring-boot:run -q
        } -ArgumentList $bff.Path, $bff.Name

        $runningServices += @{Name = $bff.Name; Job = $job; Port = $bff.Port}

        Write-Host "✅ $($bff.Name) iniciado em background" -ForegroundColor Green
        Start-Sleep -Seconds 3
    } catch {
        Write-Host "⚠️  $($bff.Name) falhou ao iniciar: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ============================================
# FASE 5: STATUS FINAL
# ============================================
Write-Host "`n📊 [STATUS] Sistema Iniciado!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

Write-Host "`n🔗 SERVIÇOS DISPONÍVEIS:" -ForegroundColor Cyan
foreach ($service in $runningServices) {
    Write-Host "  📡 $($service.Name) → http://localhost:$($service.Port)" -ForegroundColor White
}

Write-Host "`n🗄️  BANCO DE DADOS:" -ForegroundColor Cyan
Write-Host "  🐘 PostgreSQL → localhost:5432" -ForegroundColor White
Write-Host "  🔴 Redis → localhost:6379" -ForegroundColor White

Write-Host "`n🧪 TESTES MANUAIS DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  🔍 Health Checks Básicos:" -ForegroundColor White
Write-Host "    • curl http://localhost:8091/actuator/health  # Benefits Core" -ForegroundColor Gray
Write-Host "    • curl http://localhost:8080/actuator/health   # User BFF" -ForegroundColor Gray
Write-Host "    • curl http://localhost:8097/actuator/health   # Platform BFF" -ForegroundColor Gray
Write-Host ""
Write-Host "  📋 APIs de Autenticação:" -ForegroundColor White
Write-Host "    • POST http://localhost:8080/api/v1/auth/test" -ForegroundColor Gray
Write-Host "      Body: {}" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    • POST http://localhost:8087/internal/identity/persons" -ForegroundColor Gray
Write-Host "      Header: X-Tenant-Id: 550e8400-e29b-41d4-a716-446655440000" -ForegroundColor DarkGray
Write-Host "      Body: {\"name\":\"Test User\",\"email\":\"test@example.com\",\"documentNumber\":\"12345678901\",\"birthDate\":\"1990-01-01\"}" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  💰 APIs de Benefits:" -ForegroundColor White
Write-Host "    • POST http://localhost:8091/internal/batches/credits" -ForegroundColor Gray
Write-Host "      Header: X-Tenant-Id: 550e8400-e29b-41d4-a716-446655440000" -ForegroundColor DarkGray
Write-Host "      Header: X-Employer-Id: 550e8400-e29b-41d4-a716-446655440001" -ForegroundColor DarkGray
Write-Host "      Header: Idempotency-Key: test-123" -ForegroundColor DarkGray
Write-Host "      Body: {\"employerId\":\"550e8400-e29b-41d4-a716-446655440001\",\"items\":[{\"personId\":\"550e8400-e29b-41d4-a716-446655440002\",\"amount\":1000.00,\"description\":\"Test credit\"}]}" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    • GET http://localhost:8080/api/v1/catalog  # Via BFF" -ForegroundColor Gray
Write-Host ""
Write-Host "  🔄 APIs de Integração:" -ForegroundColor White
Write-Host "    • GET http://localhost:8097/api/v1/platform/health/services" -ForegroundColor Gray
Write-Host ""
Write-Host "    • POST http://localhost:8086/api/v1/expenses  # Support BFF" -ForegroundColor Gray
Write-Host "      Body: {\"amount\":75.50,\"description\":\"Test expense\",\"category\":\"Meals\",\"currency\":\"BRL\"}" -ForegroundColor DarkGray

Write-Host "`n🎮 SCRIPTS DE TESTE DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  • .\scripts\smoke.ps1 - Testes básicos de saúde" -ForegroundColor White
Write-Host "  • .\scripts\integration-test.ps1 - Testes de integração" -ForegroundColor White
Write-Host "  • .\scripts\load-test.ps1 - Testes de carga" -ForegroundColor White

Write-Host "`n📱 FRONTENDS PARA TESTE MANUAL:" -ForegroundColor Cyan
Write-Host "  • Flutter App: cd apps/app-user-flutter && flutter run" -ForegroundColor White
Write-Host "  • Angular Portal: cd portals/portal-admin-angular && npm start" -ForegroundColor White

Write-Host "`n🛑 PARA PARAR TUDO:" -ForegroundColor Red
Write-Host "  • .\scripts\stop-everything.ps1" -ForegroundColor White
Write-Host "  • Ou pressione Ctrl+C múltiplas vezes" -ForegroundColor White

Write-Host "`n🎯 SISTEMA PRONTO PARA TESTES MANUAIS!" -ForegroundColor Green
Write-Host "💡 Execute os comandos abaixo em terminais separados para testar tudo:" -ForegroundColor Cyan

Write-Host "`n📋 INSTRUÇÕES PARA TESTE MANUAL COMPLETO:" -ForegroundColor Yellow
Write-Host "1️⃣  Abra um novo terminal PowerShell" -ForegroundColor White
Write-Host "2️⃣  Execute: .\scripts\test-manual-apis.ps1" -ForegroundColor White
Write-Host "3️⃣  Aguarde os testes rodarem automaticamente" -ForegroundColor White
Write-Host "4️⃣  Verifique os resultados (✅ SUCCESS = funcionando)" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Para testar individualmente:" -ForegroundColor Cyan
Write-Host "  • curl http://localhost:8091/actuator/health" -ForegroundColor Gray
Write-Host "  • Abra navegador: http://localhost:8080 (se BFF rodando)" -ForegroundColor Gray
Write-Host "  • Teste mobile: cd apps/app-user-flutter && flutter run" -ForegroundColor Gray

# Aguardar input do usuário
Write-Host "`n⏳ Pressione Enter para manter serviços rodando, ou Ctrl+C para parar..." -ForegroundColor Yellow
Read-Host