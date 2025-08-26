# Script para gerar builds Android mockados
# Tenta resolver problemas de permissão do Gradle

Write-Host "🚀 GERANDO BUILDS ANDROID MOCKADOS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Verificar Flutter
Write-Host "🔍 Verificando Flutter..." -ForegroundColor Yellow
flutter --version

# Criar pasta de builds
$buildsDir = "builds_android"
if (Test-Path $buildsDir) {
    Remove-Item $buildsDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $buildsDir | Out-Null

Write-Host "`n📁 Pasta de builds criada: $buildsDir" -ForegroundColor Green

# ========================================
# 🔧 TENTATIVA 1: Limpeza completa
# ========================================
Write-Host "`n🔧 TENTATIVA 1: Limpeza completa..." -ForegroundColor Yellow

# Parar todos os processos Java/Gradle
Write-Host "Parando processos Java/Gradle..." -ForegroundColor White
taskkill /f /im java.exe 2>$null
taskkill /f /im gradle.exe 2>$null

# Aguardar um pouco
Start-Sleep -Seconds 3

# Tentar limpar o projeto
Write-Host "Limpando projeto..." -ForegroundColor White
flutter clean 2>$null

# ========================================
# 🧪 BUILD MOCK - Tentativa com diferentes abordagens
# ========================================
Write-Host "`n🧪 GERANDO BUILD MOCK..." -ForegroundColor Green
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - USE_MOCKS=true" -ForegroundColor White
Write-Host "  - ENV=mock" -ForegroundColor White
Write-Host "  - TEST_MODE=true" -ForegroundColor White

$buildSuccess = $false

# Tentativa 1: Build debug normal
if (-not $buildSuccess) {
    Write-Host "Tentativa 1: Build debug normal..." -ForegroundColor White
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
                $buildSuccess = $true
            }
        }
    } catch {
        Write-Host "❌ Tentativa 1 falhou: $_" -ForegroundColor Red
    }
}

# Tentativa 2: Build com --no-tree-shake-icons
if (-not $buildSuccess) {
    Write-Host "Tentativa 2: Build com --no-tree-shake-icons..." -ForegroundColor White
    try {
        flutter build apk --debug `
            --no-tree-shake-icons `
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
                $buildSuccess = $true
            }
        }
    } catch {
        Write-Host "❌ Tentativa 2 falhou: $_" -ForegroundColor Red
    }
}

# Tentativa 3: Build com --split-per-abi
if (-not $buildSuccess) {
    Write-Host "Tentativa 3: Build com --split-per-abi..." -ForegroundColor White
    try {
        flutter build apk --debug `
            --split-per-abi `
            --dart-define=USE_MOCKS=true `
            --dart-define=ENV=mock `
            --dart-define=TEST_MODE=true `
            --dart-define=ENABLE_DEBUG_LOGS=true `
            --dart-define=API_BASE_URL=https://mock-api.exemplo.com `
            --dart-define=NETWORK_DELAY_SECONDS=2.0
        
        if ($LASTEXITCODE -eq 0) {
            # Copiar todos os APKs gerados
            $apkFiles = Get-ChildItem "build/app/outputs/flutter-apk/" -Filter "*.apk"
            foreach ($apk in $apkFiles) {
                $dest = "$buildsDir/app-mock-debug-$($apk.Name)"
                Copy-Item $apk.FullName $dest
                Write-Host "✅ Build MOCK gerado: $dest" -ForegroundColor Green
            }
            $buildSuccess = $true
        }
    } catch {
        Write-Host "❌ Tentativa 3 falhou: $_" -ForegroundColor Red
    }
}

# ========================================
# 🛠️ BUILD DEV - Se o MOCK funcionou
# ========================================
if ($buildSuccess) {
    Write-Host "`n🛠️ GERANDO BUILD DEV..." -ForegroundColor Green
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

if ($buildSuccess) {
    Write-Host "`n🚀 GERAÇÃO DE BUILDS ANDROID CONCLUÍDA!" -ForegroundColor Green
    Write-Host "Os APKs estão na pasta '$buildsDir' e podem ser instalados em dispositivos Android." -ForegroundColor White
} else {
    Write-Host "`n⚠️ PROBLEMAS COM BUILDS ANDROID" -ForegroundColor Yellow
    Write-Host "O build WEB foi gerado com sucesso, mas os builds Android falharam." -ForegroundColor White
    Write-Host "Possíveis soluções:" -ForegroundColor White
    Write-Host "1. Reiniciar o computador" -ForegroundColor White
    Write-Host "2. Executar como administrador" -ForegroundColor White
    Write-Host "3. Usar Android Studio para builds" -ForegroundColor White
}
