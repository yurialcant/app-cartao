# Script Inteligente de Setup - Verifica e instala apenas o necessário
param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=== Setup Inteligente do Sistema Benefits ===" -ForegroundColor Cyan
Write-Host "Verificando e instalando apenas o necessário...`n" -ForegroundColor Gray

# Função para verificar se um comando existe
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Função para verificar se uma porta está livre
function Test-Port {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -eq $connection
}

# Função para verificar se um serviço Docker está rodando
function Test-DockerService {
    param([string]$ServiceName)
    $container = docker ps --filter "name=$ServiceName" --format "{{.Names}}" 2>$null
    return $container -eq $ServiceName
}

# 1. Verificar Docker
Write-Host "[1/7] Verificando Docker..." -ForegroundColor Yellow
if (Test-Command "docker") {
    $dockerVersion = docker --version
    Write-Host "  ✓ Docker encontrado: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "  ✗ Docker não encontrado!" -ForegroundColor Red
    Write-Host "  Instalando Docker Desktop..." -ForegroundColor Yellow
    
    # Verifica se o instalador existe
    $dockerInstaller = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerInstaller) {
        Write-Host "  Docker Desktop encontrado, mas não está rodando." -ForegroundColor Yellow
        Write-Host "  Por favor, inicie o Docker Desktop manualmente e execute este script novamente." -ForegroundColor Yellow
        Start-Process $dockerInstaller
        exit 1
    } else {
        Write-Host "  Por favor, instale o Docker Desktop:" -ForegroundColor Yellow
        Write-Host "  https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
        exit 1
    }
}

# Verificar se Docker está rodando (verificação mais robusta)
function Test-DockerRunning {
    try {
        $result = docker info 2>&1
        # Verifica tanto o exit code quanto se não tem erro de pipe
        if ($LASTEXITCODE -eq 0 -and $result -notmatch "error" -and $result -notmatch "pipe") {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Verifica Docker
Write-Host "  Verificando se Docker está rodando..." -ForegroundColor Gray
if (Test-DockerRunning) {
    Write-Host "  ✓ Docker está rodando e acessível" -ForegroundColor Green
} else {
    Write-Host "  ✗ Docker não está acessível!" -ForegroundColor Red
    Write-Host "`n  Tentando iniciar Docker Desktop..." -ForegroundColor Yellow
    
    # Tenta encontrar e iniciar Docker Desktop
    $dockerPaths = @(
        "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe",
        "$env:LOCALAPPDATA\Docker\Docker Desktop.exe"
    )
    
    $dockerFound = $false
    foreach ($path in $dockerPaths) {
        if (Test-Path $path) {
            Write-Host "  Iniciando: $path" -ForegroundColor Yellow
            
            # Verifica se já está rodando
            $process = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  ⚠ Docker Desktop já está em execução" -ForegroundColor Yellow
                Write-Host "  Aguardando daemon iniciar..." -ForegroundColor Yellow
            } else {
                Start-Process $path
                Write-Host "  ✓ Docker Desktop iniciado" -ForegroundColor Green
            }
            
            $dockerFound = $true
            break
        }
    }
    
    if (-not $dockerFound) {
        Write-Host "`n  ✗ Docker Desktop não encontrado!" -ForegroundColor Red
        Write-Host "`n  Por favor:" -ForegroundColor Yellow
        Write-Host "  1. Instale o Docker Desktop:" -ForegroundColor Yellow
        Write-Host "     https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
        Write-Host "  2. Ou execute: .\scripts\check-docker.ps1" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "`n  Aguardando Docker iniciar completamente..." -ForegroundColor Yellow
    Write-Host "  (Isso pode levar 30-90 segundos na primeira vez)" -ForegroundColor Gray
    
    # Aguarda até 90 segundos, verificando a cada 3 segundos
    $maxWait = 90
    $waited = 0
    $dockerReady = $false
    
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 3
        $waited += 3
        
        if (Test-DockerRunning) {
            $dockerReady = $true
            break
        }
        
        if ($waited % 15 -eq 0) {
            Write-Host "  Aguardando... ($waited/$maxWait segundos)" -ForegroundColor Gray
        }
    }
    
    if ($dockerReady) {
        Write-Host "  ✓ Docker está pronto!" -ForegroundColor Green
    } else {
        Write-Host "`n  ✗ Docker não iniciou a tempo." -ForegroundColor Red
        Write-Host "`n  Por favor:" -ForegroundColor Yellow
        Write-Host "  1. Verifique se o Docker Desktop está rodando na bandeja do sistema" -ForegroundColor Yellow
        Write-Host "  2. Aguarde até aparecer 'Docker Desktop is running'" -ForegroundColor Yellow
        Write-Host "  3. Execute: .\scripts\check-docker.ps1" -ForegroundColor Cyan
        Write-Host "  4. Ou execute este script novamente" -ForegroundColor Yellow
        exit 1
    }
}

# 2. Verificar Docker Compose
Write-Host "`n[2/7] Verificando Docker Compose..." -ForegroundColor Yellow
if (Test-Command "docker-compose") {
    $composeVersion = docker-compose --version
    Write-Host "  ✓ Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} else {
    # Docker Compose geralmente vem com Docker Desktop
    Write-Host "  ⚠ Docker Compose não encontrado como comando separado" -ForegroundColor Yellow
    Write-Host "  Tentando 'docker compose' (v2)..." -ForegroundColor Yellow
    
    try {
        docker compose version | Out-Null
        Write-Host "  ✓ Docker Compose v2 encontrado" -ForegroundColor Green
        $script:UseDockerComposeV2 = $true
    } catch {
        Write-Host "  ✗ Docker Compose não encontrado!" -ForegroundColor Red
        Write-Host "  Por favor, atualize o Docker Desktop para a versão mais recente." -ForegroundColor Yellow
        exit 1
    }
}

# 3. Verificar estrutura de arquivos
Write-Host "`n[3/7] Verificando estrutura de arquivos..." -ForegroundColor Yellow
$requiredFiles = @{
    "infra/docker-compose.yml" = "Docker Compose"
    "infra/keycloak/realm-benefits.json" = "Configuração Keycloak"
    "services/user-bff/pom.xml" = "Maven POM"
    "services/user-bff/Dockerfile" = "Dockerfile do BFF"
    "apps/user_app_flutter/pubspec.yaml" = "Flutter Pubspec"
}

$missingFiles = @()
foreach ($file in $requiredFiles.Keys) {
    if (Test-Path $file) {
        Write-Host "  ✓ $($requiredFiles[$file])" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($requiredFiles[$file]) não encontrado: $file" -ForegroundColor Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "`n  ✗ Arquivos faltando! Execute este script da raiz do projeto." -ForegroundColor Red
    exit 1
}

# 4. Verificar portas
Write-Host "`n[4/7] Verificando portas..." -ForegroundColor Yellow
$ports = @{
    5432 = "PostgreSQL"
    8080 = "User BFF"
    8081 = "Keycloak"
}

$portsInUse = @()
foreach ($port in $ports.Keys) {
    if (Test-Port $port) {
        Write-Host "  ✓ Porta $port ($($ports[$port])) disponível" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Porta $port ($($ports[$port])) em uso" -ForegroundColor Yellow
        
        # Verifica se é um container nosso
        $container = docker ps --filter "publish=$port" --format "{{.Names}}" 2>$null
        if ($container -like "*benefits*") {
            Write-Host "    (Container benefits já está usando esta porta)" -ForegroundColor Gray
        } else {
            $portsInUse += $port
        }
    }
}

if ($portsInUse.Count -gt 0 -and -not $Force) {
    Write-Host "`n  ⚠ Algumas portas estão em uso por outros processos." -ForegroundColor Yellow
    Write-Host "  Use -Force para continuar mesmo assim." -ForegroundColor Yellow
    Write-Host "  Portas em uso: $($portsInUse -join ', ')" -ForegroundColor Yellow
}

# 5. Verificar containers existentes
Write-Host "`n[5/7] Verificando containers existentes..." -ForegroundColor Yellow
$containers = @("benefits-postgres", "benefits-keycloak", "benefits-user-bff")
$existingContainers = docker ps -a --filter "name=benefits" --format "{{.Names}}" 2>$null

if ($existingContainers) {
    Write-Host "  Containers encontrados:" -ForegroundColor Cyan
    foreach ($container in $existingContainers) {
        $status = docker ps --filter "name=$container" --format "{{.Status}}" 2>$null
        if ($status) {
            Write-Host "    ✓ $container ($status)" -ForegroundColor Green
        } else {
            Write-Host "    ⚠ $container (parado)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  Nenhum container benefits encontrado" -ForegroundColor Gray
}

# 6. Verificar imagens Docker necessárias
Write-Host "`n[6/7] Verificando imagens Docker..." -ForegroundColor Yellow

# Verifica se Docker está realmente acessível antes de verificar imagens
if (-not (Test-DockerRunning)) {
    Write-Host "  ✗ Docker não está acessível. Pulando verificação de imagens." -ForegroundColor Red
} else {
    $requiredImages = @(
        "postgres:16-alpine",
        "quay.io/keycloak/keycloak:26.4.7",
        "maven:3.9-eclipse-temurin-17",
        "eclipse-temurin:17-jre-alpine"
    )

    foreach ($image in $requiredImages) {
        try {
            $imageName = $image.Split(':')[0]
            $tag = if ($image.Contains(':')) { $image.Split(':')[1] } else { "latest" }
            
            $exists = docker images --format "{{.Repository}}:{{.Tag}}" 2>&1 | Select-String "^${imageName}:${tag}$"
            if ($exists) {
                Write-Host "  ✓ $image" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ $image (será baixada durante o build)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  ⚠ $image (será baixada durante o build)" -ForegroundColor Yellow
        }
    }
}

# 7. Preparar ambiente e aplicar Terraform
Write-Host "`n[7/8] Preparando ambiente..." -ForegroundColor Yellow

# Navegar para o diretório infra
Push-Location infra

try {
    # Parar containers existentes se necessário
    if ($existingContainers) {
        Write-Host "  Parando containers existentes..." -ForegroundColor Yellow
        docker-compose down 2>&1 | Out-Null
    }
    
    # Build e start
    Write-Host "  Construindo e iniciando serviços..." -ForegroundColor Yellow
    Write-Host "  (Isso pode levar alguns minutos na primeira execução)`n" -ForegroundColor Gray
    
    docker-compose up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n  ✓ Serviços iniciados com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "`n  ✗ Erro ao iniciar serviços" -ForegroundColor Red
        Write-Host "  Verifique os logs: docker-compose logs" -ForegroundColor Yellow
        exit 1
    }
} finally {
    Pop-Location
}

# 8. Aplicar Terraform no LocalStack (opcional)
Write-Host "`n[8/8] Aplicando Terraform no LocalStack..." -ForegroundColor Yellow
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Host "  Terraform encontrado, aplicando recursos..." -ForegroundColor Gray
    Push-Location infra/terraform
    try {
        if (-not (Test-Path ".terraform")) {
            terraform init 2>&1 | Out-Null
        }
        terraform apply -auto-approve 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Terraform aplicado com sucesso" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Terraform não aplicado (pode aplicar manualmente depois)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠ Erro ao aplicar Terraform (pode aplicar manualmente depois)" -ForegroundColor Yellow
    } finally {
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Terraform não encontrado (pode aplicar manualmente depois)" -ForegroundColor Yellow
    Write-Host "    Execute: .\scripts\apply-terraform.ps1" -ForegroundColor Gray
}

# Aguardar serviços iniciarem
Write-Host "`n=== Aguardando serviços iniciarem ===" -ForegroundColor Cyan
Write-Host "Aguarde 30 segundos para os serviços iniciarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Verificar saúde dos serviços
Write-Host "`n=== Verificando saúde dos serviços ===" -ForegroundColor Cyan

# PostgreSQL
Write-Host "`nPostgreSQL..." -ForegroundColor Yellow
$pgReady = docker exec benefits-postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ PostgreSQL está pronto" -ForegroundColor Green
} else {
    Write-Host "  ⚠ PostgreSQL ainda está iniciando..." -ForegroundColor Yellow
}

# Keycloak (pode levar até 60s)
Write-Host "`nKeycloak..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health/ready" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop 2>&1
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Keycloak está pronto" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠ Keycloak ainda está iniciando (pode levar até 60s na primeira vez)" -ForegroundColor Yellow
    Write-Host "    Verifique: docker-compose logs keycloak" -ForegroundColor Gray
}

# User BFF
Write-Host "`nUser BFF..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop 2>&1
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ User BFF está pronto" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠ User BFF ainda está iniciando (pode levar até 40s)" -ForegroundColor Yellow
    Write-Host "    Verifique: docker-compose logs user-bff" -ForegroundColor Gray
}

# Resumo final
Write-Host "`n=== Resumo ===" -ForegroundColor Cyan
Write-Host "Serviços:" -ForegroundColor Yellow
Write-Host "  PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "  Keycloak: http://localhost:8081" -ForegroundColor White
Write-Host "  Keycloak Admin: http://localhost:8081/admin (admin/admin)" -ForegroundColor White
Write-Host "  User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  User BFF Health: http://localhost:8080/actuator/health" -ForegroundColor White

Write-Host "`nComandos úteis:" -ForegroundColor Yellow
Write-Host "  Ver logs: docker-compose -f infra/docker-compose.yml logs -f" -ForegroundColor Gray
Write-Host "  Parar: docker-compose -f infra/docker-compose.yml down" -ForegroundColor Gray
Write-Host "  Status: docker-compose -f infra/docker-compose.yml ps" -ForegroundColor Gray

Write-Host "`n✓ Setup concluído!" -ForegroundColor Green

