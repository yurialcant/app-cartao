package com.benefits.support.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("support_tickets")
public class SupportTicket {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("ticket_number")
    private String ticketNumber;

    @Column("person_id")
    private UUID personId;

    @Column("employer_id")
    private UUID employerId;

    @Column("category")
    private String category;

    @Column("priority")
    private String priority;

    @Column("status")
    private String status;

    @Column("title")
    private String title;

    @Column("description")
    private String description;

    @Column("assigned_to")
    private UUID assignedTo;

    @Column("resolution")
    private String resolution;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    @Column("resolved_at")
    private LocalDateTime resolvedAt;

    @Column("closed_at")
    private LocalDateTime closedAt;

    // Default constructor
    public SupportTicket() {}

    // Constructor
    public SupportTicket(UUID tenantId, String ticketNumber, UUID personId, String category,
                        String priority, String title, String description) {
        this.tenantId = tenantId;
        this.ticketNumber = ticketNumber;
        this.personId = personId;
        this.category = category;
        this.priority = priority;
        this.status = "OPEN";
        this.title = title;
        this.description = description;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }

    public UUID getPersonId() { return personId; }
    public void setPersonId(UUID personId) { this.personId = personId; }

    public UUID getEmployerId() { return employerId; }
    public void setEmployerId(UUID employerId) { this.employerId = employerId; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; this.updatedAt = LocalDateTime.now(); }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; this.updatedAt = LocalDateTime.now(); }

    public String getStatus() { return status; }
    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
        if ("RESOLVED".equals(status)) {
            this.resolvedAt = LocalDateTime.now();
        } else if ("CLOSED".equals(status)) {
            this.closedAt = LocalDateTime.now();
        }
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; this.updatedAt = LocalDateTime.now(); }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; this.updatedAt = LocalDateTime.now(); }

    public UUID getAssignedTo() { return assignedTo; }
    public void setAssignedTo(UUID assignedTo) { this.assignedTo = assignedTo; this.updatedAt = LocalDateTime.now(); }

    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; this.updatedAt = LocalDateTime.now(); }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }

    public LocalDateTime getClosedAt() { return closedAt; }
    public void setClosedAt(LocalDateTime closedAt) { this.closedAt = closedAt; }

    // Business methods
    public boolean isOpen() { return "OPEN".equals(status); }
    public boolean isInProgress() { return "IN_PROGRESS".equals(status); }
    public boolean isResolved() { return "RESOLVED".equals(status); }
    public boolean isClosed() { return "CLOSED".equals(status); }

    public boolean isHighPriority() { return "HIGH".equals(priority) || "CRITICAL".equals(priority); }
    public boolean isLowPriority() { return "LOW".equals(priority); }
}