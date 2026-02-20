# Script completo para preparar e executar testes E2E de TODOS os fluxos
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 PREPARANDO TESTES E2E COMPLETOS 🚀                    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# 1. Verificar Docker
Write-Host "[1/8] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando. Iniciando Docker Desktop..." -ForegroundColor Red
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Start-Sleep -Seconds 30
}

# 2. Subir todos os serviços
Write-Host "`n[2/8] Subindo todos os serviços..." -ForegroundColor Yellow
cd infra
docker-compose up -d --build 2>&1 | Out-Null
cd ..
Start-Sleep -Seconds 20
Write-Host "  ✓ Serviços iniciados" -ForegroundColor Green

# 3. Criar todas as tabelas
Write-Host "`n[3/8] Criando tabelas do banco..." -ForegroundColor Yellow
if (Test-Path "infra\sql\create-all-tables.sql") {
    Get-Content "infra\sql\create-all-tables.sql" | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Tabelas criadas" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Arquivo create-all-tables.sql não encontrado" -ForegroundColor Yellow
}

# 4. Criar massa de dados completa
Write-Host "`n[4/8] Criando massa de dados completa..." -ForegroundColor Yellow
if (Test-Path "scripts\create-complete-test-data-all-flows-e2e.ps1") {
    .\scripts\create-complete-test-data-all-flows-e2e.ps1 2>&1 | Out-Null
    Write-Host "  ✓ Massa de dados criada" -ForegroundColor Green
}

# 5. Instalar dependências do Flutter
Write-Host "`n[5/8] Instalando dependências do Flutter..." -ForegroundColor Yellow
cd apps\user_app_flutter
flutter pub get 2>&1 | Out-Null
cd ..\..
Write-Host "  ✓ Dependências do Flutter instaladas" -ForegroundColor Green

# 6. Instalar dependências do Angular Admin
Write-Host "`n[6/8] Instalando dependências do Angular Admin..." -ForegroundColor Yellow
cd apps\admin_angular
if (-not (Test-Path "node_modules")) {
    npm install --silent 2>&1 | Out-Null
}
cd ..\..
Write-Host "  ✓ Dependências do Angular instaladas" -ForegroundColor Green

# 7. Verificar serviços
Write-Host "`n[7/8] Verificando serviços..." -ForegroundColor Yellow
$services = @(
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"},
    @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits"}
)

$allOk = $true
foreach ($svc in $services) {
    try {
        $response = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "  ✓ $($svc.Name) - OK" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $($svc.Name) - ERRO" -ForegroundColor Red
        $allOk = $false
    }
}

# 8. Executar testes E2E
Write-Host "`n[8/8] Executando testes E2E..." -ForegroundColor Yellow
if (Test-Path "scripts\run-complete-e2e-all-flows.ps1") {
    .\scripts\run-complete-e2e-all-flows.ps1
} else {
    Write-Host "  ⚠ Script de testes E2E não encontrado" -ForegroundColor Yellow
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ PREPARAÇÃO COMPLETA PARA TESTES E2E! ✅               ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. TESTAR FLUTTER APP:" -ForegroundColor Yellow
Write-Host "   cd apps/user_app_flutter" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor White
Write-Host ""
Write-Host "2. TESTAR ANGULAR ADMIN:" -ForegroundColor Yellow
Write-Host "   cd apps/admin_angular" -ForegroundColor White
Write-Host "   npm start" -ForegroundColor White
Write-Host ""
Write-Host "3. FLUXOS PARA TESTAR:" -ForegroundColor Yellow
Write-Host "   ✓ Onboarding completo" -ForegroundColor White
Write-Host "   ✓ Login com usuário e senha" -ForegroundColor White
Write-Host "   ✓ Login com biometria (se disponível)" -ForegroundColor White
Write-Host "   ✓ Ver cartões e saldo" -ForegroundColor White
Write-Host "   ✓ Bloquear/desbloquear cartão" -ForegroundColor White
Write-Host "   ✓ Fazer pagamentos" -ForegroundColor White
Write-Host "   ✓ Resetar senha com OTP" -ForegroundColor White
Write-Host "   ✓ Navegar entre telas" -ForegroundColor White
Write-Host ""
Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "   • User: user1 / Passw0rd!" -ForegroundColor White
Write-Host "   • Admin: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "🌐 URLs:" -ForegroundColor Cyan
Write-Host "   • User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "   • Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "   • Angular Admin: http://localhost:4200" -ForegroundColor White
Write-Host ""
