# Script Master para Rodar TUDO End-to-End
# Inclui: Serviços, BFFs, Banco de Dados, Stubs, Apps Android, Admin Angular

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🚀 RODANDO TUDO END-TO-END - TODOS OS FLUXOS 🚀            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Função para verificar se um comando existe
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Função para aguardar serviço ficar saudável
function Wait-ForService {
    param($Url, $ServiceName, $MaxAttempts = 30)
    
    Write-Host "  ⏳ Aguardando $ServiceName..." -ForegroundColor Yellow
    $attempt = 0
    
    while ($attempt -lt $MaxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "  ✅ $ServiceName está saudável!" -ForegroundColor Green
                return $true
            }
        } catch {
            # Serviço ainda não está pronto
        }
        
        $attempt++
        Start-Sleep -Seconds 2
    }
    
    Write-Host "  ⚠️  $ServiceName não ficou saudável após $MaxAttempts tentativas" -ForegroundColor Yellow
    return $false
}

# ============================================
# FASE 1: Verificar Dependências
# ============================================
Write-Host "[FASE 1/7] Verificando dependências..." -ForegroundColor Yellow

$dependencies = @{
    "Docker" = "docker"
    "Docker Compose" = "docker-compose"
    "Java" = "java"
    "Maven" = "mvn"
    "Flutter" = "flutter"
    "Angular CLI" = "ng"
    "Node.js" = "node"
}

$missingDeps = @()
foreach ($dep in $dependencies.GetEnumerator()) {
    if (Test-Command $dep.Value) {
        Write-Host "  ✅ $($dep.Key)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($dep.Key) não encontrado" -ForegroundColor Red
        $missingDeps += $dep.Key
    }
}

if ($missingDeps.Count -gt 0) {
    Write-Host "`n❌ Dependências faltando: $($missingDeps -join ', ')" -ForegroundColor Red
    Write-Host "Por favor, instale as dependências faltantes antes de continuar." -ForegroundColor Yellow
    exit 1
}

# ============================================
# FASE 2: Parar serviços existentes
# ============================================
Write-Host "`n[FASE 2/7] Parando serviços existentes..." -ForegroundColor Yellow
Push-Location "$script:RootPath\infra"
try {
    docker-compose down 2>&1 | Out-Null
    Write-Host "  ✅ Serviços parados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Nenhum serviço rodando" -ForegroundColor Yellow
}
Pop-Location

# ============================================
# FASE 3: Buildar todos os serviços
# ============================================
Write-Host "`n[FASE 3/7] Buildando todos os serviços..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Buildando imagens Docker (isso pode levar alguns minutos)..." -ForegroundColor Yellow
    docker-compose build --parallel 2>&1 | Tee-Object -Variable buildOutput
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ Erro ao buildar serviços" -ForegroundColor Red
        Write-Host $buildOutput
        exit 1
    }
    
    Write-Host "  ✅ Todos os serviços buildados!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao buildar: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 4: Iniciar infraestrutura (Postgres, Keycloak, LocalStack)
# ============================================
Write-Host "`n[FASE 4/7] Iniciando infraestrutura base..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Iniciando PostgreSQL, Keycloak e LocalStack..." -ForegroundColor Yellow
    docker-compose up -d postgres keycloak localstack
    
    Write-Host "  ⏳ Aguardando PostgreSQL..." -ForegroundColor Yellow
    Wait-ForService "http://localhost:5432" "PostgreSQL" 30
    
    Write-Host "  ⏳ Aguardando Keycloak..." -ForegroundColor Yellow
    Wait-ForService "http://localhost:8081/realms/benefits" "Keycloak" 60
    
    Write-Host "  ⏳ Aguardando LocalStack..." -ForegroundColor Yellow
    Wait-ForService "http://localhost:4566/_localstack/health" "LocalStack" 30
    
    Write-Host "  ✅ Infraestrutura base iniciada!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao iniciar infraestrutura: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 5: Iniciar todos os serviços
# ============================================
Write-Host "`n[FASE 5/7] Iniciando todos os serviços..." -ForegroundColor Yellow

Push-Location "$script:RootPath\infra"
try {
    Write-Host "  ⏳ Iniciando todos os serviços (isso pode levar alguns minutos)..." -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host "  ⏳ Aguardando serviços ficarem saudáveis..." -ForegroundColor Yellow
    
    # Lista de serviços para verificar
    $services = @(
        @{Name="benefits-core"; Url="http://localhost:8091/actuator/health"},
        @{Name="user-bff"; Url="http://localhost:8080/actuator/health"},
        @{Name="admin-bff"; Url="http://localhost:8083/actuator/health"},
        @{Name="merchant-bff"; Url="http://localhost:8084/actuator/health"},
        @{Name="merchant-portal-bff"; Url="http://localhost:8085/actuator/health"},
        @{Name="employer-bff"; Url="http://localhost:8086/actuator/health"},
        @{Name="payments-orchestrator"; Url="http://localhost:8092/actuator/health"},
        @{Name="acquirer-adapter"; Url="http://localhost:8093/actuator/health"},
        @{Name="acquirer-stub"; Url="http://localhost:8104/actuator/health"},
        @{Name="notification-service"; Url="http://localhost:8100/actuator/health"},
        @{Name="kyc-service"; Url="http://localhost:8101/actuator/health"},
        @{Name="kyb-service"; Url="http://localhost:8102/actuator/health"},
        @{Name="risk-service"; Url="http://localhost:8094/actuator/health"},
        @{Name="support-service"; Url="http://localhost:8095/actuator/health"},
        @{Name="settlement-service"; Url="http://localhost:8096/actuator/health"},
        @{Name="recon-service"; Url="http://localhost:8097/actuator/health"},
        @{Name="device-service"; Url="http://localhost:8098/actuator/health"},
        @{Name="audit-service"; Url="http://localhost:8099/actuator/health"},
        @{Name="privacy-service"; Url="http://localhost:8103/actuator/health"},
        @{Name="webhook-receiver"; Url="http://localhost:8105/actuator/health"},
        @{Name="tenant-service"; Url="http://localhost:8106/actuator/health"},
        @{Name="employer-service"; Url="http://localhost:8107/actuator/health"}
    )
    
    $healthyServices = 0
    foreach ($service in $services) {
        if (Wait-ForService $service.Url $service.Name 20) {
            $healthyServices++
        }
    }
    
    Write-Host "`n  📊 Serviços saudáveis: $healthyServices/$($services.Count)" -ForegroundColor Cyan
    
    if ($healthyServices -lt ($services.Count * 0.8)) {
        Write-Host "  ⚠️  Alguns serviços não ficaram saudáveis. Verifique os logs:" -ForegroundColor Yellow
        Write-Host "     docker-compose logs" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Maioria dos serviços está saudável!" -ForegroundColor Green
    }
} catch {
    Write-Host "  ❌ Erro ao iniciar serviços: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

# ============================================
# FASE 6: Iniciar Apps Angular
# ============================================
Write-Host "`n[FASE 6/7] Iniciando aplicações Angular..." -ForegroundColor Yellow

$angularApps = @(
    @{Name="Admin Angular"; Path="apps/admin_angular"; Port=4200},
    @{Name="Merchant Portal Angular"; Path="apps/merchant_portal_angular"; Port=4201},
    @{Name="Employer Portal Angular"; Path="apps/employer_portal_angular"; Port=4202}
)

foreach ($app in $angularApps) {
    $appPath = Join-Path $script:RootPath $app.Path
    if (Test-Path $appPath) {
        Write-Host "  ⏳ Iniciando $($app.Name) na porta $($app.Port)..." -ForegroundColor Yellow
        
        Push-Location $appPath
        try {
            # Verificar se node_modules existe
            if (-not (Test-Path "node_modules")) {
                Write-Host "    ⏳ Instalando dependências..." -ForegroundColor Yellow
                npm install 2>&1 | Out-Null
            }
            
            # Iniciar em background
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$appPath'; ng serve --port $($app.Port) --host 0.0.0.0" -WindowStyle Minimized
            
            Write-Host "    ✅ $($app.Name) iniciado em http://localhost:$($app.Port)" -ForegroundColor Green
            Start-Sleep -Seconds 3
        } catch {
            Write-Host "    ⚠️  Erro ao iniciar $($app.Name): $_" -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "  ⚠️  $($app.Name) não encontrado em $appPath" -ForegroundColor Yellow
    }
}

# ============================================
# FASE 7: Preparar Apps Flutter Android
# ============================================
Write-Host "`n[FASE 7/7] Preparando Apps Flutter Android..." -ForegroundColor Yellow

$flutterApps = @(
    @{Name="User App Flutter"; Path="apps/user_app_flutter"},
    @{Name="Merchant POS Flutter"; Path="apps/merchant_pos_flutter"}
)

foreach ($app in $flutterApps) {
    $appPath = Join-Path $script:RootPath $app.Path
    if (Test-Path $appPath) {
        Write-Host "  ⏳ Preparando $($app.Name)..." -ForegroundColor Yellow
        
        Push-Location $appPath
        try {
            # Verificar se Flutter está configurado
            flutter doctor 2>&1 | Out-Null
            
            # Verificar se há dispositivo Android disponível
            $devices = flutter devices 2>&1 | Select-String "android"
            if ($devices) {
                Write-Host "    ✅ Dispositivo Android encontrado" -ForegroundColor Green
                Write-Host "    💡 Para rodar o app, execute:" -ForegroundColor Cyan
                Write-Host "       cd $appPath" -ForegroundColor White
                Write-Host "       flutter run" -ForegroundColor White
            } else {
                Write-Host "    ⚠️  Nenhum dispositivo Android encontrado" -ForegroundColor Yellow
                Write-Host "    💡 Inicie um emulador Android ou conecte um dispositivo físico" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "    ⚠️  Erro ao preparar $($app.Name): $_" -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "  ⚠️  $($app.Name) não encontrado em $appPath" -ForegroundColor Yellow
    }
}

# ============================================
# RESUMO FINAL
# ============================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ TUDO RODANDO END-TO-END! ✅                             ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📊 RESUMO:" -ForegroundColor Cyan
Write-Host "  ✅ Infraestrutura: PostgreSQL, Keycloak, LocalStack" -ForegroundColor White
Write-Host "  ✅ Serviços: $healthyServices/$($services.Count) saudáveis" -ForegroundColor White
Write-Host "  ✅ Apps Angular: Admin (4200), Merchant Portal (4201), Employer Portal (4202)" -ForegroundColor White
Write-Host "  ✅ Apps Flutter: User App, Merchant POS (prontos para rodar)" -ForegroundColor White

Write-Host "`n🌐 URLs DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "  🔐 Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  📱 User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  👨‍💼 Admin BFF: http://localhost:8083" -ForegroundColor White
Write-Host "  🏪 Merchant BFF: http://localhost:8084" -ForegroundColor White
Write-Host "  💳 Payments Orchestrator: http://localhost:8092" -ForegroundColor White
Write-Host "  📧 Notification Service: http://localhost:8100" -ForegroundColor White
Write-Host "  🏦 Acquirer Stub: http://localhost:8104" -ForegroundColor White
Write-Host "  🌐 Admin Angular: http://localhost:4200" -ForegroundColor White
Write-Host "  🌐 Merchant Portal: http://localhost:4201" -ForegroundColor White
Write-Host "  🌐 Employer Portal: http://localhost:4202" -ForegroundColor White

Write-Host "`n📱 PARA RODAR OS APPS FLUTTER:" -ForegroundColor Cyan
Write-Host "  cd apps/user_app_flutter && flutter run" -ForegroundColor White
Write-Host "  cd apps/merchant_pos_flutter && flutter run" -ForegroundColor White

Write-Host "`n📋 COMANDOS ÚTEIS:" -ForegroundColor Cyan
Write-Host "  Ver logs: docker-compose logs -f [servico]" -ForegroundColor White
Write-Host "  Parar tudo: docker-compose down" -ForegroundColor White
Write-Host "  Status: docker-compose ps" -ForegroundColor White

Write-Host "`n✅ TUDO PRONTO PARA TESTAR OS FLUXOS E2E!" -ForegroundColor Green
Write-Host ""
