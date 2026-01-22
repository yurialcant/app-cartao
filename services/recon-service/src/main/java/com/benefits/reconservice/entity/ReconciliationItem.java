package com.benefits.reconservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "reconciliation_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReconciliationItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String batchId;
    
    @Column(nullable = false)
    private String status; // MATCHED, UNMATCHED_SYSTEM, UNMATCHED_EXTERNAL, DISCREPANCY
    
    // Dados do nosso sistema
    private String systemTransactionId;
    private BigDecimal systemAmount;
    private LocalDateTime systemTimestamp;
    
    // Dados externos
    private String externalTransactionId;
    private BigDecimal externalAmount;
    private LocalDateTime externalTimestamp;
    
    // Matching
    private String matchType; // AUTO, MANUAL, FUZZY
    private BigDecimal amountDifference;
    
    // Discrepância
    private String discrepancyType; // AMOUNT_MISMATCH, MISSING_SYSTEM, MISSING_EXTERNAL, DUPLICATE
    private String discrepancyReason;
    
    // Resolução
    private Boolean resolved = false;
    private LocalDateTime resolvedAt;
    private String resolvedBy;
    private String resolutionAction; // ADJUSTED, DISPUTED, IGNORED
    
    @Column(columnDefinition = "TEXT")
    private String notes;
}
