package com.benefits.userbff.dto;

import java.util.List;

public class WalletDto {
    private String id;
    private String walletType;
    private String displayName;
    private String iconKey;
    private long availableCents;
    private String currency;
    private String status;
    private List<String> ruleTags;

    public WalletDto() {}

    public WalletDto(
        String id,
        String walletType,
        String displayName,
        String iconKey,
        long availableCents,
        String currency,
        String status,
        List<String> ruleTags
    ) {
        this.id = id;
        this.walletType = walletType;
        this.displayName = displayName;
        this.iconKey = iconKey;
        this.availableCents = availableCents;
        this.currency = currency;
        this.status = status;
        this.ruleTags = ruleTags;
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getWalletType() { return walletType; }
    public void setWalletType(String walletType) { this.walletType = walletType; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getIconKey() { return iconKey; }
    public void setIconKey(String iconKey) { this.iconKey = iconKey; }

    public long getAvailableCents() { return availableCents; }
    public void setAvailableCents(long availableCents) { this.availableCents = availableCents; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public List<String> getRuleTags() { return ruleTags; }
    public void setRuleTags(List<String> ruleTags) { this.ruleTags = ruleTags; }

    // Computed properties
    public double getAvailableAmount() {
        return availableCents / 100.0;
    }

    public boolean isActive() {
        return "ACTIVE".equals(status);
    }

    public boolean isLocked() {
        return "LOCKED".equals(status);
    }
}