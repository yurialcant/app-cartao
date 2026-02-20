# Script completo para resetar, instalar tudo e rodar tudo
# Executa como admin quando necessário

param(
    [switch]$RunAsAdmin
)

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot | Split-Path -Parent

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔄 RESET COMPLETO + INSTALAÇÃO + INÍCIO 🔄              ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. PARAR TUDO
# ============================================================================
Write-Host "[1/6] Parando tudo que está rodando..." -ForegroundColor Yellow

# Parar Docker containers
Write-Host "  → Parando containers Docker..." -ForegroundColor Gray
Push-Location "$projectRoot\infra"
try {
    docker-compose down 2>&1 | Out-Null
    Write-Host "    ✓ Containers Docker parados" -ForegroundColor Green
} catch {
    Write-Host "    ⚠ Erro ao parar containers: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Parar processos Node/Angular
Write-Host "  → Parando processos Node/Angular..." -ForegroundColor Gray
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "ng" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "    ✓ Processos Node parados" -ForegroundColor Green

# Parar processos Flutter
Write-Host "  → Parando processos Flutter..." -ForegroundColor Gray
Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "    ✓ Processos Flutter parados" -ForegroundColor Green

Write-Host "  ✅ Tudo parado!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 2. VERIFICAR E INSTALAR DEPENDÊNCIAS
# ============================================================================
Write-Host "[2/6] Verificando e instalando dependências..." -ForegroundColor Yellow

# Node.js e npm
Write-Host "  → Verificando Node.js..." -ForegroundColor Gray
try {
    $nodeVersion = node --version 2>&1
    Write-Host "    ✓ Node.js instalado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Node.js não encontrado. Instale de https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Angular CLI
Write-Host "  → Verificando Angular CLI..." -ForegroundColor Gray
try {
    $ngVersion = ng version --json 2>&1 | ConvertFrom-Json
    Write-Host "    ✓ Angular CLI instalado" -ForegroundColor Green
} catch {
    Write-Host "    → Instalando Angular CLI globalmente..." -ForegroundColor Yellow
    npm install -g @angular/cli 2>&1 | Out-Null
    Write-Host "    ✓ Angular CLI instalado" -ForegroundColor Green
}

# Flutter
Write-Host "  → Verificando Flutter..." -ForegroundColor Gray
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "    ✓ Flutter instalado: $flutterVersion" -ForegroundColor Green
    flutter doctor 2>&1 | Out-Null
} catch {
    Write-Host "    ✗ Flutter não encontrado. Instale de https://flutter.dev/" -ForegroundColor Red
    exit 1
}

# Java e Maven
Write-Host "  → Verificando Java..." -ForegroundColor Gray
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "    ✓ Java instalado" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Java não encontrado. Instale Java 17+ de https://adoptium.net/" -ForegroundColor Red
    exit 1
}

try {
    $mavenVersion = mvn --version 2>&1 | Select-Object -First 1
    Write-Host "    ✓ Maven instalado" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Maven não encontrado. Instale de https://maven.apache.org/" -ForegroundColor Red
    exit 1
}

# Docker
Write-Host "  → Verificando Docker..." -ForegroundColor Gray
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "    ✓ Docker instalado: $dockerVersion" -ForegroundColor Green
    
    # Verificar se Docker está rodando
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    → Iniciando Docker Desktop..." -ForegroundColor Yellow
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -ErrorAction SilentlyContinue
        Write-Host "    → Aguardando Docker iniciar (30 segundos)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
    }
    Write-Host "    ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "    ✗ Docker não encontrado. Instale Docker Desktop de https://www.docker.com/" -ForegroundColor Red
    exit 1
}

Write-Host "  ✅ Todas as dependências verificadas!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 3. INSTALAR DEPENDÊNCIAS DOS PROJETOS
# ============================================================================
Write-Host "[3/6] Instalando dependências dos projetos..." -ForegroundColor Yellow

# Angular Admin
Write-Host "  → Instalando dependências Angular Admin..." -ForegroundColor Gray
Push-Location "$projectRoot\apps\admin_angular"
try {
    if (Test-Path "node_modules") {
        Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
        Remove-Item -Force "package-lock.json" -ErrorAction SilentlyContinue
    }
    npm install 2>&1 | Out-Null
    Write-Host "    ✓ Angular Admin dependências instaladas" -ForegroundColor Green
} catch {
    Write-Host "    ⚠ Erro ao instalar dependências Angular Admin: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Angular Merchant Portal
Write-Host "  → Instalando dependências Angular Merchant Portal..." -ForegroundColor Gray
Push-Location "$projectRoot\apps\merchant_portal_angular"
try {
    if (Test-Path "node_modules") {
        Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
        Remove-Item -Force "package-lock.json" -ErrorAction SilentlyContinue
    }
    npm install 2>&1 | Out-Null
    Write-Host "    ✓ Merchant Portal dependências instaladas" -ForegroundColor Green
} catch {
    Write-Host "    ⚠ Erro ao instalar dependências Merchant Portal: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Flutter User App
Write-Host "  → Instalando dependências Flutter User App..." -ForegroundColor Gray
Push-Location "$projectRoot\apps\user_app_flutter"
try {
    flutter clean 2>&1 | Out-Null
    flutter pub get 2>&1 | Out-Null
    Write-Host "    ✓ Flutter User App dependências instaladas" -ForegroundColor Green
} catch {
    Write-Host "    ⚠ Erro ao instalar dependências Flutter User App: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Flutter Merchant POS
Write-Host "  → Instalando dependências Flutter Merchant POS..." -ForegroundColor Gray
Push-Location "$projectRoot\apps\merchant_pos_flutter"
try {
    flutter clean 2>&1 | Out-Null
    flutter pub get 2>&1 | Out-Null
    Write-Host "    ✓ Flutter Merchant POS dependências instaladas" -ForegroundColor Green
} catch {
    Write-Host "    ⚠ Erro ao instalar dependências Flutter Merchant POS: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

Write-Host "  ✅ Dependências dos projetos instaladas!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 4. SUBIR SERVIÇOS DOCKER
# ============================================================================
Write-Host "[4/6] Subindo serviços Docker..." -ForegroundColor Yellow
Push-Location "$projectRoot\infra"
try {
    docker-compose up -d --build 2>&1 | Out-Null
    Write-Host "  ✓ Serviços Docker iniciados" -ForegroundColor Green
    Write-Host "  → Aguardando serviços iniciarem (45 segundos)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 45
} catch {
    Write-Host "  ⚠ Erro ao iniciar serviços Docker: $_" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# ============================================================================
# 5. CRIAR TABELAS E DADOS
# ============================================================================
Write-Host "[5/6] Criando tabelas e dados..." -ForegroundColor Yellow

# Criar tabelas
if (Test-Path "$projectRoot\infra\sql\create-all-tables.sql") {
    Write-Host "  → Criando tabelas..." -ForegroundColor Gray
    Get-Content "$projectRoot\infra\sql\create-all-tables.sql" | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "    ✓ Tabelas criadas" -ForegroundColor Green
}

# Criar seed completo
if (Test-Path "$projectRoot\scripts\seed-complete-previous.ps1") {
    Write-Host "  → Criando seed completo..." -ForegroundColor Gray
    & "$projectRoot\scripts\seed-complete-previous.ps1" 2>&1 | Out-Null
    Write-Host "    ✓ Seed completo criado" -ForegroundColor Green
}

Write-Host "  ✅ Banco de dados preparado!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 6. INICIAR APPS
# ============================================================================
Write-Host "[6/6] Iniciando aplicações..." -ForegroundColor Yellow

# Angular Admin
Write-Host "  → Iniciando Angular Admin..." -ForegroundColor Gray
$adminScript = @"
cd `"$projectRoot\apps\admin_angular`"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║                                                              ║' -ForegroundColor Green
Write-Host '║     🚀 ANGULAR ADMIN - http://localhost:4200 🚀             ║' -ForegroundColor Green
Write-Host '║                                                              ║' -ForegroundColor Green
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Green
Write-Host ''
Write-Host 'Login: admin / admin123' -ForegroundColor Yellow
Write-Host ''
npm start
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $adminScript
Write-Host "    ✓ Angular Admin iniciando" -ForegroundColor Green

Start-Sleep -Seconds 3

# Angular Merchant Portal
Write-Host "  → Iniciando Angular Merchant Portal..." -ForegroundColor Gray
$portalScript = @"
cd `"$projectRoot\apps\merchant_portal_angular`"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Green
Write-Host '║                                                              ║' -ForegroundColor Green
Write-Host '║     🚀 MERCHANT PORTAL - http://localhost:4201 🚀            ║' -ForegroundColor Green
Write-Host '║                                                              ║' -ForegroundColor Green
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Green
Write-Host ''
npm start
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $portalScript
Write-Host "    ✓ Merchant Portal iniciando" -ForegroundColor Green

Start-Sleep -Seconds 3

# Flutter User App
Write-Host "  → Iniciando Flutter User App..." -ForegroundColor Gray
$flutterUserScript = @"
cd `"$projectRoot\apps\user_app_flutter`"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Blue
Write-Host '║                                                              ║' -ForegroundColor Blue
Write-Host '║     📱 FLUTTER USER APP 📱                                  ║' -ForegroundColor Blue
Write-Host '║                                                              ║' -ForegroundColor Blue
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Blue
Write-Host ''
Write-Host 'Login: user1 / Passw0rd!' -ForegroundColor Yellow
Write-Host ''
flutter run
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterUserScript
Write-Host "    ✓ Flutter User App iniciando" -ForegroundColor Green

Start-Sleep -Seconds 3

# Flutter Merchant POS
Write-Host "  → Iniciando Flutter Merchant POS..." -ForegroundColor Gray
$flutterMerchantScript = @"
cd `"$projectRoot\apps\merchant_pos_flutter`"
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Magenta
Write-Host '║                                                              ║' -ForegroundColor Magenta
Write-Host '║     💳 FLUTTER MERCHANT POS 💳                              ║' -ForegroundColor Magenta
Write-Host '║                                                              ║' -ForegroundColor Magenta
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Magenta
Write-Host ''
Write-Host 'Login: merchant1 / Passw0rd!' -ForegroundColor Yellow
Write-Host ''
flutter run
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterMerchantScript
Write-Host "    ✓ Flutter Merchant POS iniciando" -ForegroundColor Green

Write-Host "  ✅ Aplicações iniciando!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# RESUMO FINAL
# ============================================================================
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ TUDO INICIADO COM SUCESSO! ✅                         ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  • Angular Admin: http://localhost:4200" -ForegroundColor White
Write-Host "  • Angular Merchant Portal: http://localhost:4201" -ForegroundColor White
Write-Host "  • Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  • User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  • Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  • Core Service: http://localhost:8091" -ForegroundColor White
Write-Host ""
Write-Host "🔑 CREDENCIAIS:" -ForegroundColor Yellow
Write-Host "  • User: user1 / Passw0rd!" -ForegroundColor White
Write-Host "  • Admin: admin / admin123" -ForegroundColor White
Write-Host "  • Merchant: merchant1 / Passw0rd!" -ForegroundColor White
Write-Host ""
Write-Host "📱 APPS:" -ForegroundColor Cyan
Write-Host "  • Flutter User App: Terminal separado" -ForegroundColor White
Write-Host "  • Flutter Merchant POS: Terminal separado" -ForegroundColor White
Write-Host ""
Write-Host "✅ Verifique os terminais abertos para ver os logs!" -ForegroundColor Green
Write-Host ""
