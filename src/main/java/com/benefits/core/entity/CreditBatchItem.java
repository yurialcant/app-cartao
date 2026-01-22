package com.benefits.core.entity;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Entity for credit_batch_items table.
 * Matches actual table structure: id (UUID), tenant_id, batch_id, user_id,
 * wallet_type, amount_cents, status, error_message, created_at, processed_at
 */
@Table("credit_batch_items")
public class CreditBatchItem {

    @Id
    @Column("id")
    private UUID id;

    @Column("batch_id")
    private UUID batchId;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("user_id")
    private UUID userId;

    @Column("wallet_type")
    private String walletType;

    @Column("amount_cents")
    private Long amountCents;

    @Column("status")
    private String status;

    @Column("error_message")
    private String errorMessage;

    @Column("processed_at")
    private Instant processedAt;

    @CreatedDate
    @Column("created_at")
    private Instant createdAt;

    public CreditBatchItem() {
    }

    public CreditBatchItem(UUID batchId, UUID tenantId, UUID userId,
            String walletType, Long amountCents) {
        this.id = UUID.randomUUID();
        this.batchId = batchId;
        this.tenantId = tenantId;
        this.userId = userId;
        this.walletType = walletType;
        this.amountCents = amountCents;
        this.status = "PENDING";
        this.createdAt = Instant.now();
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getBatchId() {
        return batchId;
    }

    public void setBatchId(UUID batchId) {
        this.batchId = batchId;
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getWalletType() {
        return walletType;
    }

    public void setWalletType(String walletType) {
        this.walletType = walletType;
    }

    public Long getAmountCents() {
        return amountCents;
    }

    public void setAmountCents(Long amountCents) {
        this.amountCents = amountCents;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public Instant getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(Instant processedAt) {
        this.processedAt = processedAt;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    // Compatibility methods for service
    public UUID getPersonId() {
        return userId; // Map person_id to user_id
    }

    public void setPersonId(UUID personId) {
        this.userId = personId;
    }

    public UUID getWalletId() {
        // Cannot map wallet_id to wallet_type, return null or throw
        return null;
    }

    public void setWalletId(UUID walletId) {
        // Cannot map wallet_id to wallet_type, no-op
    }

    public BigDecimal getAmount() {
        return amountCents != null ? BigDecimal.valueOf(amountCents).divide(BigDecimal.valueOf(100)) : BigDecimal.ZERO;
    }

    public void setAmount(BigDecimal amount) {
        this.amountCents = amount != null ? amount.multiply(BigDecimal.valueOf(100)).longValue() : 0L;
    }

    public String getReference() {
        return null; // Not stored in current schema
    }

    public void setReference(String reference) {
        // No-op
    }

    public UUID getLedgerEntryId() {
        return null; // Not stored in current schema
    }

    public void setLedgerEntryId(UUID ledgerEntryId) {
        // No-op
    }

    // Business methods
    public void markAsProcessed() {
        this.status = "PROCESSED";
        this.processedAt = Instant.now();
    }

    public void markAsFailed(String errorMessage) {
        this.status = "FAILED";
        this.errorMessage = errorMessage;
        this.processedAt = Instant.now();
    }

    @Override
    public String toString() {
        return "CreditBatchItem{" +
                "id=" + id +
                ", batchId=" + batchId +
                ", tenantId=" + tenantId +
                ", userId=" + userId +
                ", walletType='" + walletType + '\'' +
                ", amountCents=" + amountCents +
                ", status='" + status + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                ", processedAt=" + processedAt +
                ", createdAt=" + createdAt +
                '}';
    }
}
