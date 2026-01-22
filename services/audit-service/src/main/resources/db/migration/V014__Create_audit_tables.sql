-- V014__Create_audit_tables.sql
-- Additional audit tables for audit-service

-- Compliance events table
CREATE TABLE compliance_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    event_type VARCHAR(100) NOT NULL,
    severity VARCHAR(20) NOT NULL DEFAULT 'INFO' CHECK (severity IN ('INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    description TEXT NOT NULL,
    user_id UUID REFERENCES persons(id),
    resource_type VARCHAR(50),
    resource_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Data retention policies
CREATE TABLE retention_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    data_type VARCHAR(50) NOT NULL,
    retention_days INTEGER NOT NULL,
    auto_delete BOOLEAN NOT NULL DEFAULT true,
    last_cleanup TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_compliance_events_tenant_id ON compliance_events(tenant_id);
CREATE INDEX idx_compliance_events_event_type ON compliance_events(event_type);
CREATE INDEX idx_compliance_events_severity ON compliance_events(severity);
CREATE INDEX idx_compliance_events_created_at ON compliance_events(created_at);

CREATE INDEX idx_retention_policies_tenant_id ON retention_policies(tenant_id);
CREATE INDEX idx_retention_policies_data_type ON retention_policies(data_type);

-- Sample data
INSERT INTO retention_policies (tenant_id, data_type, retention_days, auto_delete) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'AUDIT_LOGS', 2555, true), -- 7 years
('550e8400-e29b-41d4-a716-446655440000', 'TRANSACTION_LOGS', 2555, true),
('550e8400-e29b-41d4-a716-446655440000', 'ACCESS_LOGS', 365, true), -- 1 year
('550e8400-e29b-41d4-a716-446655440000', 'NOTIFICATION_LOGS', 90, true); -- 90 days