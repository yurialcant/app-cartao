# F06 - POS Authorize Flow

## 🎯 Visão Geral
Fluxo de autorização POS (Point of Sale) que permite merchants processarem pagamentos via POS terminals, debitanto do saldo da wallet do usuário e refletindo no statement.

## 📋 Contexto de Negócio
- **Merchant** possui **POS Terminals** para aceitar pagamentos
- **POS Terminal** solicita autorização de pagamento
- **Usuário** tem saldo em **Wallet** que será debitado
- **Transação** deve refletir em tempo real no **Statement**

## 🔄 Fluxo Completo

### **Sequência de Eventos:**
```
1. POS App solicita autorização
2. POS BFF valida token/terminal
3. benefits-core verifica saldo
4. Ledger registra DEBIT
5. Statement atualiza em tempo real
6. Resposta com authorization code
```

### **Participantes:**
- **POS App** - Aplicativo do terminal POS
- **POS BFF** - Backend for Frontend para POS
- **benefits-core** - Serviço de benefícios (SSOT)
- **Merchant** - Entidade do merchant
- **Terminal** - Terminal POS específico
- **Wallet** - Carteira do usuário
- **Ledger** - Registro contábil
- **Statement** - Extrato do usuário

## 📊 Dados e Campos

### **Merchant (SSOT: benefits-core)**
```sql
CREATE TABLE merchants (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    merchant_id VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **Terminal (SSOT: benefits-core)**
```sql
CREATE TABLE terminals (
    id UUID PRIMARY KEY,
    merchant_id UUID NOT NULL REFERENCES merchants(id),
    terminal_id VARCHAR(50) NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(merchant_id, terminal_id)
);
```

### **Authorize Request**
```json
{
  "terminal_id": "TERM001",
  "merchant_id": "MERCH001",
  "person_id": "uuid",
  "wallet_id": "uuid",
  "amount": 150.75,
  "currency": "BRL",
  "description": "Pagamento restaurante",
  "idempotency_key": "auth-12345"
}
```

### **Authorize Response**
```json
{
  "authorization_code": "AUTH-20240118-001",
  "status": "APPROVED",
  "amount": 150.75,
  "balance_before": 1000.00,
  "balance_after": 849.25,
  "transaction_id": "uuid",
  "timestamp": "2024-01-18T10:30:00Z"
}
```

## 🔒 Regras de Autorização

### **JWT Claims Obrigatórios:**
- `tenant_id` - Tenant do merchant
- `pid` (person_id) - Usuário fazendo transação
- `roles[]` - Deve incluir `pos_terminal`
- `merchant_ids[]` - Lista de merchants permitidos

### **Validações de Negócio:**
1. **Terminal existe e está ativo**
2. **Merchant existe e está ativo**
3. **Terminal pertence ao merchant**
4. **Wallet existe e pertence ao usuário**
5. **Saldo suficiente na wallet**
6. **Amount > 0**
7. **Idempotency key não duplicada**

## 💰 Lógica de Débito

### **Balance Check:**
```java
if (wallet.balance < request.amount) {
    throw new InsufficientFundsException();
}
```

### **Ledger Entry:**
```java
LedgerEntry debit = new LedgerEntry(
    tenantId: tenantId,
    personId: personId,
    walletId: walletId,
    type: "DEBIT",
    amount: request.amount,
    description: request.description,
    reference: "POS_AUTH_" + authorizationCode
);
```

### **Wallet Update:**
```java
wallet.balance -= request.amount;
wallet.updatedAt = now();
```

## 🔄 Sequence Diagram (ASCII)

```
POS App          POS BFF         benefits-core
   |                |                |
   |---authorize--->|                |
   |                |                |
   |                |--validate----->|
   |                |                |
   |                |<--check balance|
   |                |                |
   |                |--debit wallet->|
   |                |                |
   |                |<--ledger entry-|
   |                |                |
   |<--approved-----|                |
   |                |                |
   |                |---async------->|
   |                |   statement    |
   |                |   update       |
```

## 🧪 Cenários de Teste

### **Cenário 1: Autorização Aprovada**
- Terminal ativo, saldo suficiente
- Resultado: APPROVED + authorization_code

### **Cenário 2: Saldo Insuficiente**
- Saldo < amount
- Resultado: DECLINED + insufficient_funds

### **Cenário 3: Terminal Inválido**
- Terminal não existe ou inativo
- Resultado: DECLINED + invalid_terminal

### **Cenário 4: Idempotency**
- Mesmo idempotency_key enviado 2x
- Resultado: Mesmo authorization_code retornado

## 📈 Métricas de Monitoramento

- **Taxa de Aprovação:** authorizations_approved / total_authorizations
- **Tempo Médio de Resposta:** P95 < 500ms
- **Taxa de Erro:** authorization_errors / total_requests
- **Valor Médio por Transação:** Média dos amounts aprovados

## 🔗 Relacionamentos

- **Pré-condição:** F05 Credit Batch (para ter saldo nas wallets)
- **Pós-condição:** Statement atualizado em tempo real
- **Relacionado:** F07 Refund (estorno de transações POS)

## 🎯 Critérios de Aceitação

- ✅ POS pode autorizar pagamentos
- ✅ Saldo debitado corretamente
- ✅ Statement reflete transação
- ✅ Idempotency funciona
- ✅ Validações de segurança aplicadas
- ✅ Performance < 500ms P95