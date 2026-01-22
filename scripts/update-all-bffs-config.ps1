# Script para atualizar configurações de todos os BFFs com URLs dos serviços

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     ⚙️  ATUALIZANDO CONFIGURAÇÕES DOS BFFs ⚙️                  ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot

# Configurações por BFF
$bffConfigs = @{
    "user-bff" = @{
        Services = @(
            @{Name="device-service"; Url="http://device-service:8098"},
            @{Name="risk-service"; Url="http://risk-service:8094"},
            @{Name="support-service"; Url="http://support-service:8095"},
            @{Name="notification-service"; Url="http://notification-service:8100"},
            @{Name="payments-orchestrator"; Url="http://payments-orchestrator:8092"},
            @{Name="privacy-service"; Url="http://privacy-service:8103"}
        )
    }
    "admin-bff" = @{
        Services = @(
            @{Name="kyc-service"; Url="http://kyc-service:8101"},
            @{Name="kyb-service"; Url="http://kyb-service:8102"},
            @{Name="settlement-service"; Url="http://settlement-service:8096"},
            @{Name="recon-service"; Url="http://recon-service:8097"},
            @{Name="support-service"; Url="http://support-service:8095"},
            @{Name="risk-service"; Url="http://risk-service:8094"},
            @{Name="audit-service"; Url="http://audit-service:8099"}
        )
    }
    "merchant-bff" = @{
        Services = @(
            @{Name="payments-orchestrator"; Url="http://payments-orchestrator:8092"},
            @{Name="acquirer-adapter"; Url="http://acquirer-adapter:8093"},
            @{Name="risk-service"; Url="http://risk-service:8094"}
        )
    }
}

foreach ($bffName in $bffConfigs.Keys) {
    $config = $bffConfigs[$bffName]
    $ymlPath = Join-Path $baseDir "services/$bffName/src/main/resources/application-dev.yml"
    
    if (-not (Test-Path $ymlPath)) {
        Write-Host "  ⚠ $bffName/application-dev.yml não encontrado" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  Atualizando $bffName..." -ForegroundColor Yellow
    
    $ymlContent = Get-Content $ymlPath -Raw
    
    # Adicionar configurações de serviços
    $servicesConfig = "`n# URLs dos serviços especializados`n"
    foreach ($service in $config.Services) {
        $serviceKey = $service.Name.Replace('-', '')
        $servicesConfig += "$serviceKey`:`n"
        $servicesConfig += "  service:`n"
        $servicesConfig += "    url: $($service.Url)`n"
    }
    
    # Verificar se já existe
    if ($ymlContent -notmatch "# URLs dos serviços especializados") {
        $ymlContent += $servicesConfig
        Set-Content -Path $ymlPath -Value $ymlContent -Encoding UTF8
        Write-Host "    ✓ Configurações adicionadas" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ Configurações já existem" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Configurações atualizadas!" -ForegroundColor Green
Write-Host ""
