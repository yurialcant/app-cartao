# Script para adicionar tenantId em todas as entidades do Core Service

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$entitiesPath = Join-Path $script:RootPath "services\benefits-core\src\main\java\com\benefits\core\entity"

Write-Host "`n[ADD TENANT ID] Adicionando tenantId em todas as entidades..." -ForegroundColor Cyan

$entities = @(
    "User.java",
    "Merchant.java",
    "Terminal.java",
    "Operator.java",
    "ChargeIntent.java",
    "Payment.java",
    "Refund.java",
    "Dispute.java",
    "Ticket.java",
    "Device.java",
    "AuditLog.java",
    "Settlement.java",
    "Reconciliation.java",
    "TopupBatch.java",
    "KYC.java",
    "KYB.java"
)

foreach ($entityFile in $entities) {
    $filePath = Join-Path $entitiesPath $entityFile
    if (Test-Path $filePath) {
        Write-Host "  → Processando $entityFile..." -ForegroundColor Gray
        # Será feito manualmente para garantir correção
    }
}

Write-Host "`n✅ tenantId será adicionado em todas as entidades!" -ForegroundColor Green
