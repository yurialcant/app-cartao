package com.benefits.privacy.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import com.fasterxml.jackson.databind.JsonNode;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("data_subject_requests")
public class DataSubjectRequest {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("request_id")
    private String requestId;

    @Column("person_id")
    private UUID personId;

    @Column("request_type")
    private String requestType;

    @Column("status")
    private String status;

    @Column("description")
    private String description;

    @Column("requested_at")
    private LocalDateTime requestedAt;

    @Column("completed_at")
    private LocalDateTime completedAt;

    @Column("response_data")
    private JsonNode responseData;

    @Column("created_at")
    private LocalDateTime createdAt;

    // Default constructor
    public DataSubjectRequest() {}

    // Constructor
    public DataSubjectRequest(UUID tenantId, String requestId, UUID personId, String requestType, String description) {
        this.tenantId = tenantId;
        this.requestId = requestId;
        this.personId = personId;
        this.requestType = requestType;
        this.status = "PENDING";
        this.description = description;
        this.requestedAt = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getRequestId() { return requestId; }
    public void setRequestId(String requestId) { this.requestId = requestId; }

    public UUID getPersonId() { return personId; }
    public void setPersonId(UUID personId) { this.personId = personId; }

    public String getRequestType() { return requestType; }
    public void setRequestType(String requestType) { this.requestType = requestType; }

    public String getStatus() { return status; }
    public void setStatus(String status) {
        this.status = status;
        if ("COMPLETED".equals(status) || "REJECTED".equals(status)) {
            this.completedAt = LocalDateTime.now();
        }
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public JsonNode getResponseData() { return responseData; }
    public void setResponseData(JsonNode responseData) { this.responseData = responseData; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Business methods
    public boolean isPending() { return "PENDING".equals(status); }
    public boolean isInProgress() { return "IN_PROGRESS".equals(status); }
    public boolean isCompleted() { return "COMPLETED".equals(status); }
    public boolean isRejected() { return "REJECTED".equals(status); }
}