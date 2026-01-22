package com.benefits.riskservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "risk_rules")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RiskRule {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    private String tenantId; // null = global
    
    @Column(nullable = false)
    private String name;
    
    private String description;
    
    @Column(nullable = false)
    private String ruleType; // VELOCITY, AMOUNT_LIMIT, LOCATION, DEVICE, BEHAVIORAL, ML_SCORE
    
    @Column(nullable = false)
    private String action; // ALLOW, BLOCK, REVIEW, CHALLENGE
    
    @Column(nullable = false)
    private Integer priority; // 1 = highest
    
    @Column(nullable = false)
    private Boolean isActive = true;
    
    // Condições
    @Column(columnDefinition = "TEXT")
    private String conditions; // JSON: {"maxTransactionsPerHour": 10, "maxAmountPerDay": 1000}
    
    // Limites de valor
    private BigDecimal minAmount;
    private BigDecimal maxAmount;
    
    // Velocidade
    private Integer maxTransactionsPerMinute;
    private Integer maxTransactionsPerHour;
    private Integer maxTransactionsPerDay;
    
    // Threshold de score
    private Integer riskScoreThreshold; // 0-100
    
    // Aplicabilidade
    private String targetUserSegments; // Comma-separated
    private String targetMerchantCategories; // MCCs
    
    // Audit
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
}
