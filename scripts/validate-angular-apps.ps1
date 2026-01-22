# Script para validar e preparar apps Angular para E2E

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔍 VALIDANDO APPS ANGULAR 🔍                               ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$apps = @(
    @{Name="Admin Angular"; Path="apps/admin_angular"; Port=4200; BFFPort=8083},
    @{Name="Merchant Portal Angular"; Path="apps/merchant_portal_angular"; Port=4201; BFFPort=8085},
    @{Name="Employer Portal Angular"; Path="apps/employer_portal_angular"; Port=4202; BFFPort=8086}
)

foreach ($app in $apps) {
    $appPath = Join-Path $script:RootPath $app.Path
    
    if (-not (Test-Path $appPath)) {
        Write-Host "  ⚠️  $($app.Name) não encontrado em $appPath" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "`n📱 Validando $($app.Name)..." -ForegroundColor Yellow
    
    # Verificar package.json
    $packageJson = Join-Path $appPath "package.json"
    if (Test-Path $packageJson) {
        Write-Host "  ✅ package.json encontrado" -ForegroundColor Green
    } else {
        Write-Host "  ❌ package.json não encontrado" -ForegroundColor Red
        continue
    }
    
    # Verificar angular.json
    $angularJson = Join-Path $appPath "angular.json"
    if (Test-Path $angularJson) {
        Write-Host "  ✅ angular.json encontrado" -ForegroundColor Green
    } else {
        Write-Host "  ❌ angular.json não encontrado" -ForegroundColor Red
        continue
    }
    
    # Verificar environment.ts
    $envPath = Join-Path $appPath "src/environments/environment.ts"
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        if ($envContent -match "apiUrl.*localhost:$($app.BFFPort)") {
            Write-Host "  ✅ environment.ts configurado corretamente (porta $($app.BFFPort))" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  environment.ts pode ter porta incorreta" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠️  environment.ts não encontrado" -ForegroundColor Yellow
    }
    
    # Verificar node_modules
    $nodeModules = Join-Path $appPath "node_modules"
    if (Test-Path $nodeModules) {
        Write-Host "  ✅ node_modules encontrado (dependências instaladas)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  node_modules não encontrado - execute: npm install" -ForegroundColor Yellow
    }
    
    # Verificar se Angular CLI está disponível
    Push-Location $appPath
    try {
        $ngVersion = npx ng version 2>&1 | Select-String -Pattern "Angular CLI" | Select-Object -First 1
        if ($ngVersion) {
            Write-Host "  ✅ Angular CLI disponível" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Angular CLI não encontrado - execute: npm install" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠️  Não foi possível verificar Angular CLI" -ForegroundColor Yellow
    } finally {
        Pop-Location
    }
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║   ✅ VALIDAÇÃO CONCLUÍDA ✅                                  ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Para iniciar os apps Angular:" -ForegroundColor Cyan
Write-Host "  Admin Angular: cd apps/admin_angular && npm start" -ForegroundColor White
Write-Host "  Merchant Portal: cd apps/merchant_portal_angular && npm start" -ForegroundColor White
Write-Host "  Employer Portal: cd apps/employer_portal_angular && npm start" -ForegroundColor White
Write-Host ""
