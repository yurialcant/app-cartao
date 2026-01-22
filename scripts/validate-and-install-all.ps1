# Script completo para validar e instalar TODAS as dependências locais
# Antes de iniciar Angular, Flutter, etc.

$ErrorActionPreference = "Continue"
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔍 VALIDANDO E INSTALANDO AMBIENTE LOCAL 🔍            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# ============================================================================
# 1. NODE.JS E NPM
# ============================================================================
Write-Host "[1/8] Verificando Node.js e npm..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    $npmVersion = npm --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Node.js instalado: $nodeVersion" -ForegroundColor Green
        Write-Host "  ✓ npm instalado: $npmVersion" -ForegroundColor Green
        
        # Verificar versão mínima (Node.js 18+)
        $nodeMajor = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($nodeMajor -lt 18) {
            Write-Host "  ⚠ Node.js versão $nodeVersion é muito antiga. Recomendado: 18+ ou 20+" -ForegroundColor Yellow
            Write-Host "  → Baixe em: https://nodejs.org/" -ForegroundColor Gray
            $allGood = $false
        }
    } else {
        throw "Node.js não encontrado"
    }
} catch {
    Write-Host "  ✗ Node.js não está instalado" -ForegroundColor Red
    Write-Host "  → Instale Node.js 18+ ou 20+ em: https://nodejs.org/" -ForegroundColor Gray
    Write-Host "  → Ou use Chocolatey: choco install nodejs-lts" -ForegroundColor Gray
    $allGood = $false
}

# ============================================================================
# 2. ANGULAR CLI
# ============================================================================
Write-Host "`n[2/8] Verificando Angular CLI..." -ForegroundColor Yellow
try {
    $ngVersion = ng version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0 -or $ngVersion -match "Angular CLI") {
        Write-Host "  ✓ Angular CLI instalado" -ForegroundColor Green
        Write-Host "  → Versão: $ngVersion" -ForegroundColor Gray
    } else {
        throw "Angular CLI não encontrado"
    }
} catch {
    Write-Host "  ⚠ Angular CLI não está instalado globalmente" -ForegroundColor Yellow
    Write-Host "  → Instalando Angular CLI globalmente..." -ForegroundColor Cyan
    try {
        npm install -g @angular/cli@latest
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Angular CLI instalado com sucesso" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Erro ao instalar Angular CLI" -ForegroundColor Red
            Write-Host "  → Execute manualmente: npm install -g @angular/cli" -ForegroundColor Gray
            $allGood = $false
        }
    } catch {
        Write-Host "  ✗ Erro ao instalar Angular CLI: $_" -ForegroundColor Red
        Write-Host "  → Execute manualmente: npm install -g @angular/cli" -ForegroundColor Gray
        $allGood = $false
    }
}

# ============================================================================
# 3. FLUTTER
# ============================================================================
Write-Host "`n[3/8] Verificando Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Flutter instalado" -ForegroundColor Green
        Write-Host "  → Versão: $flutterVersion" -ForegroundColor Gray
        
        # Verificar se Flutter está configurado
        Write-Host "  → Verificando configuração do Flutter..." -ForegroundColor Gray
        flutter doctor --android-licenses 2>&1 | Out-Null
        $flutterDoctor = flutter doctor 2>&1
        if ($flutterDoctor -match "No issues found" -or $flutterDoctor -match "Doctor summary") {
            Write-Host "  ✓ Flutter configurado corretamente" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Execute 'flutter doctor' para verificar configuração completa" -ForegroundColor Yellow
        }
    } else {
        throw "Flutter não encontrado"
    }
} catch {
    Write-Host "  ✗ Flutter não está instalado" -ForegroundColor Red
    Write-Host "  → Instale Flutter em: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Gray
    Write-Host "  → Ou use Chocolatey: choco install flutter" -ForegroundColor Gray
    Write-Host "  → Depois execute: flutter doctor" -ForegroundColor Gray
    $allGood = $false
}

# ============================================================================
# 4. JAVA E MAVEN (para serviços Spring Boot)
# ============================================================================
Write-Host "`n[4/8] Verificando Java e Maven..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Java instalado" -ForegroundColor Green
        Write-Host "  → Versão: $javaVersion" -ForegroundColor Gray
        
        # Verificar versão (Java 17+)
        if ($javaVersion -match "version ""(\d+)") {
            $javaMajor = [int]$matches[1]
            if ($javaMajor -lt 17) {
                Write-Host "  ⚠ Java versão $javaMajor é muito antiga. Recomendado: 17+" -ForegroundColor Yellow
            }
        }
    } else {
        throw "Java não encontrado"
    }
} catch {
    Write-Host "  ⚠ Java não está instalado (opcional para rodar serviços via Docker)" -ForegroundColor Yellow
    Write-Host "  → Instale Java 17+ em: https://adoptium.net/" -ForegroundColor Gray
    Write-Host "  → Ou use Chocolatey: choco install openjdk17" -ForegroundColor Gray
}

try {
    $mavenVersion = mvn --version 2>&1 | Select-Object -First 1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Maven instalado" -ForegroundColor Green
        Write-Host "  → Versão: $mavenVersion" -ForegroundColor Gray
    } else {
        throw "Maven não encontrado"
    }
} catch {
    Write-Host "  ⚠ Maven não está instalado (opcional para build local)" -ForegroundColor Yellow
    Write-Host "  → Instale Maven em: https://maven.apache.org/download.cgi" -ForegroundColor Gray
    Write-Host "  → Ou use Chocolatey: choco install maven" -ForegroundColor Gray
}

# ============================================================================
# 5. DOCKER
# ============================================================================
Write-Host "`n[5/8] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Docker instalado: $dockerVersion" -ForegroundColor Green
        
        # Verificar se Docker está rodando
        try {
            docker ps 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ Docker não está rodando" -ForegroundColor Yellow
                Write-Host "  → Inicie o Docker Desktop" -ForegroundColor Gray
                $allGood = $false
            }
        } catch {
            Write-Host "  ⚠ Docker não está rodando" -ForegroundColor Yellow
            Write-Host "  → Inicie o Docker Desktop" -ForegroundColor Gray
            $allGood = $false
        }
    } else {
        throw "Docker não encontrado"
    }
} catch {
    Write-Host "  ✗ Docker não está instalado" -ForegroundColor Red
    Write-Host "  → Instale Docker Desktop em: https://www.docker.com/products/docker-desktop" -ForegroundColor Gray
    $allGood = $false
}

# ============================================================================
# 6. INSTALAR DEPENDÊNCIAS DO ANGULAR ADMIN
# ============================================================================
Write-Host "`n[6/8] Instalando dependências do Angular Admin..." -ForegroundColor Yellow
$adminPath = "apps\admin_angular"
if (Test-Path $adminPath) {
    if (Test-Path "$adminPath\node_modules") {
        Write-Host "  ✓ Dependências já instaladas" -ForegroundColor Green
    } else {
        Write-Host "  → Instalando dependências..." -ForegroundColor Cyan
        Push-Location $adminPath
        try {
            npm install
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Dependências instaladas com sucesso" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Erro ao instalar dependências" -ForegroundColor Red
                $allGood = $false
            }
        } catch {
            Write-Host "  ✗ Erro: $_" -ForegroundColor Red
            $allGood = $false
        } finally {
            Pop-Location
        }
    }
} else {
    Write-Host "  ⚠ Diretório não encontrado: $adminPath" -ForegroundColor Yellow
}

# ============================================================================
# 7. INSTALAR DEPENDÊNCIAS DO ANGULAR MERCHANT PORTAL
# ============================================================================
Write-Host "`n[7/8] Instalando dependências do Angular Merchant Portal..." -ForegroundColor Yellow
$merchantPortalPath = "apps\merchant_portal_angular"
if (Test-Path $merchantPortalPath) {
    if (Test-Path "$merchantPortalPath\node_modules") {
        Write-Host "  ✓ Dependências já instaladas" -ForegroundColor Green
    } else {
        Write-Host "  → Instalando dependências..." -ForegroundColor Cyan
        Push-Location $merchantPortalPath
        try {
            npm install
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Dependências instaladas com sucesso" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Erro ao instalar dependências" -ForegroundColor Red
                $allGood = $false
            }
        } catch {
            Write-Host "  ✗ Erro: $_" -ForegroundColor Red
            $allGood = $false
        } finally {
            Pop-Location
        }
    }
} else {
    Write-Host "  ⚠ Diretório não encontrado: $merchantPortalPath" -ForegroundColor Yellow
}

# ============================================================================
# 8. INSTALAR DEPENDÊNCIAS DO FLUTTER USER APP
# ============================================================================
Write-Host "`n[8/8] Instalando dependências do Flutter User App..." -ForegroundColor Yellow
$flutterUserPath = "apps\user_app_flutter"
if (Test-Path $flutterUserPath) {
    Push-Location $flutterUserPath
    try {
        Write-Host "  → Executando 'flutter pub get'..." -ForegroundColor Cyan
        flutter pub get
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Dependências instaladas com sucesso" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Erro ao instalar dependências" -ForegroundColor Red
            $allGood = $false
        }
    } catch {
        Write-Host "  ✗ Erro: $_" -ForegroundColor Red
        $allGood = $false
    } finally {
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Diretório não encontrado: $flutterUserPath" -ForegroundColor Yellow
}

# Verificar Flutter Merchant POS também
Write-Host "`n[8.5/8] Instalando dependências do Flutter Merchant POS..." -ForegroundColor Yellow
$flutterMerchantPath = "apps\merchant_pos_flutter"
if (Test-Path $flutterMerchantPath) {
    Push-Location $flutterMerchantPath
    try {
        Write-Host "  → Executando 'flutter pub get'..." -ForegroundColor Cyan
        flutter pub get
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Dependências instaladas com sucesso" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Erro ao instalar dependências" -ForegroundColor Red
            $allGood = $false
        }
    } catch {
        Write-Host "  ✗ Erro: $_" -ForegroundColor Red
        $allGood = $false
    } finally {
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Diretório não encontrado: $flutterMerchantPath" -ForegroundColor Yellow
}

# ============================================================================
# RESUMO FINAL
# ============================================================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
Write-Host "║     $(if ($allGood) { "✅ AMBIENTE VALIDADO E PRONTO!" } else { "⚠ ALGUMAS VALIDAÇÕES FALHARAM" }) $(if ($allGood) { "✅" } else { "⚠" })            ║" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
Write-Host ""

if ($allGood) {
    Write-Host "✅ Todos os requisitos estão instalados e configurados!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
    Write-Host "  1. Execute: .\scripts\run-everything-and-open-apps.ps1" -ForegroundColor White
    Write-Host "  2. Ou inicie os apps manualmente:" -ForegroundColor White
    Write-Host "     • Angular Admin: cd apps/admin_angular && npm start" -ForegroundColor Gray
    Write-Host "     • Flutter User App: cd apps/user_app_flutter && flutter run" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "⚠ Algumas dependências precisam ser instaladas:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 CHECKLIST:" -ForegroundColor Cyan
    Write-Host "  • Node.js 18+ instalado?" -ForegroundColor White
    Write-Host "  • Angular CLI instalado? (npm install -g @angular/cli)" -ForegroundColor White
    Write-Host "  • Flutter instalado e configurado?" -ForegroundColor White
    Write-Host "  • Docker Desktop instalado e rodando?" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 DICAS:" -ForegroundColor Cyan
    Write-Host "  • Use Chocolatey para instalar rapidamente:" -ForegroundColor White
    Write-Host "    choco install nodejs-lts flutter docker-desktop" -ForegroundColor Gray
    Write-Host "  • Após instalar, execute este script novamente" -ForegroundColor White
    Write-Host ""
}

Write-Host "🎯 Ambiente validado! 🚀" -ForegroundColor Green
Write-Host ""
