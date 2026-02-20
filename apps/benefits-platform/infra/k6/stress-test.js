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
  const healthRes = http.get(\\/actuator/health\);
  check(healthRes, {
    'health check status 200': (r) => r.status === 200,
  });
  
  sleep(0.1);
}
