# Script para limpar e corrigir docker-compose.yml completamente

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔧 CORRIGINDO DOCKER-COMPOSE.YML 🔧                       ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$dockerComposePath = Join-Path $baseDir "infra/docker-compose.yml"

# Ler o arquivo atual e extrair apenas serviços únicos
$content = Get-Content $dockerComposePath -Raw

# Criar novo docker-compose.yml limpo
$cleanCompose = @"
services:
  postgres:
    image: postgres:16-alpine
    container_name: benefits-postgres
    environment:
      POSTGRES_DB: benefits
      POSTGRES_USER: benefits
      POSTGRES_PASSWORD: benefits123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: [ "CMD-SHELL", "pg_isready -U benefits" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  keycloak:
    image: quay.io/keycloak/keycloak:26.4.7
    container_name: benefits-keycloak
    command: start-dev --import-realm
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/benefits
      KC_DB_USERNAME: benefits
      KC_DB_PASSWORD: benefits123
      KC_HOSTNAME_STRICT: false
      KC_HTTP_ENABLED: true
      KC_HOSTNAME: auth.benefits.test
      KC_HOSTNAME_PORT: 8080
    ports:
      - "8081:8080"
    volumes:
      - ./keycloak/realm-benefits.json:/opt/keycloak/data/import/realm-benefits.json
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - benefits-network

  localstack:
    image: localstack/localstack:3.0
    container_name: benefits-localstack
    environment:
      - SERVICES=s3,sqs,sns,secretsmanager,ssm
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
      - DOCKER_HOST=unix:///var/run/docker.sock
      - PERSISTENCE=1
    ports:
      - "4566:4566"
      - "4510-4559:4510-4559"
    volumes:
      - localstack_data:/var/lib/localstack
      - "/var/run/docker.sock:/var/run/docker.sock"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4566/_localstack/health"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  sms-inbox:
    image: nginx:alpine
    container_name: benefits-sms-inbox
    ports:
      - "8082:80"
    volumes:
      - ./sms-inbox:/usr/share/nginx/html:ro
    networks:
      - benefits-network

  benefits-core:
    build:
      context: ../services/benefits-core
      dockerfile: Dockerfile
    container_name: benefits-core
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/benefits
      SPRING_DATASOURCE_USERNAME: benefits
      SPRING_DATASOURCE_PASSWORD: benefits123
      SERVER_PORT: 8091
      CORE_SERVICE_API_KEY: core-service-secret-key
    ports:
      - "8091:8091"
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:8091/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  user-bff:
    build:
      context: ../services/user-bff
      dockerfile: Dockerfile
    container_name: benefits-user-bff
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/benefits
      SPRING_DATASOURCE_USERNAME: benefits
      SPRING_DATASOURCE_PASSWORD: benefits123
      KEYCLOAK_ISSUER_URI: http://keycloak:8080/realms/benefits
      SERVER_PORT: 8080
      CORE_SERVICE_URL: http://benefits-core:8091
      CORE_SERVICE_API_KEY: core-service-secret-key
      AWS_ENDPOINT_URL: http://localstack:4566
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_REGION: us-east-1
      SMS_PROVIDER: stub
      SERVER_HOSTNAME: api.benefits.test
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
      keycloak:
        condition: service_started
      benefits-core:
        condition: service_healthy
      localstack:
        condition: service_started
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  admin-bff:
    build:
      context: ../services/admin-bff
      dockerfile: Dockerfile
    container_name: benefits-admin-bff
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KEYCLOAK_ISSUER_URI: http://keycloak:8080/realms/benefits
      SERVER_PORT: 8083
      CORE_SERVICE_URL: http://benefits-core:8091
      CORE_SERVICE_API_KEY: core-service-secret-key
    ports:
      - "8083:8083"
    depends_on:
      benefits-core:
        condition: service_healthy
      keycloak:
        condition: service_started
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:8083/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  merchant-bff:
    build:
      context: ../services/merchant-bff
      dockerfile: Dockerfile
    container_name: benefits-merchant-bff
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KEYCLOAK_ISSUER_URI: http://keycloak:8080/realms/benefits
      SERVER_PORT: 8084
      CORE_SERVICE_URL: http://benefits-core:8091
      CORE_SERVICE_API_KEY: core-service-secret-key
    ports:
      - "8084:8084"
    depends_on:
      benefits-core:
        condition: service_healthy
      keycloak:
        condition: service_started
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:8084/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  merchant-portal-bff:
    build:
      context: ../services/merchant-portal-bff
      dockerfile: Dockerfile
    container_name: benefits-merchant-portal-bff
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KEYCLOAK_ISSUER_URI: http://keycloak:8080/realms/benefits
      SERVER_PORT: 8085
      CORE_SERVICE_URL: http://benefits-core:8091
      CORE_SERVICE_API_KEY: core-service-secret-key
    ports:
      - "8085:8085"
    depends_on:
      benefits-core:
        condition: service_healthy
      keycloak:
        condition: service_started
    healthcheck:
      test: [ "CMD-SHELL", "curl -f http://localhost:8085/actuator/health || exit 1" ]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - benefits-network

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - benefits-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - benefits-network
    depends_on:
      - prometheus

volumes:
  postgres_data:
  localstack_data:
  grafana-data:

networks:
  benefits-network:
    driver: bridge
"@

Set-Content -Path $dockerComposePath -Value $cleanCompose -Encoding UTF8
Write-Host "  ✓ docker-compose.yml limpo e corrigido" -ForegroundColor Green

# Validar sintaxe
Write-Host "`n  Validando sintaxe YAML..." -ForegroundColor Yellow
try {
    $validation = docker-compose -f $dockerComposePath config 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Sintaxe YAML válida" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Erro na sintaxe: $validation" -ForegroundColor Red
    }
} catch {
    Write-Host "  ⚠ Não foi possível validar (docker-compose pode não estar disponível)" -ForegroundColor Yellow
}

Write-Host "`n✅ Docker Compose corrigido!" -ForegroundColor Green
Write-Host ""
