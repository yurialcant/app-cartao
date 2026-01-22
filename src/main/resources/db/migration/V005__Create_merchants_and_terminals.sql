-- V005__Create_merchants_and_terminals.sql
-- F06 POS Authorize: Merchant and Terminal entities

-- Create merchants table
CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    merchant_id VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create unique constraint on (tenant_id, merchant_id)
CREATE UNIQUE INDEX idx_merchants_tenant_merchant ON merchants(tenant_id, merchant_id);

-- Create index on tenant_id for efficient queries
CREATE INDEX idx_merchants_tenant_id ON merchants(tenant_id);

-- Create terminals table
CREATE TABLE terminals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    terminal_id VARCHAR(50) NOT NULL,
    location VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create unique constraint on (merchant_id, terminal_id)
CREATE UNIQUE INDEX idx_terminals_merchant_terminal ON terminals(merchant_id, terminal_id);

-- Create indexes for efficient queries
CREATE INDEX idx_terminals_merchant_id ON terminals(merchant_id);
CREATE INDEX idx_terminals_status ON terminals(status);