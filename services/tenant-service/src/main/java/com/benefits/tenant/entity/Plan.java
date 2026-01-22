package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Plan Entity - Catálogo de planos do tenant
 * Define recursos e limitações disponíveis
 */
@Table("plans")
public class Plan {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("plan_code")
    private String planCode; // Unique within tenant

    @Column("name")
    private String name;

    @Column("description")
    private String description;

    @Column("status")
    private String status; // ACTIVE, INACTIVE, DEPRECATED

    @Column("wallet_types")
    private String walletTypesJson; // JSON array of allowed wallet types

    @Column("max_employees")
    private Integer maxEmployees;

    @Column("monthly_credit_limit_cents")
    private Long monthlyCreditLimitCents;

    @Column("transaction_limit_cents")
    private Long transactionLimitCents;

    @Column("daily_transaction_limit")
    private Integer dailyTransactionLimit;

    @Column("features")
    private String featuresJson; // JSON object with enabled features

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Plan() {}

    // Constructor
    public Plan(UUID tenantId, String planCode, String name, String description) {
        this.tenantId = tenantId;
        this.planCode = planCode;
        this.name = name;
        this.description = description;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getPlanCode() { return planCode; }
    public void setPlanCode(String planCode) { this.planCode = planCode; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public String getWalletTypesJson() { return walletTypesJson; }
    public void setWalletTypesJson(String walletTypesJson) { this.walletTypesJson = walletTypesJson; }

    public Integer getMaxEmployees() { return maxEmployees; }
    public void setMaxEmployees(Integer maxEmployees) { this.maxEmployees = maxEmployees; }

    public Long getMonthlyCreditLimitCents() { return monthlyCreditLimitCents; }
    public void setMonthlyCreditLimitCents(Long monthlyCreditLimitCents) { this.monthlyCreditLimitCents = monthlyCreditLimitCents; }

    public Long getTransactionLimitCents() { return transactionLimitCents; }
    public void setTransactionLimitCents(Long transactionLimitCents) { this.transactionLimitCents = transactionLimitCents; }

    public Integer getDailyTransactionLimit() { return dailyTransactionLimit; }
    public void setDailyTransactionLimit(Integer dailyTransactionLimit) { this.dailyTransactionLimit = dailyTransactionLimit; }

    public String getFeaturesJson() { return featuresJson; }
    public void setFeaturesJson(String featuresJson) { this.featuresJson = featuresJson; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isInactive() { return "INACTIVE".equals(status); }
    public boolean isDeprecated() { return "DEPRECATED".equals(status); }

    // Helper methods for JSON fields (would need Jackson in real implementation)
    public List<String> getWalletTypes() {
        // Parse JSON - simplified for now
        return walletTypesJson != null ? List.of() : List.of();
    }

    public void setWalletTypes(List<String> walletTypes) {
        // Convert to JSON - simplified for now
        this.walletTypesJson = "[]";
    }
}