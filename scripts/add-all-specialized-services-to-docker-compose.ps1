# Script para adicionar todos os serviços especializados ao docker-compose.yml

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║  🐳 ADICIONANDO TODOS OS SERVIÇOS ESPECIALIZADOS 🐳         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$dockerComposePath = Join-Path $baseDir "infra/docker-compose.yml"

# Ler docker-compose.yml atual
$dockerComposeContent = Get-Content $dockerComposePath -Raw

# Serviços especializados a adicionar
$services = @(
    @{Name="payments-orchestrator"; Port=8092; DependsOn=@("benefits-core")},
    @{Name="acquirer-adapter"; Port=8093; DependsOn=@("benefits-core", "acquirer-stub")},
    @{Name="risk-service"; Port=8094; DependsOn=@("benefits-core")},
    @{Name="support-service"; Port=8095; DependsOn=@("benefits-core")},
    @{Name="settlement-service"; Port=8096; DependsOn=@("benefits-core", "recon-service")},
    @{Name="recon-service"; Port=8097; DependsOn=@("benefits-core")},
    @{Name="device-service"; Port=8098; DependsOn=@("benefits-core")},
    @{Name="audit-service"; Port=8099; DependsOn=@("benefits-core")},
    @{Name="notification-service"; Port=8100; DependsOn=@("benefits-core", "localstack")},
    @{Name="kyc-service"; Port=8101; DependsOn=@("benefits-core")},
    @{Name="kyb-service"; Port=8102; DependsOn=@("benefits-core")},
    @{Name="privacy-service"; Port=8103; DependsOn=@("benefits-core")},
    @{Name="acquirer-stub"; Port=8104; DependsOn=@("benefits-core")},
    @{Name="webhook-receiver"; Port=8105; DependsOn=@("benefits-core", "acquirer-adapter")}
)

# Template de serviço
function Get-ServiceYaml {
    param(
        [string]$ServiceName,
        [int]$Port,
        [string[]]$DependsOn
    )
    
    $dependsOnYaml = ""
    if ($DependsOn.Count -gt 0) {
        $dependsOnList = $DependsOn | ForEach-Object { "`n        $_:" }
        $dependsOnYaml = "`n    depends_on:`n" + ($dependsOnList -join "`n          condition: service_healthy`n")
        if ($DependsOn.Count -gt 0) {
            $dependsOnYaml = $dependsOnYaml -replace "`n        ([^:]+):", "`n        `$1:`n          condition: service_healthy"
        }
    }
    
    $serviceYaml = @"
  $($ServiceName -replace '-', '-'):
    build:
      context: ../services/$ServiceName
      dockerfile: Dockerfile
    container_name: benefits-$($ServiceName -replace '-', '-')
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/benefits
      SPRING_DATASOURCE_USERNAME: benefits
      SPRING_DATASOURCE_PASSWORD: benefits123
      KEYCLOAK_ISSUER_URI: http://keycloak:8080/realms/benefits
      SERVER_PORT: $Port
      CORE_SERVICE_URL: http://benefits-core:8091
      CORE_SERVICE_API_KEY: core-service-secret-key$dependsOnYaml
    ports:
      - "$Port:$Port"
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:$Port/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

"@
    return $serviceYaml
}

# Encontrar onde inserir (antes do prometheus)
$insertMarker = "  prometheus:"
$servicesYaml = ""
foreach ($service in $services) {
    Write-Host "  ✅ Adicionando $($service.Name) (porta $($service.Port))..." -ForegroundColor Green
    $servicesYaml += Get-ServiceYaml -ServiceName $service.Name -Port $service.Port -DependsOn $service.DependsOn
}

# Inserir antes do prometheus
if ($dockerComposeContent -match $insertMarker) {
    $dockerComposeContent = $dockerComposeContent -replace ([regex]::Escape($insertMarker)), ($servicesYaml + $insertMarker)
    Write-Host "`n✅ Serviços adicionados ao docker-compose.yml!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Marcador não encontrado, adicionando antes do volumes..." -ForegroundColor Yellow
    $volumesMarker = "volumes:"
    $dockerComposeContent = $dockerComposeContent -replace ([regex]::Escape($volumesMarker)), ($servicesYaml + $volumesMarker)
}

# Salvar arquivo
$dockerComposeContent | Set-Content $dockerComposePath -Encoding UTF8

Write-Host "`n✅ Docker Compose atualizado com todos os serviços especializados!" -ForegroundColor Green
Write-Host "`n📋 Serviços adicionados:" -ForegroundColor Cyan
foreach ($service in $services) {
    Write-Host "   • $($service.Name) - porta $($service.Port)" -ForegroundColor White
}
