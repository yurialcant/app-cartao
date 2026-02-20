-- V003__Outbox_placeholder.sql
-- Placeholder for outbox pattern implementation
-- This will be expanded when implementing async event publishing

-- Outbox table for reliable event publishing
CREATE TABLE outbox_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    aggregate_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    actor_id UUID, -- person_id (pid)
    correlation_id UUID NOT NULL,
    event_id UUID NOT NULL UNIQUE,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    payload JSONB NOT NULL,
    published_at TIMESTAMP WITH TIME ZONE,
    published BOOLEAN NOT NULL DEFAULT FALSE,

    -- Constraints
    CONSTRAINT chk_event_id_not_empty CHECK (length(event_id::text) > 0),
    CONSTRAINT chk_payload_not_empty CHECK (jsonb_object_keys(payload) IS NOT NULL),

    -- Indexes
    INDEX idx_outbox_events_tenant (tenant_id),
    INDEX idx_outbox_events_published (published, occurred_at),
    INDEX idx_outbox_events_event_type (event_type),
    INDEX idx_outbox_events_aggregate (aggregate_type, aggregate_id),
    INDEX idx_outbox_events_correlation (correlation_id)
);

-- Comments
COMMENT ON TABLE outbox_events IS 'Outbox pattern table for reliable event publishing to EventBridge/SQS';
COMMENT ON COLUMN outbox_events.event_id IS 'Globally unique event identifier';
COMMENT ON COLUMN outbox_events.aggregate_id IS 'ID of the aggregate that generated the event';
COMMENT ON COLUMN outbox_events.actor_id IS 'Person ID (pid) of the user who triggered the event';
COMMENT ON COLUMN outbox_events.payload IS 'Event payload as JSON';
COMMENT ON COLUMN outbox_events.published IS 'Whether this event has been published to the message broker';

-- Placeholder for future idempotency table
CREATE TABLE idempotency_keys (
    key VARCHAR(255) PRIMARY KEY,
    tenant_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,

    -- Index for cleanup
    INDEX idx_idempotency_keys_expires (expires_at)
);

COMMENT ON TABLE idempotency_keys IS 'Redis-backed idempotency keys with database fallback';