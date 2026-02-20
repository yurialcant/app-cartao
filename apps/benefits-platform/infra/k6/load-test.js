import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Configuração
const KEYCLOAK_URL = __ENV.KEYCLOAK_URL || 'http://localhost:8081';
const BFF_URL = __ENV.BFF_URL || 'http://localhost:8080';
const REALM = 'benefits';
const CLIENT_ID = 'k6-dev';
const CLIENT_SECRET = 'k6-dev-secret';
const USERNAME = __ENV.USERNAME || 'user1';
const PASSWORD = __ENV.PASSWORD || 'Passw0rd!';

// Função para obter token
function getToken() {
  const tokenUrl = `${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/token`;
  
  const params = {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    username: USERNAME,
    password: PASSWORD,
    grant_type: 'password',
  };

  const response = http.post(tokenUrl, params);
  
  if (response.status === 200) {
    const body = JSON.parse(response.body);
    return body.access_token;
  }
  
  console.error(`Failed to get token: ${response.status} - ${response.body}`);
  return null;
}

// Seed: gerar transações
export function setup() {
  console.log('Setting up test data...');
  
  const token = getToken();
  if (!token) {
    throw new Error('Failed to get token in setup');
  }

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // Gera 1000 transações
  const generateUrl = `${BFF_URL}/dev/transactions/generate?count=1000`;
  const generateResponse = http.post(generateUrl, null, { headers });
  
  if (generateResponse.status === 200) {
    console.log('Test data generated successfully');
  } else {
    console.error(`Failed to generate test data: ${generateResponse.status}`);
  }

  return { token };
}

// Cenário principal: carga de leitura
export default function (data) {
  const token = data.token;
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // 70% wallet summary, 30% transactions
  const rand = Math.random();
  
  if (rand < 0.7) {
    // GET /wallets/summary
    const walletResponse = http.get(`${BFF_URL}/wallets/summary`, { headers });
    const walletSuccess = check(walletResponse, {
      'wallet summary status is 200': (r) => r.status === 200,
    });
    errorRate.add(!walletSuccess);
  } else {
    // GET /transactions?limit=10
    const transactionsResponse = http.get(`${BFF_URL}/transactions?limit=10`, { headers });
    const transactionsSuccess = check(transactionsResponse, {
      'transactions status is 200': (r) => r.status === 200,
    });
    errorRate.add(!transactionsSuccess);
  }

  sleep(1);
}

// Spike test (opcional)
export function spikeTest(data) {
  const token = data.token;
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  const walletResponse = http.get(`${BFF_URL}/wallets/summary`, { headers });
  check(walletResponse, {
    'spike wallet status is 200': (r) => r.status === 200,
  });
}

// Configuração de opções
export const options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up: 10 usuários em 2 min
    { duration: '5m', target: 10 },    // Mantém: 10 usuários por 5 min
    { duration: '1m', target: 100 },  // Spike: 100 usuários em 1 min
    { duration: '2m', target: 10 },   // Ramp down: volta para 10
    { duration: '1m', target: 0 },    // Finaliza
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% das requisições < 500ms
    http_req_failed: ['rate<0.01'],    // Taxa de erro < 1%
    errors: ['rate<0.01'],
  },
};

