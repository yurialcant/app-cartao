-- Schema Completo Benefits Platform - Criação Manual (Bootstrap)

CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255),
    active BOOLEAN DEFAULT true,
    program_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    tenant_id VARCHAR(100) NOT NULL,
    keycloak_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    full_name VARCHAR(255),
    cpf VARCHAR(11) UNIQUE,
    phone VARCHAR(20),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS employers (
    id UUID PRIMARY KEY,
    tenant_id VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    email VARCHAR(255),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS merchants (
    id UUID PRIMARY KEY,
    tenant_id VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    email VARCHAR(255),
    mcc VARCHAR(10),
    category VARCHAR(255),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY,
    tenant_id VARCHAR(100) NOT NULL,
    user_id TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    balance NUMERIC(19,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'BRL',
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY,
    tenant_id VARCHAR(100) NOT NULL,
    user_id TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    amount NUMERIC(19,2),
    merchant VARCHAR(255),
    description VARCHAR(500),
    status VARCHAR(50) DEFAULT 'APPROVED',
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS feature_flags (
    id UUID PRIMARY KEY,
    key VARCHAR(255) NOT NULL,
    value BOOLEAN DEFAULT true,
    scope VARCHAR(50),
    scope_id VARCHAR(100),
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_tenant ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_wallets_tenant_user ON wallets(tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_tenant_user ON transactions(tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at DESC);

-- F05 Credit Batch Support
CREATE TABLE IF NOT EXISTS credit_batches (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    employer_id UUID NOT NULL,
    batch_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PENDING',
    total_amount_cents BIGINT,
    total_items INTEGER,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    idempotency_key VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS credit_batch_items (
    id UUID PRIMARY KEY,
    batch_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    user_id UUID NOT NULL,
    wallet_type VARCHAR(50),
    amount_cents BIGINT,
    status VARCHAR(50) DEFAULT 'PENDING',
    error_message TEXT,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (batch_id) REFERENCES credit_batches(id)
);

CREATE INDEX IF NOT EXISTS idx_credit_batches_tenant ON credit_batches(tenant_id);
CREATE INDEX IF NOT EXISTS idx_credit_batches_created ON credit_batches(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_credit_batches_idem ON credit_batches(tenant_id, idempotency_key);
CREATE INDEX IF NOT EXISTS idx_credit_batch_items_batch ON credit_batch_items(batch_id);

-- Ensure ledger_entries exists (Source of Truth) if not already
CREATE TABLE IF NOT EXISTS ledger_entries (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    wallet_id UUID NOT NULL,
    entry_type VARCHAR(50) NOT NULL,
    amount NUMERIC(19,2),
    balance_after NUMERIC(19,2),
    description VARCHAR(500),
    reference_id VARCHAR(255),
    reference_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT NOW(),
    balance_after_cents BIGINT
);
CREATE INDEX IF NOT EXISTS idx_ledger_wallet_created on ledger_entries(wallet_id, created_at DESC);

