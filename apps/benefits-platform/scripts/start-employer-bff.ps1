# start-employer-bff.ps1
# Script to start employer-bff with proper checks and background execution

param(
    [switch]$NoWait,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration
$ServiceName = "employer-bff"
$Port = 8083
$WorkingDir = Split-Path -Parent $PSScriptRoot
$ServiceDir = Join-Path $WorkingDir "bffs\employer-bff"

Write-Host "🚀 Starting $ServiceName..." -ForegroundColor Green
Write-Host "Port: $Port" -ForegroundColor Cyan
Write-Host "Directory: $ServiceDir" -ForegroundColor Cyan

# Check if port is already in use
$existingProcess = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq "Listen" }

if ($existingProcess -and -not $Force) {
    Write-Host "❌ Port $Port is already in use. Use -Force to kill existing process." -ForegroundColor Red
    exit 1
}

# Kill existing process if Force is specified
if ($existingProcess -and $Force) {
    Write-Host "🔫 Force killing existing process on port $Port..." -ForegroundColor Yellow
    $processId = (Get-NetTCPConnection -LocalPort $Port).OwningProcess
    if ($processId) {
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

# Change to service directory
Set-Location $ServiceDir

# Compile the service
Write-Host "🔨 Compiling $ServiceName..." -ForegroundColor Yellow
& mvn clean compile -q
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Compilation failed" -ForegroundColor Red
    exit 1
}

# Start the service in background
Write-Host "▶️  Starting $ServiceName on port $Port..." -ForegroundColor Green

if ($NoWait) {
    # Start without waiting
    $job = Start-Job -ScriptBlock {
        param($dir, $port)
        Set-Location $dir
        & mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=$port"
    } -ArgumentList $ServiceDir, $Port

    Write-Host "📋 Job started with ID: $($job.Id)" -ForegroundColor Cyan
    Write-Host "🔍 Use 'Get-Job -Id $($job.Id) | Receive-Job -Keep' to check logs" -ForegroundColor Cyan
    Write-Host "🛑 Use 'Stop-Job -Id $($job.Id)' to stop the service" -ForegroundColor Cyan
} else {
    # Start and wait for startup
    $job = Start-Job -ScriptBlock {
        param($dir, $port)
        Set-Location $dir
        & mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=$port"
    } -ArgumentList $ServiceDir, $Port

    Write-Host "⏳ Waiting for service to start..." -ForegroundColor Yellow

    # Wait for service to be ready (check if port is listening)
    $maxWait = 60
    $waited = 0
    while ($waited -lt $maxWait) {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
            Where-Object { $_.State -eq "Listen" }

        if ($connection) {
            Write-Host "✅ $ServiceName started successfully on port $Port" -ForegroundColor Green
            Write-Host "📋 Job ID: $($job.Id)" -ForegroundColor Cyan
            break
        }

        Start-Sleep -Seconds 2
        $waited += 2
        Write-Host "⏳ Still waiting... ($waited/$maxWait seconds)" -ForegroundColor Yellow
    }

    if ($waited -ge $maxWait) {
        Write-Host "❌ Service failed to start within $maxWait seconds" -ForegroundColor Red
        Receive-Job -Job $job
        exit 1
    }
}

Write-Host "" -ForegroundColor White
Write-Host "🎯 Service should be available at: http://localhost:$Port" -ForegroundColor Green
Write-Host "📖 Health check: http://localhost:$Port/actuator/health" -ForegroundColor Green
Write-Host "📋 API docs: http://localhost:$Port/swagger-ui.html" -ForegroundColor Green
