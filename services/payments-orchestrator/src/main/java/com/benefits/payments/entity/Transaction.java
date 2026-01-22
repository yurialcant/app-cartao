package com.benefits.payments.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("transactions")
public class Transaction {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("transaction_id")
    private String transactionId;

    @Column("external_reference")
    private String externalReference;

    @Column("person_id")
    private UUID personId;

    @Column("employer_id")
    private UUID employerId;

    @Column("amount")
    private BigDecimal amount;

    @Column("currency")
    private String currency;

    @Column("description")
    private String description;

    @Column("status")
    private String status;

    @Column("payment_method")
    private String paymentMethod;

    @Column("card_last_four")
    private String cardLastFour;

    @Column("installments")
    private Integer installments;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    @Column("processed_at")
    private LocalDateTime processedAt;

    @Column("authorized_at")
    private LocalDateTime authorizedAt;

    @Column("completed_at")
    private LocalDateTime completedAt;

    // Default constructor
    public Transaction() {}

    // Constructor
    public Transaction(UUID tenantId, String transactionId, UUID personId, UUID employerId,
                      BigDecimal amount, String description) {
        this.tenantId = tenantId;
        this.transactionId = transactionId;
        this.personId = personId;
        this.employerId = employerId;
        this.amount = amount;
        this.currency = "BRL";
        this.description = description;
        this.status = "PENDING";
        this.paymentMethod = "CREDIT_CARD";
        this.installments = 1;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getExternalReference() {
        return externalReference;
    }

    public void setExternalReference(String externalReference) {
        this.externalReference = externalReference;
    }

    public UUID getPersonId() {
        return personId;
    }

    public void setPersonId(UUID personId) {
        this.personId = personId;
    }

    public UUID getEmployerId() {
        return employerId;
    }

    public void setEmployerId(UUID employerId) {
        this.employerId = employerId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
        this.updatedAt = LocalDateTime.now();
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
        this.updatedAt = LocalDateTime.now();
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();

        LocalDateTime now = LocalDateTime.now();
        switch (status) {
            case "AUTHORIZED" -> this.authorizedAt = now;
            case "COMPLETED" -> this.completedAt = now;
            case "PROCESSING" -> this.processedAt = now;
        }
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getCardLastFour() {
        return cardLastFour;
    }

    public void setCardLastFour(String cardLastFour) {
        this.cardLastFour = cardLastFour;
    }

    public Integer getInstallments() {
        return installments;
    }

    public void setInstallments(Integer installments) {
        this.installments = installments;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(LocalDateTime processedAt) {
        this.processedAt = processedAt;
    }

    public LocalDateTime getAuthorizedAt() {
        return authorizedAt;
    }

    public void setAuthorizedAt(LocalDateTime authorizedAt) {
        this.authorizedAt = authorizedAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    // Business methods
    public boolean isPending() {
        return "PENDING".equals(status);
    }

    public boolean isProcessing() {
        return "PROCESSING".equals(status);
    }

    public boolean isAuthorized() {
        return "AUTHORIZED".equals(status);
    }

    public boolean isCompleted() {
        return "COMPLETED".equals(status);
    }

    public boolean isFailed() {
        return "FAILED".equals(status);
    }

    public boolean isCancelled() {
        return "CANCELLED".equals(status);
    }

    public void markAsProcessing() {
        setStatus("PROCESSING");
    }

    public void markAsAuthorized() {
        setStatus("AUTHORIZED");
    }

    public void markAsCompleted() {
        setStatus("COMPLETED");
    }

    public void markAsFailed() {
        setStatus("FAILED");
    }

    public void markAsCancelled() {
        setStatus("CANCELLED");
    }
}