#!/usr/bin/env pwsh
# Benefits Platform - View Logs
# Usage: ./logs.sh [service]
# Examples:
#   ./logs.sh postgres
#   ./logs.sh keycloak -f
#   ./logs.sh          # All services

param(
  [string]$service = "",
  [switch]$follow = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=== Benefits Platform | LOGS ===" -ForegroundColor Cyan

Push-Location "$PSScriptRoot/../infra"

try {
  $args = @()
  if ($service) { $args += $service }
  if ($follow) { $args += "-f" }
  
  Write-Host "Following logs$(if ($service) { " for: $service" } else { "" })..." -ForegroundColor Yellow
  docker-compose logs @args

} finally {
  Pop-Location
}
