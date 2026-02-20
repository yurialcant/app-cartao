package com.benefits.audit.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import com.fasterxml.jackson.databind.JsonNode;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("compliance_events")
public class ComplianceEvent {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("event_type")
    private String eventType;

    @Column("severity")
    private String severity;

    @Column("description")
    private String description;

    @Column("user_id")
    private UUID userId;

    @Column("resource_type")
    private String resourceType;

    @Column("resource_id")
    private String resourceId;

    @Column("ip_address")
    private String ipAddress;

    @Column("user_agent")
    private String userAgent;

    @Column("metadata")
    private JsonNode metadata;

    @Column("created_at")
    private LocalDateTime createdAt;

    // Default constructor
    public ComplianceEvent() {}

    // Constructor
    public ComplianceEvent(UUID tenantId, String eventType, String severity, String description) {
        this.tenantId = tenantId;
        this.eventType = eventType;
        this.severity = severity;
        this.description = description;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public String getResourceType() { return resourceType; }
    public void setResourceType(String resourceType) { this.resourceType = resourceType; }

    public String getResourceId() { return resourceId; }
    public void setResourceId(String resourceId) { this.resourceId = resourceId; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    public JsonNode getMetadata() { return metadata; }
    public void setMetadata(JsonNode metadata) { this.metadata = metadata; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Business methods
    public boolean isCritical() { return "CRITICAL".equals(severity); }
    public boolean isError() { return "ERROR".equals(severity); }
    public boolean isWarning() { return "WARNING".equals(severity); }
}