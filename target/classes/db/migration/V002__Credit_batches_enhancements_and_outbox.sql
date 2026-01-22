-- ============================================================================
-- V002: Add missing fields to credit batches and outbox table
-- ============================================================================

-- Add missing columns to credit_batches table
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(255);
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS total_amount_cents BIGINT DEFAULT 0;
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS total_items INTEGER DEFAULT 0;
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS items_succeeded INTEGER DEFAULT 0;
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS items_failed INTEGER DEFAULT 0;
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP;
ALTER TABLE credit_batches ADD COLUMN IF NOT EXISTS correlation_id UUID;

-- Add missing columns to credit_batch_items table
ALTER TABLE credit_batch_items ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(255);
ALTER TABLE credit_batch_items ADD COLUMN IF NOT EXISTS wallet_type VARCHAR(50) DEFAULT 'DEFAULT';
ALTER TABLE credit_batch_items ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE credit_batch_items ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP;
ALTER TABLE credit_batch_items ADD COLUMN IF NOT EXISTS correlation_id UUID;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_credit_batches_idempotency ON credit_batches(tenant_id, idempotency_key);
CREATE INDEX IF NOT EXISTS idx_credit_batches_correlation ON credit_batches(correlation_id);
CREATE INDEX IF NOT EXISTS idx_batch_items_tenant ON credit_batch_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_batch_items_correlation ON credit_batch_items(correlation_id);

-- ============================================================================
-- OUTBOX PATTERN TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS outbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(255) NOT NULL,
    aggregate_id UUID NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    actor_id VARCHAR(255),
    correlation_id UUID,
    payload TEXT NOT NULL,
    occurred_at TIMESTAMP NOT NULL,
    published BOOLEAN NOT NULL DEFAULT FALSE,
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_retry_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for outbox table
CREATE INDEX IF NOT EXISTS idx_outbox_published_created ON outbox(published, created_at);
CREATE INDEX IF NOT EXISTS idx_outbox_tenant_published ON outbox(tenant_id, published);
CREATE INDEX IF NOT EXISTS idx_outbox_event_type ON outbox(event_type);
CREATE INDEX IF NOT EXISTS idx_outbox_aggregate ON outbox(aggregate_type, aggregate_id);

-- ============================================================================
-- UPDATE EXISTING DATA
-- ============================================================================

-- Set tenant_id in credit_batch_items based on the related batch
UPDATE credit_batch_items
SET tenant_id = cb.tenant_id
FROM credit_batches cb
WHERE credit_batch_items.batch_id = cb.id AND credit_batch_items.tenant_id IS NULL;
