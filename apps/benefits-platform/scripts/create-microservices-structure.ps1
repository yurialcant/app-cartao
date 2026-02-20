# Script para criar estrutura completa de microserviços
# Este script cria a estrutura base de todos os serviços

Write-Host "=== Criando Estrutura de Microserviços ===" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Diretórios base
$servicesDir = "services"
$appsDir = "apps"

Write-Host "`n[1/6] Criando estrutura do Core Service..." -ForegroundColor Yellow

# Core Service já foi criado manualmente
if (Test-Path "$servicesDir/benefits-core") {
    Write-Host "  ✓ Core Service já existe" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Core Service precisa ser criado manualmente" -ForegroundColor Yellow
}

Write-Host "`n[2/6] Criando estrutura dos BFFs..." -ForegroundColor Yellow

$bffs = @(
    @{Name="admin-bff"; Port=8083; Description="BFF para Admin Angular"},
    @{Name="merchant-bff"; Port=8084; Description="BFF para Merchant POS Flutter"},
    @{Name="merchant-portal-bff"; Port=8085; Description="BFF para Merchant Portal Angular"}
)

foreach ($bff in $bffs) {
    $bffDir = "$servicesDir/$($bff.Name)"
    if (-not (Test-Path $bffDir)) {
        Write-Host "  Criando $($bff.Name)..." -ForegroundColor Gray
        New-Item -ItemType Directory -Path $bffDir -Force | Out-Null
        Write-Host "  ✓ $($bff.Name) criado" -ForegroundColor Green
    } else {
        Write-Host "  ✓ $($bff.Name) já existe" -ForegroundColor Green
    }
}

Write-Host "`n[3/6] Criando estrutura de apps..." -ForegroundColor Yellow

$apps = @(
    @{Name="merchant_pos_flutter"; Type="Flutter"; Description="Merchant POS App"},
    @{Name="admin_angular"; Type="Angular"; Description="Admin Backoffice"},
    @{Name="merchant_portal_angular"; Type="Angular"; Description="Merchant Portal"}
)

foreach ($app in $apps) {
    $appDir = "$appsDir/$($app.Name)"
    if (-not (Test-Path $appDir)) {
        Write-Host "  Criando $($app.Name)..." -ForegroundColor Gray
        New-Item -ItemType Directory -Path $appDir -Force | Out-Null
        Write-Host "  ✓ $($app.Name) criado" -ForegroundColor Green
    } else {
        Write-Host "  ✓ $($app.Name) já existe" -ForegroundColor Green
    }
}

Write-Host "`n[4/6] Criando estrutura de testes..." -ForegroundColor Yellow

$testDir = "tests"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Write-Host "  ✓ Diretório de testes criado" -ForegroundColor Green
} else {
    Write-Host "  ✓ Diretório de testes já existe" -ForegroundColor Green
}

Write-Host "`n[5/6] Criando estrutura de CI/CD..." -ForegroundColor Yellow

$githubDir = ".github/workflows"
if (-not (Test-Path $githubDir)) {
    New-Item -ItemType Directory -Path ".github" -Force | Out-Null
    New-Item -ItemType Directory -Path $githubDir -Force | Out-Null
    Write-Host "  ✓ Diretório .github/workflows criado" -ForegroundColor Green
} else {
    Write-Host "  ✓ Diretório .github/workflows já existe" -ForegroundColor Green
}

Write-Host "`n[6/6] Resumo..." -ForegroundColor Yellow

Write-Host "`n=== Estrutura Criada ===" -ForegroundColor Cyan
Write-Host "`nServiços:" -ForegroundColor Yellow
Get-ChildItem $servicesDir -Directory | ForEach-Object {
    Write-Host "  • $($_.Name)" -ForegroundColor White
}

Write-Host "`nApps:" -ForegroundColor Yellow
Get-ChildItem $appsDir -Directory | ForEach-Object {
    Write-Host "  • $($_.Name)" -ForegroundColor White
}

Write-Host "`n✅ Estrutura base criada!" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Cyan
Write-Host "  1. Implementar Core Service completo" -ForegroundColor Yellow
Write-Host "  2. Refatorar user-bff para usar Core Service" -ForegroundColor Yellow
Write-Host "  3. Implementar outros BFFs" -ForegroundColor Yellow
Write-Host "  4. Criar testes automatizados" -ForegroundColor Yellow
Write-Host "  5. Criar pipeline CI/CD" -ForegroundColor Yellow
