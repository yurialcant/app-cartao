# load-test.ps1 - Load Tests (Teste de Performance)
# Executar: .\scripts\load-test.ps1

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "⚡ [LOAD TEST] Executando testes de carga..." -ForegroundColor Cyan

$tenantId = "550e8400-e29b-41d4-a716-446655440000"
$employerId = "550e8400-e29b-41d4-a716-446655440001"
$personId = "550e8400-e29b-41d4-a716-446655440002"

$concurrentUsers = 10
$requestsPerUser = 5
$totalRequests = $concurrentUsers * $requestsPerUser

$successCount = 0
$failureCount = 0
$responseTimes = @()

Write-Host "Configuração do teste:" -ForegroundColor Yellow
Write-Host "  - Usuários simultâneos: $concurrentUsers" -ForegroundColor White
Write-Host "  - Requisições por usuário: $requestsPerUser" -ForegroundColor White
Write-Host "  - Total de requisições: $totalRequests" -ForegroundColor White

# ============================================
# TESTE DE CARGA - BENEFITS CORE
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "LOAD TEST - BENEFITS CORE" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

Write-Host "`n💰 [LOAD] Testando Benefits Core - Wallet Operations..." -ForegroundColor Cyan

$jobs = @()

for ($user = 1; $user -le $concurrentUsers; $user++) {
    $job = Start-Job -ScriptBlock {
        param($userIndex, $requestsPerUser, $tenantId, $employerId, $personId)

        $localSuccessCount = 0
        $localFailureCount = 0
        $localResponseTimes = @()

        for ($req = 1; $req -le $requestsPerUser; $req++) {
            $startTime = Get-Date

            try {
                # Create wallet operation
                $walletData = @{
                    amount = [math]::Round((Get-Random -Minimum 50 -Maximum 500), 2)
                    description = "Load test transaction $req for user $userIndex"
                } | ConvertTo-Json

                $response = Invoke-WebRequest -Uri "http://localhost:8080/internal/benefits/wallets/$personId/credit" `
                    -Method PUT `
                    -Headers @{
                        "X-Tenant-Id" = $tenantId
                        "X-Employer-Id" = $employerId
                        "Content-Type" = "application/json"
                    } `
                    -Body $walletData `
                    -UseBasicParsing `
                    -TimeoutSec 30

                $endTime = Get-Date
                $responseTime = ($endTime - $startTime).TotalMilliseconds
                $localResponseTimes += $responseTime

                if ($response.StatusCode -eq 200) {
                    $localSuccessCount++
                } else {
                    $localFailureCount++
                }
            } catch {
                $localFailureCount++
                $endTime = Get-Date
                $responseTime = ($endTime - $startTime).TotalMilliseconds
                $localResponseTimes += $responseTime
            }
        }

        return @{
            SuccessCount = $localSuccessCount
            FailureCount = $localFailureCount
            ResponseTimes = $localResponseTimes
        }
    } -ArgumentList $user, $requestsPerUser, $tenantId, $employerId, $personId

    $jobs += $job
}

# Wait for all jobs to complete
$jobs | Wait-Job

# Collect results
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    $successCount += $result.SuccessCount
    $failureCount += $result.FailureCount
    $responseTimes += $result.ResponseTimes
    Remove-Job -Job $job
}

# Calculate metrics
$totalRequests = $successCount + $failureCount
$successRate = if ($totalRequests -gt 0) { [math]::Round(($successCount / $totalRequests) * 100, 2) } else { 0 }

$avgResponseTime = if ($responseTimes.Count -gt 0) {
    [math]::Round(($responseTimes | Measure-Object -Average).Average, 2)
} else { 0 }

$minResponseTime = if ($responseTimes.Count -gt 0) {
    [math]::Round(($responseTimes | Measure-Object -Minimum).Minimum, 2)
} else { 0 }

$maxResponseTime = if ($responseTimes.Count -gt 0) {
    [math]::Round(($responseTimes | Measure-Object -Maximum).Maximum, 2)
} else { 0 }

$p95ResponseTime = if ($responseTimes.Count -gt 0) {
    $sorted = $responseTimes | Sort-Object
    $index = [math]::Floor($sorted.Count * 0.95)
    [math]::Round($sorted[$index], 2)
} else { 0 }

# ============================================
# RELATÓRIO DE PERFORMANCE
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Green
Write-Host "LOAD TEST RESULTS - BENEFITS CORE" -ForegroundColor Green
Write-Host ("="*80) -ForegroundColor Green

Write-Host "`n📊 MÉTRICAS GERAIS:" -ForegroundColor Cyan
Write-Host "  ✅ Sucessos: $successCount" -ForegroundColor Green
Write-Host "  ❌ Falhas: $failureCount" -ForegroundColor Red
Write-Host "  📈 Taxa de Sucesso: $successRate%" -ForegroundColor Yellow
Write-Host "  🎯 Total de Requisições: $totalRequests" -ForegroundColor White

Write-Host "`n⏱️  TEMPO DE RESPOSTA (ms):" -ForegroundColor Cyan
Write-Host "  📊 Média: $avgResponseTime ms" -ForegroundColor White
Write-Host "  ⚡ Mínimo: $minResponseTime ms" -ForegroundColor Green
Write-Host "  🐌 Máximo: $maxResponseTime ms" -ForegroundColor Red
Write-Host "  🎯 P95: $p95ResponseTime ms" -ForegroundColor Yellow

# Performance thresholds
$acceptableAvgResponseTime = 2000  # 2 seconds
$acceptableSuccessRate = 95       # 95%

Write-Host "`n🎯 AVALIAÇÃO DE PERFORMANCE:" -ForegroundColor Cyan

if ($successRate -ge $acceptableSuccessRate -and $avgResponseTime -le $acceptableAvgResponseTime) {
    Write-Host "  ✅ PERFORMANCE EXCELENTE - Sistema atende aos requisitos!" -ForegroundColor Green
} elseif ($successRate -ge 90 -and $avgResponseTime -le 3000) {
    Write-Host "  ⚠️  PERFORMANCE ADEQUADA - Sistema funcional mas pode ser otimizado" -ForegroundColor Yellow
} else {
    Write-Host "  ❌ PERFORMANCE INSUFICIENTE - Sistema precisa de otimizações" -ForegroundColor Red
}

# ============================================
# TESTE DE CARGA - PAYMENTS ORCHESTRATOR
# ============================================
Write-Host "`n" + ("="*60) -ForegroundColor Magenta
Write-Host "LOAD TEST - PAYMENTS ORCHESTRATOR" -ForegroundColor Magenta
Write-Host ("="*60) -ForegroundColor Magenta

Write-Host "`n💳 [LOAD] Testando Payments Orchestrator..." -ForegroundColor Cyan

$paymentJobs = @()
$paymentSuccessCount = 0
$paymentFailureCount = 0
$paymentResponseTimes = @()

for ($user = 1; $user -le $concurrentUsers; $user++) {
    $job = Start-Job -ScriptBlock {
        param($userIndex, $requestsPerUser, $tenantId, $personId, $employerId)

        $localSuccessCount = 0
        $localFailureCount = 0
        $localResponseTimes = @()

        for ($req = 1; $req -le $requestsPerUser; $req++) {
            $startTime = Get-Date

            try {
                # Create payment transaction
                $transactionData = @{
                    transactionId = "LOAD-TXN-$userIndex-$req-$(Get-Date -Format 'HHmmss')"
                    personId = $personId
                    employerId = $employerId
                    amount = [math]::Round((Get-Random -Minimum 10 -Maximum 100), 2)
                    description = "Load test payment $req for user $userIndex"
                } | ConvertTo-Json

                $response = Invoke-WebRequest -Uri "http://localhost:8088/internal/payments/transactions" `
                    -Method POST `
                    -Headers @{
                        "X-Tenant-Id" = $tenantId
                        "Content-Type" = "application/json"
                    } `
                    -Body $transactionData `
                    -UseBasicParsing `
                    -TimeoutSec 30

                $endTime = Get-Date
                $responseTime = ($endTime - $startTime).TotalMilliseconds
                $localResponseTimes += $responseTime

                if ($response.StatusCode -eq 201) {
                    $localSuccessCount++
                } else {
                    $localFailureCount++
                }
            } catch {
                $localFailureCount++
                $endTime = Get-Date
                $responseTime = ($endTime - $startTime).TotalMilliseconds
                $localResponseTimes += $responseTime
            }
        }

        return @{
            SuccessCount = $localSuccessCount
            FailureCount = $localFailureCount
            ResponseTimes = $localResponseTimes
        }
    } -ArgumentList $user, $requestsPerUser, $tenantId, $personId, $employerId

    $paymentJobs += $job
}

# Wait for payment jobs
$paymentJobs | Wait-Job

# Collect payment results
foreach ($job in $paymentJobs) {
    $result = Receive-Job -Job $job
    $paymentSuccessCount += $result.SuccessCount
    $paymentFailureCount += $result.FailureCount
    $paymentResponseTimes += $result.ResponseTimes
    Remove-Job -Job $job
}

# Calculate payment metrics
$paymentTotalRequests = $paymentSuccessCount + $paymentFailureCount
$paymentSuccessRate = if ($paymentTotalRequests -gt 0) { [math]::Round(($paymentSuccessCount / $paymentTotalRequests) * 100, 2) } else { 0 }

$paymentAvgResponseTime = if ($paymentResponseTimes.Count -gt 0) {
    [math]::Round(($paymentResponseTimes | Measure-Object -Average).Average, 2)
} else { 0 }

# ============================================
# RELATÓRIO FINAL
# ============================================
Write-Host "`n" + ("="*80) -ForegroundColor Green
Write-Host "LOAD TEST SUMMARY" -ForegroundColor Green
Write-Host ("="*80) -ForegroundColor Green

Write-Host "`n💰 BENEFITS CORE:" -ForegroundColor Cyan
Write-Host "  ✅ Sucessos: $successCount/$totalRequests ($successRate%)" -ForegroundColor White
Write-Host "  ⏱️  Tempo Médio: $avgResponseTime ms" -ForegroundColor White

Write-Host "`n💳 PAYMENTS ORCHESTRATOR:" -ForegroundColor Cyan
Write-Host "  ✅ Sucessos: $paymentSuccessCount/$paymentTotalRequests ($paymentSuccessRate%)" -ForegroundColor White
Write-Host "  ⏱️  Tempo Médio: $paymentAvgResponseTime ms" -ForegroundColor White

# Overall assessment
$overallSuccessRate = [math]::Round((($successCount + $paymentSuccessCount) / ($totalRequests + $paymentTotalRequests)) * 100, 2)
$overallAvgResponseTime = [math]::Round((($avgResponseTime + $paymentAvgResponseTime) / 2), 2)

Write-Host "`n🌍 AVALIAÇÃO GERAL:" -ForegroundColor Cyan
Write-Host "  📊 Taxa de Sucesso Geral: $overallSuccessRate%" -ForegroundColor Yellow
Write-Host "  ⏱️  Tempo Médio Geral: $overallAvgResponseTime ms" -ForegroundColor Yellow

if ($overallSuccessRate -ge 95 -and $overallAvgResponseTime -le 2000) {
    Write-Host "  ✅ SISTEMA PRONTO PARA PRODUÇÃO!" -ForegroundColor Green
    Write-Host "     Todos os testes de carga passaram com performance excelente." -ForegroundColor Green
} elseif ($overallSuccessRate -ge 90 -and $overallAvgResponseTime -le 3000) {
    Write-Host "  ⚠️  SISTEMA FUNCIONAL MAS COM LIMITAÇÕES" -ForegroundColor Yellow
    Write-Host "     Recomenda-se otimização antes do deploy em produção." -ForegroundColor Yellow
} else {
    Write-Host "  ❌ SISTEMA PRECISA DE MELHORIAS SIGNIFICANTES" -ForegroundColor Red
    Write-Host "     Não recomendado para produção até otimizações." -ForegroundColor Red
}

Write-Host "`n🏁 Load tests concluídos!" -ForegroundColor Cyan