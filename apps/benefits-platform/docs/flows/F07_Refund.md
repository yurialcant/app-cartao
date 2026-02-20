# F07 - Refund Flow

## 📋 **Visão Geral**

Fluxo completo de reembolso (refund) de uma transação POS anterior, que resulta em crédito no wallet do employee e aparece no statement.

## 🎯 **SSOT (Single Source of Truth)**

- **SSOT:** `benefits-core`
- **Tabelas:** `refunds`, `wallets`, `ledger_entry`, `ledger_entry` (transação original)
- **Service:** `RefundService`
- **Controller:** `RefundController`

## 🔄 **Lineage (Fluxo de Dados)**

```
User App (Flutter) ou Admin Portal
    ↓
user-bff ou admin-bff (BFF)
    ↓ POST /api/v1/refunds
benefits-core (SSOT)
    ↓
    ├─→ refunds (tabela)
    ├─→ wallets (atualização de balance)
    └─→ ledger_entry (CREDIT entry)
    ↓
User App (Flutter)
    ↓ GET /api/v1/wallets/statement
Statement com CREDIT entry (refund)
```

## 🔄 **Sequence Diagram (ASCII)**

```
User App/Admin     BFF              benefits-core         Database
     |              |                    |                    |
     |--POST refund->|                    |                    |
     |              |                    |                    |
     |              |--POST refund------>|                    |
     |              |  (validate)        |                    |
     |              |                    |                    |
     |              |                    |--check idempotency->|
     |              |                    |<--exists?----------|
     |              |                    |                    |
     |              |                    |--validate wallet-->|
     |              |                    |<--wallet exists----|
     |              |                    |                    |
     |              |                    |--validate original->|
     |              |                    |  transaction        |
     |              |                    |<--transaction exists|
     |              |                    |                    |
     |              |                    |--create refund---->|
     |              |                    |<--refund_id--------|
     |              |                    |                    |
     |              |                    |--update wallet---->|
     |              |                    |  (balance += amount)|
     |              |                    |<--success----------|
     |              |                    |                    |
     |              |                    |--create ledger----->|
     |              |                    |  (CREDIT entry)     |
     |              |                    |<--entry_id---------|
     |              |                    |                    |
     |              |                    |--write outbox----->|
     |              |                    |<--event_id---------|
     |              |                    |                    |
     |              |<--refund_id--------|                    |
     |<--refund_id---|                    |                    |
     |              |                    |                    |
     |              |                    |---async---------->|
     |              |                    |  (ops-relay)       |
     |              |                    |  (EventBridge)    |
```

## 📊 **Campos Exibidos vs Internos**

### **Request (BFF → benefits-core)**
**Exibidos (UI):**
- `personId`: UUID da pessoa
- `walletId`: UUID do wallet
- `originalTransactionId`: ID da transação original (POS authorize)
- `amount`: Valor do reembolso
- `reason`: Motivo do reembolso

**Internos (benefits-core):**
- `tenantId` (header X-Tenant-Id)
- `idempotencyKey` (header Idempotency-Key)
- `correlationId` (header X-Correlation-Id)
- `actorId` (extraído do JWT `pid` claim)

### **Response (benefits-core → BFF)**
**Exibidos (UI):**
- `refundId`: UUID do refund criado
- `status`: APPROVED, DECLINED, PENDING
- `amount`: Valor do reembolso
- `walletId`: UUID do wallet
- `balanceAfter`: Saldo após reembolso

**Internos (benefits-core):**
- `originalTransactionId`: ID da transação original
- `createdAt`: Timestamp de criação
- `processedAt`: Timestamp de processamento

### **Statement (User App)**
**Exibidos (UI):**
- `entryType`: CREDIT
- `amount`: Valor reembolsado
- `description`: "Refund: [reason]"
- `balanceAfter`: Saldo após reembolso
- `createdAt`: Data/hora do reembolso

**Internos (benefits-core):**
- `referenceType`: REFUND
- `referenceId`: refund.id
- `metadata`: JSON com `originalTransactionId` e `reason`

## 🔐 **Autorização**

- **Roles:** `user` (apenas seu próprio wallet), `admin_ops` (qualquer wallet do tenant), `tenant_owner` (qualquer wallet do tenant)
- **Scope:** 
  - `user`: Apenas wallets onde `person_id` = JWT `pid`
  - `admin_ops` / `tenant_owner`: Qualquer wallet do `tenant_id`
- **Validação:** BFF valida JWT e extrai `pid`, `roles[]`, `tenant_id`

## 🗄️ **Persistência**

1. **refunds:**
   - `id` (UUID, PK)
   - `tenant_id` (UUID, FK)
   - `person_id` (UUID, FK → persons)
   - `wallet_id` (UUID, FK → wallets)
   - `original_transaction_id` (VARCHAR) - ID da transação POS original
   - `amount` (DECIMAL)
   - `reason` (VARCHAR)
   - `status` (APPROVED, DECLINED, PENDING)
   - `idempotency_key` (VARCHAR, UNIQUE)
   - `created_at` (TIMESTAMP)

2. **wallets:**
   - `balance` (atualizado: balance + amount)

3. **ledger_entry:**
   - `entry_type`: CREDIT
   - `reference_type`: REFUND
   - `reference_id`: refund.id
   - `amount`: Valor do reembolso
   - `balance_after`: Novo saldo

## 🔄 **Validações de Negócio**

1. **Transação Original:**
   - Deve existir uma transação POS (DEBIT) com `originalTransactionId`
   - Transação deve estar no mesmo `wallet_id`
   - Transação deve estar no mesmo `tenant_id`

2. **Wallet:**
   - Wallet deve existir
   - Wallet deve pertencer ao `person_id`
   - Wallet deve pertencer ao `tenant_id`

3. **Valor:**
   - Valor deve ser positivo
   - Valor não pode exceder o valor da transação original

4. **Idempotência:**
   - Mesma `idempotencyKey` + mesmo payload → retorna refund existente
   - Mesma `idempotencyKey` + payload diferente → 409 Conflict

## 🔄 **Eventos (Async Backbone)**

Quando refund é aprovado:
- **Event Type:** `wallet.refund.approved.v1`
- **Aggregate Type:** `Wallet`
- **Aggregate ID:** wallet.id
- **Payload:** JSON com detalhes do refund
- **Publicado via:** Outbox pattern (tabela `outbox`)

## ✅ **Cenários de Teste**

### **Cenário 1: Refund Aprovado**
- Wallet válido
- Transação original válida
- Valor válido
- **Resultado:** APPROVED, CREDIT no statement

### **Cenário 2: Idempotência**
- Mesma `idempotencyKey` usada duas vezes
- **Resultado:** Retorna mesmo refund (200 OK)

### **Cenário 3: Wallet Inválido**
- Wallet não existe ou não pertence ao person
- **Resultado:** DECLINED (400 Bad Request)

### **Cenário 4: Transação Original Inválida**
- `originalTransactionId` não existe
- **Resultado:** DECLINED (400 Bad Request)

## 🧪 **Como Validar**

1. **Via test script:**
   ```powershell
   .\scripts\test-f07-refund.ps1
   ```

2. **Direto em benefits-core:**
   ```powershell
   $refundJson = @{
       personId = "550e8400-e29b-41d4-a716-446655440001"
       walletId = "550e8400-e29b-41d4-a716-446655440200"
       originalTransactionId = "AUTH001-ORIGINAL-12345"
       amount = 25.00
       reason = "Cliente solicitou cancelamento"
       idempotencyKey = "test-refund-001"
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri "http://localhost:8091/internal/refunds" `
       -Method POST `
       -Headers @{ "X-Tenant-Id" = "550e8400-e29b-41d4-a716-446655440000"; "Idempotency-Key" = "test-refund-001" } `
       -Body $refundJson `
       -ContentType "application/json"
   ```

3. **Verificar statement:**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8091/internal/wallets/550e8400-e29b-41d4-a716-446655440200/statement" `
       -Headers @{ "X-Tenant-Id" = "550e8400-e29b-41d4-a716-446655440000" }
   ```

## 📝 **Notas de Implementação**

- **Connection Pool:** Habilitado em `application.properties` (linha 10-13) para evitar timeouts
- **Idempotência:** Implementada via constraint única em `refunds.idempotency_key`
- **Transações:** Usa `@Transactional` para garantir atomicidade
- **Reativo:** Usa R2DBC para operações não-bloqueantes
- **Outbox:** Eventos são escritos na tabela `outbox` para publicação assíncrona

## 🔗 **Dependências**

- **F06 POS Authorize:** Deve existir uma transação POS (DEBIT) antes de fazer refund
- **F05 Credit Batch:** Wallet deve ter sido criado (via credit batch ou seed)
