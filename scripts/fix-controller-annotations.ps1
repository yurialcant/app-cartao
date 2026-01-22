# Script para corrigir anotações incorretas nos controllers
# Substitui @POST, @GET, @PUT por @PostMapping, @GetMapping, @PutMapping

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n🔧 Corrigindo anotações dos controllers..." -ForegroundColor Cyan

# Lista de controllers problemáticos
$controllers = @(
    "services/recon-service/src/main/java/com/benefits/reconservice/controller/ReconciliationController.java",
    "services/settlement-service/src/main/java/com/benefits/settlementservice/controller/SettlementController.java",
    "services/device-service/src/main/java/com/benefits/deviceservice/controller/DeviceController.java",
    "services/audit-service/src/main/java/com/benefits/auditservice/controller/AuditController.java",
    "services/privacy-service/src/main/java/com/benefits/privacyservice/controller/PrivacyController.java",
    "services/support-service/src/main/java/com/benefits/supportservice/controller/TicketController.java",
    "services/risk-service/src/main/java/com/benefits/riskservice/controller/RiskController.java",
    "services/kyc-service/src/main/java/com/benefits/kycservice/controller/KycController.java",
    "services/kyb-service/src/main/java/com/benefits/kybservice/controller/KybController.java"
)

foreach ($controllerPath in $controllers) {
    $fullPath = Join-Path $script:RootPath $controllerPath
    
    if (Test-Path $fullPath) {
        Write-Host "  Corrigindo: $controllerPath" -ForegroundColor Yellow
        
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        
        # Substituir anotações incorretas
        $content = $content -replace '@POST\(', '@PostMapping('
        $content = $content -replace '@GET\(', '@GetMapping('
        $content = $content -replace '@PUT\(', '@PutMapping('
        $content = $content -replace '@DELETE\(', '@DeleteMapping('
        
        # Corrigir nomes de métodos gerados incorretamente
        $content = $content -replace 'createReconciliationimport', 'importStatement'
        $content = $content -replace 'createReconciliationreconcile', 'reconcile'
        $content = $content -replace 'createSettlementscalculate', 'calculateSettlement'
        $content = $content -replace 'createSettlementsprocess', 'processSettlement'
        $content = $content -replace 'createDevicesregister', 'registerDevice'
        $content = $content -replace 'updateDevicestrust', 'updateDeviceTrust'
        
        # Corrigir GET com @RequestBody (não deve ter body em GET)
        $content = $content -replace '(@GetMapping\([^)]+\)\s+public[^{]+@RequestBody[^,]+,\s*)', '$1'
        
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "    ✅ Corrigido" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Arquivo não encontrado: $controllerPath" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Correções aplicadas!" -ForegroundColor Green
