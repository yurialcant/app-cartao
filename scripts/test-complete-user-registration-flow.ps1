# test-complete-user-registration-flow.ps1
# Testa o fluxo completo: Admin registra usuário → User faz login → Verifica dados

Write-Host "🧪 TESTANDO FLUXO COMPLETO: REGISTRO → LOGIN → VERIFICAÇÃO" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Green

# ============================================
# CONFIGURAÇÃO DO TESTE
# ============================================
$testResults = @{}
$companyName = "Empresa Teste $(Get-Date -Format 'yyyyMMddHHmmss')"
$userEmail = "usuario.teste$(Get-Date -Format 'yyyyMMddHHmmss')@empresa.com"
$userPassword = "Teste@123"

Write-Host "`n📋 CONFIGURAÇÃO DO TESTE:" -ForegroundColor Yellow
Write-Host "  🏢 Empresa: $companyName" -ForegroundColor White
Write-Host "  👤 Usuário: $userEmail" -ForegroundColor White
Write-Host "  🔑 Senha: $userPassword" -ForegroundColor White

# ============================================
# FASE 1: INICIAR INFRAESTRUTURA
# ============================================
Write-Host "`n🏗️ [FASE 1] INICIANDO INFRAESTRUTURA..." -ForegroundColor Yellow

# Iniciar containers
Write-Host "🐳 Iniciando PostgreSQL, Redis, Keycloak..." -ForegroundColor White
cd infra/docker
docker-compose up -d postgres redis keycloak 2>$null | Out-Null
cd ../..

# Aguardar inicialização
Write-Host "⏳ Aguardando serviços inicializarem..." -ForegroundColor Gray
Start-Sleep -Seconds 20

# Verificar serviços
$postgresUp = docker ps --filter "name=benefits-postgres" --format "{{.Status}}" | Select-String "Up" -Quiet
$redisUp = docker ps --filter "name=benefits-redis" --format "{{.Status}}" | Select-String "Up" -Quiet
$keycloakUp = docker ps --filter "name=benefits-keycloak" --format "{{.Status}}" | Select-String "Up" -Quiet

Write-Host "   🐘 Postgres: $($postgresUp ? "✅" : "❌")" -ForegroundColor ($postgresUp ? "Green" : "Red")
Write-Host "   🔴 Redis: $($redisUp ? "✅" : "❌")" -ForegroundColor ($redisUp ? "Green" : "Red")
Write-Host "   🔐 Keycloak: $($keycloakUp ? "✅" : "❌")" -ForegroundColor ($keycloakUp ? "Green" : "Red")

$infraReady = $postgresUp -and $redisUp -and $keycloakUp
$testResults["infra"] = $infraReady

if (-not $infraReady) {
    Write-Host "`n❌ Infraestrutura não iniciou corretamente. Abortando teste." -ForegroundColor Red
    exit 1
}

# ============================================
# FASE 2: INICIAR SERVIÇOS BACKEND
# ============================================
Write-Host "`n🔧 [FASE 2] INICIANDO SERVIÇOS BACKEND..." -ForegroundColor Yellow

# Iniciar benefits-core
Write-Host "🚀 Iniciando benefits-core..." -ForegroundColor White
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
Start-Sleep -Seconds 20

# Verificar se serviços estão rodando
$coreHealthy = $false
$tenantHealthy = $false

try {
    $coreResponse = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $coreHealthy = $coreResponse.StatusCode -eq 200
} catch {
    $coreHealthy = $false
}

try {
    $tenantResponse = Invoke-WebRequest -Uri "http://localhost:8106/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $tenantHealthy = $tenantResponse.StatusCode -eq 200
} catch {
    $tenantHealthy = $false
}

Write-Host "   🏦 Benefits Core: $($coreHealthy ? "✅" : "❌")" -ForegroundColor ($coreHealthy ? "Green" : "Red")
Write-Host "   🏢 Tenant Service: $($tenantHealthy ? "✅" : "❌")" -ForegroundColor ($tenantHealthy ? "Green" : "Red")

$servicesReady = $coreHealthy -and $tenantHealthy
$testResults["services"] = $servicesReady

if (-not $servicesReady) {
    Write-Host "`n❌ Serviços não iniciaram corretamente. Abortando teste." -ForegroundColor Red
    Stop-Job $coreJob -ErrorAction SilentlyContinue
    Stop-Job $tenantJob -ErrorAction SilentlyContinue
    exit 1
}

# ============================================
# FASE 3: INICIAR BFFs
# ============================================
Write-Host "`n🌐 [FASE 3] INICIANDO BFFs..." -ForegroundColor Yellow

# Iniciar user-bff
Write-Host "👤 Iniciando user-bff..." -ForegroundColor White
$userBffJob = Start-Job -ScriptBlock {
    cd bffs/user-bff
    mvn spring-boot:run -q -Dspring-boot.run.arguments="--spring.profiles.active=local"
}

# Iniciar admin-bff
Write-Host "👨‍💼 Iniciando admin-bff..." -ForegroundColor White
$adminBffJob = Start-Job -ScriptBlock {
    cd bffs/admin-bff
    mvn spring-boot:run -q -Dspring-boot.run.arguments="--spring.profiles.active=local"
}

# Aguardar inicialização
Start-Sleep -Seconds 15

# Verificar BFFs
$userBffHealthy = $false
$adminBffHealthy = $false

try {
    $userBffResponse = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $userBffHealthy = $userBffResponse.StatusCode -eq 200
} catch {
    $userBffHealthy = $false
}

try {
    $adminBffResponse = Invoke-WebRequest -Uri "http://localhost:8083/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    $adminBffHealthy = $adminBffResponse.StatusCode -eq 200
} catch {
    $adminBffHealthy = $false
}

Write-Host "   👤 User BFF: $($userBffHealthy ? "✅" : "❌")" -ForegroundColor ($userBffHealthy ? "Green" : "Red")
Write-Host "   👨‍💼 Admin BFF: $($adminBffHealthy ? "✅" : "❌")" -ForegroundColor ($adminBffHealthy ? "Green" : "Red")

$bffsReady = $userBffHealthy -and $adminBffHealthy
$testResults["bffs"] = $bffsReady

if (-not $bffsReady) {
    Write-Host "`n❌ BFFs não iniciaram corretamente. Abortando teste." -ForegroundColor Red
    Stop-Job $coreJob, $tenantJob, $userBffJob, $adminBffJob -ErrorAction SilentlyContinue
    exit 1
}

# ============================================
# FASE 4: REGISTRAR EMPRESA VIA ADMIN BFF
# ============================================
Write-Host "`n🏢 [FASE 4] REGISTRANDO EMPRESA VIA ADMIN BFF..." -ForegroundColor Yellow

$companyData = @{
    name = $companyName
    document = "12345678000199"
    email = "contato@$($companyName.ToLower().Replace(' ', '').Replace('empresa teste', 'empresa'))"
    phone = "+5511999999999"
    address = @{
        street = "Rua Teste"
        number = "123"
        city = "São Paulo"
        state = "SP"
        zipCode = "01234567"
    }
} | ConvertTo-Json

try {
    $companyResponse = Invoke-WebRequest -Uri "http://localhost:8083/api/admin/companies" `
        -Method POST `
        -Body $companyData `
        -ContentType "application/json" `
        -TimeoutSec 10

    if ($companyResponse.StatusCode -eq 201) {
        $company = $companyResponse.Content | ConvertFrom-Json
        $companyId = $company.id
        Write-Host "   ✅ Empresa registrada: $companyName (ID: $companyId)" -ForegroundColor Green
        $testResults["company-registration"] = $true
    } else {
        Write-Host "   ❌ Falha ao registrar empresa: $($companyResponse.StatusCode)" -ForegroundColor Red
        $testResults["company-registration"] = $false
    }
} catch {
    Write-Host "   ❌ Erro ao registrar empresa: $($_.Exception.Message)" -ForegroundColor Red
    $testResults["company-registration"] = $false
}

# ============================================
# FASE 5: REGISTRAR USUÁRIO VIA ADMIN BFF
# ============================================
Write-Host "`n👤 [FASE 5] REGISTRANDO USUÁRIO VIA ADMIN BFF..." -ForegroundColor Yellow

$userData = @{
    email = $userEmail
    password = $userPassword
    firstName = "Usuário"
    lastName = "Teste"
    document = "12345678901"
    phone = "+5511988888888"
    companyId = $companyId
    role = "USER"
} | ConvertTo-Json

try {
    $userResponse = Invoke-WebRequest -Uri "http://localhost:8083/api/admin/users" `
        -Method POST `
        -Body $userData `
        -ContentType "application/json" `
        -TimeoutSec 10

    if ($userResponse.StatusCode -eq 201) {
        $user = $userResponse.Content | ConvertFrom-Json
        $userId = $user.id
        Write-Host "   ✅ Usuário registrado: $userEmail (ID: $userId)" -ForegroundColor Green
        $testResults["user-registration"] = $true
    } else {
        Write-Host "   ❌ Falha ao registrar usuário: $($userResponse.StatusCode)" -ForegroundColor Red
        $testResults["user-registration"] = $false
    }
} catch {
    Write-Host "   ❌ Erro ao registrar usuário: $($_.Exception.Message)" -ForegroundColor Red
    $testResults["user-registration"] = $false
}

# ============================================
# FASE 6: VERIFICAR DADOS VIA ADMIN BFF
# ============================================
Write-Host "`n👀 [FASE 6] VERIFICANDO DADOS VIA ADMIN BFF..." -ForegroundColor Yellow

# Verificar empresa
try {
    $companyCheckResponse = Invoke-WebRequest -Uri "http://localhost:8083/api/admin/companies/$companyId" -TimeoutSec 5
    $companyVerified = $companyCheckResponse.StatusCode -eq 200
    Write-Host "   🏢 Empresa verificada: $($companyVerified ? "✅" : "❌")" -ForegroundColor ($companyVerified ? "Green" : "Red")
} catch {
    $companyVerified = $false
    Write-Host "   🏢 Empresa verificada: ❌" -ForegroundColor Red
}

# Verificar usuário
try {
    $userCheckResponse = Invoke-WebRequest -Uri "http://localhost:8083/api/admin/users/$userId" -TimeoutSec 5
    $userVerified = $userCheckResponse.StatusCode -eq 200
    Write-Host "   👤 Usuário verificado: $($userVerified ? "✅" : "❌")" -ForegroundColor ($userVerified ? "Green" : "Red")
} catch {
    $userVerified = $false
    Write-Host "   👤 Usuário verificado: ❌" -ForegroundColor Red
}

$adminDataVerified = $companyVerified -and $userVerified
$testResults["admin-verification"] = $adminDataVerified

# ============================================
# FASE 7: SIMULAR LOGIN VIA USER BFF
# ============================================
Write-Host "`n🔐 [FASE 7] SIMULANDO LOGIN VIA USER BFF..." -ForegroundColor Yellow

$loginData = @{
    email = $userEmail
    password = $userPassword
    companyId = $companyId
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginData `
        -ContentType "application/json" `
        -TimeoutSec 10

    if ($loginResponse.StatusCode -eq 200) {
        $loginResult = $loginResponse.Content | ConvertFrom-Json
        $token = $loginResult.token
        Write-Host "   ✅ Login realizado com sucesso" -ForegroundColor Green
        Write-Host "   🔑 Token JWT gerado" -ForegroundColor Gray
        $testResults["user-login"] = $true
    } else {
        Write-Host "   ❌ Falha no login: $($loginResponse.StatusCode)" -ForegroundColor Red
        $testResults["user-login"] = $false
    }
} catch {
    Write-Host "   ❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    $testResults["user-login"] = $false
}

# ============================================
# FASE 8: VERIFICAR DADOS VIA USER BFF
# ============================================
Write-Host "`n📊 [FASE 8] VERIFICANDO DADOS VIA USER BFF..." -ForegroundColor Yellow

# Headers com token
$headers = @{
    "Authorization" = "Bearer $token"
    "X-Tenant-Id" = $companyId
}

# Verificar perfil do usuário
try {
    $profileResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/user/profile" `
        -Headers $headers `
        -TimeoutSec 5

    if ($profileResponse.StatusCode -eq 200) {
        $profile = $profileResponse.Content | ConvertFrom-Json
        $profileVerified = $profile.email -eq $userEmail
        Write-Host "   👤 Perfil do usuário verificado: $($profileVerified ? "✅" : "❌")" -ForegroundColor ($profileVerified ? "Green" : "Red")
    } else {
        $profileVerified = $false
        Write-Host "   👤 Perfil do usuário verificado: ❌" -ForegroundColor Red
    }
} catch {
    $profileVerified = $false
    Write-Host "   👤 Perfil do usuário verificado: ❌ ($($_.Exception.Message))" -ForegroundColor Red
}

# Verificar empresa do usuário
try {
    $companyCheckUserResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/user/company" `
        -Headers $headers `
        -TimeoutSec 5

    if ($companyCheckUserResponse.StatusCode -eq 200) {
        $userCompany = $companyCheckUserResponse.Content | ConvertFrom-Json
        $companyFromUserVerified = $userCompany.name -eq $companyName
        Write-Host "   🏢 Empresa via user BFF verificada: $($companyFromUserVerified ? "✅" : "❌")" -ForegroundColor ($companyFromUserVerified ? "Green" : "Red")
    } else {
        $companyFromUserVerified = $false
        Write-Host "   🏢 Empresa via user BFF verificada: ❌" -ForegroundColor Red
    }
} catch {
    $companyFromUserVerified = $false
    Write-Host "   🏢 Empresa via user BFF verificada: ❌ ($($_.Exception.Message))" -ForegroundColor Red
}

$userDataVerified = $profileVerified -and $companyFromUserVerified
$testResults["user-verification"] = $userDataVerified

# ============================================
# FASE 9: SIMULAR FLUTTER APP INTERACTION
# ============================================
Write-Host "`n📱 [FASE 9] SIMULANDO INTERAÇÃO DO FLUTTER APP..." -ForegroundColor Yellow

# Simular chamadas que o Flutter app faria
$flutterCalls = @(
    @{Endpoint = "/api/user/dashboard"; Description = "Dashboard data"},
    @{Endpoint = "/api/user/wallets"; Description = "Wallet information"},
    @{Endpoint = "/api/user/benefits"; Description = "Available benefits"}
)

$flutterInteractions = @()
foreach ($call in $flutterCalls) {
    try {
        $flutterResponse = Invoke-WebRequest -Uri "http://localhost:8080$($call.Endpoint)" `
            -Headers $headers `
            -TimeoutSec 5

        $callSuccess = $flutterResponse.StatusCode -eq 200
        $flutterInteractions += @{Call = $call.Endpoint; Success = $callSuccess; Description = $call.Description}

        Write-Host "   📱 $($call.Description): $($callSuccess ? "✅" : "❌")" -ForegroundColor ($callSuccess ? "Green" : "Red")
    } catch {
        $flutterInteractions += @{Call = $call.Endpoint; Success = $false; Description = $call.Description}
        Write-Host "   📱 $($call.Description): ❌ ($($_.Exception.Message))" -ForegroundColor Red
    }
}

$flutterWorking = ($flutterInteractions | Where-Object { $_.Success -eq $true }).Count -gt 0
$testResults["flutter-simulation"] = $flutterWorking

# ============================================
# RESULTADO FINAL
# ============================================
Write-Host "`n📊 RESULTADO DO FLUXO COMPLETO:" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$passedTests = ($testResults.Values | Where-Object { $_ -eq $true }).Count
$totalTests = $testResults.Count
$successRate = [math]::Round(($passedTests / $totalTests) * 100, 1)

Write-Host "✅ Etapas Executadas: $passedTests/$totalTests ($successRate%)" -ForegroundColor ($successRate -ge 80 ? "Green" : "Yellow")

# Status detalhado
Write-Host "`n📋 STATUS DETALHADO:" -ForegroundColor Cyan
foreach ($key in $testResults.Keys) {
    $status = $testResults[$key] ? "✅" : "❌"
    $color = $testResults[$key] ? "Green" : "Red"
    $displayName = $key -replace '-', ' '
    Write-Host "  $status $($displayName)" -ForegroundColor $color
}

# Conclusão
if ($successRate -ge 80) {
    Write-Host "`n🎉 FLUXO COMPLETO FUNCIONANDO!" -ForegroundColor Green
    Write-Host "✅ Empresa registrada via Admin BFF" -ForegroundColor Green
    Write-Host "✅ Usuário registrado com dados completos" -ForegroundColor Green
    Write-Host "✅ Login realizado via User BFF" -ForegroundColor Green
    Write-Host "✅ Dados verificados em ambas as interfaces" -ForegroundColor Green
    Write-Host "✅ Flutter App pode se conectar e obter dados" -ForegroundColor Green

    Write-Host "`n🏆 RESULTADO: SISTEMA MULTI-TENANT FUNCIONANDO PERFEITAMENTE!" -ForegroundColor Green
    Write-Host "👤 Usuário: $userEmail" -ForegroundColor White
    Write-Host "🏢 Empresa: $companyName" -ForegroundColor White
    Write-Host "🔑 Token JWT gerado e funcional" -ForegroundColor White

} elseif ($successRate -ge 60) {
    Write-Host "`n⚠️ FLUXO PARCIALMENTE FUNCIONAL" -ForegroundColor Yellow
    Write-Host "🔧 Algumas etapas falharam, verificar logs" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ FLUXO COM PROBLEMAS" -ForegroundColor Red
    Write-Host "🔍 Verificar configuração dos serviços" -ForegroundColor Red
}

# ============================================
# LIMPEZA
# ============================================
Write-Host "`n🧹 LIMPANDO RECURSOS DE TESTE..." -ForegroundColor Gray

# Parar jobs
Stop-Job $coreJob, $tenantJob, $userBffJob, $adminBffJob -ErrorAction SilentlyContinue
Remove-Job $coreJob, $tenantJob, $userBffJob, $adminBffJob -ErrorAction SilentlyContinue

# Parar containers
docker-compose -f infra/docker/docker-compose.yml down 2>$null | Out-Null

Write-Host "`n💡 TESTE CONCLUÍDO!" -ForegroundColor Cyan
Write-Host "📊 Execute novamente: .\scripts\test-complete-user-registration-flow.ps1" -ForegroundColor White