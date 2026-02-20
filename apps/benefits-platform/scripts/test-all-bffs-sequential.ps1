# Test All BFFs Sequentially
# Tests each BFF one at a time to avoid port conflicts

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing All BFFs Sequentially" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$bffs = @(
    @{Name="user-bff"; Port=8080; Module="bffs/user-bff"},
    @{Name="employer-bff"; Port=8083; Module="bffs/employer-bff"},
    @{Name="merchant-bff"; Port=8085; Module="bffs/merchant-bff"},
    @{Name="pos-bff"; Port=8086; Module="bffs/pos-bff"},
    @{Name="admin-bff"; Port=8087; Module="bffs/admin-bff"}
)

foreach ($bff in $bffs) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Testing $($bff.Name) on port $($bff.Port)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Start the BFF
    Write-Host "Starting $($bff.Name)..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run -pl $($bff.Module)" -WorkingDirectory "C:\Users\gesch\Documents\projeto-lucas" -PassThru -WindowStyle Minimized
    
    Write-Host "Waiting 20 seconds for startup..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    
    # Test the endpoint
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($bff.Port)/test" -Method GET -TimeoutSec 5 -UseBasicParsing
        Write-Host "✓ $($bff.Name) is responding: $($response.Content)" -ForegroundColor Green
    } catch {
        Write-Host "✗ $($bff.Name) failed to respond: $_" -ForegroundColor Red
    }
    
    # Stop the BFF
    Write-Host "Stopping $($bff.Name)..." -ForegroundColor Yellow
    try {
        $connections = Get-NetTCPConnection -LocalPort $($bff.Port) -State Listen -ErrorAction SilentlyContinue
        if ($connections) {
            foreach ($conn in $connections) {
                $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
                if ($proc) {
                    Stop-Process -Id $proc.Id -Force
                }
            }
        }
    } catch {
        Write-Host "Error stopping: $_" -ForegroundColor Red
    }
    
    Write-Host "Waiting 5 seconds before next test..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All BFF tests completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
