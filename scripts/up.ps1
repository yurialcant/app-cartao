# up.ps1 - Subir Infraestrutura e Serviços
# Executar: .\scripts\up.ps1

param(
    [switch]$SkipDocker,
    [switch]$SkipServices
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🚀 [UP] Iniciando infraestrutura Benefits Platform..." -ForegroundColor Cyan

# 1. Docker Desktop
if (-not $SkipDocker) {
    Write-Host "`n📦 [UP] Verificando Docker Desktop..." -ForegroundColor Yellow
    
    $dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if (-not $dockerProcess) {
        Write-Host "   ⚠️  Docker Desktop não está rodando. Iniciando..." -ForegroundColor Yellow
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        Write-Host "   ⏳ Aguardando Docker inicializar (30 segundos)..." -ForegroundColor Gray
        Start-Sleep -Seconds 30
    }
    
    # Verificar se Docker está pronto
    $retries = 0
    while ($retries -lt 10) {
        try {
            docker info | Out-Null
            Write-Host "   ✅ Docker Desktop está pronto" -ForegroundColor Green
            break
        } catch {
            $retries++
            Write-Host "   ⏳ Aguardando Docker responder... ($retries/10)" -ForegroundColor Gray
            Start-Sleep -Seconds 3
        }
    }
    
    if ($retries -eq 10) {
        Write-Host "   ❌ Docker não respondeu após 30 segundos" -ForegroundColor Red
        exit 1
    }
}

# 2. Docker Compose Up
if (-not $SkipDocker) {
    Write-Host "`n🐳 [UP] Subindo containers (Postgres, Redis, Keycloak, etc.)..." -ForegroundColor Yellow
    
    Push-Location "$ProjectRoot\infra"
    try {
        docker-compose up -d 2>&1 | Where-Object { $_ -notmatch "version.*obsolete" }
        
        Write-Host "   ⏳ Aguardando Postgres ficar saudável..." -ForegroundColor Gray
        $healthy = $false
        for ($i = 0; $i -lt 30; $i++) {
            $pgStatus = docker inspect --format='{{.State.Health.Status}}' benefits-postgres 2>$null
            if ($pgStatus -eq "healthy") {
                $healthy = $true
                break
            }
            Start-Sleep -Seconds 2
        }
        
        if ($healthy) {
            Write-Host "   ✅ Postgres está saudável" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Postgres pode não estar pronto ainda" -ForegroundColor Yellow
        }
        
        Write-Host "`n   📊 Status dos containers:" -ForegroundColor Cyan
        docker-compose ps
        
    } finally {
        Pop-Location
    }
}

# 3. Compilar Serviços Java
if (-not $SkipServices) {
    Write-Host "`n☕ [UP] Compilando serviços Java..." -ForegroundColor Yellow
    
    Push-Location $ProjectRoot
    try {
        $buildOutput = mvn clean compile -T 4 -q 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Compilação bem-sucedida" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Erro na compilação" -ForegroundColor Red
            Write-Host $buildOutput
            exit 1
        }
    } finally {
        Pop-Location
    }
}

Write-Host "`n✅ [UP] Infraestrutura pronta!" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Cyan
Write-Host "  1. Aplicar seeds: .\scripts\seed.ps1" -ForegroundColor Gray
Write-Host "  2. Rodar smoke tests: .\scripts\smoke.ps1" -ForegroundColor Gray
Write-Host "  3. Iniciar serviços manualmente ou via script" -ForegroundColor Gray
