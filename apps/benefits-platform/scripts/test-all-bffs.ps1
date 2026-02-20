# Test All BFFs Script
# Validates all BFF endpoints and integration with core services

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing All BFFs - Benefits Platform" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test configuration
$bffs = @(
    @{Name="user-bff"; Port=8080; Path="/test"},
    @{Name="employer-bff"; Port=8083; Path="/test"},
    @{Name="merchant-bff"; Port=8085; Path="/test"},
    @{Name="pos-bff"; Port=8086; Path="/test"},
    @{Name="admin-bff"; Port=8087; Path="/test"}
)

$results = @()

foreach ($bff in $bffs) {
    Write-Host "`nTesting $($bff.Name) on port $($bff.Port)..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($bff.Port)$($bff.Path)" -Method GET -TimeoutSec 5 -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $($bff.Name) is UP" -ForegroundColor Green
            $results += @{BFF=$bff.Name; Status="UP"; Port=$bff.Port}
        } else {
            Write-Host "✗ $($bff.Name) returned status $($response.StatusCode)" -ForegroundColor Red
            $results += @{BFF=$bff.Name; Status="ERROR-$($response.StatusCode)"; Port=$bff.Port}
        }
    } catch {
        Write-Host "✗ $($bff.Name) is DOWN or not accessible" -ForegroundColor Red
        $results += @{BFF=$bff.Name; Status="DOWN"; Port=$bff.Port}
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($result in $results) {
    $color = if ($result.Status -eq "UP") { "Green" } else { "Red" }
    Write-Host "$($result.BFF) (Port $($result.Port)): $($result.Status)" -ForegroundColor $color
}

$upCount = ($results | Where-Object {$_.Status -eq "UP"}).Count
$totalCount = $results.Count

Write-Host "`nTotal: $upCount/$totalCount BFFs operational" -ForegroundColor $(if ($upCount -eq $totalCount) {"Green"} else {"Yellow"})
