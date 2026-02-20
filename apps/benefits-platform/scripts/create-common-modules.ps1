# Script para criar módulos comuns: common-logging e common-tenant

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$script:ServicesPath = Join-Path $script:RootPath "services"

Write-Host "`n[COMMON MODULES] Criando módulos comuns..." -ForegroundColor Cyan

# Criar common-logging
$commonLoggingPath = Join-Path $script:ServicesPath "common-logging"
if (-not (Test-Path $commonLoggingPath)) {
    New-Item -ItemType Directory -Path $commonLoggingPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$commonLoggingPath\src\main\java\com\benefits\common\logging" -Force | Out-Null
    New-Item -ItemType Directory -Path "$commonLoggingPath\src\main\resources" -Force | Out-Null
    Write-Host "  ✅ Estrutura common-logging criada" -ForegroundColor Green
}

# Criar common-tenant
$commonTenantPath = Join-Path $script:ServicesPath "common-tenant"
if (-not (Test-Path $commonTenantPath)) {
    New-Item -ItemType Directory -Path $commonTenantPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$commonTenantPath\src\main\java\com\benefits\common\tenant" -Force | Out-Null
    Write-Host "  ✅ Estrutura common-tenant criada" -ForegroundColor Green
}

Write-Host "`n✅ Módulos comuns criados!" -ForegroundColor Green
