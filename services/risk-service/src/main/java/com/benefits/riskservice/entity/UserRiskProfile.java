package com.benefits.riskservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_risk_profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRiskProfile {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false, unique = true)
    private String userId;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false)
    private Integer currentRiskScore; // 0-100
    
    @Column(nullable = false)
    private String riskLevel; // LOW, MEDIUM, HIGH, CRITICAL
    
    // Histórico
    private Integer totalTransactions = 0;
    private Integer approvedTransactions = 0;
    private Integer declinedTransactions = 0;
    private Integer chargebackCount = 0;
    private Integer disputeCount = 0;
    
    // Padrões de comportamento
    private String usualLocations; // JSON array de coordenadas
    private String usualDevices; // JSON array de device fingerprints
    private String usualMerchantCategories; // MCCs frequentes
    
    // Timing patterns
    private String usualTransactionTimes; // JSON: horários comuns de transação
    private String usualTransactionDays; // Dias da semana comuns
    
    // Limites
    private Boolean hasReachedDailyLimit = false;
    private Boolean hasReachedMonthlyLimit = false;
    
    // Flags
    private Boolean isNewUser = true;
    private Boolean hasSuspiciousActivity = false;
    private Boolean requiresManualReview = false;
    
    private LocalDateTime firstTransactionAt;
    private LocalDateTime lastTransactionAt;
    private LocalDateTime lastRiskAssessmentAt;
    
    private LocalDateTime updatedAt;
}
