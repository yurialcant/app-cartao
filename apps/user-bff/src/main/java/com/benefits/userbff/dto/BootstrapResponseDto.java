package com.benefits.userbff.dto;

import java.util.List;

public class BootstrapResponseDto {
    private TenantConfigDto tenantConfig;
    private UserProfileDto userProfile;
    private List<WalletDto> wallets;
    private List<CardDto> cards;
    private int unreadNotificationsCount;

    public BootstrapResponseDto() {}

    public BootstrapResponseDto(
        TenantConfigDto tenantConfig,
        UserProfileDto userProfile,
        List<WalletDto> wallets,
        List<CardDto> cards,
        int unreadNotificationsCount
    ) {
        this.tenantConfig = tenantConfig;
        this.userProfile = userProfile;
        this.wallets = wallets;
        this.cards = cards;
        this.unreadNotificationsCount = unreadNotificationsCount;
    }

    // Getters and setters
    public TenantConfigDto getTenantConfig() { return tenantConfig; }
    public void setTenantConfig(TenantConfigDto tenantConfig) { this.tenantConfig = tenantConfig; }

    public UserProfileDto getUserProfile() { return userProfile; }
    public void setUserProfile(UserProfileDto userProfile) { this.userProfile = userProfile; }

    public List<WalletDto> getWallets() { return wallets; }
    public void setWallets(List<WalletDto> wallets) { this.wallets = wallets; }

    public List<CardDto> getCards() { return cards; }
    public void setCards(List<CardDto> cards) { this.cards = cards; }

    public int getUnreadNotificationsCount() { return unreadNotificationsCount; }
    public void setUnreadNotificationsCount(int unreadNotificationsCount) { this.unreadNotificationsCount = unreadNotificationsCount; }
}