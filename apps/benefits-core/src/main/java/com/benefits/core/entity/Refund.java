package com.benefits.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Refund Entity
 *
 * Represents a refund request for a previous transaction (F07)
 */
@Table("refunds")
public class Refund {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("person_id")
    private UUID personId;

    @Column("wallet_id")
    private UUID walletId;

    @Column("original_transaction_id")
    private String originalTransactionId;

    @Column("amount")
    private BigDecimal amount;

    @Column("currency")
    private String currency = "BRL";

    @Column("reason")
    private String reason;

    @Column("status")
    private String status = "PENDING";

    @Column("idempotency_key")
    private String idempotencyKey;

    @Column("created_at")
    private Instant createdAt;

    @Column("updated_at")
    private Instant updatedAt;

    @Column("processed_at")
    private Instant processedAt;

    @Column("authorization_code")
    private String authorizationCode;

    @Column("error_message")
    private String errorMessage;

    // Constructors
    public Refund() {
    }

    public Refund(UUID tenantId, UUID personId, UUID walletId, String originalTransactionId,
            BigDecimal amount, String reason, String idempotencyKey) {
        this.tenantId = tenantId;
        this.personId = personId;
        this.walletId = walletId;
        this.originalTransactionId = originalTransactionId;
        this.amount = amount;
        this.reason = reason;
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

    public String getOriginalTransactionId() {
        return originalTransactionId;
    }

    public void setOriginalTransactionId(String originalTransactionId) {
        this.originalTransactionId = originalTransactionId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = Instant.now();
    }

    public String getIdempotencyKey() {
        return idempotencyKey;
    }

    public void setIdempotencyKey(String idempotencyKey) {
        this.idempotencyKey = idempotencyKey;
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

    public Instant getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(Instant processedAt) {
        this.processedAt = processedAt;
    }

    public String getAuthorizationCode() {
        return authorizationCode;
    }

    public void setAuthorizationCode(String authorizationCode) {
        this.authorizationCode = authorizationCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return "Refund{" +
                "id=" + id +
                ", tenantId=" + tenantId +
                ", personId=" + personId +
                ", walletId=" + walletId +
                ", originalTransactionId='" + originalTransactionId + '\'' +
                ", amount=" + amount +
                ", currency='" + currency + '\'' +
                ", reason='" + reason + '\'' +
                ", status='" + status + '\'' +
                ", idempotencyKey='" + idempotencyKey + '\'' +
                ", authorizationCode='" + authorizationCode + '\'' +
                '}';
    }
}