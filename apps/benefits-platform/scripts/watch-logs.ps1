# Script para monitorar logs de todos os serviços em tempo real
param(
    [switch]$BFF = $false,
    [switch]$Keycloak = $false,
    [switch]$Flutter = $false,
    [switch]$All = $true
)

Write-Host "=== Monitor de Logs em Tempo Real ===" -ForegroundColor Cyan
Write-Host "Pressione Ctrl+C para parar`n" -ForegroundColor Yellow

$ErrorActionPreference = "Continue"

if ($All -or $BFF) {
    Write-Host "[BFF] Iniciando monitoramento do User BFF..." -ForegroundColor Yellow
    Start-Job -Name "BFF-Logs" -ScriptBlock {
        docker logs -f benefits-user-bff 2>&1 | ForEach-Object {
            if ($_ -match "BFF|GET|POST|ERROR|Exception|auth|login") {
                Write-Host "[BFF] $_" -ForegroundColor Cyan
            }
        }
    } | Out-Null
}

if ($All -or $Keycloak) {
    Write-Host "[Keycloak] Iniciando monitoramento do Keycloak..." -ForegroundColor Yellow
    Start-Job -Name "KC-Logs" -ScriptBlock {
        docker logs -f benefits-keycloak 2>&1 | ForEach-Object {
            if ($_ -match "token|login|auth|ERROR|Exception") {
                Write-Host "[KC] $_" -ForegroundColor Magenta
            }
        }
    } | Out-Null
}

if ($All -or $Flutter) {
    Write-Host "[Flutter] Iniciando monitoramento do Flutter..." -ForegroundColor Yellow
    Start-Job -Name "Flutter-Logs" -ScriptBlock {
        adb logcat -c 2>&1 | Out-Null
        adb logcat 2>&1 | ForEach-Object {
            if ($_ -match "LOGIN|API|AUTH|BFF|📱|🌐|🔐|flutter") {
                Write-Host "[FLUTTER] $_" -ForegroundColor Green
            }
        }
    } | Out-Null
}

Write-Host "`n✅ Logs sendo capturados..." -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar`n" -ForegroundColor Yellow

try {
    while ($true) {
        Start-Sleep -Seconds 1
        
        # Mostra status dos jobs
        $jobs = Get-Job | Where-Object { $_.State -eq "Running" }
        if ($jobs.Count -lt 3) {
            Write-Host "⚠ Alguns jobs pararam. Reiniciando..." -ForegroundColor Yellow
            Get-Job | Stop-Job
            Get-Job | Remove-Job
            break
        }
    }
} finally {
    Write-Host "`nParando monitoramento..." -ForegroundColor Yellow
    Get-Job | Stop-Job
    Get-Job | Remove-Job
    Write-Host "✅ Monitoramento parado" -ForegroundColor Green
}
