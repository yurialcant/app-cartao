# Comprehensive BFF Test Suite
# Tests all BFFs with correct endpoint paths

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Comprehensive BFF Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$bffs = @(
    @{Name="user-bff"; Port=8080; Module="bffs/user-bff"; Endpoints=@("/actuator/health")},
    @{Name="employer-bff"; Port=8083; Module="bffs/employer-bff"; Endpoints=@("/actuator/health")},
    @{Name="merchant-bff"; Port=8085; Module="bffs/merchant-bff"; Endpoints=@("/actuator/health", "/api/v1/merchant/test")},
    @{Name="pos-bff"; Port=8086; Module="bffs/pos-bff"; Endpoints=@("/actuator/health", "/api/v1/pos/test")},
    @{Name="admin-bff"; Port=8087; Module="bffs/admin-bff"; Endpoints=@("/actuator/health", "/api/v1/admin/test")}
)

$results = @()

foreach ($bff in $bffs) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Testing $($bff.Name) on port $($bff.Port)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    # Start the BFF
    Write-Host "Starting $($bff.Name)..." -ForegroundColor Yellow
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "mvn"
    $startInfo.Arguments = "spring-boot:run -pl $($bff.Module)"
    $startInfo.WorkingDirectory = "C:\Users\gesch\Documents\projeto-lucas"
    $startInfo.WindowStyle = "Minimized"
    $startInfo.UseShellExecute = $true
    
    $process = [System.Diagnostics.Process]::Start($startInfo)
    
    Write-Host "Waiting 25 seconds for startup..." -ForegroundColor Yellow
    Start-Sleep -Seconds 25
    
    # Test endpoints
    $bffResults = @{BFF=$bff.Name; Port=$bff.Port; Endpoints=@{}}
    
    foreach ($endpoint in $bff.Endpoints) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($bff.Port)$endpoint" -Method GET -TimeoutSec 10 -UseBasicParsing
            Write-Host "  ✓ $endpoint : $($response.StatusCode)" -ForegroundColor Green
            $bffResults.Endpoints[$endpoint] = "✓ $($response.StatusCode)"
        } catch {
            Write-Host "  ✗ $endpoint : Failed" -ForegroundColor Red
            $bffResults.Endpoints[$endpoint] = "✗ Failed"
        }
    }
    
    $results += $bffResults
    
    # Stop the BFF
    Write-Host "Stopping $($bff.Name)..." -ForegroundColor Yellow
    try {
        $connections = Get-NetTCPConnection -LocalPort $($bff.Port) -State Listen -ErrorAction SilentlyContinue
        if ($connections) {
            foreach ($conn in $connections) {
                $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
                if ($proc) {
                    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                }
            }
        }
    } catch {
        # Ignore errors
    }
    
    Start-Sleep -Seconds 5
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($result in $results) {
    Write-Host "`n$($result.BFF) (Port $($result.Port)):" -ForegroundColor Yellow
    foreach ($endpoint in $result.Endpoints.Keys) {
        Write-Host "  $endpoint : $($result.Endpoints[$endpoint])"
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All tests completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
