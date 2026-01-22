package com.benefits.riskservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "risk_assessments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RiskAssessment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false)
    private String transactionId;
    
    @Column(nullable = false)
    private String userId;
    
    private String merchantId;
    
    @Column(nullable = false)
    private Integer riskScore; // 0-100 (0 = sem risco, 100 = alto risco)
    
    @Column(nullable = false)
    private String riskLevel; // LOW, MEDIUM, HIGH, CRITICAL
    
    @Column(nullable = false)
    private String decision; // APPROVED, DECLINED, REVIEW_REQUIRED
    
    // Fatores de risco detectados
    @Column(columnDefinition = "TEXT")
    private String riskFactors; // JSON array: ["VELOCITY_EXCEEDED", "UNUSUAL_LOCATION", "NEW_DEVICE"]
    
    // Regras que foram acionadas
    @Column(columnDefinition = "TEXT")
    private String triggeredRules; // JSON array com IDs das regras
    
    // Scores individuais
    private Integer velocityScore;
    private Integer locationScore;
    private Integer deviceScore;
    private Integer behavioralScore;
    private Integer mlScore; // Machine Learning score
    
    // Detalhes do contexto
    private String ipAddress;
    private String deviceFingerprint;
    private String location; // lat,lng
    private String userAgent;
    
    // Histórico
    private Integer userTransactionCount; // Total de transações do usuário
    private Integer recentDeclinedCount; // Transações negadas recentemente
    
    @Column(nullable = false)
    private LocalDateTime assessedAt;
    
    private Long processingTimeMs; // Tempo de processamento em ms
    
    @Column(columnDefinition = "TEXT")
    private String metadata; // JSON com dados extras
}
