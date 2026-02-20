# stop-everything.ps1 - Para Todo o Sistema
# Executar: .\scripts\stop-everything.ps1

Write-Host "🛑 [STOP-EVERYTHING] Parando sistema completo..." -ForegroundColor Red

# #region agent log
try {
    Invoke-WebRequest -Uri 'http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033' -Method POST -ContentType 'application/json' -Body (@{
        sessionId = 'debug-session'
        runId = 'full-system-shutdown'
        hypothesisId = 'STOP'
        location = 'stop-everything.ps1:5'
        message = 'Full system shutdown initiated'
        data = @{script = 'stop-everything.ps1', action = 'stop_all'}
        timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    } | ConvertTo-Json) -UseBasicParsing
} catch {}
# #endregion

# ============================================
# PARAR SERVIÇOS JAVA
# ============================================
Write-Host "`n🔪 Parando serviços Java..." -ForegroundColor Yellow

# Matar processos Java (Spring Boot)
try {
    Get-Process java -ErrorAction SilentlyContinue | Where-Object {
        $_.MainWindowTitle -like "*Spring*" -or
        $_.CommandLine -like "*spring-boot*"
    } | Stop-Process -Force

    Write-Host "✅ Serviços Java parados" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Nenhum serviço Java encontrado rodando" -ForegroundColor Yellow
}

# ============================================
# PARAR INFRAESTRUTURA DOCKER
# ============================================
Write-Host "`n🐳 Parando containers Docker..." -ForegroundColor Yellow

cd infra/docker
docker-compose down
cd ../..

Write-Host "✅ Containers Docker parados" -ForegroundColor Green

# ============================================
# LIMPAR JOBS DO POWERSHELL
# ============================================
Write-Host "`n🧹 Limpando jobs do PowerShell..." -ForegroundColor Yellow

Get-Job | Where-Object { $_.State -eq 'Running' } | Stop-Job
Get-Job | Remove-Job

Write-Host "✅ Jobs do PowerShell limpos" -ForegroundColor Green

# ============================================
# STATUS FINAL
# ============================================
Write-Host "`n📊 [STATUS] Sistema completamente parado!" -ForegroundColor Green
Write-Host ("=" * 50) -ForegroundColor Green

Write-Host "`n✅ Todos os componentes foram parados:" -ForegroundColor Cyan
Write-Host "  • Serviços Spring Boot" -ForegroundColor White
Write-Host "  • Containers Docker (Postgres, Redis)" -ForegroundColor White
Write-Host "  • Jobs em background" -ForegroundColor White

Write-Host "`n🎯 Sistema pronto para próximo teste!" -ForegroundColor Green