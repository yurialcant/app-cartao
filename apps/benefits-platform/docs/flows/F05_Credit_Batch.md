# F05 - Credit Batch Flow

## 📋 **Visão Geral**

Fluxo completo de criação de batch de créditos pelo Employer, que resulta em créditos nos wallets dos employees e aparece no statement.

## 🎯 **SSOT (Single Source of Truth)**

- **SSOT:** `benefits-core`
- **Tabelas:** `credit_batches`, `credit_batch_items`, `wallets`, `ledger_entry`
- **Service:** `CreditBatchService`
- **Controller:** `InternalBatchController`

## 🔄 **Lineage (Fluxo de Dados)**

```
Employer Portal (Angular)
    ↓
employer-bff (BFF)
    ↓ POST /api/v1/employer/batches/credits
benefits-core (SSOT)
    ↓
    ├─→ credit_batches (tabela)
    ├─→ credit_batch_items (tabela)
    ├─→ wallets (atualização de balance)
    └─→ ledger_entry (CREDIT entries)
    ↓
User App (Flutter)
    ↓ GET /api/v1/wallets/statement
Statement com CREDIT entries
```

## 🔄 **Sequence Diagram (ASCII)**

```
Employer Portal    employer-bff      benefits-core         Database
     |                  |                  |                    |
     |--POST batch----->|                  |                    |
     |                  |                  |                    |
     |                  |--POST batch----->|                    |
     |                  |  (validate)       |                    |
     |                  |                  |                    |
     |                  |                  |--check idempotency->|
     |                  |                  |<--exists?----------|
     |                  |                  |                    |
     |                  |                  |--create batch----->|
     |                  |                  |<--batch_id----------|
     |                  |                  |                    |
     |                  |                  |--process items---->|
     |                  |                  |  (transaction)      |
     |                  |                  |                    |
     |                  |                  |--update wallets--->|
     |                  |                  |--create ledger----->|
     |                  |                  |<--success----------|
     |                  |                  |                    |
     |                  |                  |--write outbox----->|
     |                  |                  |<--event_id---------|
     |                  |                  |                    |
     |                  |<--batch_id-------|                    |
     |<--batch_id-------|                  |                    |
     |                  |                  |                    |
     |                  |                  |---async---------->|
     |                  |                  |  (ops-relay)       |
     |                  |                  |  (EventBridge)    |
```

## 📊 **Campos Exibidos vs Internos**

### **Request (employer-bff → benefits-core)**
**Exibidos (UI):**
- `items[]`: Array de itens com `personId`, `walletId`, `amount`, `description`

**Internos (benefits-core):**
- `tenantId` (header X-Tenant-Id)
- `employerId` (header X-Employer-Id)
- `idempotencyKey` (header Idempotency-Key)
- `correlationId` (header X-Correlation-Id)

### **Response (benefits-core → employer-bff)**
**Exibidos (UI):**
- `batchId`: UUID do batch criado
- `status`: SUBMITTED, PROCESSING, COMPLETED, FAILED
- `totalAmount`: Soma dos valores
- `itemCount`: Número de itens
- `items[]`: Array de itens processados

**Internos (benefits-core):**
- `createdAt`: Timestamp de criação
- `processedAt`: Timestamp de processamento
- `retryCount`: Contador de retries (se houver)

### **Statement (User App)**
**Exibidos (UI):**
- `entryType`: CREDIT
- `amount`: Valor creditado
- `description`: Descrição do crédito
- `balanceAfter`: Saldo após crédito
- `createdAt`: Data/hora do crédito

**Internos (benefits-core):**
- `referenceType`: TOPUP
- `referenceId`: ID do credit_batch_item
- `metadata`: JSON com detalhes do batch

## 🔐 **Autorização**

- **Role:** `employer_admin`
- **Scope:** Apenas employers permitidos (`employer_ids[]` no JWT)
- **Validação:** BFF valida JWT e extrai `employer_ids[]`

## 🗄️ **Persistência**

1. **credit_batches:**
   - `id` (UUID, PK)
   - `tenant_id` (UUID, FK)
   - `employer_id` (UUID)
   - `status` (SUBMITTED → PROCESSING → COMPLETED/FAILED)
   - `total_amount` (DECIMAL)
   - `item_count` (INTEGER)
   - `idempotency_key` (VARCHAR, UNIQUE)

2. **credit_batch_items:**
   - `id` (UUID, PK)
   - `batch_id` (UUID, FK → credit_batches)
   - `person_id` (UUID, FK → persons)
   - `wallet_id` (UUID, FK → wallets)
   - `amount` (DECIMAL)
   - `description` (VARCHAR)
   - `status` (PENDING → PROCESSED → FAILED)

3. **wallets:**
   - `balance` (atualizado via trigger ou service)

4. **ledger_entry:**
   - `entry_type`: CREDIT
   - `reference_type`: TOPUP
   - `reference_id`: credit_batch_item.id

## 🔄 **Eventos (Async Backbone)**

Quando batch é criado:
- **Event Type:** `credit.batch.submitted.v1`
- **Aggregate Type:** `CreditBatch`
- **Aggregate ID:** batch.id
- **Payload:** JSON com detalhes do batch
- **Publicado via:** Outbox pattern (tabela `outbox`)

## ✅ **Validações**

1. **Idempotência:**
   - Mesma `idempotencyKey` + mesmo payload → retorna batch existente
   - Mesma `idempotencyKey` + payload diferente → 409 Conflict

2. **Limites:**
   - Máximo de itens por batch (configurável, default: 1000)
   - Valor mínimo por item (configurável, default: 0.01)

3. **Multi-tenant:**
   - Sempre filtrar por `tenant_id`
   - Validar que `employer_id` pertence ao `tenant_id`

## 🧪 **Como Validar**

1. **Via employer-bff:**
   ```powershell
   # Iniciar employer-bff
   .\scripts\start-employer-bff.ps1
   
   # Testar POST
   $body = @{
       items = @(
           @{ personId = "550e8400-e29b-41d4-a716-446655440001"; walletId = "550e8400-e29b-41d4-a716-446655440200"; amount = 100.00; description = "Test credit" }
       )
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri "http://localhost:8083/api/v1/employer/batches/credits" `
       -Method POST `
       -Headers @{ "X-Tenant-Id" = "550e8400-e29b-41d4-a716-446655440000"; "Authorization" = "Bearer mock-token" } `
       -Body $body `
       -ContentType "application/json"
   ```

2. **Direto em benefits-core:**
   ```powershell
   .\scripts\test-f05-direct.ps1
   ```

3. **Verificar statement:**
   ```powershell
   # Após criar batch, verificar statement
   Invoke-WebRequest -Uri "http://localhost:8091/internal/wallets/550e8400-e29b-41d4-a716-446655440200/statement" `
       -Headers @{ "X-Tenant-Id" = "550e8400-e29b-41d4-a716-446655440000" }
   ```

## 📝 **Notas de Implementação**

- **Idempotência:** Implementada via constraint única em `credit_batches.idempotency_key`
- **Transações:** Usa `@Transactional` para garantir atomicidade
- **Reativo:** Usa R2DBC para operações não-bloqueantes
- **Outbox:** Eventos são escritos na tabela `outbox` para publicação assíncrona
