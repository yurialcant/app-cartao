# Script para gerar builds de todos os ambientes com configurações mockadas
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "🚀 INICIANDO GERAÇÃO DE BUILDS MOCKADOS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Verificar se o Flutter está disponível
Write-Host "🔍 Verificando Flutter..." -ForegroundColor Yellow
flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter não encontrado. Execute 'flutter doctor' primeiro." -ForegroundColor Red
    exit 1
}

# Limpar builds anteriores
Write-Host "🧹 Limpando builds anteriores..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Criar diretório para builds
$buildsDir = "builds"
if (Test-Path $buildsDir) {
    Remove-Item $buildsDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildsDir | Out-Null

# ========================================
# 🧪 BUILD MOCK - Ambiente totalmente mockado
# ========================================
Write-Host "`n🧪 GERANDO BUILD MOCK..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=mock" -ForegroundColor White
Write-Host "  - TEST_MODE=true" -ForegroundColor White
Write-Host "  - ENABLE_DEBUG_LOGS=true" -ForegroundColor White

flutter build apk --release `
    --dart-define=USE_MOCKS=true `
    --dart-define=ENV=mock `
    --dart-define=TEST_MODE=true `
    --dart-define=ENABLE_DEBUG_LOGS=true `
    --dart-define=API_BASE_URL=https://mock-api.exemplo.com `
    --dart-define=NETWORK_DELAY_SECONDS=2.0

if ($LASTEXITCODE -eq 0) {
    $mockApk = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $mockApk) {
        $mockDest = "$buildsDir/app-mock-release.apk"
        Copy-Item $mockApk $mockDest
        Write-Host "✅ Build MOCK gerado: $mockDest" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Erro ao gerar build MOCK" -ForegroundColor Red
}

# ========================================
# 🛠️ BUILD DEV - Ambiente de desenvolvimento
# ========================================
Write-Host "`n🛠️ GERANDO BUILD DEV..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=dev" -ForegroundColor White
Write-Host "  - TEST_MODE=false" -ForegroundColor White
Write-Host "  - ENABLE_DEBUG_LOGS=true" -ForegroundColor White

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
} else {
    Write-Host "❌ Erro ao gerar build DEV" -ForegroundColor Red
}

# ========================================
# 📦 BUILD RELEASE - Ambiente de release
# ========================================
Write-Host "`n📦 GERANDO BUILD RELEASE..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=release" -ForegroundColor White
Write-Host "  - TEST_MODE=false" -ForegroundColor White
Write-Host "  - ENABLE_DEBUG_LOGS=false" -ForegroundColor White

flutter build apk --release `
    --dart-define=USE_MOCKS=true `
    --dart-define=ENV=release `
    --dart-define=TEST_MODE=false `
    --dart-define=ENABLE_DEBUG_LOGS=false `
    --dart-define=API_BASE_URL=https://release-api.exemplo.com `
    --dart-define=NETWORK_DELAY_SECONDS=0.5

if ($LASTEXITCODE -eq 0) {
    $releaseApk = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $releaseApk) {
        $releaseDest = "$buildsDir/app-release-release.apk"
        Copy-Item $releaseApk $releaseDest
        Write-Host "✅ Build RELEASE gerado: $releaseDest" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Erro ao gerar build RELEASE" -ForegroundColor Red
}

# ========================================
# 🌐 BUILD PROD - Ambiente de produção (mockado para demo)
# ========================================
Write-Host "`n🌐 GERANDO BUILD PROD (MOCKADO PARA DEMO)..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=prod" -ForegroundColor White
Write-Host "  - TEST_MODE=false" -ForegroundColor White
Write-Host "  - ENABLE_DEBUG_LOGS=false" -ForegroundColor White

flutter build apk --release `
    --dart-define=USE_MOCKS=true `
    --dart-define=ENV=prod `
    --dart-define=TEST_MODE=false `
    --dart-define=ENABLE_DEBUG_LOGS=false `
    --dart-define=API_BASE_URL=https://prod-api.exemplo.com `
    --dart-define=NETWORK_DELAY_SECONDS=0.2

if ($LASTEXITCODE -eq 0) {
    $prodApk = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $prodApk) {
        $prodDest = "$buildsDir/app-prod-release.apk"
        Copy-Item $prodApk $prodDest
        Write-Host "✅ Build PROD gerado: $prodDest" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Erro ao gerar build PROD" -ForegroundColor Red
}

# ========================================
# 📱 BUILD WEB (opcional)
# ========================================
Write-Host "`n🌐 GERANDO BUILD WEB MOCK..." -ForegroundColor Green

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
} else {
    Write-Host "❌ Erro ao gerar build WEB" -ForegroundColor Red
}

# ========================================
# 📊 RESUMO DOS BUILDS
# ========================================
Write-Host "`n📊 RESUMO DOS BUILDS GERADOS:" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Get-ChildItem $buildsDir -Recurse | ForEach-Object {
    if ($_.PSIsContainer) {
        Write-Host "📁 $($_.Name)/" -ForegroundColor Blue
    } else {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "📱 $($_.Name) ($size MB)" -ForegroundColor Green
    }
}

Write-Host "`n🎯 CONFIGURAÇÕES APLICADAS:" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "✅ Todos os builds configurados com USE_MOCKS=true" -ForegroundColor Green
Write-Host "✅ Diferentes ambientes (mock, dev, release, prod)" -ForegroundColor Green
Write-Host "✅ Configurações específicas para cada ambiente" -ForegroundColor Green
Write-Host "✅ Builds organizados na pasta 'builds/'" -ForegroundColor Green

Write-Host "`n🚀 GERAÇÃO DE BUILDS CONCLUÍDA!" -ForegroundColor Green
Write-Host "Os APKs estão na pasta 'builds/' e podem ser instalados em dispositivos Android." -ForegroundColor White
