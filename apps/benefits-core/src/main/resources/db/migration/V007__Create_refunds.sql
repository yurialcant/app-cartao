-- V007__Create_refunds.sql
-- F07 Refund: Refund entities and workflow

-- Create refunds table
CREATE TABLE refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    person_id UUID NOT NULL REFERENCES users(id),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    original_transaction_id VARCHAR(100) NOT NULL, -- Reference to original transaction
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
    reason VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    idempotency_key VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    authorization_code VARCHAR(50), -- Generated when approved
    error_message TEXT
);

-- Create unique constraint on idempotency_key per tenant
CREATE UNIQUE INDEX idx_refunds_tenant_idempotency ON refunds(tenant_id, idempotency_key);

-- Create indexes for efficient queries
CREATE INDEX idx_refunds_tenant_id ON refunds(tenant_id);
CREATE INDEX idx_refunds_person_id ON refunds(person_id);
CREATE INDEX idx_refunds_wallet_id ON refunds(wallet_id);
CREATE INDEX idx_refunds_status ON refunds(status);
CREATE INDEX idx_refunds_original_transaction ON refunds(original_transaction_id);

-- Add status check constraint
ALTER TABLE refunds ADD CONSTRAINT chk_refunds_status
    CHECK (status IN ('PENDING', 'PROCESSING', 'APPROVED', 'DECLINED', 'FAILED'));