# Script para monitorar logs de todos os serviços
param(
    [switch]$Flutter = $false,
    [switch]$BFF = $false,
    [switch]$Keycloak = $false,
    [switch]$All = $true
)

Write-Host "=== Monitor de Logs ===" -ForegroundColor Cyan
Write-Host "Pressione Ctrl+C para parar`n" -ForegroundColor Yellow

if ($All -or $BFF) {
    Write-Host "[BFF] Monitorando logs do User BFF..." -ForegroundColor Yellow
    Start-Job -ScriptBlock {
        docker logs -f benefits-user-bff 2>&1 | ForEach-Object {
            Write-Host "[BFF] $_" -ForegroundColor Cyan
        }
    } | Out-Null
}

if ($All -or $Keycloak) {
    Write-Host "[Keycloak] Monitorando logs do Keycloak..." -ForegroundColor Yellow
    Start-Job -ScriptBlock {
        docker logs -f benefits-keycloak 2>&1 | ForEach-Object {
            Write-Host "[KC] $_" -ForegroundColor Magenta
        }
    } | Out-Null
}

if ($All -or $Flutter) {
    Write-Host "[Flutter] Para ver logs do Flutter, execute no terminal:" -ForegroundColor Yellow
    Write-Host "  adb logcat | Select-String 'LOGIN|API|AUTH'" -ForegroundColor White
    Write-Host ""
}

Write-Host "Logs sendo capturados... Pressione Ctrl+C para parar" -ForegroundColor Green
Write-Host ""

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host "`nParando monitoramento..." -ForegroundColor Yellow
    Get-Job | Stop-Job
    Get-Job | Remove-Job
}
