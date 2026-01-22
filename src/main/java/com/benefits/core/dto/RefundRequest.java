package com.benefits.core.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Refund Request DTO
 *
 * Request for processing a refund (F07)
 */
public class RefundRequest {

    // Optional: normally comes from headers, but can be in body for testing
    private UUID tenantId;

    @NotNull(message = "person_id is required")
    private UUID personId;

    @NotNull(message = "wallet_id is required")
    private UUID walletId;

    @NotBlank(message = "original_transaction_id is required")
    private String originalTransactionId;

    @NotNull(message = "amount is required")
    @DecimalMin(value = "0.01", message = "amount must be greater than 0")
    private BigDecimal amount;

    private String currency = "BRL";

    private String reason;

    @NotBlank(message = "idempotency_key is required")
    private String idempotencyKey;

    public RefundRequest() {
    }

    public RefundRequest(UUID personId, UUID walletId, String originalTransactionId,
            BigDecimal amount, String reason, String idempotencyKey) {
        this.personId = personId;
        this.walletId = walletId;
        this.originalTransactionId = originalTransactionId;
        this.amount = amount;
        this.reason = reason;
        this.idempotencyKey = idempotencyKey;
    }

    // Getters and Setters
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

    public String getIdempotencyKey() {
        return idempotencyKey;
    }

    public void setIdempotencyKey(String idempotencyKey) {
        this.idempotencyKey = idempotencyKey;
    }

    @Override
    public String toString() {
        return "RefundRequest{" +
                "tenantId=" + tenantId +
                ", personId=" + personId +
                ", walletId=" + walletId +
                ", originalTransactionId='" + originalTransactionId + '\'' +
                ", amount=" + amount +
                ", currency='" + currency + '\'' +
                ", reason='" + reason + '\'' +
                ", idempotencyKey='" + idempotencyKey + '\'' +
                '}';
    }
}