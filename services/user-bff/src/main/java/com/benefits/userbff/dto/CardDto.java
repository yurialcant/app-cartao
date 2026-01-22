package com.benefits.userbff.dto;

import java.time.Instant;

public class CardDto {
    private String id;
    private String type;
    private String status;
    private String brand;
    private String maskedPan;
    private String holderName;
    private Instant createdAt;
    private String walletBinding;

    public CardDto() {}

    public CardDto(
        String id,
        String type,
        String status,
        String brand,
        String maskedPan,
        String holderName,
        Instant createdAt,
        String walletBinding
    ) {
        this.id = id;
        this.type = type;
        this.status = status;
        this.brand = brand;
        this.maskedPan = maskedPan;
        this.holderName = holderName;
        this.createdAt = createdAt;
        this.walletBinding = walletBinding;
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getMaskedPan() { return maskedPan; }
    public void setMaskedPan(String maskedPan) { this.maskedPan = maskedPan; }

    public String getHolderName() { return holderName; }
    public void setHolderName(String holderName) { this.holderName = holderName; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public String getWalletBinding() { return walletBinding; }
    public void setWalletBinding(String walletBinding) { this.walletBinding = walletBinding; }

    // Computed properties
    public boolean isPhysical() {
        return "PHYSICAL".equals(type);
    }

    public boolean isVirtual() {
        return "VIRTUAL".equals(type);
    }

    public boolean isActive() {
        return "ACTIVE".equals(status);
    }

    public boolean isFrozen() {
        return "FROZEN".equals(status);
    }

    public String getCardTypeDisplay() {
        return isPhysical() ? "Físico" : "Virtual";
    }

    public String getDisplayStatus() {
        switch (status) {
            case "ACTIVE": return "Ativo";
            case "FROZEN": return "Bloqueado";
            case "CANCELLED": return "Cancelado";
            case "PENDING": return "Pendente";
            default: return status;
        }
    }
}