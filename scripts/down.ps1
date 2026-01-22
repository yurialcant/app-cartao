# down.ps1 - Parar Todos os Serviços
# Executar: .\scripts\down.ps1

param(
    [switch]$KeepDocker,
    [switch]$PruneAll
)

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🛑 [DOWN] Parando serviços Benefits Platform..." -ForegroundColor Cyan

# 1. Parar processos Java
Write-Host "`n☕ [DOWN] Parando processos Java..." -ForegroundColor Yellow

$javaProcesses = Get-Process -Name java -ErrorAction SilentlyContinue
if ($javaProcesses) {
    Write-Host "   Encontrados $($javaProcesses.Count) processos Java" -ForegroundColor Gray
    $javaProcesses | Stop-Process -Force
    Write-Host "   ✅ Processos Java parados" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  Nenhum processo Java rodando" -ForegroundColor Gray
}

# 2. Parar PowerShell jobs (se houver)
Write-Host "`n📜 [DOWN] Parando PowerShell jobs..." -ForegroundColor Yellow

$jobs = Get-Job -ErrorAction SilentlyContinue
if ($jobs) {
    Write-Host "   Encontrados $($jobs.Count) jobs" -ForegroundColor Gray
    $jobs | Stop-Job
    $jobs | Remove-Job
    Write-Host "   ✅ Jobs parados e removidos" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  Nenhum job rodando" -ForegroundColor Gray
}

# 3. Parar Docker Compose
if (-not $KeepDocker) {
    Write-Host "`n🐳 [DOWN] Parando containers Docker..." -ForegroundColor Yellow
    
    Push-Location "$ProjectRoot\infra"
    try {
        docker-compose down 2>&1 | Where-Object { $_ -notmatch "version.*obsolete" }
        Write-Host "   ✅ Containers parados" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

# 4. Prune (opcional)
if ($PruneAll) {
    Write-Host "`n🧹 [DOWN] Limpando recursos Docker..." -ForegroundColor Yellow
    
    Write-Host "   Removendo containers parados..." -ForegroundColor Gray
    docker container prune -f | Out-Null
    
    Write-Host "   Removendo volumes não utilizados..." -ForegroundColor Gray
    docker volume prune -f | Out-Null
    
    Write-Host "   Removendo networks não utilizadas..." -ForegroundColor Gray
    docker network prune -f | Out-Null
    
    Write-Host "   ✅ Limpeza concluída" -ForegroundColor Green
}

# 5. Verificação final
Write-Host "`n🔍 [DOWN] Verificação final..." -ForegroundColor Yellow

$javaRunning = Get-Process -Name java -ErrorAction SilentlyContinue
$containersRunning = docker ps -q 2>$null

if (-not $javaRunning -and -not $containersRunning) {
    Write-Host "   ✅ Todos os serviços foram parados" -ForegroundColor Green
} else {
    if ($javaRunning) {
        Write-Host "   ⚠️  Ainda há $($javaRunning.Count) processos Java rodando" -ForegroundColor Yellow
    }
    if ($containersRunning) {
        Write-Host "   ⚠️  Ainda há containers Docker rodando" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ [DOWN] Shutdown completo!" -ForegroundColor Green
Write-Host "`nPara reiniciar:" -ForegroundColor Cyan
Write-Host "  .\scripts\up.ps1" -ForegroundColor Gray
Write-Host "  .\scripts\seed.ps1" -ForegroundColor Gray
Write-Host "  .\scripts\smoke.ps1" -ForegroundColor Gray
