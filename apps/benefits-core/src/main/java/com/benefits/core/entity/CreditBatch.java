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
 * Entity for credit_batches table.
 * Matches actual table structure: id (UUID), tenant_id, employer_id,
 * batch_name, status,
 * total_amount_cents, total_items, created_at, updated_at, processed_at
 */
@Table("credit_batches")
public class CreditBatch {

    @Id
    @Column("id")
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("employer_id")
    private UUID employerId;

    @Column("batch_name")
    private String batchName;

    @Column("status")
    private String status;

    @Column("total_amount_cents")
    private Long totalAmountCents;

    @Column("total_items")
    private Integer totalItems;

    @Column("processed_at")
    private Instant processedAt;

    @Column("idempotency_key")
    private String idempotencyKey;

    @CreatedDate
    @Column("created_at")
    private Instant createdAt;

    @LastModifiedDate
    @Column("updated_at")
    private Instant updatedAt;

    public CreditBatch() {
    }

    public CreditBatch(UUID tenantId, UUID employerId, String batchName,
            Long totalAmountCents, Integer totalItems, String idempotencyKey) {
        this.id = UUID.randomUUID();
        this.tenantId = tenantId;
        this.employerId = employerId;
        this.batchName = batchName;
        this.status = "SUBMITTED";
        this.totalAmountCents = totalAmountCents;
        this.totalItems = totalItems;
        this.idempotencyKey = idempotencyKey;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }
    
    public String getIdempotencyKey() {
        return idempotencyKey;
    }

    public void setIdempotencyKey(String idempotencyKey) {
        this.idempotencyKey = idempotencyKey;
    }

    public UUID getEmployerId() {
        return employerId;
    }

    public void setEmployerId(UUID employerId) {
        this.employerId = employerId;
    }

    public String getBatchName() {
        return batchName;
    }

    public void setBatchName(String batchName) {
        this.batchName = batchName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getTotalAmountCents() {
        return totalAmountCents;
    }

    public void setTotalAmountCents(Long totalAmountCents) {
        this.totalAmountCents = totalAmountCents;
    }

    public Integer getTotalItems() {
        return totalItems;
    }

    public void setTotalItems(Integer totalItems) {
        this.totalItems = totalItems;
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

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Compatibility methods for service
    public String getBatchReference() {
        return batchName;
    }

    public void setBatchReference(String batchReference) {
        this.batchName = batchReference;
    }

    public UUID getBatchId() {
        return id; // Use id as batchId for compatibility
    }

    public void setBatchId(UUID batchId) {
        this.id = batchId;
    }

    public BigDecimal getTotalAmount() {
        return totalAmountCents != null ? BigDecimal.valueOf(totalAmountCents).divide(BigDecimal.valueOf(100))
                : BigDecimal.ZERO;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmountCents = totalAmount != null ? totalAmount.multiply(BigDecimal.valueOf(100)).longValue() : 0L;
    }

    // Compatibility methods (not in DB but used by service)
    public Integer getProcessedItems() {
        return 0; // Not stored in current schema
    }

    public void setProcessedItems(Integer processedItems) {
        // No-op
    }

    public UUID getActorId() {
        return null; // Not stored in current schema
    }

    public void setActorId(UUID actorId) {
        // No-op
    }

    public UUID getCorrelationId() {
        return null; // Not stored in current schema
    }

    public void setCorrelationId(UUID correlationId) {
        // No-op
    }

    public String getIdempotencyKey() {
        return null; // Not stored in current schema
    }

    public void setIdempotencyKey(String idempotencyKey) {
        // No-op
    }

    // Business methods
    public void markAsProcessing() {
        this.status = "PROCESSING";
        this.updatedAt = Instant.now();
    }

    public void markAsCompleted() {
        this.status = "COMPLETED";
        this.processedAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public void markAsFailed() {
        this.status = "FAILED";
        this.processedAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public void incrementProcessedItems() {
        // No-op: processedItems not stored in current schema
        this.updatedAt = Instant.now();
    }

    @Override
    public String toString() {
        return "CreditBatch{" +
                "id=" + id +
                ", tenantId=" + tenantId +
                ", employerId=" + employerId +
                ", batchName='" + batchName + '\'' +
                ", status='" + status + '\'' +
                ", totalAmountCents=" + totalAmountCents +
                ", totalItems=" + totalItems +
                ", processedAt=" + processedAt +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
