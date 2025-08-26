# Script simplificado para gerar builds mockados
# Evita problemas de permissão do Gradle

Write-Host "🚀 GERANDO BUILDS MOCKADOS SIMPLIFICADOS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Verificar Flutter
Write-Host "🔍 Verificando Flutter..." -ForegroundColor Yellow
flutter --version

# Criar pasta de builds
$buildsDir = "builds_simple"
if (Test-Path $buildsDir) {
    Remove-Item $buildsDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $buildsDir | Out-Null

Write-Host "`n📁 Pasta de builds criada: $buildsDir" -ForegroundColor Green

# ========================================
# 🧪 BUILD MOCK - Debug (mais estável)
# ========================================
Write-Host "`n🧪 GERANDO BUILD MOCK (DEBUG)..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=mock" -ForegroundColor White
Write-Host "  - TEST_MODE=true" -ForegroundColor White

try {
    flutter build apk --debug `
        --dart-define=USE_MOCKS=true `
        --dart-define=ENV=mock `
        --dart-define=TEST_MODE=true `
        --dart-define=ENABLE_DEBUG_LOGS=true `
        --dart-define=API_BASE_URL=https://mock-api.exemplo.com `
        --dart-define=NETWORK_DELAY_SECONDS=2.0
    
    if ($LASTEXITCODE -eq 0) {
        $mockApk = "build/app/outputs/flutter-apk/app-debug.apk"
        if (Test-Path $mockApk) {
            $mockDest = "$buildsDir/app-mock-debug.apk"
            Copy-Item $mockApk $mockDest
            Write-Host "✅ Build MOCK gerado: $mockDest" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "❌ Erro ao gerar build MOCK: $_" -ForegroundColor Red
}

# ========================================
# 🛠️ BUILD DEV - Debug
# ========================================
Write-Host "`n🛠️ GERANDO BUILD DEV (DEBUG)..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=dev" -ForegroundColor White
Write-Host "  - TEST_MODE=false" -ForegroundColor White

try {
    flutter build apk --debug `
        --dart-define=USE_MOCKS=true `
        --dart-define=ENV=dev `
        --dart-define=TEST_MODE=false `
        --dart-define=ENABLE_DEBUG_LOGS=true `
        --dart-define=API_BASE_URL=https://dev-api.exemplo.com `
        --dart-define=NETWORK_DELAY_SECONDS=1.0
    
    if ($LASTEXITCODE -eq 0) {
        $devApk = "build/app/outputs/flutter-apk/app-debug.apk"
        if (Test-Path $devApk) {
            $devDest = "$buildsDir/app-dev-debug.apk"
            Copy-Item $devApk $devDest
            Write-Host "✅ Build DEV gerado: $devDest" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "❌ Erro ao gerar build DEV: $_" -ForegroundColor Red
}

# ========================================
# 📱 BUILD WEB MOCK
# ========================================
Write-Host "`n🌐 GERANDO BUILD WEB MOCK..." -ForegroundColor Green

try {
    flutter build web `
        --dart-define=USE_MOCKS=true `
        --dart-define=ENV=mock `
        --dart-define=TEST_MODE=true `
        --dart-define=ENABLE_DEBUG_LOGS=true
    
    if ($LASTEXITCODE -eq 0) {
        $webDir = "build/web"
        if (Test-Path $webDir) {
            $webDest = "$buildsDir/web-mock"
            Copy-Item $webDir $webDest -Recurse
            Write-Host "✅ Build WEB gerado: $webDest" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "❌ Erro ao gerar build WEB: $_" -ForegroundColor Red
}

# ========================================
# 📊 RESUMO DOS BUILDS
# ========================================
Write-Host "`n📊 RESUMO DOS BUILDS GERADOS:" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

if (Test-Path $buildsDir) {
    Get-ChildItem $buildsDir -Recurse | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host "📁 $($_.Name)/" -ForegroundColor Blue
        } else {
            $size = [math]::Round($_.Length / 1MB, 2)
            Write-Host "📱 $($_.Name) ($size MB)" -ForegroundColor Green
        }
    }
} else {
    Write-Host "❌ Nenhum build foi gerado" -ForegroundColor Red
}

Write-Host "`n🎯 CONFIGURAÇÕES APLICADAS:" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "✅ Todos os builds configurados com USE_MOCKS=true" -ForegroundColor Green
Write-Host "✅ Diferentes ambientes (mock, dev)" -ForegroundColor Green
Write-Host "✅ Builds organizados na pasta '$buildsDir'" -ForegroundColor Green

Write-Host "`n🚀 GERAÇÃO DE BUILDS CONCLUÍDA!" -ForegroundColor Green
Write-Host "Os APKs estão na pasta '$buildsDir' e podem ser instalados em dispositivos Android." -ForegroundColor White
