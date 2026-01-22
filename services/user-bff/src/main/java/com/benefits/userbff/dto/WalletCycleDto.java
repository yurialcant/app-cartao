package com.benefits.userbff.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletCycleDto {
    private int cycleStartDay;
    private int cycleEndDay;
    private String timezone;

    // Getters and setters for compatibility
    public int getCycleStartDay() { return cycleStartDay; }
    public void setCycleStartDay(int cycleStartDay) { this.cycleStartDay = cycleStartDay; }

    public int getCycleEndDay() { return cycleEndDay; }
    public void setCycleEndDay(int cycleEndDay) { this.cycleEndDay = cycleEndDay; }

    public String getTimezone() { return timezone; }
    public void setTimezone(String timezone) { this.timezone = timezone; }
}