-- V021__Recreate_Credit_Batches_Correctly.sql
-- Force schema alignment with Java Entities (UUID IDs, consistent columns)
-- This fixes conflicts between previous V002/V004 versions

DROP TABLE IF EXISTS credit_batch_items;
DROP TABLE IF EXISTS credit_batches;

CREATE TABLE credit_batches (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    employer_id UUID NOT NULL,
    batch_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PENDING',
    total_amount_cents BIGINT,
    total_items INTEGER,
    items_succeeded INTEGER DEFAULT 0,
    items_failed INTEGER DEFAULT 0,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    idempotency_key VARCHAR(255)
);

CREATE TABLE credit_batch_items (
    id UUID PRIMARY KEY,
    batch_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    user_id UUID NOT NULL,
    wallet_type VARCHAR(50),
    amount_cents BIGINT,
    status VARCHAR(50) DEFAULT 'PENDING',
    error_message TEXT,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_batch FOREIGN KEY (batch_id) REFERENCES credit_batches(id) ON DELETE CASCADE
);

CREATE INDEX idx_credit_batches_tenant ON credit_batches(tenant_id);
CREATE INDEX idx_credit_batches_created ON credit_batches(created_at DESC);
CREATE INDEX idx_credit_batches_idem ON credit_batches(tenant_id, idempotency_key);
CREATE INDEX idx_credit_batch_items_batch ON credit_batch_items(batch_id);
