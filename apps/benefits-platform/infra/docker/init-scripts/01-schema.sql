-- Benefits Platform - PostgreSQL Schema Initialization
-- M1-M5 Core Tables

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tenant
CREATE TABLE tenant (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    administrator_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT now(),
    created_by VARCHAR(255)
);

-- Employer
CREATE TABLE employer (
    employer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id),
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(tenant_id, name)
);

-- Employment
CREATE TABLE employment (
    employment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id),
    employer_id UUID NOT NULL REFERENCES employer(employer_id),
    user_id VARCHAR(255) NOT NULL,
    employee_code VARCHAR(50),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    hire_date DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Wallet
CREATE TABLE wallet (
    wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id),
    user_id VARCHAR(255) NOT NULL,
    wallet_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Wallet Balance
CREATE TABLE wallet_balance (
    wallet_balance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID UNIQUE NOT NULL REFERENCES wallet(wallet_id),
    available_cents BIGINT DEFAULT 0,
    reserved_cents BIGINT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Ledger Entry
CREATE TABLE ledger_entry (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id),
    wallet_id UUID NOT NULL REFERENCES wallet(wallet_id),
    entry_type VARCHAR(50) NOT NULL,
    amount_cents BIGINT NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    ref_type VARCHAR(50),
    ref_id VARCHAR(255),
    description TEXT,
    merchant_name VARCHAR(255),
    occurred_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_wallet_tenant_user ON wallet(tenant_id, user_id);
CREATE INDEX idx_ledger_wallet ON ledger_entry(wallet_id);
CREATE INDEX idx_ledger_tenant_created ON ledger_entry(tenant_id, created_at DESC);
CREATE INDEX idx_employer_tenant ON employer(tenant_id);
CREATE INDEX idx_employment_tenant_user ON employment(tenant_id, user_id);
