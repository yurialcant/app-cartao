package com.benefits.core.entity;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * LedgerEntry Entity
 *
 * Immutable transaction log - Source of Truth for balance changes.
 * Part of F06 POS Authorize flow - records all debit/credit transactions.
 *
 * This is the immutable audit trail for all wallet balance changes.
 */
@Table("ledger_entries")
public class LedgerEntry {

    @Id
    @Column("id")
    private UUID id;

    @Column("tenant_id")
    private String tenantId;

    @Column("wallet_id")
    private UUID walletId;

    @Column("entry_type")
    private String entryType; // CREDIT, DEBIT

    @Column("amount")
    private BigDecimal amount;

    @Column("description")
    private String description;

    @Column("reference_id")
    private String referenceId; // payment_id, refund_id, etc.

    @Column("reference_type")
    private String referenceType; // PAYMENT, REFUND, ADJUSTMENT, etc.

    @Column("status")
    private String status;

    @CreatedDate
    @Column("created_at")
    private Instant createdAt;

    public LedgerEntry() {}

    public LedgerEntry(String tenantId, UUID walletId, String entryType, BigDecimal amount, String description) {
        this.id = UUID.randomUUID();
        this.tenantId = tenantId;
        this.walletId = walletId;
        this.entryType = entryType;
        this.amount = amount;
        this.description = description;
        this.status = "COMPLETED";
        this.createdAt = Instant.now();
    }

    public LedgerEntry(String tenantId, UUID walletId, String entryType, BigDecimal amount,
                      String description, String referenceId, String referenceType) {
        this.id = UUID.randomUUID();
        this.tenantId = tenantId;
        this.walletId = walletId;
        this.entryType = entryType;
        this.amount = amount;
        this.description = description;
        this.referenceId = referenceId;
        this.referenceType = referenceType;
        this.status = "COMPLETED";
        this.createdAt = Instant.now();
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getTenantId() {
        return tenantId;
    }

    public void setTenantId(String tenantId) {
        this.tenantId = tenantId;
    }

    public UUID getWalletId() {
        return walletId;
    }

    public void setWalletId(UUID walletId) {
        this.walletId = walletId;
    }

    public String getEntryType() {
        return entryType;
    }

    public void setEntryType(String entryType) {
        this.entryType = entryType;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(String referenceId) {
        this.referenceId = referenceId;
    }

    public String getReferenceType() {
        return referenceType;
    }

    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "LedgerEntry{" +
                "id=" + id +
                ", tenantId='" + tenantId + '\'' +
                ", walletId=" + walletId +
                ", entryType='" + entryType + '\'' +
                ", amount=" + amount +
                ", description='" + description + '\'' +
                ", referenceId='" + referenceId + '\'' +
                ", referenceType='" + referenceType + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}