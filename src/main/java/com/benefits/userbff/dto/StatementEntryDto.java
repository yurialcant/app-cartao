package com.benefits.userbff.dto;

import java.time.Instant;

public class StatementEntryDto {
    private String id;
    private Instant occurredAt;
    private String direction;
    private long amountCents;
    private String currency;
    private String walletId;
    private String walletType;
    private String merchantName;
    private String status;
    private String referenceType;
    private String referenceId;
    private String categoryLabel;
    private String description;
    private String notes;

    public StatementEntryDto() {}

    public StatementEntryDto(
        String id,
        Instant occurredAt,
        String direction,
        long amountCents,
        String currency,
        String walletId,
        String walletType,
        String merchantName,
        String status,
        String referenceType,
        String referenceId,
        String categoryLabel,
        String description,
        String notes
    ) {
        this.id = id;
        this.occurredAt = occurredAt;
        this.direction = direction;
        this.amountCents = amountCents;
        this.currency = currency;
        this.walletId = walletId;
        this.walletType = walletType;
        this.merchantName = merchantName;
        this.status = status;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.categoryLabel = categoryLabel;
        this.description = description;
        this.notes = notes;
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Instant getOccurredAt() { return occurredAt; }
    public void setOccurredAt(Instant occurredAt) { this.occurredAt = occurredAt; }

    public String getDirection() { return direction; }
    public void setDirection(String direction) { this.direction = direction; }

    public long getAmountCents() { return amountCents; }
    public void setAmountCents(long amountCents) { this.amountCents = amountCents; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getWalletId() { return walletId; }
    public void setWalletId(String walletId) { this.walletId = walletId; }

    public String getWalletType() { return walletType; }
    public void setWalletType(String walletType) { this.walletType = walletType; }

    public String getMerchantName() { return merchantName; }
    public void setMerchantName(String merchantName) { this.merchantName = merchantName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getReferenceType() { return referenceType; }
    public void setReferenceType(String referenceType) { this.referenceType = referenceType; }

    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }

    public String getCategoryLabel() { return categoryLabel; }
    public void setCategoryLabel(String categoryLabel) { this.categoryLabel = categoryLabel; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    // Computed properties
    public double getAmount() {
        return amountCents / 100.0;
    }

    public boolean isDebit() {
        return "DEBIT".equals(direction);
    }

    public boolean isCredit() {
        return "CREDIT".equals(direction);
    }

    public boolean isPosted() {
        return "POSTED".equals(status);
    }

    public boolean isPending() {
        return "PENDING".equals(status);
    }

    public String getDisplayAmount() {
        String sign = isDebit() ? "-" : "+";
        return sign + String.format("%.2f", getAmount()) + " " + currency;
    }

    public String getDisplayDescription() {
        if (merchantName != null && !merchantName.isEmpty()) {
            return merchantName;
        }
        if (description != null && !description.isEmpty()) {
            return description;
        }
        return referenceType;
    }

    public String getDisplayCategory() {
        return categoryLabel != null ? categoryLabel : "Outros";
    }
}