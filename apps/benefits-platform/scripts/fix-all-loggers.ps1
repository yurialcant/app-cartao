# Script para adicionar logger manualmente em todos os serviços que precisam

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n🔧 Adicionando loggers manualmente..." -ForegroundColor Cyan

# Lista de arquivos que precisam de logger
$files = @(
    @{Path="services/settlement-service/src/main/java/com/benefits/settlementservice/controller/SettlementController.java"; Class="SettlementController"},
    @{Path="services/settlement-service/src/main/java/com/benefits/settlementservice/service/SettlementService.java"; Class="SettlementService"},
    @{Path="services/device-service/src/main/java/com/benefits/deviceservice/controller/DeviceController.java"; Class="DeviceController"},
    @{Path="services/device-service/src/main/java/com/benefits/deviceservice/service/DeviceService.java"; Class="DeviceService"},
    @{Path="services/audit-service/src/main/java/com/benefits/auditservice/controller/AuditController.java"; Class="AuditController"},
    @{Path="services/privacy-service/src/main/java/com/benefits/privacyservice/controller/PrivacyController.java"; Class="PrivacyController"},
    @{Path="services/support-service/src/main/java/com/benefits/supportservice/controller/TicketController.java"; Class="TicketController"},
    @{Path="services/support-service/src/main/java/com/benefits/supportservice/service/TicketService.java"; Class="TicketService"},
    @{Path="services/risk-service/src/main/java/com/benefits/riskservice/controller/RiskController.java"; Class="RiskController"},
    @{Path="services/risk-service/src/main/java/com/benefits/riskservice/service/RiskService.java"; Class="RiskService"},
    @{Path="services/kyc-service/src/main/java/com/benefits/kycservice/controller/KycController.java"; Class="KycController"},
    @{Path="services/kyb-service/src/main/java/com/benefits/kybservice/controller/KybController.java"; Class="KybController"}
)

foreach ($file in $files) {
    $fullPath = Join-Path $script:RootPath $file.Path
    
    if (Test-Path $fullPath) {
        Write-Host "  Corrigindo: $($file.Path)" -ForegroundColor Yellow
        
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        
        # Remover @Slf4j se existir
        $content = $content -replace 'import lombok\.extern\.slf4j\.Slf4j;', ''
        $content = $content -replace '@Slf4j\s*', ''
        
        # Adicionar imports se não existirem
        if ($content -notmatch 'import org\.slf4j\.Logger;') {
            $content = $content -replace '(import lombok\.RequiredArgsConstructor;)', "`$1`nimport org.slf4j.Logger;`nimport org.slf4j.LoggerFactory;"
        }
        
        # Adicionar logger após a declaração da classe
        if ($content -notmatch 'private static final Logger log') {
            $content = $content -replace '(@RequiredArgsConstructor\s+)?(public class ' + [regex]::Escape($file.Class) + ')', "`$1`$2`n    `n    private static final Logger log = LoggerFactory.getLogger($($file.Class).class);"
        }
        
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "    ✅ Corrigido" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Arquivo não encontrado: $($file.Path)" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Loggers adicionados!" -ForegroundColor Green
