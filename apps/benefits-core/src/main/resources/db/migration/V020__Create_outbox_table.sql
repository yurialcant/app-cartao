-- Create outbox table for reliable event publishing
-- Used by Outbox pattern to ensure events are published reliably

CREATE TABLE IF NOT EXISTS outbox (
    id UUID PRIMARY KEY,
    event_type VARCHAR(255) NOT NULL,
    payload TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE NULL,
    tenant_id UUID NULL, -- For multi-tenancy support

    CONSTRAINT chk_outbox_status CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED'))
);

-- Index for efficient querying of pending events
CREATE INDEX IF NOT EXISTS idx_outbox_status_created_at ON outbox(status, created_at);

-- Index for tenant-specific queries
CREATE INDEX IF NOT EXISTS idx_outbox_tenant_status ON outbox(tenant_id, status);

-- Comments
COMMENT ON TABLE outbox IS 'Outbox table for reliable event publishing using the Outbox pattern';
COMMENT ON COLUMN outbox.id IS 'Unique identifier for the outbox event';
COMMENT ON COLUMN outbox.event_type IS 'Type of event being published';
COMMENT ON COLUMN outbox.payload IS 'JSON payload of the event data';
COMMENT ON COLUMN outbox.status IS 'Status of event processing: PENDING, PROCESSED, FAILED';
COMMENT ON COLUMN outbox.created_at IS 'Timestamp when event was created';
COMMENT ON COLUMN outbox.processed_at IS 'Timestamp when event was processed';
COMMENT ON COLUMN outbox.tenant_id IS 'Tenant identifier for multi-tenant events';