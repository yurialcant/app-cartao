#!/usr/bin/env pwsh
# Benefits Platform - Start All Services
# Usage: ./up.sh

$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"

Write-Host "=== Benefits Platform | UP ===" -ForegroundColor Cyan

# Change to infra directory
Push-Location "$PSScriptRoot/../infra"

try {
  Write-Host "Building Docker images..." -ForegroundColor Yellow
  docker-compose build --no-cache 2>&1 | Tee-Object -Variable BuildOutput | Out-Null

  Write-Host "Starting containers..." -ForegroundColor Yellow
  docker-compose up -d

  Write-Host "Waiting for services to be healthy..." -ForegroundColor Yellow
  $maxRetries = 30
  $retries = 0
  
  while ($retries -lt $maxRetries) {
    $dbHealth = docker exec benefits-postgres pg_isready -U benefits -d benefits 2>/dev/null
    $redisHealth = docker exec benefits-redis redis-cli ping 2>/dev/null
    $kcHealth = docker exec benefits-keycloak curl -s http://localhost:8080/health/ready 2>/dev/null
    
    if ($dbHealth -eq "accepting connections" -and $redisHealth -eq "PONG" -and $kcHealth) {
      Write-Host "✓ All infrastructure services are healthy" -ForegroundColor Green
      break
    }
    
    $retries++
    Start-Sleep -Seconds 2
    Write-Host "  Waiting... ($retries/$maxRetries)" -ForegroundColor Gray
  }

  if ($retries -ge $maxRetries) {
    Write-Host "✗ Services did not become healthy in time" -ForegroundColor Red
    exit 1
  }

  Write-Host "`n=== Services Running ===" -ForegroundColor Cyan
  Write-Host "Postgres:     localhost:5432 (benefits/benefits123)" -ForegroundColor Gray
  Write-Host "Redis:        localhost:6379" -ForegroundColor Gray
  Write-Host "Keycloak:     http://localhost:8081 (admin/admin)" -ForegroundColor Gray
  Write-Host "LocalStack:   http://localhost:4566" -ForegroundColor Gray
  Write-Host "Jaeger:       http://localhost:16686" -ForegroundColor Gray
  Write-Host "Prometheus:   http://localhost:9090" -ForegroundColor Gray
  Write-Host "Grafana:      http://localhost:3000 (admin/admin)" -ForegroundColor Gray
  Write-Host "`n✓ Infrastructure is ready. Run './seed.sh' to seed data." -ForegroundColor Green

} finally {
  Pop-Location
}
