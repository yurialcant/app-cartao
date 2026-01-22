-- V010__Create_person_identity.sql
-- Create person and identity management tables

CREATE TABLE persons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    person_type VARCHAR(20) NOT NULL CHECK (person_type IN ('NATURAL', 'LEGAL')),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    document_type VARCHAR(20) CHECK (document_type IN ('CPF', 'CNPJ', 'PASSPORT')),
    document_number VARCHAR(50),
    birth_date DATE,
    nationality VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE identity_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    person_id UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    issuer VARCHAR(100) NOT NULL, -- e.g., 'GOOGLE', 'MICROSOFT', 'KEYCLOAK'
    subject VARCHAR(255) NOT NULL, -- external ID from identity provider
    email VARCHAR(255),
    verified BOOLEAN NOT NULL DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    person_id UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    employer_id UUID NOT NULL REFERENCES employers(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'EMPLOYEE' CHECK (role IN ('EMPLOYEE', 'MANAGER', 'ADMIN')),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    start_date DATE NOT NULL,
    end_date DATE,
    employment_id VARCHAR(100), -- external reference
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_persons_tenant_id ON persons(tenant_id);
CREATE INDEX idx_persons_email ON persons(email);
CREATE INDEX idx_persons_document ON persons(document_type, document_number);

CREATE INDEX idx_identity_links_tenant_id ON identity_links(tenant_id);
CREATE INDEX idx_identity_links_person_id ON identity_links(person_id);
CREATE INDEX idx_identity_links_issuer_subject ON identity_links(issuer, subject);
CREATE UNIQUE INDEX idx_identity_links_unique ON identity_links(tenant_id, issuer, subject);

CREATE INDEX idx_memberships_tenant_id ON memberships(tenant_id);
CREATE INDEX idx_memberships_person_id ON memberships(person_id);
CREATE INDEX idx_memberships_employer_id ON memberships(employer_id);
CREATE INDEX idx_memberships_status ON memberships(status);

-- Constraints
ALTER TABLE persons ADD CONSTRAINT chk_persons_email_format
    CHECK (email IS NULL OR email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

ALTER TABLE identity_links ADD CONSTRAINT chk_identity_links_email_format
    CHECK (email IS NULL OR email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');