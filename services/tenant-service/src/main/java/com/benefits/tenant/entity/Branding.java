package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Branding Entity - White-label visual
 * Cores, logos, nome da aplicação
 */
@Table("branding")
public class Branding {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("app_name")
    private String appName;

    @Column("primary_color")
    private String primaryColor; // Hex color

    @Column("secondary_color")
    private String secondaryColor; // Hex color

    @Column("logo_url")
    private String logoUrl;

    @Column("favicon_url")
    private String faviconUrl;

    @Column("support_email")
    private String supportEmail;

    @Column("support_phone")
    private String supportPhone;

    @Column("terms_url")
    private String termsUrl;

    @Column("privacy_url")
    private String privacyUrl;

    @Column("status")
    private String status; // ACTIVE, DRAFT

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Branding() {}

    // Constructor
    public Branding(UUID tenantId, String appName, String primaryColor) {
        this.tenantId = tenantId;
        this.appName = appName;
        this.primaryColor = primaryColor;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getAppName() { return appName; }
    public void setAppName(String appName) { this.appName = appName; }

    public String getPrimaryColor() { return primaryColor; }
    public void setPrimaryColor(String primaryColor) { this.primaryColor = primaryColor; }

    public String getSecondaryColor() { return secondaryColor; }
    public void setSecondaryColor(String secondaryColor) { this.secondaryColor = secondaryColor; }

    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }

    public String getFaviconUrl() { return faviconUrl; }
    public void setFaviconUrl(String faviconUrl) { this.faviconUrl = faviconUrl; }

    public String getSupportEmail() { return supportEmail; }
    public void setSupportEmail(String supportEmail) { this.supportEmail = supportEmail; }

    public String getSupportPhone() { return supportPhone; }
    public void setSupportPhone(String supportPhone) { this.supportPhone = supportPhone; }

    public String getTermsUrl() { return termsUrl; }
    public void setTermsUrl(String termsUrl) { this.termsUrl = termsUrl; }

    public String getPrivacyUrl() { return privacyUrl; }
    public void setPrivacyUrl(String privacyUrl) { this.privacyUrl = privacyUrl; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isDraft() { return "DRAFT".equals(status); }
}