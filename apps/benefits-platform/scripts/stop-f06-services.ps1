# stop-f06-services.ps1 - Para serviços F06
# Executar: .\scripts\stop-f06-services.ps1

$ErrorActionPreference = "Stop"

Write-Host "🛑 [F06] Parando serviços F06..." -ForegroundColor Cyan

# Parar jobs do PowerShell
Write-Host "`n🔄 [F06] Parando jobs PowerShell..." -ForegroundColor Yellow
try {
    Get-Job | Where-Object { $_.Name -like "*benefits*" -or $_.Name -like "*pos*" } | Stop-Job -PassThru | Remove-Job
    Write-Host "   ✅ Jobs parados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Nenhum job encontrado ou erro: $_" -ForegroundColor Yellow
}

# Matar processos Java
Write-Host "`n💀 [F06] Matando processos Java..." -ForegroundColor Yellow
try {
    $javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
    if ($javaProcesses) {
        $javaProcesses | Where-Object {
            $_.CommandLine -like "*benefits-core*" -or
            $_.CommandLine -like "*pos-bff*" -or
            $_.MainWindowTitle -eq ""
        } | Stop-Process -Force
        Write-Host "   ✅ Processos Java parados" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Nenhum processo Java encontrado" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Erro ao parar processos: $_" -ForegroundColor Yellow
}

# Verificar portas liberadas
Write-Host "`n🔍 [F06] Verificando portas..." -ForegroundColor Yellow
$ports = @(8091, 8086)
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "   ⚠️  Porta $port ainda em uso (PID: $($connection.OwningProcess))" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ Porta $port liberada" -ForegroundColor Green
    }
}

Write-Host "`n✅ [F06] Serviços parados!" -ForegroundColor Green