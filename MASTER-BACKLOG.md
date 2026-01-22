# MASTER BACKLOG: Multi-Tenant Benefits Platform (M0 → M20)

**Versão**: 1.0  
**Data**: 2026-01-16  
**Status**: Foundation Complete  

---

# 1) CAMPOS CANÔNICOS EM COMUM (Padrão Global)

## 1.1 Identificadores (IDs) – padrão e origem

**Regra:** IDs de domínio são **UUID** (string), exceto quando fizer sentido `slug` (string) e `external_ref` (string).

### IDs usados em quase tudo

* `administrator_id: uuid`
  * **SSOT:** tenant-service
  * **Aparece em:** Platform/Admin portals (exibido), tokens/claims (opcional), eventos (sim), logs (sim)

* `tenant_id: uuid`
  * **SSOT:** tenant-service
  * **Aparece em:** todos os serviços (interno), BFFs (interno), eventos (sim), logs/traces (sim)
  * **Exibido:** normalmente **não** (só no Platform/Admin)

* `employer_id: uuid`
  * **SSOT:** tenant-service (cadastro), com espelho em employer-bff (view)
  * **Exibido:** Employer/Admin (sim), User App (não)

* `user_id: string` (Keycloak `sub`)
  * **SSOT:** Keycloak para identidade; "perfil de negócio" no tenant-service/support-service
  * **Exibido:** depende do canal (Admin sim, Employer sim, User não)

* `merchant_id: uuid`
  * **SSOT:** merchant-service
  * **Exibido:** Merchant/Admin (sim), User App (parcial no extrato)

* `terminal_id: uuid`
  * **SSOT:** merchant-service
  * **Exibido:** Merchant/Admin (sim), POS App (não precisa)

* `wallet_id: uuid`
  * **SSOT:** benefits-core
  * **Exibido:** User/Admin (sim em detalhes), Employer (pouco)

* `payment_id: uuid`
  * **SSOT:** payments-orchestrator
  * **Exibido:** POS/Merchant/Admin (sim), User (sim no extrato)

* `expense_id: uuid`
  * **SSOT:** support-service
  * **Exibido:** User/Employer/Admin (sim)

* `receipt_id: uuid`
  * **SSOT:** support-service
  * **Exibido:** User (sim como "anexo"), Employer/Admin (sim com link)

* `correlation_id: uuid`
  * **SSOT:** gerado no edge (app/portal/bff)
  * **Exibido:** não; **logs/traces/events** sim

* `idempotency_key: string`
  * **SSOT:** request do cliente
  * **Exibido:** não; interno e logs

---

## 1.2 Tipos e formatos canônicos

* `amount_cents: int64` (sempre centavos)
* `currency: string` (ISO-4217, ex `BRL`)
* `status: string enum` (legível, sem int)
* `created_at / updated_at: timestamptz ISO-8601`
* `date: yyyy-mm-dd` (ex: `expense.date`)
* `metadata: object (jsonb)` (campos auxiliares/versionáveis)

---

## 1.3 Campos "comuns" que todo domínio deveria ter (quando fizer sentido)

* `tenant_id` (sempre)
* `created_at`, `created_by` (ator)
* `updated_at`, `updated_by` (quando editável)
* `correlation_id` (em comandos/eventos)
* `source_channel: enum` (`USER_APP|POS_APP|EMPLOYER_PORTAL|ADMIN_PORTAL|MERCHANT_PORTAL|PLATFORM_PORTAL|SYSTEM`)
* `external_ref: string` (quando importar/integração)
* `version: int` (para optimistic lock onde precisar)

---

## 1.4 O que é exibido vs interno (regra rápida)

**Exibido normalmente:**
* nomes, labels, amounts, datas, statuses, reason_code (explicado), merchant_name, wallet_label

**Interno normalmente (não exibir):**
* `tenant_id`, `administrator_id`, `request_hash`, `credential_hash`, `inbox_processed`, `outbox_event`, `fail_count`, `provider_payload_raw`, `risk_score_raw`, `ip_address` (apenas admin/segurança)

---

# 2) SSOT (fonte do dado) e "data lineage" (onde nasce → onde aparece)

## 2.1 SSOT por domínio (obrigatório)

* Catálogo/white-label/políticas/UI composition → **tenant-service**
* Wallet/Ledger/Balance/Statement → **benefits-core**
* Payment/Refund/Payment state → **payments-orchestrator**
* Merchant/Terminal/Credentials → **merchant-service**
* Expenses/Receipts/Corporate approvals → **support-service**
* Audit timeline → **audit-service**
* Notifications inbox → **notification-service**
* Recon/Settlement (financeiro contábil) → **recon-service / settlement-service**
* Privacy (LGPD export/anonymize/delete) → **privacy-service**
* Billing/Usage → **billing-service** (ou módulo dentro de platform no início)

---

# 3) MODELOS COMPLETOS (entidades + campos + origem + onde vai + exibido?)

Legenda: **U/E/M/A/PF/POS** = User App, Employer, Merchant, Admin, Platform, POS App

## 3.1 Tenant / White-label (tenant-service)

### `tenant`
* `tenant_id: uuid` — SSOT tenant-service — consome tudo — exibido: **A, PF**
* `administrator_id: uuid` — SSOT tenant-service — platform/admin — exibido: **PF**
* `name: string` — exibido: **U, E, M, A, PF**
* `slug: string` — exibido: **PF** (e usado em URLs)
* `status: enum(ACTIVE|INACTIVE)` — exibido: **A, PF**
* `created_at: datetime` — exibido: **PF** (opcional)

### `branding`
* `tenant_id: uuid` — interno
* `app_name: string` — exibido: **U, E, M**
* `logo_url: string` — exibido: **U, E, M**
* `primary_color: string` — exibido: **U, E, M**
* `secondary_color: string` — exibido: **U, E, M**
* `support_url: string` — exibido: **U**
* `legal_name: string` — exibido: **U** (rodapé)
* `terms_url/privacy_url: string` — exibido: **U**

### `modules`
* `tenant_id: uuid`
* `wallets_enabled: bool` — exibido: **PF/A** (e afeta UI U/E/M)
* `payments_enabled: bool` — exibido: **PF/A**
* `expenses_enabled: bool` — exibido: **PF/A**
* `merchant_portal_enabled: bool` — exibido: **PF/A**
* `admin_ops_enabled: bool` — exibido: **PF/A**

### `ui_composition`
* `schema_version: string` — exibido: **PF/A** (debug)
* `home_json: json` — exibido: **não** diretamente; **consumido por U** para render

### `wallet_definition`
* `wallet_type: string` (FOOD/MOBILITY/HEALTH/…) — exibido: **U/E/A/PF**
* `label: string` — exibido: **U/E/A/PF**
* `rules_json: json` (MCC allow/deny, limites) — exibido: **PF/A** (editor); aplicado em POS/credits

---

## 3.2 Employer / Employee linkage (tenant-service + employer portal views)

### `employer`
* `employer_id: uuid` — exibido: **E/A/PF**
* `tenant_id: uuid` — interno
* `name: string` — exibido: **E/A/PF**
* `status: enum` — exibido: **E/A/PF**
* `policies_json: json` — exibido: **E/A/PF** (editor)

### `employment` (ligação employer-user)
* `employment_id: uuid` — interno (pode exibir em A)
* `employer_id: uuid` — exibido: **E/A**
* `user_id: string` — exibido: **E/A**
* `employee_code: string` — exibido: **E** (sim) / **U** (não)
* `status: enum(ACTIVE|SUSPENDED|TERMINATED)` — exibido: **E/A**
* `hire_date: date` — exibido: **E/A**
* `department: string` — exibido: **E/A**
* `cost_center: string` — exibido: **E/A**
* `created_at: datetime`

---

## 3.3 Wallet / Ledger (benefits-core)

### `wallet`
* `wallet_id: uuid` — exibido: **U/A**
* `tenant_id: uuid` — interno
* `user_id: string` — exibido: **A**
* `wallet_type: string` — exibido: **U/A/E**
* `status: enum(ACTIVE|LOCKED)` — exibido: **U/A**
* `created_at: datetime`

### `wallet_balance`
* `wallet_id: uuid` — exibido: **A** (debug)
* `available_cents: int64` — exibido: **U/A**
* `reserved_cents: int64` — exibido: **A** (U só se quiser)
* `updated_at: datetime`

### `ledger_entry` (imutável)
* `entry_id: uuid` — exibido: **A** (debug)
* `wallet_id: uuid` — exibido: **A**
* `entry_type: enum(CREDIT|DEBIT|RESERVE|RELEASE|ADJUST|REVERSAL)` — exibido: **U/A**
* `amount_cents: int64` — exibido: **U/A**
* `currency: string` — exibido: **U/A**
* `ref_type: enum(PAYMENT|REFUND|CREDIT_BATCH|ADJUSTMENT|EXPENSE)` — exibido: **U/A**
* `ref_id: string` — exibido: **A** (U só se quiser)
* `description: string` (derivado/armazenado) — exibido: **U/A**
* `merchant_name: string` (quando payment) — exibido: **U**
* `occurred_at: datetime` — exibido: **U/A**
* `metadata_json: json` — interno (admin debug)

**Observação de lineage:**
* `merchant_name` nasce em **payments-orchestrator/merchant-service**, mas **aparece no statement** via `metadata_json` do ledger ou via join em query view. Regra: **o statement do benefits-core** é a "visão final" pro app.

---

## 3.4 Credit batch (benefits-core + employer portal)

### `credit_batch`
* `batch_id: string/uuid` — exibido: **E/A**
* `tenant_id: uuid` — interno
* `employer_id: uuid` — exibido: **E/A**
* `status: enum(CREATED|PROCESSING|COMPLETED|PARTIAL|FAILED)` — exibido: **E/A**
* `accepted_count: int` — exibido: **E/A**
* `rejected_count: int` — exibido: **E/A**
* `created_by: string` — exibido: **A** (E opcional)
* `created_at: datetime` — exibido: **E/A**

### `credit_batch_item`
* `batch_id: ...` — exibido: **E/A**
* `line_no: int` — exibido: **E**
* `user_id: string` — exibido: **E/A**
* `wallet_type: string` — exibido: **E**
* `amount_cents: int64` — exibido: **E**
* `status: enum(ACCEPTED|REJECTED|APPLIED)` — exibido: **E**
* `error_code: string` — exibido: **E**
* `error_detail: string` — exibido: **E**

---

## 3.5 Payments / Refund (payments-orchestrator)

### `payment`
* `payment_id: uuid` — exibido: **POS/M/A/U**
* `tenant_id: uuid` — interno
* `merchant_id: uuid` — exibido: **M/A** (U não)
* `merchant_name: string` — exibido: **U/M/A/POS** (origem: merchant-service cache / snapshot)
* `terminal_id: uuid` — exibido: **M/A**
* `user_id: string` — exibido: **A**
* `wallet_type: string` — exibido: **U/A/POS** (se selecionável)
* `amount_cents: int64` — exibido: **U/M/A/POS**
* `currency: string` — exibido: **U/M/A/POS**
* `mcc: string` — exibido: **A/M** (U geralmente não)
* `status: enum(CREATED|AUTHORIZING|AUTHORIZED|DECLINED|FAILED|REFUNDING|REFUNDED)` — exibido: **M/A/POS**
* `reason_code: string` (se declined/failed) — exibido: **POS/M/A** (U opcional)
* `provider_ref: string` — interno (A debug)
* `idempotency_key: string` — interno
* `occurred_at: datetime` — exibido: **U/M/A/POS**
* `created_at: datetime` — exibido: **A/M**

### `payment_event`
* exibido: **A** (timeline), **M** (debug opcional) — interno pro resto

### Refund (como evento/command)
* `refund_id: uuid` (opcional separar entidade) — exibido: **A/M**
* `amount_cents: int64` — exibido: **U/M/A/POS**
* `reason_code: string` — exibido: **A/M/POS**

**Lineage:**
* POS authorize cria Payment (SSOT) → chama benefits-core reserve/confirm → benefits-core cria ledger entries → User App vê statement.

---

## 3.6 Merchant / Terminal (merchant-service)

### `merchant`
* `merchant_id: uuid` — exibido: **M/A**
* `tenant_id: uuid` — interno
* `name: string` — exibido: **U/M/A/POS**
* `status: enum` — exibido: **M/A**
* `mcc_default: string` — exibido: **M/A**
* `created_at: datetime`

### `terminal`
* `terminal_id: uuid` — exibido: **M/A**
* `merchant_id: uuid` — exibido: **M/A**
* `status: enum(ACTIVE|DISABLED)` — exibido: **M/A**
* `credential_last4: string` — exibido: **M/A** (nunca mostrar hash)
* `credential_hash: string` — interno
* `rotated_at: datetime` — exibido: **M/A**

---

## 3.7 Support (support-service)

### `expense`
* `expense_id: uuid` — exibido: **U/E/A**
* `tenant_id: uuid` — interno
* `employer_id: uuid` — exibido: **E/A**
* `user_id: string` — exibido: **E/A**
* `amount_cents: int64` — exibido: **U/E/A**
* `currency: string` — exibido: **U/E/A**
* `date: date` — exibido: **U/E/A**
* `category: string` — exibido: **U/E/A**
* `notes: string` — exibido: **U/E/A**
* `status: enum(DRAFT|RECEIPT_UPLOADED|SUBMITTED|APPROVED|REJECTED)` — exibido: **U/E/A**
* `review_comment: string` — exibido: **U/E/A**
* `created_at: datetime` — exibido: **U/E/A**

### `receipt`
* `receipt_id: uuid` — exibido: **U/E/A**
* `expense_id: uuid`
* `s3_bucket: string` — interno
* `s3_key: string` — interno (E/A pode ver via link)
* `mime: string` — exibido: **E/A** (U opcional)
* `size_bytes: int64` — exibido: **E/A**
* `sha256: string` — interno
* `created_at`

### `corporate_request`
* `request_id: uuid` — exibido: **U/E/A**
* `type: enum(LIMIT|OTHER)` — exibido: **U/E/A**
* `amount_cents: int64` — exibido: **U/E/A**
* `reason: string` — exibido: **U/E/A**
* `status: enum(CREATED|PENDING|APPROVED|REJECTED)` — exibido: **U/E/A**
* `review_comment: string` — exibido: **U/E/A**
* `created_at`

---

## 3.8 Audit / Ops (audit-service + ops)

### `audit_record`
* `audit_id: uuid` — exibido: **A**
* `tenant_id: uuid` — interno
* `actor_id: string` — exibido: **A**
* `action: string` — exibido: **A**
* `target_type: string` — exibido: **A**
* `target_id: string` — exibido: **A**
* `before_json / after_json: json` — exibido: **A** (debug)
* `reason_code: string` — exibido: **A**
* `note: string` — exibido: **A**
* `correlation_id: uuid` — exibido: **A**
* `created_at`

### `outbox_event / inbox_processed`
* internos (nunca exibir, só ops)

---

# 4) LINEAGE POR FLUXO (de onde vem → onde vai → onde aparece)

## Fluxo: Login + Bootstrap catálogo
* **Origem:** Keycloak (token) + tenant-service (catalog)
* **Vai para:** user-bff → User App
* **Campos exibidos:** `branding.app_name/logo/colors`, módulos habilitados, blocos da home
* **Campos internos:** `tenant_id`, `schema_version` (pode mostrar em debug)

## Fluxo: Wallets + Statement
* **Origem:** benefits-core (wallet, balance, ledger_entry)
* **Vai para:** user-bff → User App; admin-bff → Admin Portal
* **Exibidos:** amount, date, description, merchant_name, status
* **Internos:** ref_id, metadata_json (exceto debug)

## Fluxo: Credit batch
* **Origem:** Employer Portal (itens) + tenant-service (valida user e policy) + benefits-core (aplica)
* **Vai para:** Employer Portal (resultado) + User App (saldo/extrato)
* **Exibidos:** accepted/rejected, errors por linha, crédito no statement
* **Internos:** request_hash, idempotency_record

## Fluxo: POS authorize
* **Origem:** POS App (amount/mcc) + payments-orchestrator (status) + benefits-core (ledger)
* **Vai para:** POS App (resultado), Merchant Portal (transações), User App (extrato), Admin Portal (investigação)
* **Exibidos:** aprovado/negado, reason_code, merchant_name, amount, data
* **Internos:** provider_ref, idempotency details

## Fluxo: Expense + receipt + approval
* **Origem:** User App (expense), LocalStack S3 (receipt), support-service (estado), Employer approval
* **Vai para:** User App, Employer Portal, Admin Portal
* **Exibidos:** status, amounts, receipt link, comentários
* **Internos:** s3_key, sha256

---

# 5) LISTA COMPLETA DE TAREFAS (M0…M20)

## M0 — Repo + Docs base + Convenções

### Infra/Repo
* Criar pastas padrão
* Criar targets build/test/lint por stack (maven + wrappers)

### Docs
* Criar `MASTER-BACKLOG.md` (este arquivo!)
* Criar templates: fluxo/tela/schema/evento
* Criar ASCII C4 L1/L2 rascunho

### DoD
* docs navegáveis + skeleton

---

## M1 — Infra local completa (Keycloak + LocalStack + Observability + flagd)

### Infra
* Compose: Postgres/Redis/Keycloak/LocalStack/OTel stack/Grafana/Tempo/Loki/Prom/flagd
* Scripts LocalStack:
  * buckets: receipts/exports/settlements
  * bus `benefits-bus`
  * queues + DLQ
  * rules roteando `wallet.*`, `payment.*`, `expense.*`, `*`→audit

### Segurança
* Keycloak realm:
  * roles: platform_owner/admin_ops/employer_admin/merchant_admin/user/pos_terminal
  * clients por app/portal e BFF
  * usuários seed

### Scripts
* `up/down/logs/smoke` (infra)

### Docs
* runbook local (URLs, credenciais)

### DoD
* infra sobe + smoke ok

---

## M2 — Cross-cutting libs (erros/idempotência/tenant/observability)

### Libs
* `common-errors` Problem Details + codes
* `common-tenant` TenantContext
* `common-idempotency` (Redis ou PG) + 409
* `common-observability` correlation + logs + OTel

### Docs
* Padrões globais com exemplos

### DoD
* 1 serviço de teste usa tudo e aparece em trace

---

## M3 — tenant-service (catálogo white-label SSOT) + schemas completos

### Dados (campos)
* administrator/tenant/employer
* branding (app_name/logo/colors/links)
* modules toggles
* ui_composition (schema_version/home_json)
* wallet_definition (wallet_type/label/rules_json)
* employment (link employer-user + employee_code etc)

### Endpoints internos (platform/admin)
* CRUD tenant/employer
* update branding/modules/ui/wallet defs/policies
* `GET /internal/catalog`

### Seed (idempotente)
* 2 administradoras, 3 tenants, 3 employers, 20 users, 5 merchants/terminals
* branding diferente por tenant
* home_json diferente por tenant

### DoD
* catalog consistente por tenant

---

## M4 — user-bff + User App E2E (login + bootstrap + home dinâmica)

### BFF
* OpenAPI `/me`, `/catalog`
* Compose tenant-service

### App
* Login OIDC
* Bootstrap: apply theme + render blocks
* Telas: login/bootstrap/home

### Testes
* smoke: token dev + `/catalog`
* pact: contract `/catalog`

### DoD
* MVP 1 ok

---

## M5 — benefits-core SSOT (wallet/ledger) + UI wallets/statement

### Dados (campos)
* wallet/wallet_balance/ledger_entry
* índices por (tenant_id,user_id,created_at)

### Commands
* credit/reserve/confirm/release/adjust

### Queries
* wallets, statement (paginado + filtros)

### BFF
* user-bff `/wallets` `/statement`

### App
* wallets list/detail
* statement list/detail

### Testes
* Testcontainers invariantes

### DoD
* MVP 2 ok

---

## M6 — employer-bff + Employer Portal: employees + credit batch

### Dados
* credit_batch/credit_batch_item (campos + erro por linha)

### Employer features
* Employees list/import CSV (employee_code, dept, status)
* Credit batch create/history/detail

### Testes
* Playwright: login employer → cria batch → vê resultado
* Smoke: statement tem novo CREDIT

### DoD
* Employer E2E ok

---

## M7 — payments-orchestrator + pos-bff + POS App + merchant basics

### Payments (campos)
* payment/payment_event/idempotency_record
* merchant_name snapshot
* reason_code

### POS
* authorize reserve→confirm
* refund total/parcial

### Merchant
* merchant-service merchant/terminal (rotate/disable)
* merchant portal terminals + transactions

### Testes
* smoke: authorize→debit, refund→credit

### DoD
* core transacional E2E ok

---

## M8 — Async backbone (outbox/inbox/DLQ) + audit + notifications + ops replay

### Eventos (catálogo)
* wallet.credited/debited/adjusted
* payment.authorized/declined/refunded
* expense.submitted/approved/rejected
* catalog.updated

### Infra
* outbox table + relay
* inbox dedup
* DLQ replay endpoints

### UI Ops (mínimo)
* Admin portal: "DLQ viewer + reprocess"

### DoD
* replay seguro e audit timeline preenchido

---

## M9 — Admin Ops completo (Admin portal)

### Features
* user search (email/user_id/employee_code)
* user 360 (wallets+statement+payments+expenses+audit)
* wallet adjust (reason obrigatório) + audit
* refund admin + reprocess stub

### DoD
* operação funcional

---

## M10 — Platform owner completo (Platform portal)

### Features
* wizard tenant/employer
* editor branding/modules/ui/wallet defs/policies
* preview catalog JSON
* feature flags por tenant (OpenFeature/flagd)

### DoD
* alterar catalog e refletir no app

---

## M11 — support-service completo + expenses/receipts + approvals

### Features
* expense lifecycle
* receipt presign/confirm + download link
* employer approve/reject
* user app: criar expense + upload + submit

### DoD
* fluxo E2E completo

---

## M12 — Merchant completo + transações + refunds + exports

### Features
* terminals management
* transactions detail
* refunds via portal
* export CSV

### DoD
* merchant autoatendimento

---

## M13 — Recon (mismatches) + Settlement (batches reais) + relatórios

### Features
* recon_run + recon_issue (missing/duplicate/mismatch)
* settlement_batch + settlement_item + fee rules
* export S3
* portal merchant: settlements list/detail/download

### DoD
* repasse demonstrável

---

## M14 — Policy engine avançado (MCC/limites)

### Features
* rules_json DSL + evaluator
* enforcement em credit e em authorize
* platform portal: editor + simulação

### DoD
* policy altera comportamento em runtime

---

## M15 — Privacy/LGPD + impersonation + compliance

### Features
* export de dados por user (S3)
* anonymize/delete (simulado mas consistente)
* impersonation admin com audit forte

### DoD
* compliance demonstrável

---

## M16 — Observability/Operability avançadas

### Features
* dashboards por serviço
* alert rules
* incident runbook
* backfill/replay por janela (ops)

### DoD
* debug e operação "de verdade"

---

## M17 — Testes e qualidade "pipeline-grade"

### Features
* Pact matrix
* Playwright suite completa
* Flutter integration suites
* Testcontainers + LocalStack integration
* e2e.sh 100% verde

### DoD
* pipeline local determinística

---

## M18 — Performance / Escalabilidade / Rate limiting

### Features
* índices, paginação cursor
* caching catalog/policies
* rate limit
* k6 smoke perf

### DoD
* P95 ok em endpoints críticos

---

## M19 — AWS deploy (IaC + CI/CD)

### Features
* Terraform/CDK: RDS/Redis/S3/EventBridge/SQS/ECS
* pipeline GH Actions
* staging

### DoD
* deploy repetível

---

## M20 — Produto vendável final (multi-admin, billing, docs pacote)

### Features
* multi-administradora com quotas
* billing/usage records
* demo script + documentação final (C4/UML/ERD/flows/runbooks)

### DoD
* "pronto pra vender"

---

**Fim do Master Backlog**
