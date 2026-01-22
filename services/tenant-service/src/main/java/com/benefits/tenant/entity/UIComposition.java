package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * UIComposition Entity - Home JSON e schemas
 * Define a composição da interface do usuário
 */
@Table("ui_composition")
public class UIComposition {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("schema_version")
    private String schemaVersion; // Version for validation

    @Column("home_json")
    private String homeJson; // JSON with home screen composition

    @Column("navigation_config")
    private String navigationConfig; // JSON with navigation rules

    @Column("feature_flags")
    private String featureFlags; // JSON with feature toggles

    @Column("status")
    private String status; // ACTIVE, DRAFT, VALIDATION_FAILED

    @Column("validation_errors")
    private String validationErrors; // JSON array of validation errors

    @Column("published_at")
    private LocalDateTime publishedAt;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public UIComposition() {}

    // Constructor
    public UIComposition(UUID tenantId, String schemaVersion, String homeJson) {
        this.tenantId = tenantId;
        this.schemaVersion = schemaVersion;
        this.homeJson = homeJson;
        this.status = "DRAFT";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getSchemaVersion() { return schemaVersion; }
    public void setSchemaVersion(String schemaVersion) { this.schemaVersion = schemaVersion; }

    public String getHomeJson() { return homeJson; }
    public void setHomeJson(String homeJson) { this.homeJson = homeJson; this.updatedAt = LocalDateTime.now(); }

    public String getNavigationConfig() { return navigationConfig; }
    public void setNavigationConfig(String navigationConfig) { this.navigationConfig = navigationConfig; }

    public String getFeatureFlags() { return featureFlags; }
    public void setFeatureFlags(String featureFlags) { this.featureFlags = featureFlags; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public String getValidationErrors() { return validationErrors; }
    public void setValidationErrors(String validationErrors) { this.validationErrors = validationErrors; }

    public LocalDateTime getPublishedAt() { return publishedAt; }
    public void setPublishedAt(LocalDateTime publishedAt) { this.publishedAt = publishedAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isDraft() { return "DRAFT".equals(status); }
    public boolean hasValidationErrors() { return "VALIDATION_FAILED".equals(status); }

    public void publish() {
        if (!hasValidationErrors()) {
            this.status = "ACTIVE";
            this.publishedAt = LocalDateTime.now();
            this.updatedAt = LocalDateTime.now();
        }
    }

    public void markAsFailed(String errors) {
        this.status = "VALIDATION_FAILED";
        this.validationErrors = errors;
        this.updatedAt = LocalDateTime.now();
    }
}