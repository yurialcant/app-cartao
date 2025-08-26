# Script de Build Automático em Loop com Incremento de Versão
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

param(
    [int]$MaxBuilds = 10,
    [int]$DelayBetweenBuilds = 30,
    [switch]$SkipCleanup,
    [switch]$ForceInstall
)

Write-Host "🚀 SISTEMA DE BUILD AUTOMÁTICO EM LOOP" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Configurações:" -ForegroundColor White
Write-Host "  - Máximo de builds: $MaxBuilds" -ForegroundColor White
Write-Host "  - Delay entre builds: $DelayBetweenBuilds segundos" -ForegroundColor White
Write-Host "  - Pular limpeza: $SkipCleanup" -ForegroundColor White
Write-Host "  - Forçar instalação: $ForceInstall" -ForegroundColor White

# Verificar Flutter e ADB
Write-Host "`n🔍 Verificando dependências..." -ForegroundColor Yellow
flutter --version
adb version

# Verificar dispositivos conectados
Write-Host "`n📱 Verificando dispositivos Android..." -ForegroundColor Yellow
$devices = adb devices
Write-Host $devices

# Criar pasta para builds
$buildsDir = "auto_builds"
if (Test-Path $buildsDir) {
    Remove-Item $buildsDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $buildsDir | Out-Null

# Contador de builds
$buildCount = 0
$successfulBuilds = 0
$failedBuilds = 0

# Loop principal de builds
while ($buildCount -lt $MaxBuilds) {
    $buildCount++
    Write-Host "`n🔄 BUILD #$buildCount de $MaxBuilds" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    
    try {
        # 1. Incrementar versão
        Write-Host "📝 Incrementando versão..." -ForegroundColor Yellow
        $newVersion = "0.0.$buildCount"
        $newBuildNumber = $buildCount.ToString("000")
        
        # Atualizar arquivo de versão
        $versionFile = "lib/core/config/app_version.dart"
        $versionContent = Get-Content $versionFile -Raw
        $versionContent = $versionContent -replace "static const String version = '.*';", "static const String version = '$newVersion';"
        $versionContent = $versionContent -replace "static const String buildNumber = '.*';", "static const String buildNumber = '$newBuildNumber';"
        $versionContent = $versionContent -replace "static const String releaseDate = '.*';", "static const String releaseDate = '$(Get-Date -Format 'dd/MM/yyyy HH:mm')';"
        Set-Content $versionFile $versionContent
        
        Write-Host "✅ Versão atualizada: $newVersion-$newBuildNumber" -ForegroundColor Green
        
        # 2. Limpar projeto (se não pular)
        if (-not $SkipCleanup) {
            Write-Host "🧹 Limpando projeto..." -ForegroundColor Yellow
            taskkill /f /im java.exe 2>$null
            taskkill /f /im gradle.exe 2>$null
            Start-Sleep -Seconds 3
            flutter clean 2>$null
        }
        
        # 3. Gerar build
        Write-Host "🔨 Gerando build APK..." -ForegroundColor Yellow
        $buildResult = flutter build apk --debug `
            --dart-define=USE_MOCKS=true `
            --dart-define=ENV=mock `
            --dart-define=TEST_MODE=true `
            --dart-define=ENABLE_DEBUG_LOGS=true `
            --dart-define=API_BASE_URL=https://mock-api.exemplo.com `
            --dart-define=NETWORK_DELAY_SECONDS=2.0
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Build gerado com sucesso!" -ForegroundColor Green
            
            # 4. Copiar APK para pasta de builds
            $apkSource = "build/app/outputs/flutter-apk/app-debug.apk"
            if (Test-Path $apkSource) {
                $apkDest = "$buildsDir/app-v$newVersion-build$newBuildNumber.apk"
                Copy-Item $apkSource $apkDest
                Write-Host "📱 APK copiado: $apkDest" -ForegroundColor Green
                
                # 5. Instalar no dispositivo
                Write-Host "📲 Instalando no dispositivo..." -ForegroundColor Yellow
                $installResult = adb install -r $apkDest
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ APK instalado com sucesso!" -ForegroundColor Green
                    $successfulBuilds++
                    
                    # 6. Abrir app
                    Write-Host "🚀 Abrindo aplicativo..." -ForegroundColor Yellow
                    adb shell am start -n com.example.flutter_login_app/.MainActivity 2>$null
                    
                } else {
                    Write-Host "❌ Falha na instalação: $installResult" -ForegroundColor Red
                    if ($ForceInstall) {
                        Write-Host "🔄 Tentando instalação forçada..." -ForegroundColor Yellow
                        adb install -r -d $apkDest
                    }
                }
            } else {
                Write-Host "❌ APK não encontrado em: $apkSource" -ForegroundColor Red
                $failedBuilds++
            }
        } else {
            Write-Host "❌ Falha na geração do build" -ForegroundColor Red
            $failedBuilds++
        }
        
        # 7. Aguardar antes do próximo build
        if ($buildCount -lt $MaxBuilds) {
            Write-Host "`n⏳ Aguardando $DelayBetweenBuilds segundos para o próximo build..." -ForegroundColor Yellow
            Start-Sleep -Seconds $DelayBetweenBuilds
        }
        
    } catch {
        Write-Host "❌ Erro durante o build #$buildCount : $_" -ForegroundColor Red
        $failedBuilds++
    }
}

# Resumo final
Write-Host "`n📊 RESUMO FINAL DOS BUILDS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🏗️ Total de builds: $buildCount" -ForegroundColor White
Write-Host "✅ Sucessos: $successfulBuilds" -ForegroundColor Green
Write-Host "❌ Falhas: $failedBuilds" -ForegroundColor Red
Write-Host "📁 Builds salvos em: $buildsDir" -ForegroundColor Blue

# Listar builds gerados
if (Test-Path $buildsDir) {
    Write-Host "`n📱 APKs gerados:" -ForegroundColor Cyan
    Get-ChildItem $buildsDir -Filter "*.apk" | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  📱 $($_.Name) ($size MB)" -ForegroundColor Green
    }
}

Write-Host "`n🚀 LOOP DE BUILDS CONCLUÍDO!" -ForegroundColor Green
