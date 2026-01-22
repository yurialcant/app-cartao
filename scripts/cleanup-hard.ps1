# Cleanup HARD - Reset completo (DB, volumes, caches, tudo)
# Uso: Quando DB/migrations/LocalStack ficarem inconsistentes
# Remove: TUDO exceto código-fonte e node_modules (opcional)

param(
    [switch]$RemoveNodeModules,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$logFile = "logs/cleanup-hard.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Write-Host $logLine
    Add-Content -Path $logFile -Value $logLine
}

Write-Log "💣 [CLEANUP-HARD] Iniciando HARD RESET..."
Write-Log "⚠️  ATENÇÃO: Isso vai remover volumes Docker (banco de dados será perdido)"
Start-Sleep -Seconds 2

# 1. Executar cleanup médio primeiro
Write-Log "📦 [CLEANUP-HARD] Executando cleanup médio..."
& "$PSScriptRoot/cleanup.ps1" 2>&1 | Out-Null

# 2. Parar TUDO e remover volumes
Write-Log "🐳 [CLEANUP-HARD] Removendo containers + volumes Docker..."
docker compose -f infra/docker-compose.yml down -v --remove-orphans 2>&1 | Out-Null
Write-Log "   ✅ Volumes Docker removidos (Postgres/Redis/etc.)"

# 3. Limpar LocalStack data (se persistido localmente)
Write-Log "☁️ [CLEANUP-HARD] Limpando LocalStack data..."
$localstackDirs = @(
    "./infra/localstack/data",
    "./infra/localstack/tmp",
    "$env:USERPROFILE\.localstack"
)
foreach ($dir in $localstackDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $dir"
    }
}

# 4. Limpar Keycloak data persistido (se houver)
Write-Log "🔐 [CLEANUP-HARD] Limpando Keycloak data..."
if (Test-Path "./infra/keycloak/data") {
    Remove-Item -Path "./infra/keycloak/data" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: ./infra/keycloak/data"
}

# 5. Limpar Prometheus/Grafana data (se persistido)
Write-Log "📊 [CLEANUP-HARD] Limpando Observability data..."
$obsDirs = @(
    "./infra/prometheus/data",
    "./infra/grafana/data",
    "./infra/otel/data"
)
foreach ($dir in $obsDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $dir"
    }
}

# 6. Limpar todos os build/out/dist
Write-Log "🗑️  [CLEANUP-HARD] Limpando TODOS os outputs..."
$outputDirs = @("./build", "./out", "./dist")
foreach ($dir in $outputDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: $dir"
    }
}

# 7. Limpar Maven cache completo (opcional, apenas do projeto)
Write-Log "☕ [CLEANUP-HARD] Limpando Maven cache completo..."
if (Test-Path "$env:USERPROFILE\.m2\repository\com\benefits") {
    Remove-Item -Path "$env:USERPROFILE\.m2\repository\com\benefits" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Removido: Maven cache (com.benefits)"
}

# 8. Limpar node_modules (se flag ativada)
if ($RemoveNodeModules) {
    Write-Log "📦 [CLEANUP-HARD] Removendo node_modules (flag ativada)..."
    if (Test-Path "./node_modules") {
        Remove-Item -Path "./node_modules" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "   ✅ Removido: ./node_modules"
    }
    
    Get-ChildItem -Path "./apps" -Recurse -Directory -Filter "node_modules" -ErrorAction SilentlyContinue | 
        ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "   ✅ Removido: $($_.FullName)"
        }
}

# 9. Limpar logs antigos (manter apenas último dia)
Write-Log "📝 [CLEANUP-HARD] Limpando logs antigos..."
if (Test-Path "./logs") {
    Get-ChildItem -Path "./logs" -Directory | 
        Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and $_.LastWriteTime -lt (Get-Date).AddDays(-1) } | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "   ✅ Logs >1 dia removidos"
}

# 10. Docker system prune (CUIDADO: remove imagens não usadas)
Write-Log "🐳 [CLEANUP-HARD] Docker system prune..."
Write-Host "⚠️  Removendo imagens Docker não usadas..."
docker system prune -f 2>&1 | Out-Null
Write-Log "   ✅ Docker prune executado"

Write-Log ""
Write-Log "💥 [CLEANUP-HARD] HARD RESET concluído!"
Write-Log ""
Write-Log "Estado após HARD RESET:"
Write-Log "  ✅ Containers: removidos"
Write-Log "  ✅ Volumes Docker: REMOVIDOS (banco zerado)"
Write-Log "  ✅ Caches: removidos"
Write-Log "  ✅ Outputs: removidos"
Write-Log "  ✅ LocalStack data: removido"
if ($RemoveNodeModules) {
    Write-Log "  ✅ node_modules: REMOVIDOS"
} else {
    Write-Log "  ⚠️  node_modules: mantidos (use -RemoveNodeModules para remover)"
}
Write-Log ""
Write-Log "⚠️  ATENÇÃO: Banco de dados foi ZERADO!"
Write-Log "Próximos passos OBRIGATÓRIOS:"
Write-Log "  1. ./scripts/up.ps1        (recria containers + schema)"
Write-Log "  2. ./scripts/seed.ps1      (recria dados de teste)"
Write-Log "  3. ./scripts/smoke.ps1     (valida ambiente)"
