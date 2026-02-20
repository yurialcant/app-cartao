# Start Support BFF
# Initializes the Support BFF service for expense reimbursement

param(
    [switch]$Background,
    [string]$JavaOpts = "-Xmx512m -Xms256m"
)

Write-Host "🚀 [Support-BFF] Starting Support BFF..." -ForegroundColor Magenta

# Check if port 8086 is available
$portInUse = Get-NetTCPConnection -LocalPort 8086 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "❌ Port 8086 is already in use. Support BFF may already be running." -ForegroundColor Red
    exit 1
}

# Check if benefits-core is running (required dependency)
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -Method GET -TimeoutSec 5
    if ($response.StatusCode -ne 200) {
        throw "Benefits-core not responding"
    }
} catch {
    Write-Host "❌ Benefits-core is not running on port 8091. Please start benefits-core first." -ForegroundColor Red
    Write-Host "   Run: .\scripts\start-benefits-core.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Dependencies checked - benefits-core is running" -ForegroundColor Green

# Set working directory to bffs/support-bff
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$supportBffDir = Join-Path $projectRoot "bffs\support-bff"

# Build the application
Write-Host "🔨 Building support-bff..." -ForegroundColor Yellow
Push-Location $supportBffDir
try {
    & mvn clean compile -q
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed"
    }
} finally {
    Pop-Location
}

Write-Host "✅ Build successful" -ForegroundColor Green

# Start the application
Write-Host "🚀 Starting Support BFF on port 8086..." -ForegroundColor Cyan

$startCommand = "mvn spring-boot:run -Dspring-boot.run.jvmArguments='$JavaOpts'"

if ($Background) {
    Write-Host "📋 Starting in background mode..." -ForegroundColor Gray
    $job = Start-Job -ScriptBlock {
        param($dir, $cmd)
        Set-Location $dir
        Invoke-Expression $cmd
    } -ArgumentList $supportBffDir, $startCommand

    Start-Sleep -Seconds 5

    # Check if job is still running
    if ($job.State -eq "Running") {
        Write-Host "✅ Support BFF started successfully in background" -ForegroundColor Green
        Write-Host "📊 Job ID: $($job.Id)" -ForegroundColor Gray
        Write-Host "🔗 Health Check: http://localhost:8086/actuator/health" -ForegroundColor Cyan
        Write-Host "📚 API Docs: http://localhost:8086/api/v1/expenses" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Failed to start Support BFF in background" -ForegroundColor Red
        Receive-Job $job
        exit 1
    }
} else {
    Write-Host "📋 Starting in foreground mode..." -ForegroundColor Gray
    Write-Host "📊 Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""

    Push-Location $supportBffDir
    try {
        Invoke-Expression $startCommand
    } finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "🎯 Support BFF Configuration:" -ForegroundColor Cyan
Write-Host "   📍 Port: 8086" -ForegroundColor White
Write-Host "   🔗 Health: http://localhost:8086/actuator/health" -ForegroundColor White
Write-Host "   📚 API: http://localhost:8086/api/v1/expenses" -ForegroundColor White
Write-Host "   🔧 Dependencies: benefits-core (port 8091)" -ForegroundColor White
Write-Host ""
Write-Host "📋 Available endpoints:" -ForegroundColor Yellow
Write-Host "   POST /api/v1/expenses              # Submit expense" -ForegroundColor White
Write-Host "   GET  /api/v1/expenses              # List user expenses" -ForegroundColor White
Write-Host "   GET  /api/v1/expenses/{id}         # Get expense details" -ForegroundColor White
Write-Host "   POST /api/v1/expenses/{id}/receipts # Add receipt" -ForegroundColor White
Write-Host "   GET  /api/v1/expenses/employer/pending # List pending for approval" -ForegroundColor White
Write-Host "   PUT  /api/v1/expenses/employer/{id}/approve # Approve expense" -ForegroundColor White
Write-Host "   PUT  /api/v1/expenses/employer/{id}/reject  # Reject expense" -ForegroundColor White