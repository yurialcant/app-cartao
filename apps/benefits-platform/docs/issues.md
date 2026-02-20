# Issues

1) F05 persistence missing
- Status: resolved ✅
- Impact: Credit batches are in-memory only; lost on restart
- Resolution: Entities + repositories + migrations implemented (V002, V003)

2) Auth tokens mock-only
- Status: open
- Impact: No real JWT validation; scopes not enforced
- Workaround: Keep mock auth for dev; replace with Keycloak integration

3) Smoke coverage minimal
- Status: open
- Impact: No automated assertion for F05 paths
- Workaround: Manual curl per STATUS; expand scripts/smoke.ps1

4) benefits-core não responde após iniciar
- Status: resolved ✅ (2026-01-18 02:10)
- Impact: Validação F05 bloqueada, smoke tests não podem rodar
- Causa: Configuração usava `benefits-postgres:5432` (hostname Docker) mas serviço roda no host Windows
- Resolução: Alterado para `localhost:5432` em `application.properties`
- Resultado: ✅ Serviço está rodando e respondendo na porta 8091

5) F07 Refund endpoint timeout
- Status: resolved ✅ (2026-01-18 17:00)
- Impact: Validação E2E F07 bloqueada, endpoint não responde dentro do timeout
- Causa: Connection pool desabilitado (`spring.r2dbc.pool.enabled=false`) causava problemas de conexão em código reativo R2DBC
- Resolução: Habilitado connection pool em `services/benefits-core/src/main/resources/application.properties` linha 10-13
- Resultado: ✅ Connection pool habilitado, aguardando teste do endpoint
- Próximo: @QA testar endpoint e executar smoke tests F07
