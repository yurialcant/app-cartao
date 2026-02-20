package com.benefits.core.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Refund Response DTO
 *
 * Response for refund operations (F07)
 */
public class RefundResponse {

    private UUID refundId;
    private String status;
    private String authorizationCode;
    private BigDecimal amount;
    private String currency;
    private String originalTransactionId;
    private Instant processedAt;
    private String errorCode;
    private String errorMessage;

    // Constructors
    public RefundResponse() {
    }

    public static RefundResponse approved(UUID refundId, String authorizationCode, BigDecimal amount,
            String originalTransactionId, Instant processedAt) {
        RefundResponse response = new RefundResponse();
        response.setRefundId(refundId);
        response.setStatus("APPROVED");
        response.setAuthorizationCode(authorizationCode);
        response.setAmount(amount);
        response.setOriginalTransactionId(originalTransactionId);
        response.setProcessedAt(processedAt);
        return response;
    }

    public static RefundResponse declined(String errorCode, String errorMessage) {
        RefundResponse response = new RefundResponse();
        response.setStatus("DECLINED");
        response.setErrorCode(errorCode);
        response.setErrorMessage(errorMessage);
        return response;
    }

    public static RefundResponse processing(UUID refundId) {
        RefundResponse response = new RefundResponse();
        response.setRefundId(refundId);
        response.setStatus("PROCESSING");
        return response;
    }

    // Getters and Setters
    public UUID getRefundId() {
        return refundId;
    }

    public void setRefundId(UUID refundId) {
        this.refundId = refundId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAuthorizationCode() {
        return authorizationCode;
    }

    public void setAuthorizationCode(String authorizationCode) {
        this.authorizationCode = authorizationCode;
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

    public String getOriginalTransactionId() {
        return originalTransactionId;
    }

    public void setOriginalTransactionId(String originalTransactionId) {
        this.originalTransactionId = originalTransactionId;
    }

    public Instant getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(Instant processedAt) {
        this.processedAt = processedAt;
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
        return "RefundResponse{" +
                "refundId=" + refundId +
                ", status='" + status + '\'' +
                ", authorizationCode='" + authorizationCode + '\'' +
                ", amount=" + amount +
                ", originalTransactionId='" + originalTransactionId + '\'' +
                ", errorCode='" + errorCode + '\'' +
                '}';
    }
}