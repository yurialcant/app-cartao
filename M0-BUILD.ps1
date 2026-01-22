#!/usr/bin/env pwsh

<#
.SYNOPSIS
  M0 Build Helper - Compile, test, lint, and validate the project

.DESCRIPTION
  Multi-purpose build script supporting Maven, Node, and Docker operations.
  - clean: Remove build artifacts
  - build: Compile all services
  - test: Run unit tests
  - lint: Check code quality
  - docker-build: Build service images
  - validate: Smoke tests on local infra

.EXAMPLE
  .\M0-BUILD.ps1 build
  .\M0-BUILD.ps1 test
  .\M0-BUILD.ps1 docker-build

#>

param(
  [Parameter(Position = 0)]
  [ValidateSet('clean', 'build', 'test', 'lint', 'docker-build', 'validate', 'help')]
  [string]$Target = 'help'
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Print-Header {
  param([string]$Message)
  Write-Host "`n$('='*60)" -ForegroundColor Cyan
  Write-Host "  $Message" -ForegroundColor Cyan
  Write-Host "$('='*60)`n" -ForegroundColor Cyan
}

function Print-Step {
  param([string]$Message)
  Write-Host "▶ $Message" -ForegroundColor Yellow
}

function Print-Success {
  param([string]$Message)
  Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
  param([string]$Message)
  Write-Host "✗ $Message" -ForegroundColor Red
}

# Clean
function Invoke-Clean {
  Print-Header "Cleaning build artifacts"
  
  Print-Step "Removing target/ directories"
  Get-ChildItem -Path $RootDir -Recurse -Directory -Filter "target" | 
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  
  Print-Step "Removing node_modules and dist"
  Get-ChildItem -Path $RootDir -Recurse -Directory -Filter "node_modules" | 
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  Get-ChildItem -Path $RootDir -Recurse -Directory -Filter "dist" | 
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  
  Print-Success "Clean complete"
}

# Build
function Invoke-Build {
  Print-Header "Building project (Maven)"
  
  Print-Step "Running mvn clean package"
  cd $RootDir
  
  $MvnCmd = "mvn clean package -DskipTests -T 1.5C"
  
  if ($env:CI) {
    & $MvnCmd
  } else {
    & $MvnCmd
  }
  
  if ($LASTEXITCODE -ne 0) {
    Print-Error "Build failed"
    exit 1
  }
  
  Print-Success "Build complete"
}

# Test
function Invoke-Test {
  Print-Header "Running tests"
  
  Print-Step "Running Maven tests"
  cd $RootDir
  
  mvn test -T 1.5C
  
  if ($LASTEXITCODE -ne 0) {
    Print-Error "Tests failed"
    exit 1
  }
  
  Print-Success "Tests passed"
}

# Lint
function Invoke-Lint {
  Print-Header "Running linters"
  
  Print-Step "Checking code quality with SpotBugs"
  cd $RootDir
  
  mvn spotbugs:check -DfailOnError=false
  
  Print-Step "Checking for security issues"
  mvn dependency-check:check -DfailOnError=false
  
  Print-Success "Lint complete (check output for issues)"
}

# Docker build
function Invoke-DockerBuild {
  Print-Header "Building Docker images"
  
  $Services = @(
    "libs/common",
    "services/benefits-core",
    "bffs/user-bff",
    "bffs/employer-bff",
    "bffs/pos-bff"
  )
  
  foreach ($Service in $Services) {
    Print-Step "Building $Service"
    $DockerFile = Join-Path $RootDir $Service "Dockerfile"
    
    if (Test-Path $DockerFile) {
      docker build -t "benefits/$Service" -f $DockerFile $RootDir/$Service
    } else {
      Print-Error "Dockerfile not found for $Service"
    }
  }
  
  Print-Success "Docker build complete"
}

# Validate
function Invoke-Validate {
  Print-Header "Running validation/smoke tests"
  
  Print-Step "Checking Java version"
  java -version
  
  Print-Step "Checking Maven"
  mvn --version
  
  Print-Step "Checking Docker"
  docker --version
  
  Print-Step "Checking PostgreSQL connectivity (local)"
  # Would connect to local PG if running
  Write-Host "  (Skipped - requires local infra running)"
  
  Print-Success "Validation complete"
}

# Help
function Print-Help {
  Print-Header "M0 Build Helper"
  
  Write-Host @"
USAGE: .\M0-BUILD.ps1 [TARGET]

TARGETS:
  clean           Remove build artifacts and caches
  build           Compile Maven modules (skip tests)
  test            Run all unit tests
  lint            Run code quality and security checks
  docker-build    Build Docker images for services
  validate        Run validation and smoke tests
  help            Print this help message

EXAMPLES:
  .\M0-BUILD.ps1 build          # Compile everything
  .\M0-BUILD.ps1 test           # Run tests
  .\M0-BUILD.ps1 docker-build   # Build Docker images

ENVIRONMENT:
  CI=true                        # Set to skip interactive features in CI

NOTES:
  - Requires Java 21+
  - Requires Maven 3.9+
  - Requires Docker (for docker-build target)
  - Some services may be disabled (see pom.xml comments)

"@
}

# Main dispatch
switch ($Target) {
  'clean' { Invoke-Clean }
  'build' { Invoke-Build }
  'test' { Invoke-Test }
  'lint' { Invoke-Lint }
  'docker-build' { Invoke-DockerBuild }
  'validate' { Invoke-Validate }
  'help' { Print-Help }
  default { Print-Help }
}
