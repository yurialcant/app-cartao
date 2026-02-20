# Script para aplicar Terraform no LocalStack
# Executa terraform apply para criar recursos AWS no LocalStack

Write-Host "=== Aplicando Terraform no LocalStack ===" -ForegroundColor Cyan

# Verifica se está no diretório correto
if (-not (Test-Path "infra/terraform/main.tf")) {
    Write-Host "✗ Execute este script da raiz do projeto!" -ForegroundColor Red
    exit 1
}

# Verifica se LocalStack está rodando
Write-Host "`n[1/4] Verificando LocalStack..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ LocalStack está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ LocalStack não está respondendo corretamente" -ForegroundColor Red
        Write-Host "  Execute: cd infra && docker-compose up -d localstack" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "  ✗ LocalStack não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: cd infra && docker-compose up -d localstack" -ForegroundColor Yellow
    exit 1
}

# Verifica se Terraform está instalado
Write-Host "`n[2/4] Verificando Terraform..." -ForegroundColor Yellow
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $terraformVersion = terraform version
    Write-Host "  ✓ Terraform encontrado" -ForegroundColor Green
    Write-Host "  $($terraformVersion.Split("`n")[0])" -ForegroundColor Gray
} else {
    Write-Host "  ✗ Terraform não encontrado!" -ForegroundColor Red
    Write-Host "  Instale o Terraform: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Verifica se tflocal está disponível (recomendado para LocalStack)
Write-Host "`n[3/4] Verificando tflocal (wrapper Terraform para LocalStack)..." -ForegroundColor Yellow
if (Get-Command tflocal -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ tflocal encontrado (recomendado)" -ForegroundColor Green
    $useTflocal = $true
} else {
    Write-Host "  ⚠ tflocal não encontrado, usando terraform diretamente" -ForegroundColor Yellow
    Write-Host "  Para melhor experiência, instale: pip install terraform-local" -ForegroundColor Gray
    $useTflocal = $false
}

# Navega para o diretório Terraform
Push-Location infra/terraform

try {
    Write-Host "`n[4/4] Aplicando Terraform..." -ForegroundColor Yellow
    
    # Inicializa Terraform se necessário
    if (-not (Test-Path ".terraform")) {
        Write-Host "  Inicializando Terraform..." -ForegroundColor Gray
        if ($useTflocal) {
            tflocal init
        } else {
            terraform init
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ✗ Erro ao inicializar Terraform" -ForegroundColor Red
            exit 1
        }
    }
    
    # Aplica Terraform
    Write-Host "  Aplicando recursos..." -ForegroundColor Gray
    if ($useTflocal) {
        tflocal apply -auto-approve
    } else {
        terraform apply -auto-approve
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n  ✓ Terraform aplicado com sucesso!" -ForegroundColor Green
        
        # Mostra outputs
        Write-Host "`n=== Recursos Criados ===" -ForegroundColor Cyan
        if ($useTflocal) {
            tflocal output
        } else {
            terraform output
        }
        
        Write-Host "`n=== Próximos Passos ===" -ForegroundColor Cyan
        Write-Host "1. Configure SMS_PROVIDER=aws_sns no docker-compose.yml para usar AWS SNS" -ForegroundColor Yellow
        Write-Host "2. Reinicie o user-bff: docker-compose restart user-bff" -ForegroundColor Yellow
        Write-Host "3. Teste enviando SMS via POST /auth/forgot-password" -ForegroundColor Yellow
        
    } else {
        Write-Host "`n  ✗ Erro ao aplicar Terraform" -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host "`n=== Concluído ===" -ForegroundColor Cyan
