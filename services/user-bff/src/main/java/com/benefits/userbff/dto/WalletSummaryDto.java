package com.benefits.userbff.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class WalletSummaryDto {
    private String userId;
    private BigDecimal totalBalance;
    private List<Map<String, Object>> wallets;
    private Map<String, Object> summary;

    public WalletSummaryDto() {}

    // Getters and setters
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public BigDecimal getTotalBalance() { return totalBalance; }
    public void setTotalBalance(BigDecimal totalBalance) { this.totalBalance = totalBalance; }
    public List<Map<String, Object>> getWallets() { return wallets; }
    public void setWallets(List<Map<String, Object>> wallets) { this.wallets = wallets; }
    public Map<String, Object> getSummary() { return summary; }
    public void setSummary(Map<String, Object> summary) { this.summary = summary; }
}