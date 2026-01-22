package com.benefits.settlement.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "settlements")
@Data
public class Settlement {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "tenant_id")
    private UUID tenantId;

    @Column(name = "settlement_id")
    private String settlementId;

    @Column(name = "merchant_id")
    private UUID merchantId;

    @Column(name = "settlement_date")
    private LocalDate settlementDate;

    @Column(name = "period_start")
    private LocalDate periodStart;

    @Column(name = "period_end")
    private LocalDate periodEnd;

    @Column(name = "total_amount")
    private BigDecimal totalAmount;

    @Column(name = "net_amount")
    private BigDecimal netAmount;

    @Column(name = "fee_amount")
    private BigDecimal feeAmount;

    @Column(name = "transaction_count")
    private Integer transactionCount;

    @Column(name = "status")
    private String status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    // Default constructor
    public Settlement() {}

    // Constructor
    public Settlement(UUID tenantId, String settlementId, UUID merchantId, LocalDate periodStart, LocalDate periodEnd) {
        this.tenantId = tenantId;
        this.settlementId = settlementId;
        this.merchantId = merchantId;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.settlementDate = LocalDate.now();
        this.totalAmount = BigDecimal.ZERO;
        this.netAmount = BigDecimal.ZERO;
        this.feeAmount = BigDecimal.ZERO;
        this.transactionCount = 0;
        this.status = "PENDING";
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getSettlementId() { return settlementId; }
    public void setSettlementId(String settlementId) { this.settlementId = settlementId; }

    public UUID getMerchantId() { return merchantId; }
    public void setMerchantId(UUID merchantId) { this.merchantId = merchantId; }

    public LocalDate getSettlementDate() { return settlementDate; }
    public void setSettlementDate(LocalDate settlementDate) { this.settlementDate = settlementDate; }

    public LocalDate getPeriodStart() { return periodStart; }
    public void setPeriodStart(LocalDate periodStart) { this.periodStart = periodStart; }

    public LocalDate getPeriodEnd() { return periodEnd; }
    public void setPeriodEnd(LocalDate periodEnd) { this.periodEnd = periodEnd; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getNetAmount() { return netAmount; }
    public void setNetAmount(BigDecimal netAmount) { this.netAmount = netAmount; }

    public BigDecimal getFeeAmount() { return feeAmount; }
    public void setFeeAmount(BigDecimal feeAmount) { this.feeAmount = feeAmount; }

    public Integer getTransactionCount() { return transactionCount; }
    public void setTransactionCount(Integer transactionCount) { this.transactionCount = transactionCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) {
        this.status = status;
        LocalDateTime now = LocalDateTime.now();
        if ("COMPLETED".equals(status)) {
            this.processedAt = now;
        } else if ("PAID".equals(status)) {
            this.paidAt = now;
        }
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getProcessedAt() { return processedAt; }
    public void setProcessedAt(LocalDateTime processedAt) { this.processedAt = processedAt; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }

    // Business methods
    public boolean isPending() { return "PENDING".equals(status); }
    public boolean isProcessing() { return "PROCESSING".equals(status); }
    public boolean isCompleted() { return "COMPLETED".equals(status); }
    public boolean isPaid() { return "PAID".equals(status); }
}
