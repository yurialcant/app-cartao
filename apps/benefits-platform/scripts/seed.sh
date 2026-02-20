#!/usr/bin/env pwsh
# Benefits Platform - Seed Database (Idempotent)
# Usage: ./seed.sh

$ErrorActionPreference = "Stop"

Write-Host "=== Benefits Platform | SEED ===" -ForegroundColor Cyan

Push-Location "$PSScriptRoot/../"

try {
  # Check if postgres is healthy
  Write-Host "Waiting for Postgres to be ready..." -ForegroundColor Yellow
  $maxRetries = 30
  $retries = 0
  
  while ($retries -lt $maxRetries) {
    try {
      docker exec benefits-postgres pg_isready -U benefits -d benefits 2>&1 | Out-Null
      if ($?) { break }
    } catch {
      # Ignore errors
    }
    $retries++
    Start-Sleep -Seconds 1
  }

  Write-Host "Creating schemas..." -ForegroundColor Yellow
  
  # Create schemas if not exist
  $schemas = @(
    "CREATE SCHEMA IF NOT EXISTS tenant_service;",
    "CREATE SCHEMA IF NOT EXISTS benefits_core;",
    "CREATE SCHEMA IF NOT EXISTS payments;",
    "CREATE SCHEMA IF NOT EXISTS support;",
    "CREATE SCHEMA IF NOT EXISTS merchant;",
    "CREATE SCHEMA IF NOT EXISTS recon;",
    "CREATE SCHEMA IF NOT EXISTS settlement;",
    "CREATE SCHEMA IF NOT EXISTS audit;",
    "CREATE SCHEMA IF NOT EXISTS ops;",
    "CREATE SCHEMA IF NOT EXISTS public;"
  )

  foreach ($schema in $schemas) {
    echo $schema | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
  }

  Write-Host "Seeding test data (idempotent)..." -ForegroundColor Yellow
  
  # Import seeds SQL (if exists)
  if (Test-Path "./seeds.sql") {
    Get-Content "./seeds.sql" | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "✓ Seeds imported" -ForegroundColor Green
  } else {
    Write-Host "⚠ seeds.sql not found, skipping seed data" -ForegroundColor Yellow
  }

  Write-Host "✓ Database seeded successfully" -ForegroundColor Green

} finally {
  Pop-Location
}
