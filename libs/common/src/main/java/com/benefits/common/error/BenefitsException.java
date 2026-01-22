package com.benefits.common.error;

/**
 * Business exception base class
 * All service exceptions inherit from this
 */
public class BenefitsException extends RuntimeException {
    
    private final String code;
    private final Integer statusCode;
    private final Boolean retryable;
    private final String correlationId;
    
    public BenefitsException(String code, String message, Integer statusCode, Boolean retryable) {
        super(message);
        this.code = code;
        this.statusCode = statusCode;
        this.retryable = retryable;
        this.correlationId = null;
    }
    
    public BenefitsException(String code, String message, Integer statusCode, Boolean retryable, String correlationId) {
        super(message);
        this.code = code;
        this.statusCode = statusCode;
        this.retryable = retryable;
        this.correlationId = correlationId;
    }
    
    public String getCode() {
        return code;
    }
    
    public Integer getStatusCode() {
        return statusCode;
    }
    
    public Boolean getRetryable() {
        return retryable;
    }
    
    public String getCorrelationId() {
        return correlationId;
    }
    
    public static class WalletNotFound extends BenefitsException {
        public WalletNotFound(String userId) {
            super("WALLET_NOT_FOUND", "Wallet not found for user: " + userId, 404, false);
        }
    }
    
    public static class InsufficientBalance extends BenefitsException {
        public InsufficientBalance(String walletId, String message) {
            super("INSUFFICIENT_BALANCE", message, 422, false);
        }
    }
    
    public static class IdempotencyConflict extends BenefitsException {
        public IdempotencyConflict(String idempotencyKey) {
            super("IDEMPOTENCY_CONFLICT", "Duplicate request detected: " + idempotencyKey, 409, false);
        }
    }
    
    public static class ValidationError extends BenefitsException {
        public ValidationError(String message) {
            super("VALIDATION_ERROR", message, 400, false);
        }
    }
    
    public static class TenantNotFound extends BenefitsException {
        public TenantNotFound(String tenantId) {
            super("TENANT_NOT_FOUND", "Tenant not found: " + tenantId, 404, false);
        }
    }
}
