#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick build script - Maven clean install for all services
.DESCRIPTION
    Compiles all backend services (benefits-core, tenant-service, 3 BFFs)
    with skip tests flag for faster builds during development
.EXAMPLE
    .\QUICK-BUILD.ps1
#>

Write-Host "🔨 BENEFITS PLATFORM - QUICK BUILD SCRIPT" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Validate Maven is installed
Write-Host "`n📋 Checking Maven installation..." -ForegroundColor Yellow
$mvnVersion = mvn --version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Maven not found! Please install Maven 3.9+" -ForegroundColor Red
    exit 1
}
Write-Host "✅ $mvnVersion" -ForegroundColor Green

# Validate Java is installed
Write-Host "`n📋 Checking Java installation..." -ForegroundColor Yellow
$javaVersion = java -version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Java not found! Please install Java 17+" -ForegroundColor Red
    exit 1
}
Write-Host "✅ $($javaVersion[0])" -ForegroundColor Green

# Get workspace root
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

# Clean and build
Write-Host "`n🚀 Starting Maven build..." -ForegroundColor Cyan
Write-Host "Command: mvn clean install -DskipTests" -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

# Run Maven build
mvn clean install -DskipTests -q

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ BUILD FAILED!" -ForegroundColor Red
    Write-Host "Run 'mvn clean install -DskipTests' for verbose output" -ForegroundColor Yellow
    exit 1
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "`n✅ BUILD SUCCESS!" -ForegroundColor Green
Write-Host "⏱️  Duration: ${duration:N1} seconds" -ForegroundColor Cyan

# Verify JAR files
Write-Host "`n📦 Verifying generated artifacts..." -ForegroundColor Yellow

$expectedJars = @(
    "libs/common/target/common-*.jar",
    "libs/events-sdk/target/events-sdk-*.jar",
    "services/benefits-core/target/benefits-core-*.jar",
    "services/tenant-service/target/tenant-service-*.jar",
    "bffs/user-bff/target/user-bff-*.jar",
    "bffs/employer-bff/target/employer-bff-*.jar",
    "bffs/pos-bff/target/pos-bff-*.jar"
)

$missingJars = @()
foreach ($pattern in $expectedJars) {
    $jars = Get-Item $pattern -ErrorAction SilentlyContinue
    if ($jars) {
        $jarName = Split-Path -Leaf $jars.FullName
        Write-Host "  ✅ $jarName" -ForegroundColor Green
    } else {
        $missingJars += $pattern
    }
}

if ($missingJars.Count -gt 0) {
    Write-Host "`n⚠️  Missing JARs:" -ForegroundColor Yellow
    foreach ($jar in $missingJars) {
        Write-Host "  ❌ $jar" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "✨ BUILD COMPLETE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "`n📚 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open 5 PowerShell terminals" -ForegroundColor White
Write-Host "  2. In each terminal, run one of:" -ForegroundColor White
Write-Host "     - cd services\benefits-core && mvn spring-boot:run" -ForegroundColor Gray
Write-Host "     - cd services\tenant-service && mvn spring-boot:run" -ForegroundColor Gray
Write-Host "     - cd bffs\user-bff && mvn spring-boot:run" -ForegroundColor Gray
Write-Host "     - cd bffs\employer-bff && mvn spring-boot:run" -ForegroundColor Gray
Write-Host "     - cd bffs\pos-bff && mvn spring-boot:run" -ForegroundColor Gray
Write-Host "`n  3. Once all started, verify health:" -ForegroundColor White
Write-Host "     curl http://localhost:8091/actuator/health" -ForegroundColor Gray
Write-Host "     curl http://localhost:8080/actuator/health" -ForegroundColor Gray
Write-Host "`n  4. See NEXT-STEPS.md for endpoint testing" -ForegroundColor White
Write-Host ""
