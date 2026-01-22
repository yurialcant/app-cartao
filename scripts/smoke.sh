#!/usr/bin/env pwsh
# Benefits Platform - Smoke Tests (Health checks)
# Usage: ./smoke.sh

$ErrorActionPreference = "Stop"

Write-Host "=== Benefits Platform | SMOKE TESTS ===" -ForegroundColor Cyan

$healthchecks = @(
  @{ name = "Postgres"; url = ""; cmd = "docker exec benefits-postgres pg_isready -U benefits" },
  @{ name = "Redis"; url = ""; cmd = "docker exec benefits-redis redis-cli ping" },
  @{ name = "Keycloak Health"; url = "http://localhost:8081/health/ready"; cmd = "" },
  @{ name = "Jaeger"; url = "http://localhost:16686"; cmd = "" },
  @{ name = "Prometheus"; url = "http://localhost:9090/-/healthy"; cmd = "" },
  @{ name = "Grafana"; url = "http://localhost:3000/api/health"; cmd = "" }
)

$passed = 0
$failed = 0

foreach ($check in $healthchecks) {
  Write-Host "Checking $($check.name)..." -NoNewline -ForegroundColor Gray
  
  try {
    if ($check.cmd) {
      $result = Invoke-Expression $check.cmd 2>&1
      if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓" -ForegroundColor Green
        $passed++
      } else {
        Write-Host " ✗ (Command failed)" -ForegroundColor Red
        $failed++
      }
    } else {
      $response = Invoke-WebRequest -Uri $check.url -ErrorAction Stop -SkipHttpErrorCheck
      if ($response.StatusCode -eq 200) {
        Write-Host " ✓" -ForegroundColor Green
        $passed++
      } else {
        Write-Host " ✗ (Status: $($response.StatusCode))" -ForegroundColor Red
        $failed++
      }
    }
  } catch {
    Write-Host " ✗ (Error: $_)" -ForegroundColor Red
    $failed++
  }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })

if ($failed -gt 0) {
  Write-Host "`n✗ Smoke tests failed" -ForegroundColor Red
  exit 1
} else {
  Write-Host "`n✓ All smoke tests passed" -ForegroundColor Green
  exit 0
}
