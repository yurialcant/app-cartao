# Script para verificar e iniciar Docker Desktop
Write-Host "=== Verificando Docker Desktop ===" -ForegroundColor Cyan

function Test-DockerRunning {
    try {
        $result = docker info 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -notmatch "error") {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Verifica se Docker está instalado
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Docker não está instalado!" -ForegroundColor Red
    Write-Host "`nPor favor, instale o Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ Docker está instalado" -ForegroundColor Green

# Verifica se Docker está rodando
if (Test-DockerRunning) {
    Write-Host "✓ Docker está rodando" -ForegroundColor Green
    docker --version
    docker info --format "{{.ServerVersion}}" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker daemon está acessível" -ForegroundColor Green
        exit 0
    }
} else {
    Write-Host "✗ Docker não está rodando!" -ForegroundColor Red
}

# Tenta encontrar Docker Desktop
$dockerPaths = @(
    "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
    "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe",
    "$env:LOCALAPPDATA\Docker\Docker Desktop.exe"
)

$dockerPath = $null
foreach ($path in $dockerPaths) {
    if (Test-Path $path) {
        $dockerPath = $path
        break
    }
}

if ($dockerPath) {
    Write-Host "`nIniciando Docker Desktop..." -ForegroundColor Yellow
    Write-Host "Caminho: $dockerPath" -ForegroundColor Gray
    
    # Verifica se já está rodando
    $process = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "⚠ Docker Desktop já está em execução, mas o daemon não está pronto." -ForegroundColor Yellow
        Write-Host "Aguarde alguns segundos e tente novamente." -ForegroundColor Yellow
    } else {
        Start-Process $dockerPath
        Write-Host "✓ Docker Desktop iniciado" -ForegroundColor Green
        Write-Host "`nAguardando Docker iniciar completamente..." -ForegroundColor Yellow
        Write-Host "(Isso pode levar 30-60 segundos)" -ForegroundColor Gray
        
        $maxWait = 90
        $waited = 0
        $dockerReady = $false
        
        while ($waited -lt $maxWait) {
            Start-Sleep -Seconds 5
            $waited += 5
            
            if (Test-DockerRunning) {
                $dockerReady = $true
                break
            }
            
            Write-Host "  Aguardando... ($waited/$maxWait segundos)" -ForegroundColor Gray
        }
        
        if ($dockerReady) {
            Write-Host "`n✓ Docker está pronto!" -ForegroundColor Green
            docker --version
        } else {
            Write-Host "`n✗ Docker não iniciou a tempo." -ForegroundColor Red
            Write-Host "`nPor favor:" -ForegroundColor Yellow
            Write-Host "1. Verifique se o Docker Desktop está rodando na bandeja do sistema" -ForegroundColor Yellow
            Write-Host "2. Aguarde até aparecer 'Docker Desktop is running'" -ForegroundColor Yellow
            Write-Host "3. Execute este script novamente ou:" -ForegroundColor Yellow
            Write-Host "   .\scripts\setup.ps1" -ForegroundColor Cyan
            exit 1
        }
    }
} else {
    Write-Host "✗ Docker Desktop não encontrado!" -ForegroundColor Red
    Write-Host "`nPor favor, instale o Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    exit 1
}

