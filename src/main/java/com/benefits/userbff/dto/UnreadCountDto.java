package com.benefits.userbff.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UnreadCountDto {
    private int count;

    // Getters and setters for compatibility
    public int getCount() { return count; }
    public void setCount(int count) { this.count = count; }
}