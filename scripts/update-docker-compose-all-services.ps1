# Script para atualizar docker-compose.yml com todos os novos serviços

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🐳 ATUALIZANDO DOCKER COMPOSE COM TODOS OS SERVIÇOS 🐳    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$dockerComposePath = Join-Path $baseDir "infra/docker-compose.yml"

# Ler docker-compose.yml atual
$dockerComposeContent = Get-Content $dockerComposePath -Raw

# Serviços a adicionar
$newServices = @(
    @{Name="payments-orchestrator"; Port=8092},
    @{Name="acquirer-adapter"; Port=8093},
    @{Name="risk-service"; Port=8094},
    @{Name="support-service"; Port=8095},
    @{Name="settlement-service"; Port=8096},
    @{Name="recon-service"; Port=8097},
    @{Name="device-service"; Port=8098},
    @{Name="audit-service"; Port=8099},
    @{Name="notification-service"; Port=8100},
    @{Name="kyc-service"; Port=8101},
    @{Name="kyb-service"; Port=8102},
    @{Name="privacy-service"; Port=8103},
    @{Name="acquirer-stub"; Port=8104},
    @{Name="webhook-receiver"; Port=8105}
)

# Template de serviço
function Get-ServiceTemplate {
    param(
        [string]$ServiceName,
        [int]$Port
    )
    
    $serviceNameClean = $ServiceName.Replace('-', '')
    
    $serviceNameEscaped = $ServiceName
    return @"
  ${serviceNameEscaped}:
    build:
      context: ../services/${serviceNameEscaped}
      dockerfile: Dockerfile
    container_name: benefits-${serviceNameEscaped}
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SERVER_PORT: $Port
      CORE_SERVICE_URL: http://benefits-core:8091
      CORE_SERVICE_API_KEY: core-service-secret-key
    ports:
      - "$Port`:$Port"
    depends_on:
      benefits-core:
        condition: service_healthy
      postgres:
        condition: service_healthy
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:$Port/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

"@
}

# Encontrar onde inserir (antes do fechamento de services)
$insertPosition = $dockerComposeContent.LastIndexOf("  sms-inbox:")

if ($insertPosition -eq -1) {
    Write-Host "✗ Não foi possível encontrar posição de inserção" -ForegroundColor Red
    exit 1
}

# Encontrar fim do serviço sms-inbox
$afterSmsInbox = $dockerComposeContent.Substring($insertPosition)
$endOfSmsInbox = $afterSmsInbox.IndexOf("volumes:")
if ($endOfSmsInbox -eq -1) {
    $endOfSmsInbox = $afterSmsInbox.IndexOf("networks:")
}

$insertPos = $insertPosition + $endOfSmsInbox

# Construir conteúdo dos novos serviços
$newServicesContent = ""
foreach ($service in $newServices) {
    $newServicesContent += Get-ServiceTemplate -ServiceName $service.Name -Port $service.Port
    Write-Host "  ✓ Adicionado $($service.Name)" -ForegroundColor Green
}

# Inserir novos serviços
$newDockerComposeContent = $dockerComposeContent.Insert($insertPos, $newServicesContent)

# Salvar
Set-Content -Path $dockerComposePath -Value $newDockerComposeContent -Encoding UTF8

Write-Host "`n✅ Docker Compose atualizado com sucesso!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Implementar lógica básica em cada serviço" -ForegroundColor White
Write-Host "  2. Testar build: docker-compose build" -ForegroundColor White
Write-Host "  3. Subir serviços: docker-compose up -d" -ForegroundColor White
Write-Host ""
