# Script Master - Executa TUDO de ponta a ponta
# 1. Inicia serviços Docker
# 2. Verifica serviços prontos
# 3. Inicia emulador Android (se necessário)
# 4. Compila e instala app Flutter no Android
# 5. Executa testes end-to-end completos
Write-Host "=== Execução Completa End-to-End - Sistema Benefits ===" -ForegroundColor Cyan
Write-Host "Do macro ao micro: Docker → Serviços → Android App → Testes`n" -ForegroundColor Gray

$ErrorActionPreference = "Continue"

# ============================================
# ETAPA 1: INICIAR SERVIÇOS DOCKER
# ============================================
Write-Host "=== [ETAPA 1/5] Iniciando Serviços Docker ===" -ForegroundColor Cyan

# Verificar Docker
try {
    docker ps | Out-Null
    Write-Host "✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: .\scripts\check-docker.ps1" -ForegroundColor Yellow
    exit 1
}

# Iniciar serviços
Push-Location infra
Write-Host "`nIniciando serviços Docker Compose..." -ForegroundColor Yellow
docker-compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Erro ao iniciar serviços Docker" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✓ Serviços Docker iniciados" -ForegroundColor Green
Pop-Location

# Aguardar serviços iniciarem
Write-Host "`nAguardando serviços iniciarem (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# ============================================
# ETAPA 2: VERIFICAR SERVIÇOS PRONTOS
# ============================================
Write-Host "`n=== [ETAPA 2/5] Verificando Serviços Prontos ===" -ForegroundColor Cyan

# PostgreSQL
$pgReady = docker exec benefits-postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PostgreSQL está pronto" -ForegroundColor Green
} else {
    Write-Host "✗ PostgreSQL não está pronto" -ForegroundColor Red
    exit 1
}

# Keycloak
Write-Host "Verificando Keycloak..." -ForegroundColor Yellow
$keycloakReady = $false
for ($i = 0; $i -lt 30; $i++) {
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
    Write-Host "✓ Keycloak está pronto" -ForegroundColor Green
} else {
    Write-Host "✗ Keycloak não está pronto (aguardou 60s)" -ForegroundColor Red
    Write-Host "  Verifique: docker logs benefits-keycloak" -ForegroundColor Yellow
    exit 1
}

# User BFF
Write-Host "Verificando User BFF..." -ForegroundColor Yellow
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
    Write-Host "✓ User BFF está pronto" -ForegroundColor Green
} else {
    Write-Host "✗ User BFF não está pronto (aguardou 40s)" -ForegroundColor Red
    Write-Host "  Verifique: docker logs benefits-user-bff" -ForegroundColor Yellow
    exit 1
}

# ============================================
# ETAPA 3: TESTAR SERVIÇOS (API)
# ============================================
Write-Host "`n=== [ETAPA 3/5] Testando APIs dos Serviços ===" -ForegroundColor Cyan

Write-Host "Executando testes de API..." -ForegroundColor Yellow
.\scripts\test-e2e.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n⚠ Alguns testes de API falharam, mas continuando..." -ForegroundColor Yellow
}

# ============================================
# ETAPA 4: PREPARAR E INSTALAR APP ANDROID
# ============================================
Write-Host "`n=== [ETAPA 4/5] Preparando App Android ===" -ForegroundColor Cyan

# Verificar Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Flutter encontrado: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter não encontrado!" -ForegroundColor Red
    exit 1
}

# Verificar Android SDK
$androidSdk = $env:ANDROID_HOME
if (-not $androidSdk -or -not (Test-Path "$androidSdk\platform-tools\adb.exe")) {
    # Tentar localizações comuns
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "$env:ProgramFiles\Android\Android Studio\sdk",
        "C:\Android\android-sdk"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path "$path\platform-tools\adb.exe") {
            $androidSdk = $path
            break
        }
    }
}

if ($androidSdk -and (Test-Path "$androidSdk\platform-tools\adb.exe")) {
    Write-Host "✓ Android SDK encontrado: $androidSdk" -ForegroundColor Green
    $env:ANDROID_HOME = $androidSdk
    $env:PATH = "$androidSdk\platform-tools;$env:PATH"
} else {
    Write-Host "⚠ Android SDK não encontrado automaticamente" -ForegroundColor Yellow
    Write-Host "  Tentando usar adb do PATH..." -ForegroundColor Yellow
    
    # Tentar usar adb do PATH
    $adbPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbPath) {
        Write-Host "✓ ADB encontrado no PATH" -ForegroundColor Green
    } else {
        Write-Host "✗ Android SDK não encontrado!" -ForegroundColor Red
        Write-Host "  Instale Android Studio: https://developer.android.com/studio" -ForegroundColor Yellow
        Write-Host "  Ou configure ANDROID_HOME manualmente" -ForegroundColor Yellow
        # Não sair, apenas avisar - o Flutter pode funcionar sem isso
    }
}

# Verificar/Iniciar emulador
Write-Host "`nVerificando dispositivos Android..." -ForegroundColor Yellow
$devices = adb devices 2>&1 | Select-String -Pattern "device$" | ForEach-Object { ($_ -split '\s+')[0] }

if (-not $devices) {
    Write-Host "Nenhum dispositivo Android conectado" -ForegroundColor Yellow
    Write-Host "Verificando emuladores disponíveis..." -ForegroundColor Yellow
    
    $emulators = flutter emulators 2>&1
    $emulatorList = $emulators | Select-String -Pattern "^\s+\w+" | ForEach-Object { 
        $line = $_.ToString().Trim()
        if ($line -match "^\w+") {
            ($line -split '\s+')[0]
        }
    } | Where-Object { $_ -ne "" }
    
    if ($emulatorList) {
        $emulatorToStart = $emulatorList | Select-Object -First 1
        Write-Host "Iniciando emulador: $emulatorToStart" -ForegroundColor Yellow
        Start-Process -FilePath "flutter" -ArgumentList "emulators", "--launch", $emulatorToStart -NoNewWindow -Wait:$false
        
        Write-Host "Aguardando emulador iniciar (90 segundos)..." -ForegroundColor Yellow
        $emulatorReady = $false
        for ($i = 0; $i -lt 90; $i++) {
            Start-Sleep -Seconds 2
            $devices = adb devices 2>&1 | Select-String -Pattern "device$" | ForEach-Object { ($_ -split '\s+')[0] }
            if ($devices) {
                $emulatorReady = $true
                Write-Host "✓ Emulador iniciado: $devices" -ForegroundColor Green
                break
            }
            if ($i % 10 -eq 0) {
                Write-Host "  Aguardando... ($i/90 segundos)" -ForegroundColor Gray
            }
        }
        
        if (-not $emulatorReady) {
            Write-Host "⚠ Emulador não iniciou a tempo" -ForegroundColor Yellow
            Write-Host "  Você pode iniciar manualmente e executar novamente" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠ Nenhum emulador configurado" -ForegroundColor Yellow
        Write-Host "  Configure um emulador no Android Studio" -ForegroundColor Yellow
    }
} else {
    Write-Host "✓ Dispositivo Android conectado: $devices" -ForegroundColor Green
}

# Compilar e instalar app
if ($devices) {
    Push-Location apps/user_app_flutter
    
    Write-Host "`nPreparando app Flutter..." -ForegroundColor Yellow
    flutter pub get 2>&1 | Out-Null
    
    Write-Host "Compilando app Flutter (debug)..." -ForegroundColor Yellow
    flutter build apk --debug 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ App compilado com sucesso" -ForegroundColor Green
        
        Write-Host "Instalando app no dispositivo Android..." -ForegroundColor Yellow
        # Desinstalar versão anterior se existir
        adb uninstall com.benefits.app 2>&1 | Out-Null
        
        # Instalar APK debug
        $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
        if (Test-Path $apkPath) {
            $installResult = adb install $apkPath 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ App instalado com sucesso" -ForegroundColor Green
            } else {
                Write-Host "⚠ Erro ao instalar app" -ForegroundColor Yellow
                Write-Host "  Saída: $installResult" -ForegroundColor Gray
                Write-Host "  Tentando flutter install..." -ForegroundColor Yellow
                flutter install 2>&1 | Out-Null
            }
        } else {
            Write-Host "⚠ APK não encontrado em $apkPath" -ForegroundColor Yellow
            Write-Host "  Tentando flutter install..." -ForegroundColor Yellow
            flutter install 2>&1 | Out-Null
        }
    } else {
        Write-Host "✗ Erro ao compilar app" -ForegroundColor Red
    }
    
    Pop-Location
} else {
    Write-Host "`n⚠ Nenhum dispositivo Android disponível" -ForegroundColor Yellow
    Write-Host "  Para testar o app:" -ForegroundColor Yellow
    Write-Host "    1. Conecte um dispositivo ou inicie um emulador" -ForegroundColor White
    Write-Host "    2. Execute: cd apps/user_app_flutter && flutter run" -ForegroundColor White
}

# ============================================
# ETAPA 5: EXECUTAR TESTES COMPLETOS
# ============================================
Write-Host "`n=== [ETAPA 5/5] Executando Testes Completos ===" -ForegroundColor Cyan

Write-Host "Executando testes end-to-end completos..." -ForegroundColor Yellow
.\scripts\test-full-e2e.ps1

# ============================================
# RESUMO FINAL
# ============================================
Write-Host "`n=== RESUMO FINAL ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Execução completa finalizada!" -ForegroundColor Green
Write-Host ""
Write-Host "Serviços rodando:" -ForegroundColor Yellow
Write-Host "  - PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "  - Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  - Keycloak Admin: http://localhost:8081/admin (admin/admin)" -ForegroundColor White
Write-Host "  - User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  - User BFF Health: http://localhost:8080/actuator/health" -ForegroundColor White

if ($devices) {
    Write-Host ""
    Write-Host "App Android:" -ForegroundColor Yellow
    Write-Host "  - Instalado em: $devices" -ForegroundColor White
    Write-Host "  - Para iniciar: cd apps/user_app_flutter && flutter run" -ForegroundColor White
    Write-Host "  - Ou abra manualmente o app 'Benefits' no dispositivo" -ForegroundColor White
    Write-Host ""
    Write-Host "Credenciais de teste:" -ForegroundColor Yellow
    Write-Host "  - Usuário: user1" -ForegroundColor White
    Write-Host "  - Senha: Passw0rd!" -ForegroundColor White
}

Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Teste o app Flutter no dispositivo Android" -ForegroundColor White
Write-Host "  2. Execute testes de carga: k6 run infra/k6/load-test.js" -ForegroundColor White
Write-Host "  3. Verifique logs: docker-compose -f infra/docker-compose.yml logs -f" -ForegroundColor White
