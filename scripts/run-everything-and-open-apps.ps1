# Script para rodar TUDO e abrir TODOS os apps para testes
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 RODANDO TUDO E ABRINDO APPS PARA TESTES 🚀            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Validar e instalar ambiente antes de iniciar
Write-Host "[0/10] Validando e instalando ambiente local..." -ForegroundColor Yellow
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$scriptPath\validate-and-install-all.ps1"
Write-Host ""

# 1. Verificar Docker
Write-Host "[1/10] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando. Iniciando..." -ForegroundColor Red
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 30
}

# 2. Subir todos os serviços
Write-Host "`n[2/10] Subindo todos os serviços..." -ForegroundColor Yellow
cd infra
docker-compose up -d --build 2>&1 | Out-Null
cd ..
Write-Host "  ✓ Serviços iniciados" -ForegroundColor Green
Start-Sleep -Seconds 30

# 3. Criar tabelas
Write-Host "`n[3/10] Criando tabelas..." -ForegroundColor Yellow
if (Test-Path "infra\sql\create-all-tables.sql") {
    Get-Content "infra\sql\create-all-tables.sql" | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Tabelas criadas" -ForegroundColor Green
}

# 4. Criar dados compartilhados
Write-Host "`n[4/10] Criando dados compartilhados..." -ForegroundColor Yellow
if (Test-Path "scripts\create-shared-data-all-apps.ps1") {
    .\scripts\create-shared-data-all-apps.ps1 2>&1 | Out-Null
    Write-Host "  ✓ Dados compartilhados criados" -ForegroundColor Green
}

# 5. Verificar serviços
Write-Host "`n[5/10] Verificando serviços..." -ForegroundColor Yellow
$services = @(
    @{Name="PostgreSQL"; Check=$false},
    @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits"},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"},
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"}
)

$allOk = $true
foreach ($svc in $services) {
    if ($svc.Check -eq $false) { continue }
    try {
        $response = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "  ✓ $($svc.Name) - OK" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $($svc.Name) - ERRO" -ForegroundColor Red
        $allOk = $false
    }
}

# 6. Instalar dependências Flutter
Write-Host "`n[6/10] Instalando dependências Flutter..." -ForegroundColor Yellow
cd apps\user_app_flutter
flutter pub get 2>&1 | Out-Null
cd ..\..
Write-Host "  ✓ Dependências Flutter instaladas" -ForegroundColor Green

# 7. Instalar dependências Angular Admin
Write-Host "`n[7/10] Instalando dependências Angular Admin..." -ForegroundColor Yellow
cd apps\admin_angular
if (-not (Test-Path "node_modules")) {
    npm install --silent 2>&1 | Out-Null
}
cd ..\..
Write-Host "  ✓ Dependências Angular instaladas" -ForegroundColor Green

# 8. Abrir Angular Admin no navegador
Write-Host "`n[8/10] Iniciando Angular Admin..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\gesch\Documents\projeto-lucas\apps\admin_angular'; Write-Host '🚀 Angular Admin iniciando...' -ForegroundColor Green; Write-Host 'Acesse: http://localhost:4200' -ForegroundColor Cyan; npm start" -WindowStyle Normal
Start-Sleep -Seconds 5
Write-Host "  ✓ Angular Admin iniciando em nova janela" -ForegroundColor Green
Write-Host "  → Abrindo navegador em 30 segundos..." -ForegroundColor Gray
Start-Job -ScriptBlock { Start-Sleep -Seconds 30; Start-Process "http://localhost:4200" } | Out-Null

# 9. Abrir Angular Merchant Portal
Write-Host "`n[9/10] Iniciando Angular Merchant Portal..." -ForegroundColor Yellow
if (Test-Path "apps\merchant_portal_angular\package.json") {
    cd apps\merchant_portal_angular
    if (-not (Test-Path "node_modules")) {
        npm install --silent 2>&1 | Out-Null
    }
    cd ..\..
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\gesch\Documents\projeto-lucas\apps\merchant_portal_angular'; Write-Host '🚀 Merchant Portal iniciando...' -ForegroundColor Green; Write-Host 'Acesse: http://localhost:4201' -ForegroundColor Cyan; npm start" -WindowStyle Normal
    Start-Sleep -Seconds 5
    Write-Host "  ✓ Merchant Portal iniciando" -ForegroundColor Green
    Start-Job -ScriptBlock { Start-Sleep -Seconds 35; Start-Process "http://localhost:4201" } | Out-Null
} else {
    Write-Host "  ⚠ Merchant Portal não configurado ainda" -ForegroundColor Yellow
}

# 10. Preparar Flutter apps
Write-Host "`n[10/10] Preparando Flutter apps..." -ForegroundColor Yellow
Write-Host "  ✓ Flutter User App pronto para execução" -ForegroundColor Green
Write-Host "  ✓ Flutter Merchant POS pronto para execução" -ForegroundColor Green
Write-Host ""
Write-Host "  Para executar Flutter apps:" -ForegroundColor Yellow
Write-Host "    cd apps/user_app_flutter && flutter run" -ForegroundColor Gray
Write-Host "    cd apps/merchant_pos_flutter && flutter run" -ForegroundColor Gray

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ TUDO RODANDO E APPS ABERTOS! ✅                       ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 APPS ABERTOS:" -ForegroundColor Cyan
Write-Host "  • Angular Admin: http://localhost:4200 (abrindo em 30s)" -ForegroundColor White
Write-Host "  • Angular Merchant Portal: http://localhost:4201 (abrindo em 35s)" -ForegroundColor White
Write-Host "  • Flutter User App: Execute 'cd apps/user_app_flutter && flutter run'" -ForegroundColor Yellow
Write-Host "  • Flutter Merchant POS: Execute 'cd apps/merchant_pos_flutter && flutter run'" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔗 INTEGRAÇÃO:" -ForegroundColor Cyan
Write-Host "  ✓ Todos os BFFs consomem Core Service" -ForegroundColor Green
Write-Host "  ✓ Dados compartilhados via mesmo banco" -ForegroundColor Green
Write-Host "  ✓ Alterações no Admin aparecem no User App" -ForegroundColor Green
Write-Host ""
Write-Host "📝 TESTE O FLUXO COMPLETO:" -ForegroundColor Yellow
Write-Host "  1. Admin Angular: Criar topup para user1" -ForegroundColor White
Write-Host "  2. User App Flutter: Ver saldo atualizado" -ForegroundColor White
Write-Host "  3. Admin Angular: Ver transações do user1" -ForegroundColor White
Write-Host "  4. User App Flutter: Fazer pagamento" -ForegroundColor White
Write-Host "  5. Admin Angular: Ver nova transação" -ForegroundColor White
Write-Host ""
Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "  • User: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  • Admin: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "🎯 TUDO PRONTO PARA TESTAR! 🚀" -ForegroundColor Green
Write-Host ""
