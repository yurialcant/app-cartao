# Script para subir TUDO para testes manuais

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🚀 SUBINDO TUDO PARA TESTES MANUAIS 🚀                   ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot

# Verificar Docker
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "  ✓ Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não encontrado. Por favor, instale o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Verificar se Docker está rodando
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Docker não está rodando. Tentando iniciar..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Write-Host "  Aguardando Docker iniciar..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
}

# Subir serviços Docker
Write-Host "`n[2/6] Subindo serviços Docker..." -ForegroundColor Yellow
Set-Location (Join-Path $baseDir "infra")
docker-compose up -d --build
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Serviços Docker iniciados" -ForegroundColor Green
} else {
    Write-Host "  ✗ Erro ao iniciar serviços Docker" -ForegroundColor Red
    exit 1
}

Write-Host "`n  Aguardando serviços iniciarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Verificar saúde dos serviços
Write-Host "`n[3/6] Verificando saúde dos serviços..." -ForegroundColor Yellow
$services = @(
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"}
)

foreach ($service in $services) {
    $maxRetries = 10
    $retry = 0
    $success = $false
    
    while ($retry -lt $maxRetries -and -not $success) {
        try {
            $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "  ✓ $($service.Name) está funcionando" -ForegroundColor Green
                $success = $true
            }
        } catch {
            $retry++
            if ($retry -lt $maxRetries) {
                Start-Sleep -Seconds 3
            }
        }
    }
    
    if (-not $success) {
        Write-Host "  ⚠ $($service.Name) ainda não está respondendo (pode estar iniciando)" -ForegroundColor Yellow
    }
}

# Seed do banco de dados
Write-Host "`n[4/6] Populando banco de dados..." -ForegroundColor Yellow
Set-Location $baseDir
if (Test-Path "scripts\seed-database-complete.ps1") {
    .\scripts\seed-database-complete.ps1
    Write-Host "  ✓ Banco de dados populado" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Script de seed não encontrado" -ForegroundColor Yellow
}

# Iniciar Angular Admin
Write-Host "`n[5/6] Iniciando Angular Admin..." -ForegroundColor Yellow
$angularAdminDir = Join-Path $baseDir "apps/admin_angular"
if (Test-Path $angularAdminDir) {
    Set-Location $angularAdminDir
    if (Test-Path "node_modules") {
        Write-Host "  ✓ Dependências já instaladas" -ForegroundColor Green
    } else {
        Write-Host "  Instalando dependências..." -ForegroundColor Yellow
        npm install --silent
    }
    
    Write-Host "  Iniciando Angular Admin na porta 4200..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$angularAdminDir'; npm start"
    Write-Host "  ✓ Angular Admin iniciando em http://localhost:4200" -ForegroundColor Green
    Start-Sleep -Seconds 5
} else {
    Write-Host "  ⚠ Angular Admin não encontrado" -ForegroundColor Yellow
}

# Iniciar Angular Merchant Portal
Write-Host "`n[6/6] Iniciando Angular Merchant Portal..." -ForegroundColor Yellow
$angularMerchantDir = Join-Path $baseDir "apps/merchant_portal_angular"
if (Test-Path $angularMerchantDir) {
    Set-Location $angularMerchantDir
    if (Test-Path "node_modules") {
        Write-Host "  ✓ Dependências já instaladas" -ForegroundColor Green
    } else {
        Write-Host "  Instalando dependências..." -ForegroundColor Yellow
        npm install --silent
    }
    
    Write-Host "  Iniciando Angular Merchant Portal na porta 4201..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$angularMerchantDir'; npm start"
    Write-Host "  ✓ Angular Merchant Portal iniciando em http://localhost:4201" -ForegroundColor Green
    Start-Sleep -Seconds 5
} else {
    Write-Host "  ⚠ Angular Merchant Portal não encontrado" -ForegroundColor Yellow
}

Set-Location $baseDir

# Resumo final
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ TUDO ESTÁ RODANDO PARA TESTES MANUAIS! ✅             ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📊 SERVIÇOS BACKEND:" -ForegroundColor Cyan
Write-Host "  • User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  • Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  • Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host "  • Core Service: http://localhost:8091" -ForegroundColor White
Write-Host "  • Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host ""

Write-Host "🌐 APPS FRONTEND:" -ForegroundColor Cyan
Write-Host "  • Angular Admin: http://localhost:4200" -ForegroundColor White
Write-Host "  • Angular Merchant Portal: http://localhost:4201" -ForegroundColor White
Write-Host "  • Flutter User App: Execute 'flutter run' em apps/user_app_flutter" -ForegroundColor White
Write-Host "  • Flutter Merchant POS: Execute 'flutter run' em apps/merchant_pos_flutter" -ForegroundColor White
Write-Host ""

Write-Host "📊 MONITORAMENTO:" -ForegroundColor Cyan
Write-Host "  • Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  • Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host ""

Write-Host "🔐 CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "  • User: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  • Admin: admin / admin123" -ForegroundColor White
Write-Host "  • Merchant: merchant1 / merchant123" -ForegroundColor White
Write-Host ""

Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. Aguarde alguns segundos para todos os serviços iniciarem completamente" -ForegroundColor White
Write-Host "  2. Acesse Angular Admin: http://localhost:4200" -ForegroundColor White
Write-Host "  3. Acesse Angular Merchant Portal: http://localhost:4201" -ForegroundColor White
Write-Host "  4. Execute Flutter apps manualmente:" -ForegroundColor White
Write-Host "     cd apps/user_app_flutter && flutter run" -ForegroundColor Gray
Write-Host "     cd apps/merchant_pos_flutter && flutter run" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 DICA: Use 'docker-compose logs -f' para ver logs de todos os serviços" -ForegroundColor Yellow
Write-Host ""
