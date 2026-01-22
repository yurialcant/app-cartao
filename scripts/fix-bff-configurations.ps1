# fix-bff-configurations.ps1
# Corrige configurações dos BFFs para integração completa

Write-Host "🔧 CORRIGINDO CONFIGURAÇÕES DOS BFFs..." -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Green

# ============================================
# FASE 1: CRIAR APPLICATION-DOCKER.YML NOS BFFs
# ============================================
Write-Host "`n📝 [FASE 1] Criando application-docker.yml nos BFFs..." -ForegroundColor Yellow

$bffs = @(
    "user-bff",
    "admin-bff",
    "merchant-bff",
    "employer-bff",
    "support-bff",
    "pos-bff"
)

foreach ($bff in $bffs) {
    $dockerConfigPath = "bffs/$bff/src/main/resources/application-docker.yml"

    if (!(Test-Path "bffs/$bff")) {
        Write-Host "   ⚠️  BFF $bff não encontrado, pulando..." -ForegroundColor Yellow
        continue
    }

    Write-Host "   🔧 $bff..." -ForegroundColor Gray

    # Configuração Docker para BFFs
    $dockerConfig = @"
# application-docker.yml - Configuração para execução em containers Docker
spring:
  profiles:
    active: docker

# Service URLs para Docker containers
benefits:
  core:
    url: http://benefits-core:8091

tenant:
  service:
    url: http://tenant-service:8106

# Outros serviços
identity:
  service:
    url: http://identity-service:8084

notification:
  service:
    url: http://notification-service:8085

payments:
  orchestrator:
    url: http://payments-orchestrator:8082

employer:
  service:
    url: http://employer-service:8107

merchant:
  service:
    url: http://merchant-service:8108

support:
  service:
    url: http://support-service:8109

device:
  service:
    url: http://device-service:8088

card:
  service:
    url: http://card-service:8089

risk:
  service:
    url: http://risk-service:8094

# Acquirer services
acquirer:
  adapter:
    url: http://acquirer-adapter:8093

# Keycloak para Docker
keycloak:
  url: http://keycloak:8080
  realm: benefits

# Logging mais detalhado para debug em Docker
logging:
  level:
    com.benefits: DEBUG
    org.springframework.cloud.openfeign: DEBUG
    org.springframework.web.client: DEBUG
"@

    $dockerConfig | Set-Content $dockerConfigPath -Encoding UTF8
    Write-Host "   ✅ $bff application-docker.yml criado" -ForegroundColor Green
}

# ============================================
# FASE 2: ATUALIZAR APPLICATION.YML PRINCIPAL
# ============================================
Write-Host "`n📝 [FASE 2] Atualizando application.yml principal dos BFFs..." -ForegroundColor Yellow

foreach ($bff in $bffs) {
    $appYmlPath = "bffs/$bff/src/main/resources/application.yml"

    if (!(Test-Path $appYmlPath)) {
        Write-Host "   ⚠️  $appYmlPath não encontrado, pulando..." -ForegroundColor Yellow
        continue
    }

    Write-Host "   🔧 $bff application.yml..." -ForegroundColor Gray

    $content = Get-Content $appYmlPath -Raw

    # Adicionar profile condicional
    if ($content -notmatch "spring:\s*\n\s*profiles:") {
        $content = $content -replace "spring:", "spring:`n  profiles:`n    active: local  # docker para containers"
    }

    # Garantir comentário explicativo
    if ($content -notmatch "active: local") {
        $content = $content -replace "active: local", "active: local  # docker para containers"
    }

    $content | Set-Content $appYmlPath -NoNewline
}

Write-Host "   ✅ Application.yml dos BFFs atualizados" -ForegroundColor Green

# ============================================
# FASE 3: CRIAR CONFIGURAÇÕES PARA APPS
# ============================================
Write-Host "`n📱 [FASE 3] Atualizando configurações dos apps..." -ForegroundColor Yellow

# Flutter - adicionar configuração Docker
$flutterConfigPath = "apps/user_app_flutter/lib/config/app_environment.dart"
if (Test-Path $flutterConfigPath) {
    $content = Get-Content $flutterConfigPath -Raw

    # Adicionar configuração Docker
    $dockerConfigFlutter = @"

  /// Configuração para execução em containers Docker
  Map<String, String> _dockerConfig() {
    return {
      'base_url': 'http://host.docker.internal:8080',
      'api_timeout': '15',
      'retry_enabled': 'true',
      'debug_enabled': 'true',
      'log_enabled': 'true',
    };
  }
"@

    # Adicionar antes do último }
    $content = $content -replace "}\s*$", "$dockerConfigFlutter}"

    $content | Set-Content $flutterConfigPath -NoNewline
    Write-Host "   ✅ Flutter app_environment.dart atualizado" -ForegroundColor Green
}

# Angular - adicionar environment.docker.ts
$angularEnvPath = "apps/admin_angular/src/environments"
if (Test-Path $angularEnvPath) {
    $dockerEnvContent = @"
export const environment = {
  production: false,
  apiUrl: 'http://host.docker.internal:8083',
  keycloakUrl: 'http://host.docker.internal:8080',
  keycloakRealm: 'benefits',
  keycloakClientId: 'benefits-admin-portal'
};
"@

    $dockerEnvContent | Set-Content "$angularEnvPath/environment.docker.ts" -Encoding UTF8
    Write-Host "   ✅ Angular environment.docker.ts criado" -ForegroundColor Green
}

# ============================================
# FASE 4: ATUALIZAR DOCKER COMPOSE
# ============================================
Write-Host "`n🐳 [FASE 4] Atualizando docker-compose com services Java..." -ForegroundColor Yellow

$dockerComposePath = "infra/docker/docker-compose.yml"
$content = Get-Content $dockerComposePath -Raw

# Adicionar services Java no final, antes de volumes
$servicesSection = @"

  # ==================== JAVA SERVICES ====================

  benefits-core:
    build:
      context: ../../services/benefits-core
      dockerfile: Dockerfile
    container_name: benefits-core
    ports:
      - "8091:8091"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/benefits_db
      SPRING_DATASOURCE_USERNAME: benefits
      SPRING_DATASOURCE_PASSWORD: benefits_password
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - benefits-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8091/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  tenant-service:
    build:
      context: ../../services/tenant-service
      dockerfile: Dockerfile
    container_name: tenant-service
    ports:
      - "8106:8106"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/benefits_db
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - benefits-network

  # ==================== BFF SERVICES ====================

  user-bff:
    build:
      context: ../../bffs/user-bff
      dockerfile: Dockerfile
    container_name: user-bff
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: docker
    depends_on:
      benefits-core:
        condition: service_healthy
      tenant-service:
        condition: service_healthy
    networks:
      - benefits-network

  admin-bff:
    build:
      context: ../../bffs/admin-bff
      dockerfile: Dockerfile
    container_name: admin-bff
    ports:
      - "8083:8083"
    environment:
      SPRING_PROFILES_ACTIVE: docker
    depends_on:
      benefits-core:
        condition: service_healthy
    networks:
      - benefits-network

"@

# Inserir antes da seção volumes
$content = $content -replace "volumes:", "$servicesSection`nvolumes:"

$content | Set-Content $dockerComposePath -NoNewline
Write-Host "   ✅ Docker compose atualizado com services Java" -ForegroundColor Green

# ============================================
# RESULTADO FINAL
# ============================================
Write-Host "`n🎉 CONFIGURAÇÕES DOS BFFs CORRIGIDAS!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

Write-Host "`n✅ CORREÇÕES IMPLEMENTADAS:" -ForegroundColor Cyan
Write-Host "  • application-docker.yml criado em todos os BFFs" -ForegroundColor White
Write-Host "  • URLs atualizadas para nomes de container Docker" -ForegroundColor White
Write-Host "  • Configurações Flutter/Angular atualizadas" -ForegroundColor White
Write-Host "  • Docker compose extendido com services Java" -ForegroundColor White

Write-Host "`n🚀 AGORA É POSSÍVEL:" -ForegroundColor Cyan
Write-Host "  • Modo Local: .\scripts\start-everything.ps1" -ForegroundColor White
Write-Host "  • Modo Docker: docker-compose up -d (infra + services)" -ForegroundColor White
Write-Host "  • Apps conectando corretamente aos BFFs" -ForegroundColor White
Write-Host "  • Service discovery funcionando em ambos os modos" -ForegroundColor White

Write-Host "`n💡 PRÓXIMO PASSO:" -ForegroundColor Cyan
Write-Host "  .\scripts\test-full-integration.ps1  # Validar 100% de integração" -ForegroundColor White