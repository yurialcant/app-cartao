package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Tenant Entity - SSOT de white-label
 * Representa uma administradora/tenant no sistema
 */
@Table("tenants")
public class Tenant {

    @Id
    private UUID id;

    @Column("slug")
    private String slug; // Unique identifier for URLs/API calls

    @Column("name")
    private String name;

    @Column("description")
    private String description;

    @Column("status")
    private String status; // ACTIVE, INACTIVE, SUSPENDED

    @Column("owner_person_id")
    private UUID ownerPersonId; // Platform Owner or Tenant Owner

    @Column("billing_email")
    private String billingEmail;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Tenant() {}

    // Constructor
    public Tenant(String slug, String name, String description, UUID ownerPersonId) {
        this.slug = slug;
        this.name = name;
        this.description = description;
        this.ownerPersonId = ownerPersonId;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public UUID getOwnerPersonId() { return ownerPersonId; }
    public void setOwnerPersonId(UUID ownerPersonId) { this.ownerPersonId = ownerPersonId; }

    public String getBillingEmail() { return billingEmail; }
    public void setBillingEmail(String billingEmail) { this.billingEmail = billingEmail; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isInactive() { return "INACTIVE".equals(status); }
    public boolean isSuspended() { return "SUSPENDED".equals(status); }
}