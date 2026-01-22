# Stop All BFFs Script
# Stops all running BFF processes

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Stopping All BFFs - Benefits Platform" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$ports = @(8080, 8083, 8085, 8086, 8087)
$stoppedCount = 0

foreach ($port in $ports) {
    Write-Host "`nChecking port $port..." -ForegroundColor Yellow
    
    try {
        $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
        
        if ($connections) {
            foreach ($conn in $connections) {
                $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
                
                if ($process) {
                    Write-Host "Stopping process $($process.ProcessName) (PID: $($process.Id)) on port $port..." -ForegroundColor Yellow
                    Stop-Process -Id $process.Id -Force
                    $stoppedCount++
                    Write-Host "✓ Stopped process on port $port" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "No process found on port $port" -ForegroundColor Gray
        }
    } catch {
        Write-Host "Error checking port $port : $_" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Stopped $stoppedCount processes" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
