package com.benefits.userbff.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDto {
    private String id;
    private String type; // CREDIT, DEBIT
    private BigDecimal amount;
    private String description;
    private Instant timestamp;
    private String merchantName;
    private String category;
}