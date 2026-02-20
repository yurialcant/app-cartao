package com.benefits.identity.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * TenantMembership Entity - Acesso ao tenant
 * Define o nível de acesso da pessoa dentro do tenant
 */
@Table("tenant_memberships")
public class TenantMembership {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("person_id")
    private UUID personId;

    @Column("role")
    private String role; // PLATFORM_OWNER, TENANT_OWNER, EMPLOYER_ADMIN, EMPLOYER_USER, MERCHANT_ADMIN, USER

    @Column("status")
    private String status; // ACTIVE, INACTIVE, SUSPENDED

    @Column("granted_by")
    private UUID grantedBy; // Person who granted the access

    @Column("granted_at")
    private LocalDateTime grantedAt;

    @Column("expires_at")
    private LocalDateTime expiresAt; // Optional expiration

    @Column("permissions")
    private String permissions; // JSON array of specific permissions

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public TenantMembership() {}

    // Constructor
    public TenantMembership(UUID tenantId, UUID personId, String role, UUID grantedBy) {
        this.tenantId = tenantId;
        this.personId = personId;
        this.role = role;
        this.grantedBy = grantedBy;
        this.status = "ACTIVE";
        this.grantedAt = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public UUID getPersonId() { return personId; }
    public void setPersonId(UUID personId) { this.personId = personId; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public UUID getGrantedBy() { return grantedBy; }
    public void setGrantedBy(UUID grantedBy) { this.grantedBy = grantedBy; }

    public LocalDateTime getGrantedAt() { return grantedAt; }
    public void setGrantedAt(LocalDateTime grantedAt) { this.grantedAt = grantedAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public String getPermissions() { return permissions; }
    public void setPermissions(String permissions) { this.permissions = permissions; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() {
        return "ACTIVE".equals(status) &&
               (expiresAt == null || LocalDateTime.now().isBefore(expiresAt));
    }

    public boolean isInactive() { return "INACTIVE".equals(status); }
    public boolean isSuspended() { return "SUSPENDED".equals(status); }
    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }

    // Role checks
    public boolean isPlatformOwner() { return "PLATFORM_OWNER".equals(role); }
    public boolean isTenantOwner() { return "TENANT_OWNER".equals(role); }
    public boolean isEmployerAdmin() { return "EMPLOYER_ADMIN".equals(role); }
    public boolean isEmployerUser() { return "EMPLOYER_USER".equals(role); }
    public boolean isMerchantAdmin() { return "MERCHANT_ADMIN".equals(role); }
    public boolean isUser() { return "USER".equals(role); }

    // Permission checks (simplified)
    public boolean hasPermission(String permission) {
        if (permissions == null) return false;
        // In real implementation, parse JSON and check
        return permissions.contains(permission);
    }
}