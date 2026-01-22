-- V017__Create_settlement_tables.sql
-- Create settlement and billing tables

CREATE TABLE settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    settlement_id VARCHAR(50) UNIQUE NOT NULL,
    merchant_id UUID NOT NULL REFERENCES merchants(id),
    settlement_date DATE NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    net_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    fee_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    transaction_count INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE settlement_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    settlement_id UUID NOT NULL REFERENCES settlements(id) ON DELETE CASCADE,
    transaction_id UUID NOT NULL REFERENCES transactions(id),
    amount DECIMAL(15,2) NOT NULL,
    fee DECIMAL(15,2) NOT NULL DEFAULT 0,
    net_amount DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_settlements_tenant_id ON settlements(tenant_id);
CREATE INDEX idx_settlements_merchant_id ON settlements(merchant_id);
CREATE INDEX idx_settlements_settlement_id ON settlements(settlement_id);
CREATE INDEX idx_settlements_status ON settlements(status);
CREATE INDEX idx_settlements_date_range ON settlements(period_start, period_end);

CREATE INDEX idx_settlement_items_tenant_id ON settlement_items(tenant_id);
CREATE INDEX idx_settlement_items_settlement_id ON settlement_items(settlement_id);
CREATE INDEX idx_settlement_items_transaction_id ON settlement_items(transaction_id);

-- Sample data
INSERT INTO settlements (tenant_id, settlement_id, merchant_id, settlement_date, period_start, period_end, total_amount, net_amount, fee_amount, transaction_count, status) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'STL-001', (SELECT id FROM merchants WHERE merchant_id = 'MERC001'), '2026-01-31', '2026-01-01', '2026-01-31', 15000.00, 14250.00, 750.00, 150, 'COMPLETED');