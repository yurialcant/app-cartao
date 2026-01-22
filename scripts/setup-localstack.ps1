# setup-localstack.ps1
# Script para configurar LocalStack (EventBridge, SQS, DLQ)
# Executar: .\scripts\setup-localstack.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🔧 [LocalStack] Configurando EventBridge, SQS e DLQ..." -ForegroundColor Cyan

# Verificar se LocalStack está rodando
Write-Host "`n🔍 Verificando LocalStack..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ LocalStack está rodando" -ForegroundColor Green
    } else {
        Write-Host "   ❌ LocalStack não está respondendo corretamente" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ LocalStack não está rodando. Execute .\scripts\up.ps1 primeiro" -ForegroundColor Red
    Write-Host "   Detalhes: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

# Configurar AWS CLI para LocalStack
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "us-east-1"
$env:AWS_ENDPOINT_URL = "http://localhost:4566"

# Função para executar comandos AWS LocalStack
function Invoke-AWSLocal {
    param(
        [string]$Service,
        [string]$Command,
        [string]$Arguments = ""
    )
    
    $fullCommand = "aws $Service $Command $Arguments --endpoint-url http://localhost:4566 --region us-east-1"
    Write-Host "   Executando: $fullCommand" -ForegroundColor Gray
    
    try {
        $result = Invoke-Expression $fullCommand 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Sucesso" -ForegroundColor Green
            return $result
        } else {
            Write-Host "   ❌ Erro: $result" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "   ❌ Erro: $_" -ForegroundColor Red
        return $null
    }
}

# 1. Criar EventBridge Bus
Write-Host "`n📡 Criando EventBridge Bus..." -ForegroundColor Yellow
$busResult = Invoke-AWSLocal -Service "events" -Command "create-event-bus" -Arguments "--name benefits-events"
if ($busResult) {
    Write-Host "   ✅ EventBridge Bus 'benefits-events' criado" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Bus pode já existir, continuando..." -ForegroundColor Yellow
}

# 2. Criar SQS Queue principal
Write-Host "`n📬 Criando SQS Queue principal..." -ForegroundColor Yellow
$queueResult = Invoke-AWSLocal -Service "sqs" -Command "create-queue" -Arguments "--queue-name benefits-events-queue"
if ($queueResult) {
    Write-Host "   ✅ SQS Queue 'benefits-events-queue' criada" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Queue pode já existir, continuando..." -ForegroundColor Yellow
}

# 3. Criar DLQ (Dead Letter Queue)
Write-Host "`n💀 Criando DLQ (Dead Letter Queue)..." -ForegroundColor Yellow
$dlqResult = Invoke-AWSLocal -Service "sqs" -Command "create-queue" -Arguments "--queue-name benefits-events-dlq"
if ($dlqResult) {
    Write-Host "   ✅ DLQ 'benefits-events-dlq' criada" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  DLQ pode já existir, continuando..." -ForegroundColor Yellow
}

# 4. Obter URLs das filas
Write-Host "`n🔗 Obtendo URLs das filas..." -ForegroundColor Yellow
$queueUrlResult = Invoke-AWSLocal -Service "sqs" -Command "get-queue-url" -Arguments "--queue-name benefits-events-queue"
$dlqUrlResult = Invoke-AWSLocal -Service "sqs" -Command "get-queue-url" -Arguments "--queue-name benefits-events-dlq"

if ($queueUrlResult) {
    Write-Host "   ✅ Queue URL obtida" -ForegroundColor Green
}
if ($dlqUrlResult) {
    Write-Host "   ✅ DLQ URL obtida" -ForegroundColor Green
}

# 5. Configurar DLQ na queue principal (redrive policy)
Write-Host "`n⚙️  Configurando Redrive Policy (DLQ)..." -ForegroundColor Yellow
# Obter ARN da DLQ
$dlqArn = "arn:aws:sqs:us-east-1:000000000000:benefits-events-dlq"
$redrivePolicy = @{
    deadLetterTargetArn = $dlqArn
    maxReceiveCount = 3
} | ConvertTo-Json -Compress

$redriveResult = Invoke-AWSLocal -Service "sqs" -Command "set-queue-attributes" `
    -Arguments "--queue-url http://localhost:4566/000000000000/benefits-events-queue --attributes `"RedrivePolicy=$redrivePolicy`""

if ($redriveResult) {
    Write-Host "   ✅ Redrive Policy configurada (maxReceiveCount=3)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Redrive Policy pode não ter sido configurada" -ForegroundColor Yellow
}

# 6. Listar recursos criados
Write-Host "`n📋 Recursos criados:" -ForegroundColor Cyan
Write-Host "   EventBridge Bus: benefits-events" -ForegroundColor Gray
Write-Host "   SQS Queue: benefits-events-queue" -ForegroundColor Gray
Write-Host "   DLQ: benefits-events-dlq" -ForegroundColor Gray

Write-Host "`n✅ LocalStack configurado com sucesso!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Iniciar ops-relay: .\scripts\start-ops-relay.ps1 (quando criado)" -ForegroundColor Gray
Write-Host "   2. Testar publicação de eventos" -ForegroundColor Gray
Write-Host "   3. Verificar DLQ: aws sqs get-queue-attributes --queue-url http://localhost:4566/000000000000/benefits-events-dlq --endpoint-url http://localhost:4566" -ForegroundColor Gray
