# start-merchant-service.ps1
# Build and start the merchant-service in background

param(
    [switch]$Foreground,
    [switch]$SkipBuild
)

$serviceName = "merchant-service"
$port = 8089

Write-Host "🏪 Starting $serviceName..." -ForegroundColor Green

# Check if Java is available
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Java not found in PATH"
    exit 1
}

# Check if Maven is available
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Maven not found in PATH"
    exit 1
}

# Build the service
if (-not $SkipBuild) {
    Write-Host "📦 Building $serviceName..." -ForegroundColor Yellow
    Push-Location "services/$serviceName"
    try {
        & mvn clean package -DskipTests
        if ($LASTEXITCODE -ne 0) {
            Write-Error "❌ Build failed"
            exit 1
        }
    } finally {
        Pop-Location
    }
}

# Start the service
Write-Host "🏃 Starting $serviceName on port $port..." -ForegroundColor Cyan

if ($Foreground) {
    Write-Host "Running in foreground mode. Press Ctrl+C to stop." -ForegroundColor Yellow
    & java -jar "services/$serviceName/target/$serviceName-1.0.0-SNAPSHOT.jar" --server.port=$port
} else {
    Write-Host "Running in background mode." -ForegroundColor Yellow

    # Kill any existing process on the port
    $existingProcess = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -ErrorAction SilentlyContinue
    if ($existingProcess) {
        Write-Host "🔪 Killing existing process on port $port..." -ForegroundColor Red
        Stop-Process -Id $existingProcess -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }

    # Start in background
    $jobName = "$serviceName-job"
    $job = Start-Job -Name $jobName -ScriptBlock {
        param($jarPath, $port)
        try {
            & java -jar $jarPath --server.port=$port
        } catch {
            Write-Host "❌ Error starting service: $($_.Exception.Message)" -ForegroundColor Red
        }
    } -ArgumentList "services/$serviceName/target/$serviceName-1.0.0-SNAPSHOT.jar", $port

    Start-Sleep -Seconds 3

    # Check if service started successfully
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$port/actuator/health" -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $serviceName started successfully on port $port" -ForegroundColor Green
            Write-Host "📊 Health check: http://localhost:$port/actuator/health" -ForegroundColor Blue
        } else {
            Write-Host "⚠️ $serviceName may have started but health check returned status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️ $serviceName may have started but health check failed" -ForegroundColor Yellow
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "🔍 Job status: $(Get-Job -Name $jobName | Select-Object -ExpandProperty State)" -ForegroundColor Gray
}

Write-Host "🎯 $serviceName startup complete" -ForegroundColor Green