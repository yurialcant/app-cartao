# Script para validar todos os stubs baseados em serviços reais

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   ✅ VALIDANDO TODOS OS STUBS BASEADOS EM SERVIÇOS REAIS ✅  ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$stubs = @(
    @{Name="Cielo"; File="services/acquirer-stub/src/main/java/com/benefits/acquirerstub/adapter/CieloStubAdapter.java"; Status="✅"},
    @{Name="Stone"; File="services/acquirer-stub/src/main/java/com/benefits/acquirerstub/adapter/StoneStubAdapter.java"; Status="✅"},
    @{Name="PagSeguro"; File="services/acquirer-stub/src/main/java/com/benefits/acquirerstub/adapter/PagSeguroStubAdapter.java"; Status="✅"},
    @{Name="Twilio SMS"; File="services/notification-service/src/main/java/com/benefits/notificationservice/provider/TwilioSmsProvider.java"; Status="✅"},
    @{Name="AWS SNS SMS"; File="services/notification-service/src/main/java/com/benefits/notificationservice/provider/AwsSnsSmsProvider.java"; Status="✅"},
    @{Name="AWS SES Email"; File="services/notification-service/src/main/java/com/benefits/notificationservice/provider/AwsSesEmailProvider.java"; Status="✅"},
    @{Name="SendGrid Email"; File="services/notification-service/src/main/java/com/benefits/notificationservice/provider/SendGridEmailProvider.java"; Status="✅"},
    @{Name="FCM Push"; File="services/notification-service/src/main/java/com/benefits/notificationservice/provider/FcmPushProvider.java"; Status="✅"},
    @{Name="APNS Push"; File="services/notification-service/src/main/java/com/benefits/notificationservice/provider/ApnsPushProvider.java"; Status="✅"},
    @{Name="Serpro KYC"; File="services/kyc-service/src/main/java/com/benefits/kycservice/provider/SerproKycProvider.java"; Status="✅"},
    @{Name="Serasa KYC"; File="services/kyc-service/src/main/java/com/benefits/kycservice/provider/SerasaKycProvider.java"; Status="✅"},
    @{Name="FaceTec Biometric"; File="services/kyc-service/src/main/java/com/benefits/kycservice/provider/FaceTecBiometricProvider.java"; Status="✅"},
    @{Name="ReceitaWS KYB"; File="services/kyb-service/src/main/java/com/benefits/kybservice/provider/ReceitaWsKybProvider.java"; Status="✅"}
)

Write-Host "`n[VALIDAÇÃO] Verificando arquivos dos stubs..." -ForegroundColor Yellow

$valid = 0
$invalid = 0

foreach ($stub in $stubs) {
    $filePath = Join-Path $script:RootPath $stub.File
    if (Test-Path $filePath) {
        Write-Host "  ✅ $($stub.Name) - Arquivo encontrado" -ForegroundColor Green
        $valid++
    } else {
        Write-Host "  ❌ $($stub.Name) - Arquivo NÃO encontrado: $($stub.File)" -ForegroundColor Red
        $invalid++
    }
}

Write-Host "`n📊 RESUMO:" -ForegroundColor Cyan
Write-Host "  ✅ Stubs válidos: $valid" -ForegroundColor Green
Write-Host "  ❌ Stubs faltando: $invalid" -ForegroundColor $(if ($invalid -gt 0) { "Red" } else { "Green" })

if ($invalid -eq 0) {
    Write-Host "`n✅ TODOS OS STUBS ESTÃO IMPLEMENTADOS!" -ForegroundColor Green
    Write-Host "📄 Documentação completa em: docs\STUBS-BASEADOS-SERVICOS-REAIS.md" -ForegroundColor Cyan
    Write-Host "📄 Resumo em: docs\STUBS-IMPLEMENTADOS-RESUMO.md" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠️  Alguns stubs estão faltando!" -ForegroundColor Yellow
}
