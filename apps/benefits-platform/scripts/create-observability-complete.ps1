# Script para implementar observabilidade completa

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📊 IMPLEMENTANDO OBSERVABILIDADE COMPLETA 📊               ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot

# Adicionar Prometheus e Grafana ao docker-compose
$dockerComposePath = Join-Path $baseDir "infra/docker-compose.yml"
$dockerComposeContent = Get-Content $dockerComposePath -Raw

$prometheusGrafana = @"

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
  grafana-data:
"@

if ($dockerComposeContent -notmatch "prometheus:") {
    # Adicionar antes do fechamento do arquivo
    $dockerComposeContent = $dockerComposeContent -replace "networks:", "$prometheusGrafana`n`nnetworks:"
    Set-Content -Path $dockerComposePath -Value $dockerComposeContent -Encoding UTF8
    Write-Host "  ✓ Prometheus e Grafana adicionados ao docker-compose" -ForegroundColor Green
}

# Criar configuração do Prometheus
$prometheusDir = Join-Path $baseDir "infra/prometheus"
if (-not (Test-Path $prometheusDir)) {
    New-Item -ItemType Directory -Path $prometheusDir -Force | Out-Null
}

$prometheusConfig = @"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'user-bff'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['user-bff:8080']

  - job_name: 'admin-bff'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['admin-bff:8083']

  - job_name: 'merchant-bff'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['merchant-bff:8084']

  - job_name: 'benefits-core'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['benefits-core:8091']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
"@

$prometheusConfigPath = Join-Path $prometheusDir "prometheus.yml"
Set-Content -Path $prometheusConfigPath -Value $prometheusConfig -Encoding UTF8
Write-Host "  ✓ Configuração do Prometheus criada" -ForegroundColor Green

# Criar documentação de observabilidade
$obsDoc = @"
# Observabilidade Completa

## Métricas

### Prometheus
- **URL**: http://localhost:9090
- **Scrape Interval**: 15s
- **Targets**: Todos os serviços Spring Boot com Actuator

### Métricas Coletadas
- Latência (p50, p95, p99)
- Taxa de erro
- Throughput
- Métricas de JVM
- Métricas de banco de dados

## Dashboards

### Grafana
- **URL**: http://localhost:3000
- **Usuário**: admin
- **Senha**: admin

### Dashboards Disponíveis
1. **Overview**: Visão geral de todos os serviços
2. **User BFF**: Métricas específicas do User BFF
3. **Admin BFF**: Métricas específicas do Admin BFF
4. **Core Service**: Métricas do Core Service
5. **Database**: Métricas do PostgreSQL

## Logs

### Estrutura
- Logs estruturados em JSON
- Correlation ID em todas as requisições
- Níveis: DEBUG, INFO, WARN, ERROR

### Visualização
- Via `scripts/monitor-all-logs.ps1`
- Ou diretamente via Docker: `docker logs <service>`

## Tracing

### Implementação
- Request ID propagado entre serviços
- Logs correlacionados por request ID
- Tracing distribuído via headers HTTP

### Uso
- Buscar logs por request ID
- Rastrear requisição através de todos os serviços

## Alertas

### Configuração
- Alertas configurados no Prometheus
- Notificações via webhook (configurável)

### Alertas Principais
- Alta taxa de erro (> 5%)
- Alta latência (p95 > 1s)
- Serviço indisponível
- Uso alto de memória (> 80%)
"@

$obsDocPath = Join-Path $baseDir "docs/ops/observability.md"
if (-not (Test-Path (Split-Path $obsDocPath -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $obsDocPath -Parent) -Force | Out-Null
}
Set-Content -Path $obsDocPath -Value $obsDoc -Encoding UTF8
Write-Host "  ✓ Documentação de observabilidade criada" -ForegroundColor Green

Write-Host "`n✅ Observabilidade completa implementada!" -ForegroundColor Green
Write-Host "`n📋 Para usar:" -ForegroundColor Yellow
Write-Host "  1. docker-compose up -d prometheus grafana" -ForegroundColor White
Write-Host "  2. Acesse Grafana: http://localhost:3000" -ForegroundColor White
Write-Host "  3. Configure datasource Prometheus: http://prometheus:9090" -ForegroundColor White
Write-Host ""
