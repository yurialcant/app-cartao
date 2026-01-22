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
public class WalletPolicyDto {
    private List<String> mccAllow;
    private List<String> mccDeny;
    private long transactionLimitCents;
    private long dailyLimitCents;
    private List<String> channelsAllowed;

    // Getters and setters for compatibility
    public List<String> getMccAllow() { return mccAllow; }
    public void setMccAllow(List<String> mccAllow) { this.mccAllow = mccAllow; }

    public List<String> getMccDeny() { return mccDeny; }
    public void setMccDeny(List<String> mccDeny) { this.mccDeny = mccDeny; }

    public long getTransactionLimitCents() { return transactionLimitCents; }
    public void setTransactionLimitCents(long transactionLimitCents) { this.transactionLimitCents = transactionLimitCents; }

    public long getDailyLimitCents() { return dailyLimitCents; }
    public void setDailyLimitCents(long dailyLimitCents) { this.dailyLimitCents = dailyLimitCents; }

    public List<String> getChannelsAllowed() { return channelsAllowed; }
    public void setChannelsAllowed(List<String> channelsAllowed) { this.channelsAllowed = channelsAllowed; }
}