# Script para criar testes de performance e stress

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     ⚡ CRIANDO TESTES DE PERFORMANCE E STRESS ⚡               ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$k6Dir = Join-Path $baseDir "infra/k6"

# Criar testes de performance completos
$loadTest = @"
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 50 },   // Ramp-up
    { duration: '1m', target: 100 },   // Stay at 100 users
    { duration: '30s', target: 200 },  // Spike to 200
    { duration: '1m', target: 200 },   // Stay at 200
    { duration: '30s', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'], // 95% < 500ms, 99% < 1s
    http_req_failed: ['rate<0.01'],                  // Error rate < 1%
    errors: ['rate<0.01'],
  },
};

const BASE_URL = 'http://localhost:8080';

export default function () {
  // Login
  const loginRes = http.post(\`\${BASE_URL}/auth/login\`, JSON.stringify({
    username: 'user1',
    password: 'Passw0rd!'
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const loginSuccess = check(loginRes, {
    'login status 200': (r) => r.status === 200,
  });
  
  if (!loginSuccess) {
    errorRate.add(1);
    return;
  }
  
  const token = JSON.parse(loginRes.body).access_token;
  const headers = {
    'Authorization': \`Bearer \${token}\`,
    'Content-Type': 'application/json',
  };
  
  // Get wallet summary
  const walletRes = http.get(\`\${BASE_URL}/wallets/summary\`, { headers });
  check(walletRes, {
    'wallet status 200': (r) => r.status === 200,
    'wallet response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  // Get transactions
  const transactionsRes = http.get(\`\${BASE_URL}/transactions?limit=10\`, { headers });
  check(transactionsRes, {
    'transactions status 200': (r) => r.status === 200,
    'transactions response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
"@

$loadTestPath = Join-Path $k6Dir "load-test-complete.js"
Set-Content -Path $loadTestPath -Value $loadTest -Encoding UTF8
Write-Host "  ✓ Teste de carga completo criado" -ForegroundColor Green

# Criar teste de stress
$stressTest = @"
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 100 },
    { duration: '30s', target: 500 },
    { duration: '1m', target: 1000 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // Mais tolerante para stress
    http_req_failed: ['rate<0.05'],     // 5% de erro aceitável em stress
  },
};

const BASE_URL = 'http://localhost:8080';

export default function () {
  // Teste simples de health check
  const healthRes = http.get(\`\${BASE_URL}/actuator/health\`);
  check(healthRes, {
    'health check status 200': (r) => r.status === 200,
  });
  
  sleep(0.1);
}
"@

$stressTestPath = Join-Path $k6Dir "stress-test.js"
Set-Content -Path $stressTestPath -Value $stressTest -Encoding UTF8
Write-Host "  ✓ Teste de stress criado" -ForegroundColor Green

# Criar script de execução
$runPerformanceTests = @"
# Script para executar testes de performance

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("load", "stress", "spike")]
    [string]$TestType = "load"
)

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     ⚡ EXECUTANDO TESTES DE PERFORMANCE ⚡                     ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent `$PSScriptRoot
$k6Dir = Join-Path `$baseDir "infra/k6"

switch (`$TestType) {
    "load" {
        Write-Host "Executando teste de carga..." -ForegroundColor Yellow
        k6 run (Join-Path `$k6Dir "load-test-complete.js")
    }
    "stress" {
        Write-Host "Executando teste de stress..." -ForegroundColor Yellow
        k6 run (Join-Path `$k6Dir "stress-test.js")
    }
    "spike" {
        Write-Host "Executando teste de spike..." -ForegroundColor Yellow
        k6 run (Join-Path `$k6Dir "spike-test.js")
    }
}

Write-Host "`n✅ Testes de performance concluídos!" -ForegroundColor Green
"@

$runPerformancePath = Join-Path $baseDir "scripts/run-performance-tests.ps1"
Set-Content -Path $runPerformancePath -Value $runPerformanceTests -Encoding UTF8
Write-Host "  ✓ Script de execução criado" -ForegroundColor Green

# Criar documentação de performance
$perfDoc = @"
# Testes de Performance e Stress

## Tipos de Testes

### 1. Teste de Carga (Load Test)
- **Objetivo**: Verificar comportamento sob carga normal/esperada
- **Cenário**: 50 → 100 → 200 usuários simultâneos
- **Executar**: `.\scripts\run-performance-tests.ps1 -TestType load`

### 2. Teste de Stress (Stress Test)
- **Objetivo**: Encontrar limites do sistema
- **Cenário**: 100 → 500 → 1000 usuários simultâneos
- **Executar**: `.\scripts\run-performance-tests.ps1 -TestType stress`

### 3. Teste de Spike (Spike Test)
- **Objetivo**: Verificar comportamento com aumento súbito de carga
- **Cenário**: 0 → 500 usuários instantaneamente
- **Executar**: `.\scripts\run-performance-tests.ps1 -TestType spike`

## Métricas Coletadas

- **Latência**: p50, p95, p99
- **Taxa de Erro**: Percentual de requisições falhadas
- **Throughput**: Requisições por segundo
- **Tempo de Resposta**: Tempo médio de resposta

## Thresholds

### Load Test
- p95 < 500ms
- p99 < 1000ms
- Taxa de erro < 1%

### Stress Test
- p95 < 2000ms
- Taxa de erro < 5%

## Como Executar

1. Certifique-se de que todos os serviços estão rodando
2. Execute o teste desejado:
   ```powershell
   .\scripts\run-performance-tests.ps1 -TestType load
   ```
3. Analise os resultados no console

## Análise de Resultados

- **Latência alta**: Verificar gargalos (banco, rede, CPU)
- **Alta taxa de erro**: Verificar logs e capacidade do sistema
- **Throughput baixo**: Verificar configurações de conexão e processamento

## Próximos Passos

- Implementar testes de endurance (longa duração)
- Adicionar testes de volume (grande quantidade de dados)
- Criar dashboards de performance no Grafana
"@

$perfDocPath = Join-Path $baseDir "docs/ops/performance-tests.md"
Set-Content -Path $perfDocPath -Value $perfDoc -Encoding UTF8
Write-Host "  ✓ Documentação de performance criada" -ForegroundColor Green

Write-Host "`n✅ Testes de performance criados!" -ForegroundColor Green
Write-Host "`n📋 Para executar:" -ForegroundColor Yellow
Write-Host "  .\scripts\run-performance-tests.ps1 -TestType load" -ForegroundColor White
Write-Host ""
