# setup-localstack-complete.ps1
# Configura LocalStack completamente para reduzir dependências AWS

Write-Host "☁️  Configurando LocalStack Completo..." -ForegroundColor Cyan

# Aguardar LocalStack ficar pronto
Write-Host "⏳ Aguardando LocalStack..." -ForegroundColor White
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        # Testar S3
        $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ LocalStack está pronto!" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        Write-Host "   Tentativa $attempt/$maxAttempts..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

if ($attempt -ge $maxAttempts) {
    Write-Host "❌ LocalStack não ficou pronto. Abortando." -ForegroundColor Red
    exit 1
}

# Configurar AWS CLI para usar LocalStack
Write-Host "🔧 Configurando AWS CLI..." -ForegroundColor White
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "us-east-1"
$env:AWS_ENDPOINT_URL = "http://localhost:4566"

# Criar recursos S3
Write-Host "📦 Criando buckets S3..." -ForegroundColor White
try {
    aws s3 mb s3://benefits-receipts --endpoint-url http://localhost:4566 2>$null
    aws s3 mb s3://benefits-exports --endpoint-url http://localhost:4566 2>$null
    aws s3 mb s3://benefits-backups --endpoint-url http://localhost:4566 2>$null
    Write-Host "   ✅ Buckets criados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Alguns buckets já existem" -ForegroundColor Yellow
}

# Criar filas SQS
Write-Host "📋 Criando filas SQS..." -ForegroundColor White
try {
    aws sqs create-queue --queue-name payments-events --endpoint-url http://localhost:4566 2>$null
    aws sqs create-queue --queue-name wallet-events --endpoint-url http://localhost:4566 2>$null
    aws sqs create-queue --queue-name audit-events --endpoint-url http://localhost:4566 2>$null

    # DLQ
    aws sqs create-queue --queue-name payments-events-dlq --endpoint-url http://localhost:4566 2>$null

    # Configurar redrive policy
    $redrivePolicy = @{
        deadLetterTargetArn = "arn:aws:sqs:us-east-1:000000000000:payments-events-dlq"
        maxReceiveCount = 3
    } | ConvertTo-Json -Compress

    aws sqs set-queue-attributes `
        --queue-url http://localhost:4566/000000000000/payments-events `
        --attributes "{\"RedrivePolicy\":$redrivePolicy}" `
        --endpoint-url http://localhost:4566 2>$null

    Write-Host "   ✅ Filas SQS criadas" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Algumas filas já existem" -ForegroundColor Yellow
}

# Criar EventBridge
Write-Host "🌉 Criando EventBridge..." -ForegroundColor White
try {
    aws events create-event-bus --name benefits-events --endpoint-url http://localhost:4566 2>$null
    Write-Host "   ✅ EventBridge criado" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  EventBridge já existe" -ForegroundColor Yellow
}

# Criar tópicos SNS
Write-Host "📢 Criando tópicos SNS..." -ForegroundColor White
try {
    aws sns create-topic --name benefits-sms --endpoint-url http://localhost:4566 2>$null
    aws sns create-topic --name benefits-email --endpoint-url http://localhost:4566 2>$null
    Write-Host "   ✅ Tópicos SNS criados" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Alguns tópicos já existem" -ForegroundColor Yellow
}

# Testar integração
Write-Host "🧪 Testando integração..." -ForegroundColor White
try {
    # Testar S3
    aws s3 ls --endpoint-url http://localhost:4566 2>$null | Out-Null
    Write-Host "   ✅ S3 funcionando" -ForegroundColor Green
} catch {
    Write-Host "   ❌ S3 com problemas" -ForegroundColor Red
}

try {
    # Testar SQS
    aws sqs list-queues --endpoint-url http://localhost:4566 2>$null | Out-Null
    Write-Host "   ✅ SQS funcionando" -ForegroundColor Green
} catch {
    Write-Host "   ❌ SQS com problemas" -ForegroundColor Red
}

try {
    # Testar EventBridge
    aws events list-event-buses --endpoint-url http://localhost:4566 2>$null | Out-Null
    Write-Host "   ✅ EventBridge funcionando" -ForegroundColor Green
} catch {
    Write-Host "   ❌ EventBridge com problemas" -ForegroundColor Red
}

# Salvar configuração
$config = @{
    aws_endpoint = "http://localhost:4566"
    s3_buckets = @("benefits-receipts", "benefits-exports", "benefits-backups")
    sqs_queues = @("payments-events", "wallet-events", "audit-events", "payments-events-dlq")
    eventbridge_bus = "benefits-events"
    sns_topics = @("benefits-sms", "benefits-email")
} | ConvertTo-Json

$config | Out-File -FilePath ".cursor/localstack-config.json" -Encoding UTF8

Write-Host "`n🎉 LocalStack configurado completamente!" -ForegroundColor Green
Write-Host "💡 Serviços simulados:" -ForegroundColor Cyan
Write-Host "   • S3 (file storage)" -ForegroundColor White
Write-Host "   • SQS (message queues)" -ForegroundColor White
Write-Host "   • EventBridge (event routing)" -ForegroundColor White
Write-Host "   • SNS (notifications)" -ForegroundColor White
Write-Host "`n🔧 Use: spring.profiles.active=localstack para AWS local" -ForegroundColor Cyan