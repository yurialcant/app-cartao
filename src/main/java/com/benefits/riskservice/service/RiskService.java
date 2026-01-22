package com.benefits.riskservice.service;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RiskService {
    
    private static final Logger log = LoggerFactory.getLogger(RiskService.class);
    
    public Map<String, Object> analyzeRisk(String userId, BigDecimal amount, String merchantId) {
        log.info("🔵 [RISK-SERVICE] Analisando risco - userId: {}, amount: {}, merchantId: {}", userId, amount, merchantId);
        
        int riskScore = calculateRiskScore(userId, amount, merchantId);
        String riskLevel = getRiskLevel(riskScore);
        boolean requiresStepUp = riskScore > 70;
        
        return Map.of(
            "riskScore", riskScore,
            "riskLevel", riskLevel,
            "requiresStepUp", requiresStepUp,
            "recommendation", requiresStepUp ? "REQUIRE_MFA" : "APPROVE"
        );
    }
    
    public Map<String, Object> requiresStepUp(String userId, String action) {
        log.info("🔵 [RISK-SERVICE] Verificando step-up - userId: {}, action: {}", userId, action);
        
        // Ações sensíveis sempre requerem step-up
        boolean requires = java.util.List.of("PAYMENT", "REFUND", "CARD_BLOCK", "PANIC_MODE").contains(action);
        
        return Map.of(
            "requiresStepUp", requires,
            "action", action,
            "message", requires ? "Ação requer validação adicional" : "Ação permitida"
        );
    }
    
    public Map<String, Object> getRiskScore(String userId) {
        log.info("🔵 [RISK-SERVICE] Buscando score de risco - userId: {}", userId);
        
        int score = calculateRiskScore(userId, null, null);
        
        return Map.of(
            "userId", userId,
            "riskScore", score,
            "riskLevel", getRiskLevel(score),
            "lastUpdated", java.time.LocalDateTime.now().toString()
        );
    }
    
    private int calculateRiskScore(String userId, BigDecimal amount, String merchantId) {
        // Lógica simplificada de cálculo de risco
        int score = 30; // Base
        
        if (amount != null && amount.compareTo(new BigDecimal("500")) > 0) {
            score += 20; // Valor alto
        }
        
        // TODO: Adicionar mais fatores (device novo, velocity, etc.)
        return Math.min(score, 100);
    }
    
    private String getRiskLevel(int score) {
        if (score < 40) return "LOW";
        if (score < 70) return "MEDIUM";
        return "HIGH";
    }
}
