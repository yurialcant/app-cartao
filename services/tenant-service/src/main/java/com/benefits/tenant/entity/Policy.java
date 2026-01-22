package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Policy Entity - Regras de gasto e limitações
 * Define políticas de uso por tenant/employer/wallet_type
 */
@Table("policies")
public class Policy {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("employer_id")
    private UUID employerId; // Optional - can be tenant-wide or employer-specific

    @Column("wallet_type")
    private String walletType; // Optional - can be wallet-specific

    @Column("policy_type")
    private String policyType; // LIMIT, ALLOW_DENY, REQUIREMENT

    @Column("name")
    private String name;

    @Column("description")
    private String description;

    @Column("rules_json")
    private String rulesJson; // JSON with policy rules

    @Column("priority")
    private Integer priority; // Higher number = higher priority

    @Column("status")
    private String status; // ACTIVE, INACTIVE

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Policy() {}

    // Constructor
    public Policy(UUID tenantId, String policyType, String name, String rulesJson) {
        this.tenantId = tenantId;
        this.policyType = policyType;
        this.name = name;
        this.rulesJson = rulesJson;
        this.priority = 0;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public UUID getEmployerId() { return employerId; }
    public void setEmployerId(UUID employerId) { this.employerId = employerId; }

    public String getWalletType() { return walletType; }
    public void setWalletType(String walletType) { this.walletType = walletType; }

    public String getPolicyType() { return policyType; }
    public void setPolicyType(String policyType) { this.policyType = policyType; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getRulesJson() { return rulesJson; }
    public void setRulesJson(String rulesJson) { this.rulesJson = rulesJson; }

    public Integer getPriority() { return priority; }
    public void setPriority(Integer priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isInactive() { return "INACTIVE".equals(status); }

    public boolean isLimitPolicy() { return "LIMIT".equals(policyType); }
    public boolean isAllowDenyPolicy() { return "ALLOW_DENY".equals(policyType); }
    public boolean isRequirementPolicy() { return "REQUIREMENT".equals(policyType); }

    public boolean isTenantWide() { return employerId == null; }
    public boolean isEmployerSpecific() { return employerId != null; }
    public boolean isWalletSpecific() { return walletType != null; }
}