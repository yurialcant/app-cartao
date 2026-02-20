package com.benefits.core.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.List;

public class ExpenseRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    @Size(max = 1000, message = "Description must be less than 1000 characters")
    private String description;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    @Digits(integer = 13, fraction = 2, message = "Amount must have at most 13 integer digits and 2 fractional digits")
    private BigDecimal amount;

    @Size(max = 3, message = "Currency must be 3 characters")
    private String currency = "BRL";

    @NotBlank(message = "Category is required")
    private String category;

    @NotEmpty(message = "At least one receipt is required")
    private List<ExpenseReceiptRequest> receipts;

    // Default constructor
    public ExpenseRequest() {}

    // Constructor with required fields
    public ExpenseRequest(String title, BigDecimal amount, String category, List<ExpenseReceiptRequest> receipts) {
        this.title = title;
        this.amount = amount;
        this.category = category;
        this.receipts = receipts;
    }

    // Getters and Setters
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

    public List<ExpenseReceiptRequest> getReceipts() {
        return receipts;
    }

    public void setReceipts(List<ExpenseReceiptRequest> receipts) {
        this.receipts = receipts;
    }
}