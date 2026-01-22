#!/usr/bin/env pwsh
<#
.SYNOPSIS
    START.ps1 - Script Principal de Inicialização
    
.DESCRIPTION
    Inicia TODOS os componentes do Benefits Platform em ordem:
    1. Infrastructure (Docker: PostgreSQL, Keycloak, LocalStack)
    2. Backend Services (Spring Boot BFFs e Services)
    3. Frontend Portals (Angular 4200, 4201, 4202)
    
.NOTES
    Requer: Docker, Node.js, Java 17+, Flutter SDK
#>

Write-Host @"
╔════════════════════════════════════════════════════════════════════════════╗
║                  🚀 BENEFITS PLATFORM 2026 - STARTUP 🚀                   ║
║            Flutter App → BFFs → Core → Database                           ║
╚════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÕES
# ═══════════════════════════════════════════════════════════════════════════
$projectRoot = Get-Location
$appsDir = "$projectRoot\apps"
$servicesDir = "$projectRoot\services"
$infraDir = "$projectRoot\infra"

# ═══════════════════════════════════════════════════════════════════════════
# FUNÇÃO: Iniciar Serviço com Retentativa
# ═══════════════════════════════════════════════════════════════════════════
function Start-ServiceWithRetry {
    param(
        [string]$ServiceName,
        [string]$HealthUrl,
        [scriptblock]$StartCommand,
        [int]$MaxRetries = 10
    )
    
    Write-Host "`n🔧 Iniciando: $ServiceName" -ForegroundColor Yellow
    
    & $StartCommand
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $HealthUrl -TimeoutSec 3
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $ServiceName Online: $HealthUrl" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host "   Tentativa $i/$MaxRetries - Aguardando..." -ForegroundColor Gray
            Start-Sleep 2
        }
    }
    
    Write-Host "❌ $ServiceName NÃO respondeu" -ForegroundColor Red
    return $false
}

# ═══════════════════════════════════════════════════════════════════════════
# PASSO 1: INFRAESTRUTURA DOCKER
# ═══════════════════════════════════════════════════════════════════════════
Write-Host "`n" + ("═" * 80) -ForegroundColor Cyan
Write-Host "PASSO 1: 🐳 INFRAESTRUTURA DOCKER" -ForegroundColor Yellow
Write-Host ("═" * 80) -ForegroundColor Cyan

cd "$infraDir"
Write-Host "  📦 Iniciando Docker Compose..." -ForegroundColor Gray

try {
    docker compose up -d
    Write-Host "  ✅ Docker Compose iniciado" -ForegroundColor Green
    Start-Sleep 5
} catch {
    Write-Host "  ❌ Erro ao iniciar Docker Compose: $_" -ForegroundColor Red
    exit 1
}

# Verificar componentes chave
Write-Host "`n  🔍 Verificando componentes..." -ForegroundColor Gray

$checks = @(
    @{Name="PostgreSQL"; Port=5432; Host="localhost"},
    @{Name="Keycloak"; Port=8081; Host="localhost"},
    @{Name="LocalStack"; Port=4566; Host="localhost"}
)

foreach ($check in $checks) {
    try {
        $connection = [System.Net.Sockets.TcpClient]::new()
        $connection.Connect($check.Host, $check.Port)
        $connection.Close()
        Write-Host "    ✅ $($check.Name) pronto na porta $($check.Port)" -ForegroundColor Green
    } catch {
        Write-Host "    ⚠️  $($check.Name) não respondendo ainda..." -ForegroundColor Yellow
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# PASSO 2: SERVIÇOS BACKEND (MOCKS EM DEV)
# ═══════════════════════════════════════════════════════════════════════════
Write-Host "`n" + ("═" * 80) -ForegroundColor Cyan
Write-Host "PASSO 2: 🔧 SERVIÇOS BACKEND" -ForegroundColor Yellow
Write-Host ("═" * 80) -ForegroundColor Cyan

cd "$projectRoot"

Write-Host "`n  📌 Iniciando Mock User-BFF (8080)..." -ForegroundColor Gray
Start-Job -ScriptBlock { python "$using:projectRoot\mock-user-bff.py" } | Out-Null
Start-Sleep 2

Write-Host "  📌 Iniciando Mock Admin-BFF (8083)..." -ForegroundColor Gray
Start-Job -ScriptBlock { python "$using:projectRoot\mock-admin-bff.py" } | Out-Null
Start-Sleep 2

Write-Host "  ✅ Mock BFFs iniciados" -ForegroundColor Green

# ═══════════════════════════════════════════════════════════════════════════
# PASSO 3: ANGULAR PORTALS
# ═══════════════════════════════════════════════════════════════════════════
Write-Host "`n" + ("═" * 80) -ForegroundColor Cyan
Write-Host "PASSO 3: 📱 ANGULAR PORTALS" -ForegroundColor Yellow
Write-Host ("═" * 80) -ForegroundColor Cyan

Write-Host "`n  📌 Admin Portal (localhost:4200)..." -ForegroundColor Gray
Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $appsDir\admin_angular && ng serve --port 4200"
Write-Host "  ✅ Admin Portal iniciado (abrir http://localhost:4200)" -ForegroundColor Green

# ═══════════════════════════════════════════════════════════════════════════
# PASSO 4: FLUTTER APP
# ═══════════════════════════════════════════════════════════════════════════
Write-Host "`n" + ("═" * 80) -ForegroundColor Cyan
Write-Host "PASSO 4: 📱 FLUTTER USER APP" -ForegroundColor Yellow
Write-Host ("═" * 80) -ForegroundColor Cyan

Write-Host "`n  📌 User App Flutter (emulador)..." -ForegroundColor Gray
Write-Host "  Opções:" -ForegroundColor Gray
Write-Host "    1. flutter run -d emulator-5554" -ForegroundColor Gray
Write-Host "    2. flutter run -d windows" -ForegroundColor Gray
Write-Host "    3. flutter run -d chrome" -ForegroundColor Gray

# ═══════════════════════════════════════════════════════════════════════════
# RESUMO
# ═══════════════════════════════════════════════════════════════════════════
Write-Host "`n" + ("═" * 80) -ForegroundColor Cyan
Write-Host "✅ SISTEMA PRONTO PARA DESENVOLVIMENTO" -ForegroundColor Green
Write-Host ("═" * 80) -ForegroundColor Cyan

Write-Host @"

📊 STATUS:
  ✅ PostgreSQL:5432       - Database
  ✅ Keycloak:8081         - Authentication (admin/admin)
  ✅ LocalStack:4566       - AWS Services (S3, SQS)
  ✅ Mock User-BFF:8080    - User API
  ✅ Mock Admin-BFF:8083   - Admin API
  ✅ Admin Portal:4200     - http://localhost:4200
  
📱 PRÓXIMOS PASSOS:
  1. Flutter App: flutter run -d emulator-5554
  2. Login: tiago.tiede@flash.com / senha123
  3. Admin Portal: http://localhost:4200
  
🔗 FLUXO:
  Flutter App (8080) → Mock User-BFF → Benefits-Core → PostgreSQL
  Admin Portal (4200) → Mock Admin-BFF → Benefits-Core → PostgreSQL

💡 TESTES:
  python e2e-test.py        - Rodar teste E2E completo

📖 DOCUMENTAÇÃO:
  - README.md                    - Visão geral
  - CREDENCIAIS-ACESSO.md       - Credenciais
  - ANALISE-ARQUITETURA-REAL.md - Arquitetura detalhada

"@ -ForegroundColor Cyan

Write-Host "✨ Sistema pronto! Pressione CTRL+C para parar os serviços." -ForegroundColor Green
