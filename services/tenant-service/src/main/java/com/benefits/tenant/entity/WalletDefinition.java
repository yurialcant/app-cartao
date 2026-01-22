package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * WalletDefinition Entity - Tipos de wallet disponíveis
 * Define os tipos de carteira permitidos no tenant
 */
@Table("wallet_definitions")
public class WalletDefinition {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("wallet_type")
    private String walletType; // Unique within tenant (e.g., "MEAL", "FOOD", "FUEL")

    @Column("name")
    private String name; // Display name (e.g., "Refeição", "Alimentação")

    @Column("description")
    private String description;

    @Column("icon_url")
    private String iconUrl;

    @Column("color")
    private String color; // Hex color for UI

    @Column("category")
    private String category; // MEAL, FOOD, FUEL, HEALTH, etc.

    @Column("is_default")
    private Boolean isDefault; // If true, available by default in plans

    @Column("status")
    private String status; // ACTIVE, INACTIVE

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public WalletDefinition() {}

    // Constructor
    public WalletDefinition(UUID tenantId, String walletType, String name, String category) {
        this.tenantId = tenantId;
        this.walletType = walletType;
        this.name = name;
        this.category = category;
        this.isDefault = false;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getWalletType() { return walletType; }
    public void setWalletType(String walletType) { this.walletType = walletType; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isInactive() { return "INACTIVE".equals(status); }
}