package com.benefits.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Outbox Entity
 *
 * Represents an event that needs to be published to external systems
 * Used in the Outbox pattern for reliable event publishing
 */
@Table("outbox")
public class Outbox {

    @Id
    private UUID id;

    private String eventType;
    private String payload;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime processedAt;
    private UUID tenantId;

    // Default constructor
    public Outbox() {}

    // Constructor with required fields
    public Outbox(UUID id, String eventType, String payload, String status) {
        this.id = id;
        this.eventType = eventType;
        this.payload = payload;
        this.status = status;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getPayload() {
        return payload;
    }

    public void setPayload(String payload) {
        this.payload = payload;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(LocalDateTime processedAt) {
        this.processedAt = processedAt;
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    @Override
    public String toString() {
        return "Outbox{" +
                "id=" + id +
                ", eventType='" + eventType + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", processedAt=" + processedAt +
                ", tenantId=" + tenantId +
                '}';
    }
}