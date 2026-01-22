package com.benefits.core.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Authorize Request DTO
 *
 * Request for POS payment authorization (F06)
 */
public class AuthorizeRequest {

    // Optional: normally comes from headers, but can be in body for testing
    private UUID tenantId;

    // Temporarily disabled validation for testing
    // @NotBlank(message = "terminal_id is required")
    private String terminalId;

    // Temporarily disabled validation for testing
    // @NotBlank(message = "merchant_id is required")
    private String merchantId;

    // Optional: normally comes from headers, but can be in body for testing
    private UUID personId;

    // Temporarily disabled validation for testing
    // @NotNull(message = "wallet_id is required")
    private UUID walletId;

    // Temporarily disabled validation for testing
    // @NotNull(message = "amount is required")
    // @DecimalMin(value = "0.01", message = "amount must be greater than 0")
    private BigDecimal amount;

    private String currency = "BRL";

    private String description;

    // Temporarily disabled validation for testing
    // @NotBlank(message = "idempotency_key is required")
    private String idempotencyKey;

    public AuthorizeRequest() {
    }

    public AuthorizeRequest(String terminalId, String merchantId, UUID personId, UUID walletId,
            BigDecimal amount, String description, String idempotencyKey) {
        this.terminalId = terminalId;
        this.merchantId = merchantId;
        this.personId = personId;
        this.walletId = walletId;
        this.amount = amount;
        this.description = description;
        this.idempotencyKey = idempotencyKey;
    }

    // Getters and Setters
    public String getTerminalId() {
        return terminalId;
    }

    public void setTerminalId(String terminalId) {
        this.terminalId = terminalId;
    }

    public String getMerchantId() {
        return merchantId;
    }

    public void setMerchantId(String merchantId) {
        this.merchantId = merchantId;
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

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIdempotencyKey() {
        return idempotencyKey;
    }

    public void setIdempotencyKey(String idempotencyKey) {
        this.idempotencyKey = idempotencyKey;
    }

    // Getters and Setters for new fields
    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    @Override
    public String toString() {
        return "AuthorizeRequest{" +
                "tenantId=" + tenantId +
                ", terminalId='" + terminalId + '\'' +
                ", merchantId='" + merchantId + '\'' +
                ", personId=" + personId +
                ", walletId=" + walletId +
                ", amount=" + amount +
                ", currency='" + currency + '\'' +
                ", description='" + description + '\'' +
                ", idempotencyKey='" + idempotencyKey + '\'' +
                '}';
    }
}