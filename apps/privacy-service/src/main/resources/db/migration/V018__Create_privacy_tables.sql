-- V018__Create_privacy_tables.sql
-- Create privacy and GDPR compliance tables

CREATE TABLE data_subject_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    request_id VARCHAR(50) UNIQUE NOT NULL,
    person_id UUID NOT NULL REFERENCES persons(id),
    request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('ACCESS', 'RECTIFICATION', 'ERASURE', 'RESTRICTION', 'PORTABILITY', 'OBJECTION')),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'REJECTED')),
    description TEXT,
    requested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    response_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE consent_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    person_id UUID NOT NULL REFERENCES persons(id),
    consent_type VARCHAR(100) NOT NULL,
    consent_given BOOLEAN NOT NULL,
    consent_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expiry_date TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    user_agent TEXT,
    withdrawn_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_data_subject_requests_tenant_id ON data_subject_requests(tenant_id);
CREATE INDEX idx_data_subject_requests_person_id ON data_subject_requests(person_id);
CREATE INDEX idx_data_subject_requests_request_type ON data_subject_requests(request_type);
CREATE INDEX idx_data_subject_requests_status ON data_subject_requests(status);

CREATE INDEX idx_consent_records_tenant_id ON consent_records(tenant_id);
CREATE INDEX idx_consent_records_person_id ON consent_records(person_id);
CREATE INDEX idx_consent_records_consent_type ON consent_records(consent_type);
CREATE INDEX idx_consent_records_consent_given ON consent_records(consent_given);