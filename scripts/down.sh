#!/usr/bin/env pwsh
# Benefits Platform - Stop All Services
# Usage: ./down.sh

$ErrorActionPreference = "Stop"

Write-Host "=== Benefits Platform | DOWN ===" -ForegroundColor Cyan

Push-Location "$PSScriptRoot/../infra"

try {
  Write-Host "Stopping containers..." -ForegroundColor Yellow
  docker-compose down -v
  
  Write-Host "✓ All services stopped" -ForegroundColor Green

} finally {
  Pop-Location
}
