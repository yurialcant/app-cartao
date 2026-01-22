package com.benefits.userbff.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletDetailDto {
    private String id;
    private String description;
    private WalletCycleDto cycle;
    private long dailySuggestedCents;
    private WalletPolicyDto policy;
    private List<TransactionDto> recentTransactions;

    // Getters and setters for compatibility
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public WalletCycleDto getCycle() { return cycle; }
    public void setCycle(WalletCycleDto cycle) { this.cycle = cycle; }

    public long getDailySuggestedCents() { return dailySuggestedCents; }
    public void setDailySuggestedCents(long dailySuggestedCents) { this.dailySuggestedCents = dailySuggestedCents; }

    public WalletPolicyDto getPolicy() { return policy; }
    public void setPolicy(WalletPolicyDto policy) { this.policy = policy; }
}