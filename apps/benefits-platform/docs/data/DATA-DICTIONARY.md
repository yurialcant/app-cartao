# 📊 DICIONÁRIO DE DADOS - benefits-core (SSOT)

**Última Atualização:** 2026-01-18 14:43  
**SSOT:** `benefits-core`  
**Database:** PostgreSQL

---

## 🎯 **TABELAS PRINCIPAIS**

### **1. wallets**
**Descrição:** Carteiras de benefícios dos usuários. Source of Truth para saldos.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único da wallet | PRIMARY KEY |
| `tenant_id` | VARCHAR(255) | NOT NULL | ID do tenant (multi-tenant) | FK → tenants |
| `user_id` | VARCHAR(255) | NOT NULL | ID do usuário (person_id) | |
| `wallet_type` | VARCHAR(50) | NOT NULL | Tipo de wallet (MEAL, FOOD, TRANSPORT, FLEX) | DEFAULT 'FLEX' |
| `balance` | NUMERIC(19,2) | NOT NULL | Saldo atual da wallet | DEFAULT 0 |
| `daily_limit` | NUMERIC(19,2) | NULL | Limite diário de gasto | |
| `daily_spent` | NUMERIC(19,2) | NOT NULL | Valor gasto hoje | DEFAULT 0 |
| `last_daily_reset` | TIMESTAMP | NULL | Última vez que daily_spent foi resetado | |
| `currency` | VARCHAR(3) | NOT NULL | Moeda (BRL, USD, etc) | DEFAULT 'BRL' |
| `status` | VARCHAR(50) | NOT NULL | Status (ACTIVE, FROZEN, EXPIRED) | DEFAULT 'ACTIVE' |
| `created_at` | TIMESTAMP | NOT NULL | Data de criação | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | NOT NULL | Data de atualização | DEFAULT CURRENT_TIMESTAMP |
| `version` | INT | NOT NULL | Versão para optimistic locking | DEFAULT 0 |

**Índices:**
- `idx_wallets_tenant_user` (tenant_id, user_id) - UNIQUE
- `idx_wallets_user_id` (user_id)
- `idx_wallets_status` (status)

**Uso:** F05 (créditos), F06 (débitos POS), F07 (reembolsos)

---

### **2. ledger_entries**
**Descrição:** Registro imutável de todas as transações. Source of Truth para histórico de saldos.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do ledger entry | PRIMARY KEY |
| `tenant_id` | VARCHAR(255) | NOT NULL | ID do tenant | |
| `wallet_id` | UUID | NOT NULL | ID da wallet | FK → wallets(id) |
| `entry_type` | VARCHAR(50) | NOT NULL | Tipo (CREDIT, DEBIT) | |
| `amount` | NUMERIC(19,2) | NOT NULL | Valor da transação | |
| `description` | TEXT | NULL | Descrição da transação | |
| `reference_id` | VARCHAR(255) | NULL | ID da transação original (batch_id, refund_id, etc) | |
| `reference_type` | VARCHAR(50) | NULL | Tipo de referência (TOPUP, REFUND, POS_AUTH, etc) | |
| `status` | VARCHAR(50) | NOT NULL | Status (COMPLETED, PENDING, FAILED) | DEFAULT 'COMPLETED' |
| `created_at` | TIMESTAMP | NOT NULL | Data de criação | DEFAULT CURRENT_TIMESTAMP |

**Índices:**
- `idx_ledger_tenant_wallet` (tenant_id, wallet_id)
- `idx_ledger_wallet_id` (wallet_id)
- `idx_ledger_reference` (reference_id, reference_type)
- `idx_ledger_entry_type` (entry_type)
- `idx_ledger_created_at` (created_at)

**Uso:** F05 (CREDIT entries), F06 (DEBIT entries), F07 (CREDIT entries), Statement queries

---

### **3. credit_batches**
**Descrição:** Lotes de créditos criados por employers. F05 - Credit Batch.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do batch | PRIMARY KEY |
| `tenant_id` | UUID | NOT NULL | ID do tenant | FK → tenants(id) |
| `employer_id` | UUID | NOT NULL | ID do employer | |
| `batch_name` | VARCHAR(255) | NULL | Nome do batch | |
| `status` | VARCHAR(50) | NOT NULL | Status (SUBMITTED, PROCESSING, COMPLETED, FAILED) | |
| `total_amount_cents` | BIGINT | NULL | Total em centavos | DEFAULT 0 |
| `total_items` | INTEGER | NULL | Total de itens | DEFAULT 0 |
| `items_succeeded` | INTEGER | NULL | Itens processados com sucesso | DEFAULT 0 |
| `items_failed` | INTEGER | NULL | Itens que falharam | DEFAULT 0 |
| `idempotency_key` | VARCHAR(255) | NULL | Chave de idempotência | |
| `correlation_id` | UUID | NULL | ID de correlação para tracing | |
| `processed_at` | TIMESTAMP | NULL | Data de processamento | |
| `created_at` | TIMESTAMP | NOT NULL | Data de criação | DEFAULT CURRENT_TIMESTAMP |
| `updated_at` | TIMESTAMP | NOT NULL | Data de atualização | DEFAULT CURRENT_TIMESTAMP |

**Índices:**
- `idx_credit_batches_idempotency` (tenant_id, idempotency_key)
- `idx_credit_batches_correlation` (correlation_id)

**Uso:** F05 - Credit Batch flow

---

### **4. credit_batch_items**
**Descrição:** Itens individuais de um batch de créditos. F05 - Credit Batch.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do item | PRIMARY KEY |
| `batch_id` | UUID | NOT NULL | ID do batch | FK → credit_batches(id) |
| `tenant_id` | VARCHAR(255) | NULL | ID do tenant | |
| `person_id` | UUID | NULL | ID da pessoa | FK → users(id) |
| `wallet_id` | UUID | NULL | ID da wallet | FK → wallets(id) |
| `wallet_type` | VARCHAR(50) | NULL | Tipo de wallet | DEFAULT 'DEFAULT' |
| `amount_cents` | BIGINT | NULL | Valor em centavos | |
| `description` | TEXT | NULL | Descrição do crédito | |
| `status` | VARCHAR(50) | NULL | Status (PENDING, PROCESSED, FAILED) | |
| `processed_at` | TIMESTAMP | NULL | Data de processamento | |
| `correlation_id` | UUID | NULL | ID de correlação | |
| `created_at` | TIMESTAMP | NOT NULL | Data de criação | DEFAULT CURRENT_TIMESTAMP |

**Índices:**
- `idx_batch_items_tenant` (tenant_id)
- `idx_batch_items_correlation` (correlation_id)

**Uso:** F05 - Credit Batch flow

---

### **5. merchants**
**Descrição:** Merchants que aceitam pagamentos via POS. F06 - POS Authorize.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do merchant | PRIMARY KEY |
| `tenant_id` | UUID | NOT NULL | ID do tenant | FK → tenants(id) |
| `merchant_id` | VARCHAR(50) | NOT NULL | ID do merchant (business ID) | |
| `name` | VARCHAR(255) | NOT NULL | Nome do merchant | |
| `status` | VARCHAR(50) | NOT NULL | Status (ACTIVE, INACTIVE) | DEFAULT 'ACTIVE' |
| `created_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de criação | DEFAULT NOW() |
| `updated_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de atualização | DEFAULT NOW() |

**Índices:**
- `idx_merchants_tenant_merchant` (tenant_id, merchant_id) - UNIQUE
- `idx_merchants_tenant_id` (tenant_id)

**Uso:** F06 - POS Authorize flow

---

### **6. terminals**
**Descrição:** Terminais POS pertencentes a merchants. F06 - POS Authorize.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do terminal | PRIMARY KEY |
| `merchant_id` | UUID | NOT NULL | ID do merchant | FK → merchants(id) ON DELETE CASCADE |
| `terminal_id` | VARCHAR(50) | NOT NULL | ID do terminal (business ID) | |
| `location` | VARCHAR(255) | NULL | Localização do terminal | |
| `status` | VARCHAR(50) | NOT NULL | Status (ACTIVE, INACTIVE) | DEFAULT 'ACTIVE' |
| `created_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de criação | DEFAULT NOW() |
| `updated_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de atualização | DEFAULT NOW() |

**Índices:**
- `idx_terminals_merchant_terminal` (merchant_id, terminal_id) - UNIQUE
- `idx_terminals_merchant_id` (merchant_id)
- `idx_terminals_status` (status)

**Uso:** F06 - POS Authorize flow

---

### **7. refunds**
**Descrição:** Reembolsos de transações POS. F07 - Refund.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do refund | PRIMARY KEY |
| `tenant_id` | UUID | NOT NULL | ID do tenant | FK → tenants(id) |
| `person_id` | UUID | NOT NULL | ID da pessoa | FK → users(id) |
| `wallet_id` | UUID | NOT NULL | ID da wallet | FK → wallets(id) |
| `original_transaction_id` | VARCHAR(100) | NOT NULL | ID da transação original (POS) | |
| `amount` | DECIMAL(15,2) | NOT NULL | Valor do reembolso | CHECK (amount > 0) |
| `currency` | VARCHAR(3) | NOT NULL | Moeda | DEFAULT 'BRL' |
| `reason` | VARCHAR(255) | NULL | Motivo do reembolso | |
| `status` | VARCHAR(50) | NOT NULL | Status (PENDING, PROCESSING, APPROVED, DECLINED, FAILED) | DEFAULT 'PENDING' |
| `idempotency_key` | VARCHAR(255) | NOT NULL | Chave de idempotência | |
| `authorization_code` | VARCHAR(50) | NULL | Código de autorização (quando aprovado) | |
| `error_message` | TEXT | NULL | Mensagem de erro (se falhou) | |
| `created_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de criação | DEFAULT NOW() |
| `updated_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de atualização | DEFAULT NOW() |
| `processed_at` | TIMESTAMP WITH TIME ZONE | NULL | Data de processamento | |

**Índices:**
- `idx_refunds_tenant_idempotency` (tenant_id, idempotency_key) - UNIQUE
- `idx_refunds_tenant_id` (tenant_id)
- `idx_refunds_person_id` (person_id)
- `idx_refunds_wallet_id` (wallet_id)
- `idx_refunds_status` (status)
- `idx_refunds_original_transaction` (original_transaction_id)

**Constraints:**
- `chk_refunds_status` CHECK (status IN ('PENDING', 'PROCESSING', 'APPROVED', 'DECLINED', 'FAILED'))

**Uso:** F07 - Refund flow

---

### **8. outbox**
**Descrição:** Tabela para Outbox Pattern - eventos para publicação assíncrona. Async Backbone.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único do evento | PRIMARY KEY |
| `event_type` | VARCHAR(255) | NOT NULL | Tipo do evento (ex: credit.batch.submitted.v1) | |
| `aggregate_type` | VARCHAR(255) | NOT NULL | Tipo do agregado (ex: CreditBatch) | |
| `aggregate_id` | UUID | NOT NULL | ID do agregado | |
| `tenant_id` | VARCHAR(255) | NOT NULL | ID do tenant | |
| `actor_id` | VARCHAR(255) | NULL | ID do ator (person_id) | |
| `correlation_id` | UUID | NULL | ID de correlação | |
| `payload` | TEXT | NOT NULL | Payload JSON do evento | |
| `occurred_at` | TIMESTAMP | NOT NULL | Data/hora de ocorrência | |
| `published` | BOOLEAN | NOT NULL | Se foi publicado | DEFAULT FALSE |
| `retry_count` | INTEGER | NOT NULL | Contador de retries | DEFAULT 0 |
| `last_retry_at` | TIMESTAMP | NULL | Última tentativa de publicação | |
| `error_message` | TEXT | NULL | Mensagem de erro (se falhou) | |
| `created_at` | TIMESTAMP | NOT NULL | Data de criação | DEFAULT CURRENT_TIMESTAMP |

**Índices:**
- `idx_outbox_published_created` (published, created_at)
- `idx_outbox_tenant_published` (tenant_id, published)
- `idx_outbox_event_type` (event_type)
- `idx_outbox_aggregate` (aggregate_type, aggregate_id)

**Uso:** Async Backbone - Outbox Pattern

---

### **9. inbox** (ops-relay)
**Descrição:** Tabela para Inbox Pattern - deduplicação de eventos recebidos. Async Backbone.

| Campo | Tipo | Nullable | Descrição | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | UUID | NOT NULL | Identificador único | PRIMARY KEY |
| `event_id` | UUID | NOT NULL | ID do evento (único) | UNIQUE |
| `event_type` | VARCHAR(255) | NOT NULL | Tipo do evento | |
| `aggregate_type` | VARCHAR(255) | NOT NULL | Tipo do agregado | |
| `aggregate_id` | UUID | NOT NULL | ID do agregado | |
| `tenant_id` | VARCHAR(255) | NOT NULL | ID do tenant | |
| `actor_id` | VARCHAR(255) | NULL | ID do ator | |
| `correlation_id` | UUID | NULL | ID de correlação | |
| `payload` | TEXT | NOT NULL | Payload JSON | |
| `occurred_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data/hora de ocorrência | |
| `processed_at` | TIMESTAMP WITH TIME ZONE | NULL | Data/hora de processamento | |
| `processed` | BOOLEAN | NOT NULL | Se foi processado | DEFAULT FALSE |
| `error_message` | TEXT | NULL | Mensagem de erro | |
| `created_at` | TIMESTAMP WITH TIME ZONE | NOT NULL | Data de criação | DEFAULT NOW() |

**Índices:**
- `idx_inbox_event_id` (event_id) - UNIQUE
- `idx_inbox_processed` (processed, created_at)
- `idx_inbox_tenant` (tenant_id)

**Uso:** Async Backbone - Inbox Dedup + Replay

---

## 🔗 **RELACIONAMENTOS**

```
tenants (1) ──< (N) wallets
wallets (1) ──< (N) ledger_entries
tenants (1) ──< (N) credit_batches
credit_batches (1) ──< (N) credit_batch_items
credit_batch_items (N) ──> (1) wallets
tenants (1) ──< (N) merchants
merchants (1) ──< (N) terminals
tenants (1) ──< (N) refunds
refunds (N) ──> (1) wallets
```

---

## 📝 **NOTAS**

- **Multi-tenant:** Todas as tabelas filtram por `tenant_id`
- **Idempotência:** `credit_batches.idempotency_key` e `refunds.idempotency_key` são únicos por tenant
- **Imutabilidade:** `ledger_entries` é imutável (append-only)
- **Optimistic Locking:** `wallets.version` para evitar race conditions
- **Outbox Pattern:** Eventos são escritos em `outbox` e publicados assincronamente via `ops-relay`
- **Inbox Pattern:** Eventos recebidos são deduplicados via `inbox` (ops-relay DB)

---

## 🎯 **SSOT (Single Source of Truth)**

- **Wallet Balance:** `wallets.balance` (atualizado via triggers ou service)
- **Transaction History:** `ledger_entries` (imutável, append-only)
- **Credit Batches:** `credit_batches` + `credit_batch_items`
- **POS Transactions:** `merchants` + `terminals` + `ledger_entries` (DEBIT)
- **Refunds:** `refunds` + `ledger_entries` (CREDIT)
