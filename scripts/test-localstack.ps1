# test-localstack.ps1
# Script para testar integração LocalStack (EventBridge, SQS, DLQ)
# Executar: .\scripts\test-localstack.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "🧪 [LocalStack] Testando integração EventBridge + SQS + DLQ..." -ForegroundColor Cyan

# Configurar AWS CLI para LocalStack
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "us-east-1"
$env:AWS_ENDPOINT_URL = "http://localhost:4566"

$passedTests = 0
$failedTests = 0

# Test 1: Verificar LocalStack Health
Write-Host "`n🧪 [TEST] LocalStack Health" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        $health = $response.Content | ConvertFrom-Json
        Write-Host "   ✅ LocalStack está saudável" -ForegroundColor Green
        Write-Host "      Serviços: $($health.services -join ', ')" -ForegroundColor Gray
        $passedTests++
    } else {
        Write-Host "   ❌ LocalStack não está saudável (status: $($response.StatusCode))" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ LocalStack não está rodando: $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# Test 2: Verificar EventBridge Bus
Write-Host "`n🧪 [TEST] EventBridge Bus 'benefits-events'" -ForegroundColor Yellow
try {
    $result = aws events describe-event-bus --name benefits-events --endpoint-url http://localhost:4566 --region us-east-1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ EventBridge Bus existe" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ EventBridge Bus não encontrado. Execute .\scripts\setup-localstack.ps1 primeiro" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ Erro ao verificar EventBridge Bus: $_" -ForegroundColor Red
    $failedTests++
}

# Test 3: Verificar SQS Queue
Write-Host "`n🧪 [TEST] SQS Queue 'benefits-events-queue'" -ForegroundColor Yellow
try {
    $result = aws sqs get-queue-url --queue-name benefits-events-queue --endpoint-url http://localhost:4566 --region us-east-1 2>&1
    if ($LASTEXITCODE -eq 0) {
        $queueUrl = ($result | ConvertFrom-Json).QueueUrl
        Write-Host "   ✅ SQS Queue existe: $queueUrl" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ SQS Queue não encontrada. Execute .\scripts\setup-localstack.ps1 primeiro" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ Erro ao verificar SQS Queue: $_" -ForegroundColor Red
    $failedTests++
}

# Test 4: Verificar DLQ
Write-Host "`n🧪 [TEST] DLQ 'benefits-events-dlq'" -ForegroundColor Yellow
try {
    $result = aws sqs get-queue-url --queue-name benefits-events-dlq --endpoint-url http://localhost:4566 --region us-east-1 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dlqUrl = ($result | ConvertFrom-Json).QueueUrl
        Write-Host "   ✅ DLQ existe: $dlqUrl" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ DLQ não encontrada. Execute .\scripts\setup-localstack.ps1 primeiro" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ Erro ao verificar DLQ: $_" -ForegroundColor Red
    $failedTests++
}

# Test 5: Publicar evento de teste no EventBridge
Write-Host "`n🧪 [TEST] Publicar evento de teste no EventBridge" -ForegroundColor Yellow
try {
    $testEvent = @{
        Source = "benefits.ops-relay"
        DetailType = "test.event.v1"
        Detail = '{"test": "true", "message": "Test event from LocalStack setup"}'
    } | ConvertTo-Json -Compress

    $result = aws events put-events `
        --entries "[{\"Source\":\"benefits.ops-relay\",\"DetailType\":\"test.event.v1\",\"Detail\":\"{\\\"test\\\":\\\"true\\\"}\",\"EventBusName\":\"benefits-events\"}]" `
        --endpoint-url http://localhost:4566 `
        --region us-east-1 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Evento publicado com sucesso" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ Erro ao publicar evento: $result" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ Erro ao publicar evento: $_" -ForegroundColor Red
    $failedTests++
}

# Test 6: Enviar mensagem de teste para SQS
Write-Host "`n🧪 [TEST] Enviar mensagem de teste para SQS" -ForegroundColor Yellow
try {
    $queueUrl = "http://localhost:4566/000000000000/benefits-events-queue"
    $testMessage = '{"test": "true", "message": "Test message from LocalStack test script"}'
    
    $result = aws sqs send-message `
        --queue-url $queueUrl `
        --message-body $testMessage `
        --endpoint-url http://localhost:4566 `
        --region us-east-1 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Mensagem enviada para SQS com sucesso" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "   ❌ Erro ao enviar mensagem: $result" -ForegroundColor Red
        $failedTests++
    }
} catch {
    Write-Host "   ❌ Erro ao enviar mensagem: $_" -ForegroundColor Red
    $failedTests++
}

# Resumo
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan
Write-Host "✅ Testes passados: $passedTests" -ForegroundColor Green
Write-Host "❌ Testes falhados: $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Host ("="*60) -ForegroundColor Cyan

if ($failedTests -eq 0) {
    Write-Host "`n🎉 Todos os testes passaram! LocalStack está configurado corretamente." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Alguns testes falharam. Verifique a configuração do LocalStack." -ForegroundColor Yellow
    Write-Host "   Execute .\scripts\setup-localstack.ps1 para configurar recursos." -ForegroundColor Gray
    exit 1
}
