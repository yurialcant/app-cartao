package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Contract Entity - Tenant ↔ Employer
 * Define o contrato entre tenant e employer
 */
@Table("contracts")
public class Contract {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("employer_id")
    private UUID employerId;

    @Column("plan_code")
    private String planCode; // Reference to plan

    @Column("contract_number")
    private String contractNumber; // Unique identifier

    @Column("start_date")
    private LocalDate startDate;

    @Column("end_date")
    private LocalDate endDate; // Optional

    @Column("status")
    private String status; // ACTIVE, INACTIVE, CANCELLED, EXPIRED

    @Column("billing_cycle")
    private String billingCycle; // MONTHLY, QUARTERLY, ANNUALLY

    @Column("monthly_fee_cents")
    private Long monthlyFeeCents;

    @Column("transaction_fee_percent")
    private Integer transactionFeePercent; // Basis points (e.g., 25 = 0.25%)

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Contract() {}

    // Constructor
    public Contract(UUID tenantId, UUID employerId, String planCode,
                   LocalDate startDate, LocalDate endDate) {
        this.tenantId = tenantId;
        this.employerId = employerId;
        this.planCode = planCode;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = "ACTIVE";
        this.billingCycle = "MONTHLY";
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

    public String getPlanCode() { return planCode; }
    public void setPlanCode(String planCode) { this.planCode = planCode; }

    public String getContractNumber() { return contractNumber; }
    public void setContractNumber(String contractNumber) { this.contractNumber = contractNumber; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public String getBillingCycle() { return billingCycle; }
    public void setBillingCycle(String billingCycle) { this.billingCycle = billingCycle; }

    public Long getMonthlyFeeCents() { return monthlyFeeCents; }
    public void setMonthlyFeeCents(Long monthlyFeeCents) { this.monthlyFeeCents = monthlyFeeCents; }

    public Integer getTransactionFeePercent() { return transactionFeePercent; }
    public void setTransactionFeePercent(Integer transactionFeePercent) { this.transactionFeePercent = transactionFeePercent; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() {
        return "ACTIVE".equals(status) && !isExpired();
    }

    public boolean isExpired() {
        return endDate != null && LocalDate.now().isAfter(endDate);
    }

    public boolean isInactive() { return "INACTIVE".equals(status); }
    public boolean isCancelled() { return "CANCELLED".equals(status); }

    public boolean hasValidDates() {
        return startDate != null && (endDate == null || endDate.isAfter(startDate));
    }
}