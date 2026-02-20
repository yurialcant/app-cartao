#!/usr/bin/env pwsh
# Script para monitorar logs de todos os serviços em tempo real

param(
    [int]$Tail = 100,
    [switch]$Follow,
    [string]$Service = ""
)

$ErrorActionPreference = "Continue"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║        📊 MONITOR DE LOGS - BENEFITS SYSTEM 📊               ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$InfraDir = Join-Path $script:ProjectRoot "infra"

if (-not (Test-Path $InfraDir)) {
    Write-Host "❌ Diretório infra não encontrado: $InfraDir" -ForegroundColor Red
    exit 1
}

Set-Location $InfraDir

function Show-ServiceLogs {
    param(
        [string]$ServiceName,
        [int]$Lines = 50,
        [switch]$FollowLogs
    )
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "📋 $ServiceName" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    if ($FollowLogs) {
        docker-compose logs -f $ServiceName --tail $Lines --timestamps 2>&1
    } else {
        docker-compose logs $ServiceName --tail $Lines --timestamps 2>&1 | Select-Object -Last $Lines
    }
}

function Show-AllErrors {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "🚨 ERROS ENCONTRADOS EM TODOS OS SERVIÇOS" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    
    $errors = docker-compose logs --tail 200 2>&1 | Select-String -Pattern "ERROR|Exception|Error|Failed|500|400|WARN" -Context 1
    
    if ($errors) {
        $errors | ForEach-Object {
            if ($_ -match "ERROR|Exception|Error|Failed|500|400") {
                Write-Host $_ -ForegroundColor Red
            } elseif ($_ -match "WARN") {
                Write-Host $_ -ForegroundColor Yellow
            } else {
                Write-Host $_ -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "✓ Nenhum erro encontrado nos logs recentes" -ForegroundColor Green
    }
}

function Show-ServiceStatus {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📊 STATUS DOS SERVIÇOS" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" | Out-String | Write-Host
}

# Verificar se Docker está rodando
try {
    docker ps | Out-Null
} catch {
    Write-Host "❌ Docker não está rodando. Inicie o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

# Se um serviço específico foi solicitado
if ($Service) {
    Show-ServiceLogs -ServiceName $Service -Lines $Tail -FollowLogs:$Follow
    exit 0
}

# Mostrar status dos serviços
Show-ServiceStatus

# Mostrar erros
Show-AllErrors

# Se --follow foi especificado, monitorar todos os serviços
if ($Follow) {
    Write-Host "`n🔄 Monitorando logs em tempo real (Ctrl+C para parar)..." -ForegroundColor Yellow
    Write-Host ""
    
    docker-compose logs -f --tail $Tail --timestamps 2>&1
} else {
    # Mostrar logs de cada serviço
    $services = @(
        "user-bff",
        "benefits-core",
        "admin-bff",
        "merchant-bff",
        "merchant-portal-bff",
        "keycloak",
        "postgres"
    )
    
    foreach ($svc in $services) {
        Show-ServiceLogs -ServiceName $svc -Lines $Tail
        Start-Sleep -Milliseconds 200
    }
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "💡 Dica: Use '.\scripts\monitor-all-logs.ps1 -Follow' para monitorar em tempo real" -ForegroundColor Cyan
    Write-Host "💡 Dica: Use '.\scripts\monitor-all-logs.ps1 -Service user-bff' para um serviço específico" -ForegroundColor Cyan
    Write-Host ""
}
