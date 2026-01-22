# Script para configurar Terraform com LocalStack
Write-Host "=== Configuração Terraform + LocalStack ===" -ForegroundColor Cyan

# Verificar se Terraform está instalado
try {
    $terraformVersion = terraform version 2>&1 | Select-Object -First 1
    if ($terraformVersion -match "Terraform") {
        Write-Host "✓ Terraform encontrado: $terraformVersion" -ForegroundColor Green
    } else {
        Write-Host "✗ Terraform não encontrado!" -ForegroundColor Red
        Write-Host "  Instale Terraform: https://www.terraform.io/downloads" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Terraform não encontrado!" -ForegroundColor Red
    Write-Host "  Instale Terraform: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Verificar se tflocal está instalado
$tflocalInstalled = $false
try {
    tflocal version | Out-Null
    $tflocalInstalled = $true
    Write-Host "✓ tflocal encontrado" -ForegroundColor Green
} catch {
    Write-Host "⚠ tflocal não encontrado" -ForegroundColor Yellow
    Write-Host "  tflocal é um wrapper útil para Terraform + LocalStack" -ForegroundColor Gray
    Write-Host "  Instale: pip install tflocal" -ForegroundColor Gray
    Write-Host "  Ou use terraform diretamente com variáveis de ambiente" -ForegroundColor Gray
}

# Verificar se LocalStack está rodando
Write-Host "`nVerificando LocalStack..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ LocalStack está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ LocalStack não está rodando!" -ForegroundColor Red
    Write-Host "  Execute: cd infra && docker-compose up -d localstack" -ForegroundColor Yellow
    exit 1
}

# Navegar para diretório terraform
Push-Location infra/terraform

try {
    Write-Host "`nInicializando Terraform..." -ForegroundColor Yellow
    
    if ($tflocalInstalled) {
        tflocal init
    } else {
        # Configurar variáveis de ambiente para LocalStack
        $env:TF_VAR_aws_endpoint = "http://localhost:4566"
        terraform init -backend=false
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Terraform inicializado" -ForegroundColor Green
        
        Write-Host "`nAplicando configuração..." -ForegroundColor Yellow
        
        if ($tflocalInstalled) {
            tflocal plan
            Write-Host "`nPara aplicar, execute: tflocal apply" -ForegroundColor Yellow
        } else {
            terraform plan -var="aws_endpoint=http://localhost:4566"
            Write-Host "`nPara aplicar, execute: terraform apply -var='aws_endpoint=http://localhost:4566'" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ Erro ao inicializar Terraform" -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host "`n=== Configuração Concluída ===" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Yellow
Write-Host "  1. Revisar main.tf" -ForegroundColor White
Write-Host "  2. Executar terraform apply (ou tflocal apply)" -ForegroundColor White
Write-Host "  3. Verificar recursos criados: terraform output" -ForegroundColor White
