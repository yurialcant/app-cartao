# Script para diagnosticar e corrigir erros comuns
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Yellow
Write-Host "║     🔍 DIAGNOSTICANDO E CORRIGINDO ERROS 🔍                 ║" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

$projectRoot = $PSScriptRoot | Split-Path -Parent
$errorsFound = $false

# ============================================================================
# 1. VERIFICAR SERVIÇOS DOCKER
# ============================================================================
Write-Host "[1/6] Verificando serviços Docker..." -ForegroundColor Cyan
$services = @(
    @{Name="PostgreSQL"; Port=5432; Check=$false},
    @{Name="Keycloak"; Url="http://localhost:8081/realms/benefits/.well-known/openid-configuration"},
    @{Name="Core Service"; Url="http://localhost:8091/actuator/health"},
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"}
)

foreach ($svc in $services) {
    if ($svc.Url) {
        try {
            $response = Invoke-WebRequest -Uri $svc.Url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            Write-Host "  ✓ $($svc.Name) - OK" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ $($svc.Name) - ERRO: $_" -ForegroundColor Red
            $errorsFound = $true
        }
    }
}

# ============================================================================
# 2. VERIFICAR ANGULAR ADMIN
# ============================================================================
Write-Host "`n[2/6] Verificando Angular Admin..." -ForegroundColor Cyan
$adminPath = "$projectRoot\apps\admin_angular"
if (Test-Path $adminPath) {
    if (-not (Test-Path "$adminPath\angular.json")) {
        Write-Host "  ✗ angular.json não encontrado!" -ForegroundColor Red
        $errorsFound = $true
    } else {
        Write-Host "  ✓ angular.json encontrado" -ForegroundColor Green
    }
    
    if (-not (Test-Path "$adminPath\node_modules")) {
        Write-Host "  ⚠ node_modules não encontrado, instalando..." -ForegroundColor Yellow
        Push-Location $adminPath
        npm install
        Pop-Location
    } else {
        Write-Host "  ✓ node_modules encontrado" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ Diretório não encontrado: $adminPath" -ForegroundColor Red
    $errorsFound = $true
}

# ============================================================================
# 3. VERIFICAR ANGULAR MERCHANT PORTAL
# ============================================================================
Write-Host "`n[3/6] Verificando Angular Merchant Portal..." -ForegroundColor Cyan
$merchantPortalPath = "$projectRoot\apps\merchant_portal_angular"
if (Test-Path $merchantPortalPath) {
    if (-not (Test-Path "$merchantPortalPath\angular.json")) {
        Write-Host "  ✗ angular.json não encontrado!" -ForegroundColor Red
        $errorsFound = $true
    } else {
        Write-Host "  ✓ angular.json encontrado" -ForegroundColor Green
    }
    
    if (-not (Test-Path "$merchantPortalPath\node_modules")) {
        Write-Host "  ⚠ node_modules não encontrado, instalando..." -ForegroundColor Yellow
        Push-Location $merchantPortalPath
        npm install
        Pop-Location
    } else {
        Write-Host "  ✓ node_modules encontrado" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ Diretório não encontrado: $merchantPortalPath" -ForegroundColor Yellow
}

# ============================================================================
# 4. VERIFICAR FLUTTER USER APP
# ============================================================================
Write-Host "`n[4/6] Verificando Flutter User App..." -ForegroundColor Cyan
$flutterUserPath = "$projectRoot\apps\user_app_flutter"
if (Test-Path $flutterUserPath) {
    if (-not (Test-Path "$flutterUserPath\pubspec.yaml")) {
        Write-Host "  ✗ pubspec.yaml não encontrado!" -ForegroundColor Red
        $errorsFound = $true
    } else {
        Write-Host "  ✓ pubspec.yaml encontrado" -ForegroundColor Green
    }
    
    if (-not (Test-Path "$flutterUserPath\pubspec.lock")) {
        Write-Host "  ⚠ Dependências não instaladas, executando flutter pub get..." -ForegroundColor Yellow
        Push-Location $flutterUserPath
        flutter pub get
        Pop-Location
    } else {
        Write-Host "  ✓ Dependências instaladas" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ Diretório não encontrado: $flutterUserPath" -ForegroundColor Red
    $errorsFound = $true
}

# ============================================================================
# 5. VERIFICAR FLUTTER MERCHANT POS
# ============================================================================
Write-Host "`n[5/6] Verificando Flutter Merchant POS..." -ForegroundColor Cyan
$flutterMerchantPath = "$projectRoot\apps\merchant_pos_flutter"
if (Test-Path $flutterMerchantPath) {
    if (-not (Test-Path "$flutterMerchantPath\pubspec.yaml")) {
        Write-Host "  ✗ pubspec.yaml não encontrado!" -ForegroundColor Red
        $errorsFound = $true
    } else {
        Write-Host "  ✓ pubspec.yaml encontrado" -ForegroundColor Green
    }
    
    if (-not (Test-Path "$flutterMerchantPath\pubspec.lock")) {
        Write-Host "  ⚠ Dependências não instaladas, executando flutter pub get..." -ForegroundColor Yellow
        Push-Location $flutterMerchantPath
        flutter pub get
        Pop-Location
    } else {
        Write-Host "  ✓ Dependências instaladas" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ Diretório não encontrado: $flutterMerchantPath" -ForegroundColor Yellow
}

# ============================================================================
# 6. VERIFICAR PORTAS EM USO
# ============================================================================
Write-Host "`n[6/6] Verificando portas em uso..." -ForegroundColor Cyan
$ports = @(4200, 4201, 8080, 8081, 8083, 8084, 8091)
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "  ⚠ Porta $port está em uso" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Porta $port está livre" -ForegroundColor Green
    }
}

# ============================================================================
# RESUMO
# ============================================================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $(if ($errorsFound) { "Red" } else { "Green" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($errorsFound) { "Red" } else { "Green" })
Write-Host "║     $(if ($errorsFound) { "⚠ ERROS ENCONTRADOS" } else { "✅ TUDO OK" }) $(if ($errorsFound) { "⚠" } else { "✅" })            ║" -ForegroundColor $(if ($errorsFound) { "Red" } else { "Green" })
Write-Host "║                                                              ║" -ForegroundColor $(if ($errorsFound) { "Red" } else { "Green" })
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $(if ($errorsFound) { "Red" } else { "Green" })
Write-Host ""

if ($errorsFound) {
    Write-Host "⚠ Alguns problemas foram encontrados e corrigidos automaticamente." -ForegroundColor Yellow
    Write-Host "  Execute novamente: .\START-EVERYTHING.ps1" -ForegroundColor White
} else {
    Write-Host "✅ Tudo parece estar OK!" -ForegroundColor Green
    Write-Host "  Se ainda houver erros, verifique os terminais dos apps." -ForegroundColor White
}

Write-Host ""
