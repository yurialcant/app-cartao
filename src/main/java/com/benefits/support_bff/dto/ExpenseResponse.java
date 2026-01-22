package com.benefits.support_bff.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

// DTO matching the benefits-core internal response
public class ExpenseResponse {

    private UUID expenseId;
    private String title;
    private String description;
    private BigDecimal amount;
    private String currency;
    private String category;
    private String status;
    private LocalDateTime submittedAt;
    private LocalDateTime approvedAt;
    private UUID approvedBy;
    private LocalDateTime reimbursedAt;
    private List<ExpenseReceiptResponse> receipts;

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

    public UUID getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(UUID approvedBy) {
        this.approvedBy = approvedBy;
    }

    public LocalDateTime getReimbursedAt() {
        return reimbursedAt;
    }

    public void setReimbursedAt(LocalDateTime reimbursedAt) {
        this.reimbursedAt = reimbursedAt;
    }

    public List<ExpenseReceiptResponse> getReceipts() {
        return receipts;
    }

    public void setReceipts(List<ExpenseReceiptResponse> receipts) {
        this.receipts = receipts;
    }
}