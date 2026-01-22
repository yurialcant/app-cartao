# ============================================
# SCRIPT: Rodar tudo (Docker + Apps Flutter)
# ============================================

param(
    [ValidateSet('all', 'docker', 'user-app', 'merchant-app', 'test')]
    [string]$Action = 'all'
)

# Cores para output
$Green = 'Green'
$Yellow = 'Yellow'
$Red = 'Red'
$Blue = 'Cyan'

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor $Green
}

function Write-Info($message) {
    Write-Host "ℹ️ $message" -ForegroundColor $Blue
}

function Write-Warning($message) {
    Write-Host "⚠️ $message" -ForegroundColor $Yellow
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor $Red
}

function Test-Docker {
    Write-Info "Verificando Docker..."
    
    try {
        $version = docker --version
        Write-Success "Docker encontrado: $version"
        return $true
    } catch {
        Write-Error "Docker não encontrado ou não está rodando"
        return $false
    }
}

function Test-Flutter {
    Write-Info "Verificando Flutter..."
    
    try {
        $version = flutter --version
        Write-Success "Flutter encontrado: $(($version -split '\n')[0])"
        return $true
    } catch {
        Write-Error "Flutter não encontrado"
        return $false
    }
}

function Start-DockerServices {
    Write-Host "`n========================================" -ForegroundColor $Blue
    Write-Host "🐳 INICIANDO SERVIÇOS DOCKER" -ForegroundColor $Blue
    Write-Host "========================================`n" -ForegroundColor $Blue
    
    try {
        Push-Location "infra"
        
        Write-Info "Parando containers anteriores..."
        docker-compose down --remove-orphans 2>$null
        
        Write-Info "Buildando e iniciando serviços..."
        docker-compose up -d --build
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Containers iniciados"
        } else {
            Write-Error "Erro ao iniciar containers"
            Pop-Location
            return $false
        }
        
        Pop-Location
    } catch {
        Write-Error "Erro ao iniciar Docker: $_"
        Pop-Location
        return $false
    }
    
    # Aguardar inicialização
    Write-Info "Aguardando serviços iniciarem (60 segundos)..."
    Start-Sleep -Seconds 60
    
    # Verificar health checks
    Write-Info "Verificando health checks..."
    
    $healthChecks = @(
        @{ Name = "User BFF"; Url = "http://localhost:8080/actuator/health" },
        @{ Name = "Merchant BFF"; Url = "http://localhost:8084/actuator/health" },
        @{ Name = "Core Service"; Url = "http://localhost:8091/actuator/health" }
    )
    
    $allHealthy = $true
    foreach ($check in $healthChecks) {
        try {
            $response = Invoke-WebRequest -Uri $check.Url -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Success "$($check.Name) - OK"
            } else {
                Write-Warning "$($check.Name) - Status: $($response.StatusCode)"
                $allHealthy = $false
            }
        } catch {
            Write-Warning "$($check.Name) - Não respondendo"
            $allHealthy = $false
        }
    }
    
    if (-not $allHealthy) {
        Write-Warning "Alguns serviços ainda estão iniciando. Aguarde mais um tempo..."
    }
    
    return $true
}

function Start-UserApp {
    Write-Host "`n========================================" -ForegroundColor $Blue
    Write-Host "🦁 INICIANDO USER APP FLUTTER" -ForegroundColor $Blue
    Write-Host "========================================`n" -ForegroundColor $Blue
    
    try {
        Push-Location "apps/user_app_flutter"
        
        Write-Info "Obtendo dependências..."
        flutter pub get
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Erro ao obter dependências"
            Pop-Location
            return $false
        }
        
        Write-Info "Verificando emulador..."
        $devices = flutter devices --no-colors
        
        if ($devices -match 'emulator') {
            Write-Success "Emulador encontrado"
        } else {
            Write-Error "Nenhum emulador rodando. Inicie um com: flutter emulators --launch [nome]"
            Pop-Location
            return $false
        }
        
        Write-Success "Iniciando app no emulador..."
        Write-Host "`n💡 Credenciais:" -ForegroundColor $Blue
        Write-Host "  Username: user1" -ForegroundColor $Yellow
        Write-Host "  Password: Passw0rd!`n" -ForegroundColor $Yellow
        
        flutter run -v
        
        Pop-Location
        return $true
    } catch {
        Write-Error "Erro ao iniciar User App: $_"
        Pop-Location
        return $false
    }
}

function Start-MerchantApp {
    Write-Host "`n========================================" -ForegroundColor $Blue
    Write-Host "🏪 INICIANDO MERCHANT POS FLUTTER" -ForegroundColor $Blue
    Write-Host "========================================`n" -ForegroundColor $Blue
    
    try {
        Push-Location "apps/merchant_pos_flutter"
        
        Write-Info "Obtendo dependências..."
        flutter pub get
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Erro ao obter dependências"
            Pop-Location
            return $false
        }
        
        Write-Info "Verificando emulador..."
        $devices = flutter devices --no-colors
        
        if ($devices -match 'emulator') {
            Write-Success "Emulador encontrado"
        } else {
            Write-Error "Nenhum emulador rodando. Inicie um com: flutter emulators --launch [nome]"
            Pop-Location
            return $false
        }
        
        Write-Success "Iniciando app no emulador..."
        Write-Host "`n💡 Credenciais:" -ForegroundColor $Blue
        Write-Host "  Username: merchant1" -ForegroundColor $Yellow
        Write-Host "  Password: merchant123`n" -ForegroundColor $Yellow
        
        flutter run -v
        
        Pop-Location
        return $true
    } catch {
        Write-Error "Erro ao iniciar Merchant App: $_"
        Pop-Location
        return $false
    }
}

function Run-Tests {
    Write-Host "`n========================================" -ForegroundColor $Blue
    Write-Host "🧪 EXECUTANDO TESTES E2E" -ForegroundColor $Blue
    Write-Host "========================================`n" -ForegroundColor $Blue
    
    $tests = @(
        @{ Name = "User BFF"; Url = "http://localhost:8080/actuator/health"; Method = "GET" },
        @{ Name = "Merchant BFF"; Url = "http://localhost:8084/actuator/health"; Method = "GET" },
        @{ Name = "Core Service"; Url = "http://localhost:8091/actuator/health"; Method = "GET" },
        @{ Name = "Keycloak"; Url = "http://localhost:8081/health/started"; Method = "GET" }
    )
    
    $passedTests = 0
    $failedTests = 0
    
    foreach ($test in $tests) {
        try {
            $response = Invoke-WebRequest -Uri $test.Url -UseBasicParsing -TimeoutSec 5 -Method $test.Method
            if ($response.StatusCode -eq 200) {
                Write-Success "$($test.Name) - PASSOU"
                $passedTests++
            } else {
                Write-Warning "$($test.Name) - Status inesperado: $($response.StatusCode)"
                $failedTests++
            }
        } catch {
            Write-Error "$($test.Name) - FALHOU"
            $failedTests++
        }
    }
    
    Write-Host "`n========================================" -ForegroundColor $Blue
    Write-Host "Resultados: $passedTests/$(($tests).Count) testes passaram" -ForegroundColor $Blue
    Write-Host "========================================`n" -ForegroundColor $Blue
    
    return ($failedTests -eq 0)
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================

Write-Host "`n" -ForegroundColor $Blue
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor $Blue
Write-Host "║   SISTEMA BENEFITS - RUNNER COMPLETO   ║" -ForegroundColor $Blue
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor $Blue

# Verificar pré-requisitos
if (-not (Test-Docker)) {
    Write-Error "Docker não está disponível. Abortando."
    exit 1
}

if (-not (Test-Flutter)) {
    Write-Error "Flutter não está disponível. Abortando."
    exit 1
}

Write-Success "Pré-requisitos atendidos`n"

# Executar ações baseado no parâmetro
switch ($Action) {
    'all' {
        Write-Info "Executando fluxo completo: docker + user-app`n"
        
        if (-not (Start-DockerServices)) {
            exit 1
        }
        
        Write-Host "`n" -ForegroundColor $Blue
        $response = Read-Host "Deseja iniciar o User App Flutter? (s/n)"
        
        if ($response -eq 's' -or $response -eq 'S') {
            Start-UserApp
        }
    }
    'docker' {
        Write-Info "Iniciando apenas Docker`n"
        Start-DockerServices
    }
    'user-app' {
        Write-Info "Iniciando apenas User App Flutter`n"
        Start-UserApp
    }
    'merchant-app' {
        Write-Info "Iniciando apenas Merchant POS Flutter`n"
        Start-MerchantApp
    }
    'test' {
        Write-Info "Executando apenas testes`n"
        Run-Tests
    }
}

Write-Host "`n" -ForegroundColor $Blue
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor $Blue
Write-Host "║        EXECUÇÃO CONCLUÍDA             ║" -ForegroundColor $Blue
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor $Blue
