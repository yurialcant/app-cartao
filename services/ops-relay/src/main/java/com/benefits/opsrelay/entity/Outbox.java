package com.benefits.opsrelay.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

/**
 * Outbox entity for reliable event publishing.
 * Reuses the same structure as benefits-core Outbox entity.
 * Maps to the 'outbox' table in benefits-core database.
 */
@Table("outbox")
public class Outbox {

    @Id
    @Column("id")
    private UUID id;

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

    @Column("published")
    private Boolean published;

    @Column("retry_count")
    private Integer retryCount;

    @Column("last_retry_at")
    private Instant lastRetryAt;

    @Column("error_message")
    private String errorMessage;

    @Column("created_at")
    private Instant createdAt;

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

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

    public Boolean getPublished() { return published; }
    public void setPublished(Boolean published) { this.published = published; }

    public Integer getRetryCount() { return retryCount; }
    public void setRetryCount(Integer retryCount) { this.retryCount = retryCount; }

    public Instant getLastRetryAt() { return lastRetryAt; }
    public void setLastRetryAt(Instant lastRetryAt) { this.lastRetryAt = lastRetryAt; }

    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
