# Quick test for F05 endpoints
$tenantId = "550e8400-e29b-41d4-a716-446655440000"
$employerId = "550e8400-e29b-41d4-a716-446655440001"
$personId = "550e8400-e29b-41d4-a716-446655440100"
$walletId = "550e8400-e29b-41d4-a716-446655440200"
$idempotencyKey = "test-$(Get-Date -Format 'yyyyMMddHHmmss')"

Write-Host "`n🧪 Testing F05 Credit Batch Endpoints" -ForegroundColor Cyan

# Test POST
Write-Host "`n[TEST] POST /internal/batches/credits" -ForegroundColor Yellow
$batchBody = @{
    batch_reference = "Test Batch $(Get-Date -Format 'yyyyMMddHHmmss')"
    items = @(
        @{
            person_id = $personId
            wallet_id = $walletId
            amount = 100.50
            description = "Test credit - MEAL wallet"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $submitResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits" `
        -Method POST `
        -Headers @{
            "X-Tenant-Id" = $tenantId
            "X-Employer-Id" = $employerId
            "X-Person-Id" = $personId
            "X-Idempotency-Key" = $idempotencyKey
            "Content-Type" = "application/json"
        } `
        -Body $batchBody `
        -UseBasicParsing `
        -TimeoutSec 10

    Write-Host "   ✅ Status: $($submitResponse.StatusCode)" -ForegroundColor Green
    Write-Host "   Response: $($submitResponse.Content)" -ForegroundColor Gray
    
    if ($submitResponse.StatusCode -eq 201) {
        $responseData = $submitResponse.Content | ConvertFrom-Json
        $batchId = $responseData.id
        Write-Host "   ✅ Batch ID: $batchId" -ForegroundColor Green

        # Test GET
        Write-Host "`n[TEST] GET /internal/batches/credits/$batchId" -ForegroundColor Yellow
        try {
            $getResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits/$batchId" `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 5

            Write-Host "   ✅ Status: $($getResponse.StatusCode)" -ForegroundColor Green
            Write-Host "   ✅ PASS - Batch retrieved" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        }

        # Test LIST
        Write-Host "`n[TEST] GET /internal/batches/credits?page=1&size=10" -ForegroundColor Yellow
        try {
            $listResponse = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits?page=1&size=10" `
                -Headers @{ "X-Tenant-Id" = $tenantId } `
                -UseBasicParsing `
                -TimeoutSec 5

            Write-Host "   ✅ Status: $($listResponse.StatusCode)" -ForegroundColor Green
            Write-Host "   ✅ PASS - Batches listed" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   Status Code: $statusCode" -ForegroundColor Gray
    }
}

Write-Host "`n✅ F05 Tests Complete" -ForegroundColor Cyan
