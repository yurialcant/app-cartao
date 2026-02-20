package com.benefits.opsrelay.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

/**
 * Inbox entity for event deduplication
 * Prevents processing the same event multiple times
 */
@Table("inbox")
public class Inbox {

    @Id
    @Column("id")
    private UUID id;

    @Column("event_id")
    private UUID eventId;

    @Column("event_type")
    private String eventType;

    @Column("aggregate_type")
    private String aggregateType;

    @Column("aggregate_id")
    private UUID aggregateId;

    @Column("tenant_id")
    private String tenantId;

    @Column("actor_id")
    private String actorId;

    @Column("correlation_id")
    private UUID correlationId;

    @Column("payload")
    private String payload;

    @Column("occurred_at")
    private Instant occurredAt;

    @Column("processed_at")
    private Instant processedAt;

    @Column("processed")
    private Boolean processed;

    @Column("error_message")
    private String errorMessage;

    @Column("created_at")
    private Instant createdAt;

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getEventId() { return eventId; }
    public void setEventId(UUID eventId) { this.eventId = eventId; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    public String getAggregateType() { return aggregateType; }
    public void setAggregateType(String aggregateType) { this.aggregateType = aggregateType; }

    public UUID getAggregateId() { return aggregateId; }
    public void setAggregateId(UUID aggregateId) { this.aggregateId = aggregateId; }

    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }

    public String getActorId() { return actorId; }
    public void setActorId(String actorId) { this.actorId = actorId; }

    public UUID getCorrelationId() { return correlationId; }
    public void setCorrelationId(UUID correlationId) { this.correlationId = correlationId; }

    public String getPayload() { return payload; }
    public void setPayload(String payload) { this.payload = payload; }

    public Instant getOccurredAt() { return occurredAt; }
    public void setOccurredAt(Instant occurredAt) { this.occurredAt = occurredAt; }

    public Instant getProcessedAt() { return processedAt; }
    public void setProcessedAt(Instant processedAt) { this.processedAt = processedAt; }

    public Boolean getProcessed() { return processed; }
    public void setProcessed(Boolean processed) { this.processed = processed; }

    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
