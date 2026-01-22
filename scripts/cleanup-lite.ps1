# Cleanup Lite - Remove apenas temporários e outputs recentes
# Uso: Sempre no final de cada ciclo (mesmo quando tudo passa)
# Mantém: volumes Docker, caches de build, banco de dados

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$logFile = "logs/cleanup-lite.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Write-Host $logLine
    Add-Content -Path $logFile -Value $logLine
}

Write-Log "🧹 [CLEANUP-LITE] Iniciando limpeza leve..."

# 1. Parar serviços e containers (sem remover volumes)
Write-Log "🛑 [CLEANUP-LITE] Parando containers..."
& "$PSScriptRoot/down.ps1" 2>&1 | Out-Null

# 2. Limpar outputs temporários gerais (raiz)
Write-Log "📁 [CLEANUP-LITE] Limpando temporários da raiz..."
$tempDirs = @("./tmp", "./.tmp", "./downloads")
foreach ($dir in $tempDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $dir"
    }
}

# 3. Limpar reports recentes (manter últimos 3 dias se quiser)
Write-Log "📊 [CLEANUP-LITE] Limpando reports antigos..."
if (Test-Path "./reports") {
    Get-ChildItem -Path "./reports" -Recurse -File | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-3) } | 
        Remove-Item -Force -ErrorAction SilentlyContinue
}

# 4. Limpar Playwright reports antigos
Write-Log "🎭 [CLEANUP-LITE] Limpando Playwright reports..."
if (Test-Path "./playwright-report") {
    Remove-Item -Path "./playwright-report" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: ./playwright-report"
}

# 5. Limpar test-results antigos
Write-Log "🧪 [CLEANUP-LITE] Limpando test-results..."
if (Test-Path "./test-results") {
    Remove-Item -Path "./test-results" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: ./test-results"
}

# 6. Limpar logs antigos (manter últimos 7 dias)
Write-Log "📝 [CLEANUP-LITE] Limpando logs antigos (>7 dias)..."
if (Test-Path "./logs") {
    Get-ChildItem -Path "./logs" -Directory | 
        Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Logs antigos removidos"
}

# 7. Limpar Java target/ builds individuais (somente outputs, não cache)
Write-Log "☕ [CLEANUP-LITE] Limpando outputs Java (target/)..."
Get-ChildItem -Path "." -Recurse -Directory -Filter "target" -ErrorAction SilentlyContinue | 
    Where-Object { $_.FullName -match "(services|bffs)" } | 
    ForEach-Object {
        if (Test-Path "$($_.FullName)/surefire-reports") {
            Remove-Item -Path "$($_.FullName)/surefire-reports" -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path "$($_.FullName)/*.jar") {
            Remove-Item -Path "$($_.FullName)/*.jar" -Force -ErrorAction SilentlyContinue
        }
    }

Write-Log "✅ [CLEANUP-LITE] Limpeza leve concluída!"
Write-Log ""
Write-Log "Estado após cleanup:"
Write-Log "  ✅ Containers: parados (volumes mantidos)"
Write-Log "  ✅ Temporários: removidos"
Write-Log "  ✅ Reports antigos: removidos"
Write-Log "  ⚠️  Caches de build: mantidos"
Write-Log "  ⚠️  node_modules: mantidos"
Write-Log "  ⚠️  Volumes Docker: mantidos"
Write-Log ""
Write-Log "Pronto para: ./scripts/up.ps1"
