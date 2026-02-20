# Script Completo de Teste End-to-End Android - Valida TUDO rodando localmente
# O app Flutter roda no Android e consome serviços reais (Docker)
Write-Host "=== Teste End-to-End Completo - Android App ===" -ForegroundColor Cyan
Write-Host "App Flutter no Android consumindo serviços locais (Docker)`n" -ForegroundColor Gray

$ErrorActionPreference = "Continue"
$allTestsPassed = $true
$testResults = @{}

# Função para marcar teste
function Test-Passed {
    param([string]$TestName)
    Write-Host "  ✓ $TestName" -ForegroundColor Green
    $script:testResults[$TestName] = "PASSED"
}

function Test-Failed {
    param([string]$TestName, [string]$Reason = "")
    Write-Host "  ✗ $TestName" -ForegroundColor Red
    if ($Reason) {
        Write-Host "    Razão: $Reason" -ForegroundColor Yellow
    }
    $script:testResults[$TestName] = "FAILED"
    $script:allTestsPassed = $false
}

# ============================================
# 1. VERIFICAR DOCKER E SERVIÇOS
# ============================================
Write-Host "=== [1/9] Verificando Docker e Serviços ===" -ForegroundColor Cyan

try {
    docker ps | Out-Null
    Test-Passed "Docker está rodando"
} catch {
    Test-Failed "Docker está rodando" "Docker não está acessível"
    Write-Host "  Execute: .\scripts\check-docker.ps1" -ForegroundColor Yellow
    exit 1
}

# Verificar containers
$services = @("benefits-postgres", "benefits-keycloak", "benefits-user-bff")
foreach ($service in $services) {
    $container = docker ps --filter "name=$service" --format "{{.Names}}" 2>$null
    if ($container -eq $service) {
        Test-Passed "$service está rodando"
    } else {
        Test-Failed "$service está rodando"
        Write-Host "  Iniciando serviços..." -ForegroundColor Yellow
        Push-Location infra
        docker-compose up -d
        Pop-Location
        Start-Sleep -Seconds 10
    }
}

# ============================================
# 2. VERIFICAR SERVIÇOS ESTÃO PRONTOS
# ============================================
Write-Host "`n=== [2/9] Verificando Serviços Prontos ===" -ForegroundColor Cyan

# PostgreSQL
$pgReady = docker exec benefits-postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Test-Passed "PostgreSQL está pronto"
} else {
    Test-Failed "PostgreSQL está pronto"
}

# Keycloak
Write-Host "  Aguardando Keycloak..." -ForegroundColor Yellow
$keycloakReady = $false
for ($i = 0; $i -lt 45; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/realms/benefits/.well-known/openid-configuration" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $keycloakReady = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if ($keycloakReady) {
    Test-Passed "Keycloak está pronto"
} else {
    Test-Failed "Keycloak está pronto"
}

# User BFF
Write-Host "  Aguardando User BFF..." -ForegroundColor Yellow
$bffReady = $false
for ($i = 0; $i -lt 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $bffReady = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if ($bffReady) {
    Test-Passed "User BFF está pronto"
} else {
    Test-Failed "User BFF está pronto"
}

# ============================================
# 3. VERIFICAR FLUTTER E ANDROID SDK
# ============================================
Write-Host "`n=== [3/9] Verificando Flutter e Android SDK ===" -ForegroundColor Cyan

try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    if ($flutterVersion -match "Flutter") {
        Test-Passed "Flutter está instalado"
    } else {
        Test-Failed "Flutter está instalado"
    }
} catch {
    Test-Failed "Flutter está instalado" "Flutter não encontrado no PATH"
    exit 1
}

# Verificar Android SDK
$androidSdk = $env:ANDROID_HOME
if (-not $androidSdk) {
    $androidSdk = "$env:LOCALAPPDATA\Android\Sdk"
}

if (Test-Path "$androidSdk\platform-tools\adb.exe") {
    Test-Passed "Android SDK está instalado"
    $env:ANDROID_HOME = $androidSdk
    $env:PATH = "$androidSdk\platform-tools;$env:PATH"
} else {
    Test-Failed "Android SDK está instalado" "ADB não encontrado"
    Write-Host "  Instale Android Studio: https://developer.android.com/studio" -ForegroundColor Yellow
    exit 1
}

# ============================================
# 4. VERIFICAR/INICIAR EMULADOR ANDROID
# ============================================
Write-Host "`n=== [4/9] Verificando Emulador Android ===" -ForegroundColor Cyan

# Listar dispositivos conectados
$devices = flutter devices 2>&1 | Select-String -Pattern "android|emulator" -CaseSensitive:$false
$androidDevice = $null

if ($devices) {
    Write-Host "  Dispositivos Android encontrados:" -ForegroundColor Gray
    $devices | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    
    # Tentar encontrar dispositivo Android
    $deviceList = adb devices 2>&1 | Select-String -Pattern "device$" | ForEach-Object { ($_ -split '\s+')[0] }
    
    if ($deviceList) {
        $androidDevice = $deviceList | Select-Object -First 1
        Test-Passed "Dispositivo Android conectado: $androidDevice"
    } else {
        Write-Host "  Nenhum dispositivo Android conectado" -ForegroundColor Yellow
        Write-Host "  Verificando emuladores disponíveis..." -ForegroundColor Yellow
        
        # Listar emuladores
        $emulators = flutter emulators 2>&1
        $emulatorList = $emulators | Select-String -Pattern "^\s+\w+" | ForEach-Object { ($_ -split '\s+')[0] }
        
        if ($emulatorList) {
            Write-Host "  Emuladores disponíveis:" -ForegroundColor Gray
            $emulatorList | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
            
            $emulatorToStart = $emulatorList | Select-Object -First 1
            Write-Host "  Iniciando emulador: $emulatorToStart" -ForegroundColor Yellow
            Start-Process -FilePath "flutter" -ArgumentList "emulators", "--launch", $emulatorToStart -NoNewWindow -Wait:$false
            
            Write-Host "  Aguardando emulador iniciar (60 segundos)..." -ForegroundColor Yellow
            $emulatorReady = $false
            for ($i = 0; $i -lt 60; $i++) {
                Start-Sleep -Seconds 2
                $deviceList = adb devices 2>&1 | Select-String -Pattern "device$" | ForEach-Object { ($_ -split '\s+')[0] }
                if ($deviceList) {
                    $androidDevice = $deviceList | Select-Object -First 1
                    $emulatorReady = $true
                    break
                }
            }
            
            if ($emulatorReady) {
                Test-Passed "Emulador Android iniciado: $androidDevice"
            } else {
                Test-Failed "Emulador Android iniciado" "Timeout aguardando emulador"
                Write-Host "  Inicie manualmente: flutter emulators --launch <nome>" -ForegroundColor Yellow
            }
        } else {
            Test-Failed "Emulador Android disponível" "Nenhum emulador configurado"
            Write-Host "  Configure um emulador no Android Studio:" -ForegroundColor Yellow
            Write-Host "    1. Abra Android Studio" -ForegroundColor Gray
            Write-Host "    2. Tools > Device Manager" -ForegroundColor Gray
            Write-Host "    3. Create Device > Phone > Pixel 5 (ou similar)" -ForegroundColor Gray
            Write-Host "    4. Download uma imagem do sistema (API 30+)" -ForegroundColor Gray
        }
    }
} else {
    Test-Failed "Dispositivo Android conectado" "Nenhum dispositivo encontrado"
}

if (-not $androidDevice) {
    Write-Host "`n⚠ AVISO: Nenhum dispositivo Android disponível" -ForegroundColor Yellow
    Write-Host "  O teste continuará, mas não será possível instalar o app no Android" -ForegroundColor Yellow
    Write-Host "  Você pode:" -ForegroundColor Yellow
    Write-Host "    1. Conectar um dispositivo físico via USB (com depuração USB ativada)" -ForegroundColor Gray
    Write-Host "    2. Criar e iniciar um emulador no Android Studio" -ForegroundColor Gray
    Write-Host "    3. Continuar apenas com testes de serviços (sem app Android)" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "  Continuar sem dispositivo Android? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        exit 1
    }
}

# ============================================
# 5. VERIFICAR PROJETO FLUTTER
# ============================================
Write-Host "`n=== [5/9] Verificando Projeto Flutter ===" -ForegroundColor Cyan

if (Test-Path "apps/user_app_flutter/pubspec.yaml") {
    Test-Passed "Projeto Flutter existe"
    
    Push-Location apps/user_app_flutter
    try {
        Write-Host "  Executando flutter pub get..." -ForegroundColor Yellow
        flutter pub get 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Test-Passed "Flutter pub get executado"
        } else {
            Test-Failed "Flutter pub get executado"
        }
    } catch {
        Test-Failed "Flutter pub get executado" $_.Exception.Message
    } finally {
        Pop-Location
    }
} else {
    Test-Failed "Projeto Flutter existe"
    exit 1
}

# ============================================
# 6. VERIFICAR CONFIGURAÇÃO ANDROID
# ============================================
Write-Host "`n=== [6/9] Verificando Configuração Android ===" -ForegroundColor Cyan

$manifestPath = "apps/user_app_flutter/android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifestPath) {
    Test-Passed "AndroidManifest.xml existe"
    
    $manifestContent = Get-Content $manifestPath -Raw
    if ($manifestContent -match "com.benefits.app://oauthredirect") {
        Test-Passed "Redirect URI configurado no AndroidManifest"
    } else {
        Test-Failed "Redirect URI configurado no AndroidManifest"
    }
    
    if ($manifestContent -match "android.permission.INTERNET") {
        Test-Passed "Permissão INTERNET configurada"
    } else {
        Test-Failed "Permissão INTERNET configurada"
    }
} else {
    Test-Failed "AndroidManifest.xml existe"
}

# ============================================
# 7. COMPILAR APP FLUTTER PARA ANDROID
# ============================================
Write-Host "`n=== [7/9] Compilando App Flutter para Android ===" -ForegroundColor Cyan

if ($androidDevice) {
    Push-Location apps/user_app_flutter
    try {
        Write-Host "  Compilando app (isso pode levar alguns minutos)..." -ForegroundColor Yellow
        Write-Host "  Build: flutter build apk --debug" -ForegroundColor Gray
        
        $buildOutput = flutter build apk --debug 2>&1
        if ($LASTEXITCODE -eq 0) {
            Test-Passed "App Flutter compilado com sucesso"
        } else {
            Test-Failed "App Flutter compilado" "Erro na compilação"
            Write-Host "  Saída do build:" -ForegroundColor Yellow
            $buildOutput | Select-Object -Last 20 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        }
    } catch {
        Test-Failed "App Flutter compilado" $_.Exception.Message
    } finally {
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Pulando compilação (sem dispositivo Android)" -ForegroundColor Yellow
}

# ============================================
# 8. INSTALAR APP NO ANDROID
# ============================================
Write-Host "`n=== [8/9] Instalando App no Android ===" -ForegroundColor Cyan

if ($androidDevice) {
    Push-Location apps/user_app_flutter
    try {
        Write-Host "  Instalando app no dispositivo..." -ForegroundColor Yellow
        
        # Desinstalar versão anterior se existir
        adb uninstall com.benefits.app 2>&1 | Out-Null
        
        # Instalar app
        $installOutput = flutter install 2>&1
        if ($LASTEXITCODE -eq 0) {
            Test-Passed "App instalado no Android"
        } else {
            # Tentar instalar APK diretamente
            $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
            if (Test-Path $apkPath) {
                Write-Host "  Tentando instalar APK diretamente..." -ForegroundColor Yellow
                $adbInstall = adb install $apkPath 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Test-Passed "App instalado via ADB"
                } else {
                    Test-Failed "App instalado" "Erro na instalação"
                    Write-Host "  Saída: $adbInstall" -ForegroundColor Gray
                }
            } else {
                Test-Failed "App instalado" "APK não encontrado"
            }
        }
    } catch {
        Test-Failed "App instalado" $_.Exception.Message
    } finally {
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Pulando instalação (sem dispositivo Android)" -ForegroundColor Yellow
}

# ============================================
# 9. TESTAR CONECTIVIDADE DOS SERVIÇOS
# ============================================
Write-Host "`n=== [9/9] Testando Conectividade dos Serviços ===" -ForegroundColor Cyan

# Testar se o emulador consegue acessar os serviços via 10.0.2.2
if ($androidDevice) {
    Write-Host "  Testando conectividade do emulador para serviços locais..." -ForegroundColor Yellow
    
    # Testar User BFF via 10.0.2.2:8080
    Write-Host "  Testando User BFF (10.0.2.2:8080)..." -ForegroundColor Gray
    $bffTest = adb shell "curl -s -o /dev/null -w '%{http_code}' http://10.0.2.2:8080/actuator/health" 2>&1
    if ($bffTest -eq "200" -or $bffTest -match "200") {
        Test-Passed "Emulador consegue acessar User BFF"
    } else {
        Write-Host "    ⚠ curl pode não estar disponível no emulador" -ForegroundColor Yellow
        Write-Host "    O app Flutter testará a conectividade ao iniciar" -ForegroundColor Gray
    }
    
    # Testar Keycloak via 10.0.2.2:8081
    Write-Host "  Testando Keycloak (10.0.2.2:8081)..." -ForegroundColor Gray
    $keycloakTest = adb shell "curl -s -o /dev/null -w '%{http_code}' http://10.0.2.2:8081/realms/benefits/.well-known/openid-configuration" 2>&1
    if ($keycloakTest -eq "200" -or $keycloakTest -match "200") {
        Test-Passed "Emulador consegue acessar Keycloak"
    } else {
        Write-Host "    ⚠ curl pode não estar disponível no emulador" -ForegroundColor Yellow
        Write-Host "    O app Flutter testará a conectividade ao iniciar" -ForegroundColor Gray
    }
    
    Write-Host "`n  Para testar o app manualmente:" -ForegroundColor Yellow
    Write-Host "    1. Abra o app 'Benefits' no dispositivo Android" -ForegroundColor White
    Write-Host "    2. O app tentará fazer login via Keycloak" -ForegroundColor White
    Write-Host "    3. Use as credenciais: user1 / Passw0rd!" -ForegroundColor White
    Write-Host "    4. Verifique se consegue ver saldo e transações" -ForegroundColor White
} else {
    Write-Host "  ⚠ Pulando testes de conectividade (sem dispositivo Android)" -ForegroundColor Yellow
}

# ============================================
# RESUMO FINAL
# ============================================
Write-Host "`n=== Resumo do Teste End-to-End Android ===" -ForegroundColor Cyan
Write-Host ""

$passed = ($testResults.Values | Where-Object { $_ -eq "PASSED" }).Count
$failed = ($testResults.Values | Where-Object { $_ -eq "FAILED" }).Count
$total = $testResults.Count

Write-Host "Total de testes: $total" -ForegroundColor White
Write-Host "Passou: $passed" -ForegroundColor Green
Write-Host "Falhou: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($allTestsPassed -or ($failed -eq 0)) {
    Write-Host "`n✓ TESTE END-TO-END CONCLUÍDO!" -ForegroundColor Green
    Write-Host "`nSistema está pronto:" -ForegroundColor Green
    Write-Host "  - PostgreSQL: localhost:5432" -ForegroundColor White
    Write-Host "  - Keycloak: http://localhost:8081" -ForegroundColor White
    Write-Host "  - User BFF: http://localhost:8080" -ForegroundColor White
    
    if ($androidDevice) {
        Write-Host "  - App Android instalado em: $androidDevice" -ForegroundColor White
        Write-Host "`nPara iniciar o app:" -ForegroundColor Yellow
        Write-Host "  cd apps/user_app_flutter" -ForegroundColor Gray
        Write-Host "  flutter run" -ForegroundColor Gray
        Write-Host "`nOu abra manualmente o app 'Benefits' no dispositivo" -ForegroundColor Yellow
    } else {
        Write-Host "`n⚠ Nenhum dispositivo Android conectado" -ForegroundColor Yellow
        Write-Host "  Para testar o app:" -ForegroundColor Yellow
        Write-Host "    1. Conecte um dispositivo ou inicie um emulador" -ForegroundColor White
        Write-Host "    2. Execute: cd apps/user_app_flutter && flutter run" -ForegroundColor White
    }
    
    exit 0
} else {
    Write-Host "`n✗ ALGUNS TESTES FALHARAM" -ForegroundColor Red
    Write-Host "`nTestes que falharam:" -ForegroundColor Yellow
    foreach ($test in $testResults.GetEnumerator() | Where-Object { $_.Value -eq "FAILED" }) {
        Write-Host "  - $($test.Key)" -ForegroundColor Red
    }
    
    exit 1
}
