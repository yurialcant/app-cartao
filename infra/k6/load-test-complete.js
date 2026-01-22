import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 10, // 10 usuários virtuais
  duration: '30s', // Teste de 30 segundos

  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% das requests < 500ms
    http_req_failed: ['rate<0.1'], // < 10% de falhas
  },
};

export default function () {
  // Teste de health check
  let response = http.get('http://localhost:8091/actuator/health');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  // Teste de API funcional
  response = http.get('http://localhost:8091/internal/batches/credits?page=1&size=10');
  check(response, {
    'API response is 200': (r) => r.status === 200,
  });

  sleep(1); // Pausa de 1 segundo entre requests
}
