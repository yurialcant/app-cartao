-- Benefits Platform - Complete Database Schema
-- Compatible with seeds: 01-tenant-origami.sql, 02-users-wallets.sql
-- Idempotente: Pode rodar múltiplas vezes

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- TENANT SERVICE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    legal_name VARCHAR(255),
    tax_id VARCHAR(20),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_at TIMESTAMPTZ,
    updated_by UUID,
    tenant_id UUID NOT NULL -- Self-reference for consistency
);

CREATE TABLE IF NOT EXISTS tenant_branding (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    primary_color VARCHAR(10),
    secondary_color VARCHAR(10),
    logo_url VARCHAR(500),
    favicon_url VARCHAR(500),
    app_name VARCHAR(100),
    support_email VARCHAR(255),
    support_phone VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS plans (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    UNIQUE(tenant_id, code)
);

CREATE TABLE IF NOT EXISTS plan_modules (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    plan_id UUID NOT NULL REFERENCES plans(id),
    module_name VARCHAR(255) NOT NULL,
    module_code VARCHAR(50) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS wallet_definitions (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    wallet_type VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
    allows_negative_balance BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    UNIQUE(tenant_id, wallet_type)
);

CREATE TABLE IF NOT EXISTS feature_flags (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    flag_name VARCHAR(255) NOT NULL,
    flag_key VARCHAR(100) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    UNIQUE(tenant_id, flag_key)
);

-- ============================================
-- BENEFITS CORE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    cpf VARCHAR(11),
    phone VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    email_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    UNIQUE(tenant_id, email),
    UNIQUE(tenant_id, cpf)
);

CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    user_id UUID NOT NULL REFERENCES users(id),
    wallet_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    UNIQUE(tenant_id, user_id, wallet_type)
);

CREATE TABLE IF NOT EXISTS ledger_entry (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    type VARCHAR(50) NOT NULL,  -- CREDIT, DEBIT, REFUND, etc.
    amount_cents BIGINT NOT NULL,
    balance_after_cents BIGINT NOT NULL,
    description TEXT,
    correlation_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    version INT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS credit_batches (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    employer_id UUID,
    batch_name VARCHAR(255),
    idempotency_key VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    total_amount_cents BIGINT,
    total_items INT,
    items_succeeded INT DEFAULT 0,
    items_failed INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    correlation_id UUID,
    UNIQUE(tenant_id, idempotency_key)
);

CREATE TABLE IF NOT EXISTS credit_batch_items (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    batch_id UUID NOT NULL REFERENCES credit_batches(id),
    user_id UUID NOT NULL,
    wallet_type VARCHAR(50) NOT NULL,
    amount_cents BIGINT NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    correlation_id UUID
);

-- ============================================
-- PAYMENTS TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    user_id UUID NOT NULL,
    merchant_id UUID,
    amount_cents BIGINT NOT NULL,
    wallet_type VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    correlation_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ
);

-- ============================================
-- ASYNC BACKBONE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS outbox (
    id UUID PRIMARY KEY,
    event_type VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(100),
    aggregate_id UUID,
    tenant_id UUID NOT NULL,
    actor_id UUID,
    correlation_id UUID,
    payload JSONB NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published BOOLEAN NOT NULL DEFAULT false,
    published_at TIMESTAMPTZ,
    retry_count INT NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS merchants (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    name VARCHAR(255) NOT NULL,
    tax_id VARCHAR(20),
    mcc VARCHAR(10),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS terminals (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    merchant_id UUID NOT NULL REFERENCES merchants(id),
    terminal_code VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    UNIQUE(tenant_id, terminal_code)
);

-- ============================================
-- INDEXES
-- ============================================

-- Tenants
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON tenants(slug);
CREATE INDEX IF NOT EXISTS idx_tenants_status ON tenants(status);

-- Users
CREATE INDEX IF NOT EXISTS idx_users_tenant_email ON users(tenant_id, email);
CREATE INDEX IF NOT EXISTS idx_users_tenant_cpf ON users(tenant_id, cpf);

-- Wallets
CREATE INDEX IF NOT EXISTS idx_wallets_tenant_user ON wallets(tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_wallets_user_type ON wallets(user_id, wallet_type);

-- Ledger (CRITICAL for balance queries)
CREATE INDEX IF NOT EXISTS idx_ledger_wallet_created ON ledger_entry(wallet_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ledger_tenant ON ledger_entry(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ledger_correlation ON ledger_entry(correlation_id);

-- Credit Batches
CREATE INDEX IF NOT EXISTS idx_batches_tenant ON credit_batches(tenant_id);
CREATE INDEX IF NOT EXISTS idx_batches_status ON credit_batches(status);
CREATE INDEX IF NOT EXISTS idx_batch_items_batch ON credit_batch_items(batch_id);

-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_tenant_user ON payments(tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- Outbox
CREATE INDEX IF NOT EXISTS idx_outbox_published ON outbox(published, created_at);
CREATE INDEX IF NOT EXISTS idx_outbox_tenant ON outbox(tenant_id);
CREATE INDEX IF NOT EXISTS idx_outbox_event_type ON outbox(event_type);

-- ============================================
-- GRANTS (for application user)
-- ============================================

-- Assuming application connects as 'benefits' user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO benefits;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO benefits;

-- ============================================
-- COMPLETION
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Schema completo criado com sucesso';
    RAISE NOTICE 'Tabelas: %', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE');
END $$;
