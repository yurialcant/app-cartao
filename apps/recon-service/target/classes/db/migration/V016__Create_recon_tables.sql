-- V016__Create_recon_tables.sql
-- Create reconciliation and settlement tables

CREATE TABLE reconciliation_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    run_id VARCHAR(50) UNIQUE NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'RUNNING' CHECK (status IN ('RUNNING', 'COMPLETED', 'FAILED')),
    total_transactions INTEGER DEFAULT 0,
    matched_transactions INTEGER DEFAULT 0,
    unmatched_transactions INTEGER DEFAULT 0,
    discrepancies_found INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    report_data JSONB
);

CREATE TABLE transaction_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    reconciliation_run_id UUID NOT NULL REFERENCES reconciliation_runs(id) ON DELETE CASCADE,
    internal_transaction_id UUID,
    external_transaction_id VARCHAR(255),
    amount DECIMAL(15,2),
    match_status VARCHAR(20) NOT NULL DEFAULT 'MATCHED' CHECK (match_status IN ('MATCHED', 'UNMATCHED', 'DISCREPANCY')),
    match_confidence DECIMAL(3,2),
    discrepancy_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_reconciliation_runs_tenant_id ON reconciliation_runs(tenant_id);
CREATE INDEX idx_reconciliation_runs_run_id ON reconciliation_runs(run_id);
CREATE INDEX idx_reconciliation_runs_status ON reconciliation_runs(status);
CREATE INDEX idx_reconciliation_runs_date_range ON reconciliation_runs(start_date, end_date);

CREATE INDEX idx_transaction_matches_tenant_id ON transaction_matches(tenant_id);
CREATE INDEX idx_transaction_matches_reconciliation_run_id ON transaction_matches(reconciliation_run_id);
CREATE INDEX idx_transaction_matches_status ON transaction_matches(match_status);

-- Sample data
INSERT INTO reconciliation_runs (tenant_id, run_id, start_date, end_date, status, total_transactions, matched_transactions) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'RECON-001', '2026-01-01 00:00:00+00', '2026-01-31 23:59:59+00', 'COMPLETED', 1500, 1485);