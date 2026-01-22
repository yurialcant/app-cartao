-- V002__Credit_batches.sql
-- Create credit batch tables for F05

CREATE TABLE credit_batches (
    id BIGSERIAL PRIMARY KEY,
    batch_id UUID NOT NULL UNIQUE,
    tenant_id UUID NOT NULL,
    employer_id UUID NOT NULL,
    idempotency_key VARCHAR(255) NOT NULL,
    total_items INTEGER NOT NULL,
    total_amount DECIMAL(19,4) NOT NULL,
    processed_items INTEGER NOT NULL DEFAULT 0,
    processed_amount DECIMAL(19,4) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,

    -- Constraints
    CONSTRAINT ck_credit_batches_status CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    CONSTRAINT ck_credit_batches_totals CHECK (total_items >= 0 AND total_amount >= 0),
    CONSTRAINT ck_credit_batches_processed CHECK (processed_items >= 0 AND processed_amount >= 0),

    -- Unique constraint for idempotency within tenant
    CONSTRAINT uk_credit_batches_tenant_idempotency UNIQUE (tenant_id, idempotency_key)
);

CREATE TABLE credit_batch_items (
    id BIGSERIAL PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    person_id UUID NOT NULL,
    wallet_id UUID NOT NULL,
    amount DECIMAL(19,4) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    error_message TEXT,
    processed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign key
    CONSTRAINT fk_credit_batch_items_batch FOREIGN KEY (batch_id) REFERENCES credit_batches(id) ON DELETE CASCADE,

    -- Constraints
    CONSTRAINT ck_credit_batch_items_status CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED')),
    CONSTRAINT ck_credit_batch_items_amount CHECK (amount > 0)
);

-- Indexes for performance
CREATE INDEX idx_credit_batches_tenant_created ON credit_batches(tenant_id, created_at DESC);
CREATE INDEX idx_credit_batches_tenant_employer ON credit_batches(tenant_id, employer_id, created_at DESC);
CREATE INDEX idx_credit_batches_batch_id ON credit_batches(batch_id);
CREATE INDEX idx_credit_batches_idempotency ON credit_batches(tenant_id, idempotency_key);

CREATE INDEX idx_credit_batch_items_batch_id ON credit_batch_items(batch_id);
CREATE INDEX idx_credit_batch_items_batch_status ON credit_batch_items(batch_id, status);
CREATE INDEX idx_credit_batch_items_person_wallet ON credit_batch_items(person_id, wallet_id);

-- Comments
COMMENT ON TABLE credit_batches IS 'Credit batch operations for employer benefits distribution';
COMMENT ON TABLE credit_batch_items IS 'Individual credit items within a batch operation';

COMMENT ON COLUMN credit_batches.batch_id IS 'Public UUID for batch identification';
COMMENT ON COLUMN credit_batches.idempotency_key IS 'Idempotency key to prevent duplicate submissions';
COMMENT ON COLUMN credit_batches.created_by IS 'Actor ID (person_id) who created the batch';
COMMENT ON COLUMN credit_batch_items.person_id IS 'Target person receiving the credit';
COMMENT ON COLUMN credit_batch_items.wallet_id IS 'Target wallet for the credit transaction';