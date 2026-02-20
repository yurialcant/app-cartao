# Script completo para validar TODOS os projetos
# Verifica: Dockerfiles, docker-compose, application.yml, Feign Clients, Stubs, etc.

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║   🔍 VALIDAÇÃO COMPLETA DE TODOS OS PROJETOS 🔍              ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$warnings = @()
$success = @()

# Lista de todos os serviços esperados
$expectedServices = @(
    @{Name="benefits-core"; Port=8091; Type="Core"; HasDb=$true},
    @{Name="user-bff"; Port=8082; Type="BFF"; HasDb=$false},
    @{Name="admin-bff"; Port=8083; Type="BFF"; HasDb=$false},
    @{Name="merchant-bff"; Port=8084; Type="BFF"; HasDb=$false},
    @{Name="merchant-portal-bff"; Port=8085; Type="BFF"; HasDb=$false},
    @{Name="employer-bff"; Port=8086; Type="BFF"; HasDb=$false},
    @{Name="payments-orchestrator"; Port=8092; Type="Service"; HasDb=$false},
    @{Name="acquirer-adapter"; Port=8093; Type="Service"; HasDb=$false},
    @{Name="risk-service"; Port=8094; Type="Service"; HasDb=$false},
    @{Name="support-service"; Port=8095; Type="Service"; HasDb=$false},
    @{Name="settlement-service"; Port=8096; Type="Service"; HasDb=$false},
    @{Name="recon-service"; Port=8097; Type="Service"; HasDb=$false},
    @{Name="device-service"; Port=8098; Type="Service"; HasDb=$false},
    @{Name="audit-service"; Port=8099; Type="Service"; HasDb=$false},
    @{Name="notification-service"; Port=8100; Type="Service"; HasDb=$false},
    @{Name="kyc-service"; Port=8101; Type="Service"; HasDb=$false},
    @{Name="kyb-service"; Port=8102; Type="Service"; HasDb=$false},
    @{Name="privacy-service"; Port=8103; Type="Service"; HasDb=$false},
    @{Name="acquirer-stub"; Port=8104; Type="Stub"; HasDb=$false},
    @{Name="webhook-receiver"; Port=8105; Type="Service"; HasDb=$false},
    @{Name="tenant-service"; Port=8106; Type="Service"; HasDb=$true},
    @{Name="employer-service"; Port=8107; Type="Service"; HasDb=$true}
)

Write-Host "[1/6] Verificando Dockerfiles..." -ForegroundColor Yellow
foreach ($service in $expectedServices) {
    $dockerfilePath = Join-Path $script:RootPath "services\$($service.Name)\Dockerfile"
    if (Test-Path $dockerfilePath) {
        $success += "✅ Dockerfile: $($service.Name)"
    } else {
        $issues += "❌ Dockerfile faltando: $($service.Name)"
    }
}

Write-Host "`n[2/6] Verificando pom.xml..." -ForegroundColor Yellow
foreach ($service in $expectedServices) {
    $pomPath = Join-Path $script:RootPath "services\$($service.Name)\pom.xml"
    if (Test-Path $pomPath) {
        $success += "✅ pom.xml: $($service.Name)"
    } else {
        $issues += "❌ pom.xml faltando: $($service.Name)"
    }
}

Write-Host "`n[3/6] Verificando application.yml..." -ForegroundColor Yellow
foreach ($service in $expectedServices) {
    $appYmlPath = Join-Path $script:RootPath "services\$($service.Name)\src\main\resources\application.yml"
    if (Test-Path $appYmlPath) {
        $content = Get-Content $appYmlPath -Raw
        if ($content -match "server:\s*port:\s*$($service.Port)") {
            $success += "✅ application.yml com porta correta: $($service.Name)"
        } else {
            $warnings += "⚠️  application.yml sem porta $($service.Port): $($service.Name)"
        }
    } else {
        $issues += "❌ application.yml faltando: $($service.Name)"
    }
}

Write-Host "`n[4/6] Verificando docker-compose.yml..." -ForegroundColor Yellow
$dockerComposePath = Join-Path $script:RootPath "infra\docker-compose.yml"
if (Test-Path $dockerComposePath) {
    $dockerComposeContent = Get-Content $dockerComposePath -Raw
    foreach ($service in $expectedServices) {
        $serviceName = $service.Name -replace '-', '_'
        if ($dockerComposeContent -match $service.Name -or $dockerComposeContent -match $serviceName) {
            $success += "✅ docker-compose.yml: $($service.Name)"
        } else {
            $issues += "❌ docker-compose.yml faltando: $($service.Name)"
        }
    }
} else {
    $issues += "❌ docker-compose.yml não encontrado"
}

Write-Host "`n[5/6] Verificando Feign Clients..." -ForegroundColor Yellow
$bffs = @("user-bff", "admin-bff", "merchant-bff", "merchant-portal-bff", "employer-bff")
foreach ($bff in $bffs) {
    $bffPath = Join-Path $script:RootPath "services\$bff\src\main\java"
    if (Test-Path $bffPath) {
        $clientFiles = Get-ChildItem -Path $bffPath -Recurse -Filter "*Client.java" -ErrorAction SilentlyContinue
        if ($clientFiles.Count -gt 0) {
            $success += "✅ Feign Clients encontrados: $bff ($($clientFiles.Count) clients)"
        } else {
            $warnings += "⚠️  Nenhum Feign Client encontrado: $bff"
        }
    }
}

Write-Host "`n[6/6] Verificando integração com stubs..." -ForegroundColor Yellow
# Verificar se acquirer-adapter usa acquirer-stub
$acquirerAdapterPath = Join-Path $script:RootPath "services\acquirer-adapter\src\main\java\com\benefits\acquireradapter\service\AcquirerService.java"
if (Test-Path $acquirerAdapterPath) {
    $content = Get-Content $acquirerAdapterPath -Raw
    if ($content -match "acquirer-stub" -or $content -match "stubBaseUrl") {
        $success += "✅ acquirer-adapter integrado com acquirer-stub"
    } else {
        $issues += "❌ acquirer-adapter não está usando acquirer-stub"
    }
}

# Verificar se notification-service tem providers
$notificationServicePath = Join-Path $script:RootPath "services\notification-service\src\main\java\com\benefits\notificationservice\service\NotificationService.java"
if (Test-Path $notificationServicePath) {
    $content = Get-Content $notificationServicePath -Raw
    if ($content -match "TwilioSmsProvider|AwsSnsSmsProvider|FcmPushProvider|ApnsPushProvider") {
        $success += "✅ notification-service tem providers configurados"
    } else {
        $warnings += "⚠️  notification-service pode não ter providers configurados"
    }
}

# Verificar se kyc-service usa providers
$kycServicePath = Join-Path $script:RootPath "services\kyc-service\src\main\java\com\benefits\kycservice\service\KycService.java"
if (Test-Path $kycServicePath) {
    $content = Get-Content $kycServicePath -Raw
    if ($content -match "SerproKycProvider|SerasaKycProvider|FaceTecBiometricProvider") {
        $success += "✅ kyc-service usa providers de KYC"
    } else {
        $warnings += "⚠️  kyc-service pode não estar usando providers"
    }
}

# Verificar se kyb-service usa ReceitaWS
$kybServicePath = Join-Path $script:RootPath "services\kyb-service\src\main\java\com\benefits\kybservice\service\KybService.java"
if (Test-Path $kybServicePath) {
    $content = Get-Content $kybServicePath -Raw
    if ($content -match "ReceitaWsKybProvider") {
        $success += "✅ kyb-service usa ReceitaWS provider"
    } else {
        $warnings += "⚠️  kyb-service pode não estar usando ReceitaWS"
    }
}

# Verificar se payments-orchestrator tem Feign Clients
$paymentsOrchPath = Join-Path $script:RootPath "services\payments-orchestrator\src\main\java"
if (Test-Path $paymentsOrchPath) {
    $clientFiles = Get-ChildItem -Path $paymentsOrchPath -Recurse -Filter "*Client.java" -ErrorAction SilentlyContinue
    if ($clientFiles.Count -gt 0) {
        $success += "✅ payments-orchestrator tem Feign Clients ($($clientFiles.Count) clients)"
    } else {
        $warnings += "⚠️  payments-orchestrator pode não ter Feign Clients"
    }
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    RESUMO DA VALIDAÇÃO                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if ($success.Count -gt 0) {
    Write-Host "✅ SUCESSOS ($($success.Count)):" -ForegroundColor Green
    $success | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    if ($success.Count -gt 10) {
        Write-Host "  ... e mais $($success.Count - 10) sucessos" -ForegroundColor Gray
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  AVISOS ($($warnings.Count)):" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}

if ($issues.Count -gt 0) {
    Write-Host "`n❌ PROBLEMAS ($($issues.Count)):" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

Write-Host "`n📊 ESTATÍSTICAS:" -ForegroundColor Cyan
Write-Host "  Total de serviços esperados: $($expectedServices.Count)" -ForegroundColor White
Write-Host "  ✅ Sucessos: $($success.Count)" -ForegroundColor Green
Write-Host "  ⚠️  Avisos: $($warnings.Count)" -ForegroundColor Yellow
Write-Host "  ❌ Problemas: $($issues.Count)" -ForegroundColor Red

if ($issues.Count -eq 0) {
    Write-Host "`n✅ TODOS OS PROJETOS ESTÃO APTOS PARA RODAR!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  CORRIJA OS PROBLEMAS ANTES DE RODAR!" -ForegroundColor Yellow
}
