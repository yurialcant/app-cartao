-- V004__Fix_batch_id_types.sql
-- Fix batch_id column type inconsistency and align schema with current entity model

-- First, drop the existing foreign key constraint
ALTER TABLE credit_batch_items DROP CONSTRAINT fk_credit_batch_items_batch;

-- Change batch_id column type from BIGINT to UUID in credit_batch_items
ALTER TABLE credit_batch_items ALTER COLUMN batch_id TYPE UUID USING batch_id::text::uuid;

-- Rename columns to match current entity model
ALTER TABLE credit_batch_items RENAME COLUMN person_id TO user_id;
ALTER TABLE credit_batch_items RENAME COLUMN amount TO amount_cents;
ALTER TABLE credit_batch_items ADD COLUMN wallet_type VARCHAR(50);

-- Update data: set wallet_type based on some logic (placeholder - will be set by application)
UPDATE credit_batch_items SET wallet_type = 'MEAL' WHERE wallet_type IS NULL;

-- Make wallet_type NOT NULL
ALTER TABLE credit_batch_items ALTER COLUMN wallet_type SET NOT NULL;

-- Drop old wallet_id column as we're using wallet_type now
ALTER TABLE credit_batch_items DROP COLUMN wallet_id;

-- Recreate the foreign key constraint
ALTER TABLE credit_batch_items ADD CONSTRAINT fk_credit_batch_items_batch
    FOREIGN KEY (batch_id) REFERENCES credit_batches(id) ON DELETE CASCADE;

-- Update indexes
DROP INDEX IF EXISTS idx_credit_batch_items_batch_id;
DROP INDEX IF EXISTS idx_credit_batch_items_batch_status;
DROP INDEX IF EXISTS idx_credit_batch_items_person_wallet;

CREATE INDEX idx_credit_batch_items_batch_id ON credit_batch_items(batch_id);
CREATE INDEX idx_credit_batch_items_batch_status ON credit_batch_items(batch_id, status);
CREATE INDEX idx_credit_batch_items_user_wallet ON credit_batch_items(user_id, wallet_type);