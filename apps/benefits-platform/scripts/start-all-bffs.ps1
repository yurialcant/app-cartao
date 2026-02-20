# Start All BFFs Script
# Starts all 5 BFFs in background terminals

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting All BFFs - Benefits Platform" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$bffs = @(
    @{Name="user-bff"; Port=8080; Module="bffs/user-bff"},
    @{Name="employer-bff"; Port=8083; Module="bffs/employer-bff"},
    @{Name="merchant-bff"; Port=8085; Module="bffs/merchant-bff"},
    @{Name="pos-bff"; Port=8086; Module="bffs/pos-bff"},
    @{Name="admin-bff"; Port=8087; Module="bffs/admin-bff"}
)

$processes = @()

foreach ($bff in $bffs) {
    Write-Host "`nStarting $($bff.Name) on port $($bff.Port)..." -ForegroundColor Yellow
    
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "mvn"
    $startInfo.Arguments = "spring-boot:run -pl $($bff.Module)"
    $startInfo.WorkingDirectory = "C:\Users\gesch\Documents\projeto-lucas"
    $startInfo.UseShellExecute = $true
    $startInfo.CreateNoWindow = $false
    $startInfo.WindowStyle = "Minimized"
    
    $process = [System.Diagnostics.Process]::Start($startInfo)
    $processes += @{BFF=$bff.Name; Process=$process; Port=$bff.Port}
    
    Write-Host "Started $($bff.Name) (PID: $($process.Id))" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All BFFs started! Waiting 30s for startup..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Start-Sleep -Seconds 30

Write-Host "`nTesting all BFFs..." -ForegroundColor Yellow

foreach ($proc in $processes) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($proc.Port)/test" -Method GET -TimeoutSec 5 -UseBasicParsing
        Write-Host "✓ $($proc.BFF) is responding on port $($proc.Port)" -ForegroundColor Green
    } catch {
        Write-Host "✗ $($proc.BFF) is not responding on port $($proc.Port)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All BFFs are running in background!" -ForegroundColor Green
Write-Host "To stop all, run: .\scripts\stop-all-bffs.ps1" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
