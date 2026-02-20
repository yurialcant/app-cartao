# Sistema Inteligente de Builds com Configurações por Ambiente
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# Respeita LGPD e leis de proteção de dados

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "mock", "hml", "prod")]
    [string]$Environment,
    
    [int]$MaxBuilds = 5,
    [int]$DelayBetweenBuilds = 20,
    [switch]$SkipCleanup,
    [switch]$ForceInstall,
    [switch]$AutoLoop
)

# Configurações por ambiente
$EnvironmentConfigs = @{
    "dev" = @{
        Name = "DESENVOLVIMENTO"
        LogLevel = "DEBUG"
        EnableAllLogs = $true
        EnableDebugLogs = $true
        EnablePerformanceLogs = $true
        EnableUserTracking = $true
        EnableCrashReports = $true
        EnableAnalytics = $true
        MockMode = $true
        TestMode = $true
        NetworkDelay = 1.0
        ApiUrl = "https://dev-api.exemplo.com"
        Description = "Ambiente de desenvolvimento com logs completos"
        Color = "Green"
    }
    "mock" = @{
        Name = "MOCK"
        LogLevel = "VERBOSE"
        EnableAllLogs = $true
        EnableDebugLogs = $true
        EnablePerformanceLogs = $true
        EnableUserTracking = $true
        EnableCrashReports = $true
        EnableAnalytics = $true
        MockMode = $true
        TestMode = $true
        NetworkDelay = 2.0
        ApiUrl = "https://mock-api.exemplo.com"
        Description = "Ambiente mock com logs até no cu (máximo detalhamento)"
        Color = "Yellow"
    }
    "hml" = @{
        Name = "HOMOLOGAÇÃO"
        LogLevel = "INFO"
        EnableAllLogs = $false
        EnableDebugLogs = $false
        EnablePerformanceLogs = $true
        EnableUserTracking = $false
        EnableCrashReports = $true
        EnableAnalytics = $false
        MockMode = $false
        TestMode = $false
        NetworkDelay = 0.5
        ApiUrl = "https://hml-api.exemplo.com"
        Description = "Ambiente de homologação respeitando LGPD (sem tracking de usuário)"
        Color = "Blue"
    }
    "prod" = @{
        Name = "PRODUÇÃO"
        LogLevel = "ERROR"
        EnableAllLogs = $false
        EnableDebugLogs = $false
        EnablePerformanceLogs = $false
        EnableUserTracking = $false
        EnableCrashReports = $true
        EnableAnalytics = $false
        MockMode = $false
        TestMode = $false
        NetworkDelay = 0.1
        ApiUrl = "https://prod-api.exemplo.com"
        Description = "Ambiente de produção com compliance total (LGPD, GDPR, etc.)"
        Color = "Red"
    }
}

$Config = $EnvironmentConfigs[$Environment]
$ColorMap = @{ "Green" = "Green"; "Yellow" = "Yellow"; "Blue" = "Blue"; "Red" = "Red" }

Write-Host "🚀 SISTEMA INTELIGENTE DE BUILDS - $($Config.Name)" -ForegroundColor $ColorMap[$Config.Color]
Write-Host "===============================================" -ForegroundColor $ColorMap[$Config.Color]
Write-Host "📋 $($Config.Description)" -ForegroundColor White
Write-Host "🔧 Configurações:" -ForegroundColor White
Write-Host "  - Log Level: $($Config.LogLevel)" -ForegroundColor White
Write-Host "  - Logs Completos: $($Config.EnableAllLogs)" -ForegroundColor White
Write-Host "  - Tracking Usuário: $($Config.EnableUserTracking)" -ForegroundColor White
Write-Host "  - Modo Mock: $($Config.MockMode)" -ForegroundColor White
Write-Host "  - Delay Rede: $($Config.NetworkDelay)s" -ForegroundColor White
Write-Host "  - API: $($Config.ApiUrl)" -ForegroundColor White

# Verificar dependências
Write-Host "`n🔍 Verificando dependências..." -ForegroundColor Yellow
flutter --version
adb version

# Verificar dispositivos
Write-Host "`n📱 Verificando dispositivos Android..." -ForegroundColor Yellow
$devices = adb devices
Write-Host $devices

# Criar pasta para builds
$buildsDir = "builds_$Environment"
if (Test-Path $buildsDir) {
    Remove-Item $buildsDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $buildsDir | Out-Null

# Contador de builds
$buildCount = 0
$successfulBuilds = 0
$failedBuilds = 0

# Função para gerar build
function Generate-Build {
    param([int]$BuildNumber)
    
    Write-Host "`n🔄 BUILD #$BuildNumber" -ForegroundColor $ColorMap[$Config.Color]
    Write-Host "===============================================" -ForegroundColor $ColorMap[$Config.Color]
    
    try {
        # 1. Incrementar versão
        Write-Host "📝 Incrementando versão..." -ForegroundColor Yellow
        $newVersion = "1.0.$BuildNumber"
        $newBuildNumber = $BuildNumber.ToString("000")
        
        # Atualizar arquivo de versão
        $versionFile = "lib/core/config/app_version.dart"
        $versionContent = Get-Content $versionFile -Raw
        $versionContent = $versionContent -replace "static const String version = '.*';", "static const String version = '$newVersion';"
        $versionContent = $versionContent -replace "static const String buildNumber = '.*';", "static const String buildNumber = '$newBuildNumber';"
        $versionContent = $versionContent -replace "static const String releaseDate = '.*';", "static const String releaseDate = '$(Get-Date -Format 'dd/MM/yyyy HH:mm')';"
        $versionContent = $versionContent -replace "static const String environment = '.*';", "static const String environment = '$($Config.Name)';"
        Set-Content $versionFile $versionContent
        
        Write-Host "✅ Versão atualizada: $newVersion-$newBuildNumber ($($Config.Name))" -ForegroundColor Green
        
        # 2. Limpar projeto (se não pular)
        if (-not $SkipCleanup) {
            Write-Host "🧹 Limpando projeto..." -ForegroundColor Yellow
            taskkill /f /im java.exe 2>$null
            taskkill /f /im gradle.exe 2>$null
            Start-Sleep -Seconds 3
            flutter clean 2>$null
        }
        
        # 3. Gerar build com configurações específicas do ambiente
        Write-Host "🔨 Gerando build APK para $($Config.Name)..." -ForegroundColor Yellow
        
        $buildArgs = @(
            "build", "apk", "--debug",
            "--dart-define=USE_MOCKS=$($Config.MockMode)",
            "--dart-define=ENV=$Environment",
            "--dart-define=TEST_MODE=$($Config.TestMode)",
            "--dart-define=ENABLE_DEBUG_LOGS=$($Config.EnableDebugLogs)",
            "--dart-define=ENABLE_ALL_LOGS=$($Config.EnableAllLogs)",
            "--dart-define=ENABLE_USER_TRACKING=$($Config.EnableUserTracking)",
            "--dart-define=ENABLE_CRASH_REPORTS=$($Config.EnableCrashReports)",
            "--dart-define=ENABLE_ANALYTICS=$($Config.EnableAnalytics)",
            "--dart-define=LOG_LEVEL=$($Config.LogLevel)",
            "--dart-define=API_BASE_URL=$($Config.ApiUrl)",
            "--dart-define=NETWORK_DELAY_SECONDS=$($Config.NetworkDelay)"
        )
        
        $buildResult = flutter $buildArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Build gerado com sucesso para $($Config.Name)!" -ForegroundColor Green
            
            # 4. Copiar APK
            $apkSource = "build/app/outputs/flutter-apk/app-debug.apk"
            if (Test-Path $apkSource) {
                $apkDest = "$buildsDir/app-$Environment-v$newVersion-build$newBuildNumber.apk"
                Copy-Item $apkSource $apkDest
                Write-Host "📱 APK copiado: $apkDest" -ForegroundColor Green
                
                # 5. Instalar no dispositivo
                Write-Host "📲 Instalando no dispositivo..." -ForegroundColor Yellow
                $installResult = adb install -r $apkDest
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ APK instalado com sucesso!" -ForegroundColor Green
                    $script:successfulBuilds++
                    
                    # 6. Abrir app
                    Write-Host "🚀 Abrindo aplicativo..." -ForegroundColor Yellow
                    adb shell am start -n com.example.flutter_login_app/.MainActivity 2>$null
                    
                    return $true
                } else {
                    Write-Host "❌ Falha na instalação: $installResult" -ForegroundColor Red
                    if ($ForceInstall) {
                        Write-Host "🔄 Tentando instalação forçada..." -ForegroundColor Yellow
                        adb install -r -d $apkDest
                    }
                    return $false
                }
            } else {
                Write-Host "❌ APK não encontrado em: $apkSource" -ForegroundColor Red
                return $false
            }
        } else {
            Write-Host "❌ Falha na geração do build" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "❌ Erro durante o build #$BuildNumber : $_" -ForegroundColor Red
        return $false
    }
}

# Loop principal
if ($AutoLoop) {
    Write-Host "`n🔄 INICIANDO LOOP AUTOMÁTICO DE BUILDS" -ForegroundColor Cyan
    Write-Host "Máximo de builds: $MaxBuilds" -ForegroundColor White
    Write-Host "Delay entre builds: $DelayBetweenBuilds segundos" -ForegroundColor White
    
    while ($buildCount -lt $MaxBuilds) {
        $buildCount++
        
        $success = Generate-Build -BuildNumber $buildCount
        if (-not $success) {
            $failedBuilds++
        }
        
        # Aguardar antes do próximo build
        if ($buildCount -lt $MaxBuilds) {
            Write-Host "`n⏳ Aguardando $DelayBetweenBuilds segundos para o próximo build..." -ForegroundColor Yellow
            Start-Sleep -Seconds $DelayBetweenBuilds
        }
    }
} else {
    # Build único
    $buildCount = 1
    $success = Generate-Build -BuildNumber $buildCount
    if (-not $success) {
        $failedBuilds++
    }
}

# Resumo final
Write-Host "`n📊 RESUMO FINAL DOS BUILDS - $($Config.Name)" -ForegroundColor $ColorMap[$Config.Color]
Write-Host "===============================================" -ForegroundColor $ColorMap[$Config.Color]
Write-Host "🏗️ Total de builds: $buildCount" -ForegroundColor White
Write-Host "✅ Sucessos: $successfulBuilds" -ForegroundColor Green
Write-Host "❌ Falhas: $failedBuilds" -ForegroundColor Red
Write-Host "📁 Builds salvos em: $buildsDir" -ForegroundColor Blue

# Listar builds gerados
if (Test-Path $buildsDir) {
    Write-Host "`n📱 APKs gerados para $($Config.Name):" -ForegroundColor Cyan
    Get-ChildItem $buildsDir -Filter "*.apk" | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  📱 $($_.Name) ($size MB)" -ForegroundColor Green
    }
}

Write-Host "`n🚀 SISTEMA DE BUILDS CONCLUÍDO!" -ForegroundColor Green
Write-Host "Ambiente: $($Config.Name)" -ForegroundColor $ColorMap[$Config.Color]
Write-Host "Compliance: $($Config.Description)" -ForegroundColor White
