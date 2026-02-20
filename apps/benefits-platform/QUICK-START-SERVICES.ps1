#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick start all 5 backend services in separate processes
.DESCRIPTION
    Launches each service in its own PowerShell process using Windows Terminal tabs (if available)
    Falls back to separate console windows if Windows Terminal not available
.PARAMETER Tab
    If true (default), opens services in Windows Terminal tabs
    If false, opens in separate console windows
.EXAMPLE
    .\QUICK-START-SERVICES.ps1
    .\QUICK-START-SERVICES.ps1 -Tab $false
#>

param(
    [bool]$Tab = $true
)

Write-Host "🚀 BENEFITS PLATFORM - QUICK START SERVICES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

# Check if all JARs exist (from previous build)
Write-Host "`n📦 Checking if artifacts are built..." -ForegroundColor Yellow

$requiredJars = @(
    "services/benefits-core/target/benefits-core-*.jar",
    "services/tenant-service/target/tenant-service-*.jar",
    "bffs/user-bff/target/user-bff-*.jar",
    "bffs/employer-bff/target/employer-bff-*.jar",
    "bffs/pos-bff/target/pos-bff-*.jar"
)

$missingJars = @()
foreach ($pattern in $requiredJars) {
    $jars = Get-Item $pattern -ErrorAction SilentlyContinue
    if (-not $jars) {
        $missingJars += $pattern
    }
}

if ($missingJars.Count -gt 0) {
    Write-Host "`n❌ Missing artifacts! Run .\QUICK-BUILD.ps1 first" -ForegroundColor Red
    exit 1
}

Write-Host "✅ All artifacts ready!" -ForegroundColor Green

# Define services
$services = @(
    @{ name = "benefits-core"; port = 8091; path = "services/benefits-core" },
    @{ name = "tenant-service"; port = 9000; path = "services/tenant-service" },
    @{ name = "user-bff"; port = 8080; path = "bffs/user-bff" },
    @{ name = "employer-bff"; port = 8083; path = "bffs/employer-bff" },
    @{ name = "pos-bff"; port = 8084; path = "bffs/pos-bff" }
)

# Function to launch service
function Start-Service {
    param(
        [string]$Name,
        [int]$Port,
        [string]$Path,
        [bool]$Tab
    )
    
    $script = {
        param($Path, $Name, $Port)
        Set-Location $Path
        Write-Host "`n🚀 Starting $Name on port $Port..." -ForegroundColor Cyan
        Write-Host "Location: $(Get-Location)" -ForegroundColor Gray
        Write-Host "Command: mvn spring-boot:run" -ForegroundColor Gray
        Write-Host ""
        mvn spring-boot:run
    }
    
    if ($Tab) {
        # Use Windows Terminal if available
        $wtAvailable = @(Get-Command wt -ErrorAction SilentlyContinue).Count -gt 0
        if ($wtAvailable) {
            Write-Host "  📱 Launching $Name in Windows Terminal tab..." -ForegroundColor Cyan
            wt new-tab -p "PowerShell" -d $projectRoot pwsh -Command {
                param($Path, $Name, $Port)
                Set-Location $Path
                Write-Host "`n🚀 Starting $Name (port $Port)..." -ForegroundColor Cyan
                mvn spring-boot:run
            } -ArgumentList $Path, $Name, $Port
        } else {
            # Fallback: PowerShell ISE or Start-Process
            Write-Host "  🪟 Launching $Name in new PowerShell window..." -ForegroundColor Cyan
            Start-Process pwsh -ArgumentList "-NoExit", "-Command", "Set-Location '$Path'; mvn spring-boot:run"
        }
    } else {
        Write-Host "  🪟 Launching $Name in new console window..." -ForegroundColor Cyan
        Start-Process pwsh -ArgumentList "-NoExit", "-Command", "Set-Location '$Path'; mvn spring-boot:run"
    }
    
    Start-Sleep -Milliseconds 500
}

# Launch all services
Write-Host "`n🔌 Launching 5 services..." -ForegroundColor Cyan
Write-Host "Each service will open in its own window/tab" -ForegroundColor Gray
Write-Host ""

foreach ($svc in $services) {
    Start-Service -Name $svc.name -Port $svc.port -Path $svc.path -Tab $Tab
}

Write-Host "`n⏱️  Waiting for services to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Health check
Write-Host "`n✅ Checking service health..." -ForegroundColor Cyan
$ports = @(8091, 9000, 8080, 8083, 8084)
$healthyCount = 0

foreach ($port in $ports) {
    try {
        $response = curl -s "http://localhost:$port/actuator/health" -ErrorAction SilentlyContinue
        if ($response -match '"status":"UP"') {
            Write-Host "  ✅ Port $port: HEALTHY" -ForegroundColor Green
            $healthyCount++
        } else {
            Write-Host "  ⏳ Port $port: Starting..." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⏳ Port $port: Connecting..." -ForegroundColor Yellow
    }
}

Write-Host "`n════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Services launched: $healthyCount / 5 healthy" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

if ($healthyCount -ge 3) {
    Write-Host "`n📚 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Wait 10-30 more seconds for remaining services" -ForegroundColor White
    Write-Host "  2. Test endpoints with curl:" -ForegroundColor White
    Write-Host "     curl -H 'Authorization: Bearer {JWT}' http://localhost:8080/api/v1/catalog" -ForegroundColor Gray
    Write-Host "     curl -H 'Authorization: Bearer {JWT}' http://localhost:8080/api/v1/wallets" -ForegroundColor Gray
    Write-Host "  3. See NEXT-STEPS.md for complete testing guide" -ForegroundColor White
} else {
    Write-Host "`n⚠️  Services are still starting..." -ForegroundColor Yellow
    Write-Host "  Check individual service windows for startup messages" -ForegroundColor White
    Write-Host "  Most services take 10-30 seconds to initialize" -ForegroundColor White
}

Write-Host ""
