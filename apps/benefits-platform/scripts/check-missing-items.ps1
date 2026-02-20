# Script para verificar o que falta da lista completa

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📋 VERIFICANDO ITENS FALTANTES DA LISTA 📋                ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$missingItems = @()

# Verificar Angular Admin
$angularAdminDir = Join-Path $baseDir "apps/admin_angular"
$angularAdminSrc = Join-Path $angularAdminDir "src"
if (-not (Test-Path $angularAdminSrc) -or (Get-ChildItem $angularAdminSrc -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
    $missingItems += "Angular Admin completo (apenas README existe)"
}

# Verificar Angular Merchant Portal
$angularMerchantDir = Join-Path $baseDir "apps/merchant_portal_angular"
if (-not (Test-Path $angularMerchantDir) -or (Get-ChildItem $angularMerchantDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
    $missingItems += "Angular Merchant Portal completo"
}

# Verificar documentação de fluxos E2E conforme PRD
$flowDocs = @(
    "docs/user-journey/complete-journey.md",
    "docs/architecture/state-machine.md",
    "docs/architecture/sitemap.md"
)
foreach ($doc in $flowDocs) {
    $docPath = Join-Path $baseDir $doc
    if (-not (Test-Path $docPath)) {
        $missingItems += "Documentação: $doc"
    }
}

# Verificar testes E2E completos
$e2eTests = Join-Path $baseDir "tests/e2e/run-all-e2e-tests.ps1"
if (-not (Test-Path $e2eTests)) {
    $missingItems += "Suite de testes E2E completa"
}

# Verificar CI/CD
$ciCd = Join-Path $baseDir ".github/workflows"
if (-not (Test-Path $ciCd) -or (Get-ChildItem $ciCd -Filter "*.yml" -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
    $missingItems += "Pipeline CI/CD completo"
}

# Verificar observabilidade
$observability = @(
    "docs/ops/slo.md"
)
foreach ($obs in $observability) {
    $obsPath = Join-Path $baseDir $obs
    if (-not (Test-Path $obsPath)) {
        $missingItems += "Observabilidade: $obs"
    }
}

# Verificar documentação de compliance
$compliance = @(
    "docs/compliance/lgpd.md",
    "docs/compliance/pci.md"
)
foreach ($comp in $compliance) {
    $compPath = Join-Path $baseDir $comp
    if (-not (Test-Path $compPath)) {
        $missingItems += "Compliance: $comp"
    }
}

Write-Host "`n📊 ITENS FALTANTES ENCONTRADOS:" -ForegroundColor Yellow
Write-Host ""

if ($missingItems.Count -eq 0) {
    Write-Host "  ✅ Nenhum item crítico faltando!" -ForegroundColor Green
} else {
    foreach ($item in $missingItems) {
        Write-Host "  ⚠ $item" -ForegroundColor Yellow
    }
}

Write-Host "`n📋 CHECKLIST DO PROJETO:" -ForegroundColor Cyan
Write-Host ""

$checklist = @{
    "✅ Produto e Escopo" = @(
        "Problema e objetivo documentado",
        "Personas definidas",
        "MVP definido",
        "Regras de negócio documentadas",
        "Roadmap por fases"
    )
    "✅ Arquitetura" = @(
        "Diagrama C4",
        "Fluxos E2E documentados",
        "Modelo de domínio",
        "Contratos OpenAPI",
        "ADRs"
    )
    "⚠ Frontend Apps" = @(
        "Flutter User App ✅",
        "Flutter Merchant POS ✅",
        "Angular Admin ⚠ (estrutura básica)",
        "Angular Merchant Portal ❌"
    )
    "✅ Backend" = @(
        "19 serviços funcionais",
        "4 BFFs integrados",
        "Feign Clients configurados",
        "Stubs de adquirentes"
    )
    "⚠ Testes" = @(
        "Testes unitários básicos",
        "Testes E2E básicos ✅",
        "Testes de carga ⚠",
        "Testes de regressão ⚠"
    )
    "⚠ Observabilidade" = @(
        "Logs estruturados ✅",
        "Métricas ⚠",
        "Tracing ⚠",
        "Dashboards ⚠",
        "Alertas ⚠"
    )
    "⚠ CI/CD" = @(
        "Pipeline básico ✅",
        "Deploy automático ⚠",
        "IaC completo ⚠"
    )
    "⚠ Compliance" = @(
        "LGPD básico ✅",
        "PCI básico ✅",
        "Documentação completa ⚠"
    )
}

foreach ($category in $checklist.Keys) {
    Write-Host "  $category" -ForegroundColor $(if ($category -match "✅") { "Green" } elseif ($category -match "⚠") { "Yellow" } else { "Red" })
    foreach ($item in $checklist[$category]) {
        $status = if ($item -match "✅") { "Green" } elseif ($item -match "⚠") { "Yellow" } elseif ($item -match "❌") { "Red" } else { "White" }
        Write-Host "    • $item" -ForegroundColor $status
    }
    Write-Host ""
}

Write-Host "`n🎯 PRÓXIMOS PASSOS PRIORITÁRIOS:" -ForegroundColor Cyan
Write-Host "  1. Completar Angular Admin" -ForegroundColor White
Write-Host "  2. Criar Angular Merchant Portal" -ForegroundColor White
Write-Host "  3. Documentar fluxos E2E conforme PRD" -ForegroundColor White
Write-Host "  4. Expandir testes E2E" -ForegroundColor White
Write-Host "  5. Implementar observabilidade completa" -ForegroundColor White
Write-Host "  6. Validar tudo funcionando end-to-end" -ForegroundColor White
Write-Host ""
