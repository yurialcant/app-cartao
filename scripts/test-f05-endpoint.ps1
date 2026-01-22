# Test F05 Credit Batch Endpoint
$headers = @{
    'X-Tenant-Id' = 'origami'
    'X-Employer-Id' = 'emp-001'
    'X-Person-Id' = 'person-001'
    'X-Correlation-Id' = 'test-001'
}

Write-Host "🧪 Testing GET /internal/batches/credits..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8091/internal/batches/credits?page=0&size=10" -Method GET -Headers $headers -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}
