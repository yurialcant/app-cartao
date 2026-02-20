# Script para aplicar migração de tenant_id no banco de dados

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$sqlFile = Join-Path $script:RootPath "infra\sql\add-tenant-id-to-all-tables.sql"

Write-Host "`n[MIGRATION] Aplicando tenant_id em todas as tabelas..." -ForegroundColor Cyan

# Verificar se PostgreSQL está rodando
$pgTest = docker exec benefits-postgres pg_isready -U benefits 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ PostgreSQL não está rodando" -ForegroundColor Red
    Write-Host "  Execute: docker-compose up -d postgres" -ForegroundColor Yellow
    exit 1
}

Write-Host "  → Executando migração SQL..." -ForegroundColor Gray
Get-Content $sqlFile | docker exec -i benefits-postgres psql -U benefits -d benefits

Write-Host "`n✅ Migração de tenant_id aplicada!" -ForegroundColor Green
