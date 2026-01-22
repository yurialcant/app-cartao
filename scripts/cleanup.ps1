# Cleanup Médio - Remove caches de build/test + temporários
# Uso: Quando um teste falhar ou houver inconsistência
# Mantém: volumes Docker (Postgres/Redis), node_modules base

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$logFile = "logs/cleanup.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Write-Host $logLine
    Add-Content -Path $logFile -Value $logLine
}

Write-Log "🧹 [CLEANUP] Iniciando limpeza média..."

# 1. Executar cleanup-lite primeiro
Write-Log "📦 [CLEANUP] Executando cleanup-lite..."
& "$PSScriptRoot/cleanup-lite.ps1" 2>&1 | Out-Null

# 2. Limpar caches Java/Gradle
Write-Log "☕ [CLEANUP] Limpando caches Java/Gradle..."

# Maven local cache (somente este projeto)
if (Test-Path "$env:USERPROFILE\.m2\repository\com\benefits") {
    Remove-Item -Path "$env:USERPROFILE\.m2\repository\com\benefits" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: Maven cache (com.benefits)"
}

# Gradle cache local (se existir)
if (Test-Path "./.gradle") {
    Remove-Item -Path "./.gradle" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: .gradle/"
}

# Todos os target/ completos
Get-ChildItem -Path "." -Recurse -Directory -Filter "target" -ErrorAction SilentlyContinue | 
    Where-Object { $_.FullName -match "(services|bffs|libs)" } | 
    ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $($_.FullName)"
    }

# 3. Limpar caches Node/Nx/Angular
Write-Log "📦 [CLEANUP] Limpando caches Node/Nx/Angular..."

# Nx cache
if (Test-Path "./.nx/cache") {
    Remove-Item -Path "./.nx/cache" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: .nx/cache/"
}

# node_modules/.cache
if (Test-Path "./node_modules/.cache") {
    Remove-Item -Path "./node_modules/.cache" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: node_modules/.cache/"
}

# Angular caches em apps
Get-ChildItem -Path "./apps" -Recurse -Directory -Filter ".angular" -ErrorAction SilentlyContinue | 
    ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $($_.FullName)"
    }

# dist/ em apps
Get-ChildItem -Path "./apps" -Recurse -Directory -Filter "dist" -ErrorAction SilentlyContinue | 
    Where-Object { $_.Parent.Name -match "angular" } | 
    ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $($_.FullName)"
    }

# 4. Limpar Flutter caches
Write-Log "🐦 [CLEANUP] Limpando caches Flutter..."

$flutterApps = Get-ChildItem -Path "./apps" -Directory | Where-Object { $_.Name -match "flutter" }
foreach ($app in $flutterApps) {
    Push-Location $app.FullName
    
    if (Test-Path ".dart_tool") {
        Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $($app.Name)/.dart_tool"
    }
    
    if (Test-Path "build") {
        Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $($app.Name)/build"
    }
    
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        flutter clean 2>&1 | Out-Null
        Write-Log "   ✅ Executado: flutter clean em $($app.Name)"
    }
    
    Pop-Location
}

# 5. Limpar Pact artifacts
Write-Log "🤝 [CLEANUP] Limpando Pact artifacts..."
$pactDirs = @("./pacts", "./pact-logs", "./pact-verification-results")
foreach ($dir in $pactDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $dir"
    }
}

# 6. Limpar coverage reports
Write-Log "📊 [CLEANUP] Limpando coverage reports..."
if (Test-Path "./coverage") {
    Remove-Item -Path "./coverage" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: ./coverage"
}

# 7. Remover containers órfãos (sem remover volumes)
Write-Log "🐳 [CLEANUP] Removendo containers órfãos..."
docker compose -f infra/docker-compose.yml down --remove-orphans 2>&1 | Out-Null
Write-Log "   ✅ Containers órfãos removidos"

Write-Log "✅ [CLEANUP] Limpeza média concluída!"
Write-Log ""
Write-Log "Estado após cleanup:"
Write-Log "  ✅ Containers: parados (orphans removidos)"
Write-Log "  ✅ Caches de build: removidos"
Write-Log "  ✅ Outputs: removidos"
Write-Log "  ⚠️  node_modules base: mantido"
Write-Log "  ⚠️  Volumes Docker: mantidos (Postgres/Redis preservados)"
Write-Log ""
Write-Log "Pronto para: ./scripts/up.ps1 → seed.ps1 → smoke.ps1"
