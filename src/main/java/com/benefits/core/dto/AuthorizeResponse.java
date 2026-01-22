package com.benefits.core.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Authorize Response DTO
 *
 * Response for POS payment authorization (F06)
 */
public class AuthorizeResponse {

    private String authorizationCode;
    private String status;
    private BigDecimal amount;
    private BigDecimal balanceBefore;
    private BigDecimal balanceAfter;
    private UUID transactionId;
    private Instant timestamp;
    private String errorCode;
    private String errorMessage;

    public AuthorizeResponse() {
    }

    public AuthorizeResponse(String authorizationCode, String status, BigDecimal amount,
            BigDecimal balanceBefore, BigDecimal balanceAfter, UUID transactionId) {
        this.authorizationCode = authorizationCode;
        this.status = status;
        this.amount = amount;
        this.balanceBefore = balanceBefore;
        this.balanceAfter = balanceAfter;
        this.transactionId = transactionId;
        this.timestamp = Instant.now();
    }

    // Factory methods for different scenarios
    public static AuthorizeResponse approved(String authorizationCode, BigDecimal amount,
            BigDecimal balanceBefore, BigDecimal balanceAfter, UUID transactionId) {
        return new AuthorizeResponse(authorizationCode, "APPROVED", amount, balanceBefore, balanceAfter, transactionId);
    }

    public static AuthorizeResponse declined(String errorCode, String errorMessage) {
        AuthorizeResponse response = new AuthorizeResponse();
        response.setStatus("DECLINED");
        response.setErrorCode(errorCode);
        response.setErrorMessage(errorMessage);
        response.setTimestamp(Instant.now());
        return response;
    }

    // Getters and Setters
    public String getAuthorizationCode() {
        return authorizationCode;
    }

    public void setAuthorizationCode(String authorizationCode) {
        this.authorizationCode = authorizationCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public BigDecimal getBalanceBefore() {
        return balanceBefore;
    }

    public void setBalanceBefore(BigDecimal balanceBefore) {
        this.balanceBefore = balanceBefore;
    }

    public BigDecimal getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(BigDecimal balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public UUID getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(UUID transactionId) {
        this.transactionId = transactionId;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Instant timestamp) {
        this.timestamp = timestamp;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return "AuthorizeResponse{" +
                "authorizationCode='" + authorizationCode + '\'' +
                ", status='" + status + '\'' +
                ", amount=" + amount +
                ", balanceBefore=" + balanceBefore +
                ", balanceAfter=" + balanceAfter +
                ", transactionId=" + transactionId +
                ", timestamp=" + timestamp +
                ", errorCode='" + errorCode + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                '}';
    }
}