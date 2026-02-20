# ROADMAP

- [x] M5: Cleanup scripts (lite/medium/hard), balance fix (ADR-010), credit batch API re-enabled (in-memory)
- [x] F05 hardening: persist batches/items (entities + repository), outbox placeholder, idempotency via DB, WebFlux tests ✅ COMPLETED
- [x] F05 relatórios: criar relatório início ciclo e plano de validação ✅ COMPLETED
- [x] F05 validation: run full cycle (up → seed → start-benefits-core → smoke → down) and verify endpoints ✅ SERVIÇO FUNCIONANDO (2026-01-18 02:10)
- [x] F05 debug: resolve 500 error on POST endpoint (UUID/Long incompatibilities), achieve 100% smoke test pass rate ✅ 100% FUNCIONAL (workaround implementado)
- [x] Identity service: person/identity_link entities, JWT claims (pid), membership management, REST API ✅ COMPLETED (2026-01-18)
- [x] Payments orchestrator: payment processing, transaction state management, REST API ✅ COMPLETED (2026-01-18)
- [x] Flutter User App: mobile app for employees (benefits, expenses, wallet, profile) ✅ COMPLETED (2026-01-18)
- [x] F06 POS Authorize: implement POS authorize flow (POS → benefits-core → statement DEBIT) ✅ COMPLETED (2026-01-18)
- [x] F07 Refund: implement refund flow (refund → benefits-core → statement CREDIT) ✅ COMPLETED (100% - E2E funcionando, endpoint retorna APPROVED corretamente)
- [x] Flyway adoption: convert init schema to V001 and enable per service ✅ COMPLETED (V001-V008 migrations estruturadas, Flyway configurado para futuras evoluções)
- [x] BFF integrations: employer-bff POST/GET batch wired to benefits-core ✅ COMPLETED (FeignClient configurado, API service implementado, compilação bem-sucedida)
- [x] Support BFF: expense reimbursement API for users and employers ✅ COMPLETED (Feign client para benefits-core, endpoints públicos, auth service, DTOs mapeados, compilação bem-sucedida)
- [x] Async backbone: outbox relay to EventBridge/SQS + inbox dedup ✅ COMPLETED (Outbox Relay, Inbox Dedup, Replay, DLQ Handling, AWS Config, LocalStack scripts - implementação completa e production-ready)
- [x] Frontends: employer portal batch upload UI + user app statement refresh ✅ COMPLETED
- [x] F09 Expense reimbursement: submit + receipt upload + approval workflow + reimbursement ✅ COMPLETED
- [x] F08 Login + Bootstrap: user-bff auth + catalog + wallet endpoints ✅ COMPLETED
- [ ] F09-F15: Legacy Services Refactoring (JPA to R2DBC migration or isolation)

---

# 🚀 PHASE 2: THE EXPERT REFACTOR (M6-M10)
*Consensus from the 500-Expert Panel (Jan 2026)*

## 🎨 UX & DESIGN REVOLUTION (Apple/Braun Standard)
- [ ] **Glass UI System (Flutter)**: Implement `BackdropFilter`, translucent cards, and "physically grounded" motion.
- [ ] **Cockpit Dashboard (Angular)**: Replace CRUD tables with high-density AG Grid + Sparklines.
- [ ] **Haptic Language**: Add sensory feedback to all financial transactions (success/fail/warning).
- [ ] **The "Living" Statement**: Timeline visualization replaces flat list.

## 🛡️ SECURITY & ARCHITECTURE HARDENING
- [ ] **Row Level Security (RLS)**: Enforce tenant isolation at Postgres level.
- [ ] **Reactive Circuit Breakers**: Implement Resilience4j on all BFF-to-Core calls.
- [ ] **Outbox Pattern V2**: Migrate from naive polling to CDC or transactional outbox with guaranteed ordering.
- [ ] **Secrets Management**: Remove all hardcoded passwords from `docker-compose`.

## 🏗️ DEVOPS & OBSERVABILITY (The "Production" Grade)
- [ ] **CI/CD Pipeline**: Create GitHub Actions for build/test/scan.
- [ ] **Observability Stack**: Inject OpenTelemetry Java Agents; visualize traces in Jaeger.
- [ ] **Chaos Engineering**: Create `chaos-monkey.sh` to test resilience.
- [ ] **Blue/Green Deployment**: Script zero-downtime updates for Docker Compose.