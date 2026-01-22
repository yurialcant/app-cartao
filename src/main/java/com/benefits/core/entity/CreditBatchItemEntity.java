package com.benefits.core.entity;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Table("credit_batch_items")
public class CreditBatchItemEntity {

    @Id
    @Column("id")
    private UUID id;

    @Column("batch_id")
    private UUID batchId;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("person_id")
    private UUID personId;

    @Column("wallet_id")
    private UUID walletId;

    @Column("amount")
    private BigDecimal amount;

    @Column("reference")
    private String reference;

    @Column("status")
    private String status; // PENDING, PROCESSED, FAILED

    @Column("error_message")
    private String errorMessage;

    @Column("processed_at")
    private Instant processedAt;

    @Column("ledger_entry_id")
    private UUID ledgerEntryId;

    @CreatedDate
    @Column("created_at")
    private Instant createdAt;

    @LastModifiedDate
    @Column("updated_at")
    private Instant updatedAt;

    @Version
    @Column("version")
    private Long version;

    // Constructors
    public CreditBatchItemEntity() {}

    public CreditBatchItemEntity(UUID batchId, UUID tenantId, UUID personId,
                               UUID walletId, BigDecimal amount, String reference) {
        this.id = UUID.randomUUID();
        this.batchId = batchId;
        this.tenantId = tenantId;
        this.personId = personId;
        this.walletId = walletId;
        this.amount = amount;
        this.reference = reference;
        this.status = "PENDING";
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
        this.version = 0L;
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

    public UUID getPersonId() {
        return personId;
    }

    public void setPersonId(UUID personId) {
        this.personId = personId;
    }

    public UUID getWalletId() {
        return walletId;
    }

    public void setWalletId(UUID walletId) {
        this.walletId = walletId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
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

    public UUID getLedgerEntryId() {
        return ledgerEntryId;
    }

    public void setLedgerEntryId(UUID ledgerEntryId) {
        this.ledgerEntryId = ledgerEntryId;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Long getVersion() {
        return version;
    }

    public void setVersion(Long version) {
        this.version = version;
    }

    // Business methods
    public void markAsProcessed(UUID ledgerEntryId) {
        this.status = "PROCESSED";
        this.processedAt = Instant.now();
        this.ledgerEntryId = ledgerEntryId;
        this.updatedAt = Instant.now();
    }

    public void markAsFailed(String errorMessage) {
        this.status = "FAILED";
        this.errorMessage = errorMessage;
        this.processedAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @Override
    public String toString() {
        return "CreditBatchItemEntity{" +
                "id=" + id +
                ", batchId=" + batchId +
                ", tenantId=" + tenantId +
                ", personId=" + personId +
                ", walletId=" + walletId +
                ", amount=" + amount +
                ", reference='" + reference + '\'' +
                ", status='" + status + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                ", processedAt=" + processedAt +
                ", ledgerEntryId=" + ledgerEntryId +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", version=" + version +
                '}';
    }
}