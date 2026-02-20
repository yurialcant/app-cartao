-- V001__Create_inbox.sql
-- Inbox table for event deduplication
-- Prevents processing the same event multiple times

CREATE TABLE IF NOT EXISTS inbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL UNIQUE,
    event_type VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(255) NOT NULL,
    aggregate_id UUID NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    actor_id VARCHAR(255),
    correlation_id UUID,
    payload TEXT NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE,
    processed BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_inbox_event_id ON inbox(event_id);
CREATE INDEX IF NOT EXISTS idx_inbox_processed ON inbox(processed, occurred_at);
CREATE INDEX IF NOT EXISTS idx_inbox_tenant ON inbox(tenant_id);
CREATE INDEX IF NOT EXISTS idx_inbox_event_type ON inbox(event_type);
CREATE INDEX IF NOT EXISTS idx_inbox_aggregate ON inbox(aggregate_type, aggregate_id);

-- Comments
COMMENT ON TABLE inbox IS 'Inbox pattern table for event deduplication - prevents processing same event multiple times';
COMMENT ON COLUMN inbox.event_id IS 'Globally unique event identifier for deduplication';
COMMENT ON COLUMN inbox.processed IS 'Whether this event has been processed';
