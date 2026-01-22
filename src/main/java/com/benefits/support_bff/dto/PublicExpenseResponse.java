package com.benefits.support_bff.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class PublicExpenseResponse {

    private UUID expenseId;
    private String title;
    private String description;
    private BigDecimal amount;
    private String currency;
    private String category;
    private String status;
    private LocalDateTime submittedAt;
    private LocalDateTime approvedAt;
    private LocalDateTime reimbursedAt;
    private List<PublicReceiptResponse> receipts;

    // Default constructor
    public PublicExpenseResponse() {}

    // Constructor from internal response (would be used in service mapping)
    public PublicExpenseResponse(UUID expenseId, String title, String description,
                               BigDecimal amount, String currency, String category,
                               String status, LocalDateTime submittedAt, LocalDateTime approvedAt,
                               LocalDateTime reimbursedAt, List<PublicReceiptResponse> receipts) {
        this.expenseId = expenseId;
        this.title = title;
        this.description = description;
        this.amount = amount;
        this.currency = currency;
        this.category = category;
        this.status = status;
        this.submittedAt = submittedAt;
        this.approvedAt = approvedAt;
        this.reimbursedAt = reimbursedAt;
        this.receipts = receipts;
    }

    // Getters and Setters
    public UUID getExpenseId() {
        return expenseId;
    }

    public void setExpenseId(UUID expenseId) {
        this.expenseId = expenseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }

    public LocalDateTime getReimbursedAt() {
        return reimbursedAt;
    }

    public void setReimbursedAt(LocalDateTime reimbursedAt) {
        this.reimbursedAt = reimbursedAt;
    }

    public List<PublicReceiptResponse> getReceipts() {
        return receipts;
    }

    public void setReceipts(List<PublicReceiptResponse> receipts) {
        this.receipts = receipts;
    }

    // Helper methods for UI
    public boolean isPending() {
        return "PENDING".equals(status);
    }

    public boolean isApproved() {
        return "APPROVED".equals(status);
    }

    public boolean isRejected() {
        return "REJECTED".equals(status);
    }

    public boolean isReimbursed() {
        return "REIMBURSED".equals(status);
    }
}