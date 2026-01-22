-- V001__Create_identity_tables.sql
-- Identity Service database schema

-- Create persons table
CREATE TABLE persons (
    person_id UUID PRIMARY KEY,
    tenant_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    version BIGINT NOT NULL DEFAULT 1
);

-- Create index on tenant_id for efficient queries
CREATE INDEX idx_persons_tenant_id ON persons(tenant_id);

-- Create identity_links table
CREATE TABLE identity_links (
    id BIGSERIAL PRIMARY KEY,
    person_id UUID NOT NULL REFERENCES persons(person_id) ON DELETE CASCADE,
    issuer VARCHAR(50) NOT NULL, -- "email", "cpf", "google", "facebook", etc.
    subject VARCHAR(255) NOT NULL, -- email address, CPF number, social ID, etc.
    tenant_id VARCHAR(50) NOT NULL,
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    version BIGINT NOT NULL DEFAULT 1
);

-- Create unique constraint on (issuer, subject, tenant_id) to prevent duplicates
CREATE UNIQUE INDEX idx_identity_links_unique ON identity_links(issuer, subject, tenant_id);

-- Create indexes for efficient queries
CREATE INDEX idx_identity_links_person_id ON identity_links(person_id);
CREATE INDEX idx_identity_links_issuer_subject ON identity_links(issuer, subject);
CREATE INDEX idx_identity_links_tenant_id ON identity_links(tenant_id);

-- Create outbox table for event publishing (placeholder for future async integration)
CREATE TABLE outbox (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(255) NOT NULL,
    event_id UUID NOT NULL UNIQUE,
    aggregate_type VARCHAR(255) NOT NULL,
    aggregate_id VARCHAR(255) NOT NULL,
    tenant_id VARCHAR(50) NOT NULL,
    actor_id VARCHAR(255), -- person_id when available
    correlation_id VARCHAR(255),
    payload JSONB NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    published BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for outbox processing
CREATE INDEX idx_outbox_published ON outbox(published);
CREATE INDEX idx_outbox_event_type ON outbox(event_type);
CREATE INDEX idx_outbox_tenant_id ON outbox(tenant_id);