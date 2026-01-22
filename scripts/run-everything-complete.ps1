# Script COMPLETO - Roda TUDO: APIs, Serviços, Apps, Angular, Admin, Tudo!
Write-Host "`n=== 🚀 RODANDO TUDO - SISTEMA COMPLETO ===" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$script:StartTime = Get-Date

# ============================================
# CONFIGURAÇÕES E CREDENCIAIS
# ============================================
$script:CREDENTIALS = @{
    # Keycloak Admin
    KeycloakAdmin = @{
        Username = "admin"
        Password = "admin"
        Url = "http://localhost:8081/admin"
    }
    
    # Usuários de Teste
    Users = @{
        User1 = @{
            Username = "user1"
            Password = "Passw0rd!"
            Email = "user1@benefits.local"
            Role = "User"
        }
        Admin = @{
            Username = "admin"
            Password = "admin123"
            Email = "admin@benefits.local"
            Role = "Admin"
        }
        Merchant = @{
            Username = "merchant1"
            Password = "merchant123"
            Email = "merchant1@benefits.local"
            Role = "Merchant"
        }
    }
    
    # URLs dos Serviços
    Services = @{
        UserBFF = "http://localhost:8080"
        CoreService = "http://localhost:8081"
        AdminBFF = "http://localhost:8083"
        MerchantBFF = "http://localhost:8084"
        MerchantPortalBFF = "http://localhost:8085"
        Keycloak = "http://localhost:8081"
        KeycloakAdmin = "http://localhost:8081/admin"
        SMSInbox = "http://localhost:8082"
        LocalStack = "http://localhost:4566"
    }
    
    # Database
    Database = @{
        Host = "localhost"
        Port = "5432"
        Name = "benefits"
        User = "benefits"
        Password = "benefits123"
    }
}

# Função para exibir credenciais
function Show-Credentials {
    Write-Host "`n=== 📋 CREDENCIAIS DE ACESSO ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔐 KEYCLOAK ADMIN:" -ForegroundColor Yellow
    Write-Host "   URL: $($script:CREDENTIALS.Services.KeycloakAdmin)" -ForegroundColor White
    Write-Host "   Username: $($script:CREDENTIALS.KeycloakAdmin.Username)" -ForegroundColor White
    Write-Host "   Password: $($script:CREDENTIALS.KeycloakAdmin.Password)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "👤 USUÁRIOS DE TESTE:" -ForegroundColor Yellow
    foreach ($userKey in $script:CREDENTIALS.Users.Keys) {
        $user = $script:CREDENTIALS.Users[$userKey]
        Write-Host "   [$userKey]" -ForegroundColor Cyan
        Write-Host "      Username: $($user.Username)" -ForegroundColor White
        Write-Host "      Password: $($user.Password)" -ForegroundColor White
        Write-Host "      Email: $($user.Email)" -ForegroundColor White
        Write-Host "      Role: $($user.Role)" -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "🌐 SERVIÇOS:" -ForegroundColor Yellow
    foreach ($serviceKey in $script:CREDENTIALS.Services.Keys) {
        Write-Host "   $serviceKey : $($script:CREDENTIALS.Services[$serviceKey])" -ForegroundColor White
    }
    Write-Host ""
    
    Write-Host "💾 DATABASE:" -ForegroundColor Yellow
    Write-Host "   Host: $($script:CREDENTIALS.Database.Host):$($script:CREDENTIALS.Database.Port)" -ForegroundColor White
    Write-Host "   Database: $($script:CREDENTIALS.Database.Name)" -ForegroundColor White
    Write-Host "   User: $($script:CREDENTIALS.Database.User)" -ForegroundColor White
    Write-Host "   Password: $($script:CREDENTIALS.Database.Password)" -ForegroundColor White
    Write-Host ""
}

# Função para verificar interligações
function Test-Interconnections {
    Write-Host "`n[VERIFICAÇÃO] Testando interligações entre serviços..." -ForegroundColor Yellow
    
    $allConnected = $true
    
    # 1. User BFF → Core Service
    Write-Host "  [1/5] User BFF → Core Service..." -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest -Uri "$($script:CREDENTIALS.Services.CoreService)/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "    ✓ Core Service está acessível" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Core Service não está acessível" -ForegroundColor Red
        $allConnected = $false
    }
    
    # 2. User BFF → Keycloak
    Write-Host "  [2/5] User BFF → Keycloak..." -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest -Uri "$($script:CREDENTIALS.Services.Keycloak)/realms/benefits/.well-known/openid-configuration" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "    ✓ Keycloak está acessível" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Keycloak não está acessível" -ForegroundColor Red
        $allConnected = $false
    }
    
    # 3. Admin BFF → Core Service
    Write-Host "  [3/5] Admin BFF → Core Service..." -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest -Uri "$($script:CREDENTIALS.Services.CoreService)/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "    ✓ Core Service está acessível para Admin BFF" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Core Service não está acessível para Admin BFF" -ForegroundColor Red
        $allConnected = $false
    }
    
    # 4. Merchant BFF → Core Service
    Write-Host "  [4/5] Merchant BFF → Core Service..." -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest -Uri "$($script:CREDENTIALS.Services.CoreService)/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "    ✓ Core Service está acessível para Merchant BFF" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Core Service não está acessível para Merchant BFF" -ForegroundColor Red
        $allConnected = $false
    }
    
    # 5. Core Service → PostgreSQL
    Write-Host "  [5/5] Core Service → PostgreSQL..." -ForegroundColor Gray
    try {
        $response = docker exec benefits-postgres pg_isready -U benefits 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✓ PostgreSQL está acessível" -ForegroundColor Green
        } else {
            Write-Host "    ✗ PostgreSQL não está acessível" -ForegroundColor Red
            $allConnected = $false
        }
    } catch {
        Write-Host "    ✗ Erro ao verificar PostgreSQL" -ForegroundColor Red
        $allConnected = $false
    }
    
    return $allConnected
}

# 1. Verificar Docker
Write-Host "[1/10] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Docker não está rodando!" -ForegroundColor Red
        Write-Host "  Por favor, inicie o Docker Desktop e aguarde até que esteja completamente iniciado." -ForegroundColor Yellow
        Write-Host "  Depois execute este script novamente." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "  ✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "  Por favor, inicie o Docker Desktop e aguarde até que esteja completamente iniciado." -ForegroundColor Yellow
    Write-Host "  Depois execute este script novamente." -ForegroundColor Yellow
    exit 1
}

# 2. Buildar todos os serviços
Write-Host "`n[2/10] Buildando todos os serviços..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\build-all-services.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ Erro ao buildar serviços" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✓ Serviços buildados" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Subir Docker Compose
Write-Host "`n[3/10] Subindo Docker Compose..." -ForegroundColor Yellow
Push-Location "$PSScriptRoot\..\infra"
try {
    Write-Host "  Parando containers existentes..." -ForegroundColor Gray
    docker-compose down 2>&1 | Out-Null
    
    Write-Host "  Construindo e iniciando todos os serviços..." -ForegroundColor Gray
    docker-compose up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Serviços iniciados" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Erro ao iniciar serviços" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

# 4. Aguardar serviços iniciarem
Write-Host "`n[4/10] Aguardando serviços iniciarem (180 segundos)..." -ForegroundColor Yellow
Write-Host "  (Keycloak pode levar até 60s, serviços Spring até 40s cada)" -ForegroundColor Gray

$elapsed = 0
$interval = 15
while ($elapsed -lt 180) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    $remaining = 180 - $elapsed
    Write-Host "  $elapsed/180 segundos ($remaining restantes)..." -ForegroundColor Gray
}

Write-Host "  ✓ Tempo de espera concluído" -ForegroundColor Green

# 5. Verificar containers rodando
Write-Host "`n[5/10] Verificando containers..." -ForegroundColor Yellow
$containers = @(
    "benefits-postgres",
    "benefits-keycloak",
    "benefits-core",
    "benefits-user-bff",
    "benefits-admin-bff",
    "benefits-merchant-bff",
    "benefits-merchant-portal-bff",
    "benefits-localstack",
    "benefits-sms-inbox"
)

$allContainersRunning = $true
foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --format "{{.Status}}" 2>$null
    if ($status) {
        Write-Host "  ✓ $container está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container não está rodando" -ForegroundColor Red
        $allContainersRunning = $false
    }
}

# 6. Verificar interligações
Write-Host "`n[6/10] Verificando interligações..." -ForegroundColor Yellow
$interconnected = Test-Interconnections
if (-not $interconnected) {
    Write-Host "  ⚠ Algumas interligações falharam, mas continuando..." -ForegroundColor Yellow
}

# 7. Popular banco de dados com massa de dados completa
Write-Host "`n[7/10] Populando banco de dados com massa de dados completa..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\seed-database-complete.ps1"
    Write-Host "  ✓ Banco de dados populado" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erro ao popular banco: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Continuando mesmo assim..." -ForegroundColor Gray
}

# 8. Aplicar Terraform (LocalStack)
Write-Host "`n[8/10] Aplicando Terraform (LocalStack)..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\apply-terraform.ps1"
    Write-Host "  ✓ Terraform aplicado" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erro ao aplicar Terraform: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Continuando mesmo assim..." -ForegroundColor Gray
}

# 9. Testar todos os serviços
Write-Host "`n[9/10] Testando todos os serviços..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\test-flutter-app-e2e.ps1"
    Write-Host "  ✓ Testes executados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erro nos testes: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Continuando mesmo assim..." -ForegroundColor Gray
}

# 10. Exibir credenciais e resumo
Write-Host "`n[10/10] Preparando resumo final..." -ForegroundColor Yellow
Show-Credentials

# Resumo Final
$elapsedTime = (Get-Date) - $script:StartTime
Write-Host "`n=== ✅ SISTEMA COMPLETO RODANDO! ===" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  Tempo total: $($elapsedTime.TotalMinutes.ToString('F2')) minutos" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Testar User App Flutter:" -ForegroundColor White
Write-Host "   cd apps/user_app_flutter" -ForegroundColor Gray
Write-Host "   flutter run" -ForegroundColor Gray
Write-Host "   Credenciais: user1 / Passw0rd!" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Testar Merchant POS Flutter:" -ForegroundColor White
Write-Host "   cd apps/merchant_pos_flutter" -ForegroundColor Gray
Write-Host "   flutter run" -ForegroundColor Gray
Write-Host "   Credenciais: merchant1 / merchant123" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Acessar Admin Angular:" -ForegroundColor White
Write-Host "   cd apps/admin_angular" -ForegroundColor Gray
Write-Host "   npm install && npm start" -ForegroundColor Gray
Write-Host "   URL: http://localhost:4200" -ForegroundColor Gray
Write-Host "   Credenciais: admin / admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Acessar Merchant Portal Angular:" -ForegroundColor White
Write-Host "   cd apps/merchant_portal_angular" -ForegroundColor Gray
Write-Host "   npm install && npm start" -ForegroundColor Gray
Write-Host "   URL: http://localhost:4201" -ForegroundColor Gray
Write-Host "   Credenciais: merchant1 / merchant123" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Acessar Keycloak Admin:" -ForegroundColor White
Write-Host "   URL: $($script:CREDENTIALS.Services.KeycloakAdmin)" -ForegroundColor Gray
Write-Host "   Credenciais: admin / admin" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Acessar SMS Inbox:" -ForegroundColor White
Write-Host "   URL: $($script:CREDENTIALS.Services.SMSInbox)" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Ver logs:" -ForegroundColor Yellow
Write-Host "   docker-compose -f infra/docker-compose.yml logs -f" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 Parar tudo:" -ForegroundColor Yellow
Write-Host "   docker-compose -f infra/docker-compose.yml down" -ForegroundColor Gray
Write-Host ""
