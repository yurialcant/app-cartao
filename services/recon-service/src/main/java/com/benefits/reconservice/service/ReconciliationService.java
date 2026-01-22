package com.benefits.reconservice.service;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReconciliationService {
    
    private static final Logger log = LoggerFactory.getLogger(ReconciliationService.class);
    
    public Map<String, Object> importStatement(UUID merchantId, String acquirer, LocalDate periodStart, LocalDate periodEnd, String fileUrl) {
        log.info("🔵 [RECON-SERVICE] Importando extrato - merchantId: {}, acquirer: {}", merchantId, acquirer);
        
        // TODO: Processar arquivo de extrato e criar reconciliação
        BigDecimal expectedAmount = new BigDecimal("50000.00");
        BigDecimal actualAmount = new BigDecimal("49950.00");
        BigDecimal difference = expectedAmount.subtract(actualAmount);
        
        return Map.of(
            "reconciliationId", UUID.randomUUID().toString(),
            "merchantId", merchantId.toString(),
            "acquirer", acquirer,
            "periodStart", periodStart.toString(),
            "periodEnd", periodEnd.toString(),
            "expectedAmount", expectedAmount,
            "actualAmount", actualAmount,
            "difference", difference,
            "status", difference.abs().compareTo(new BigDecimal("10")) < 0 ? "OK" : "DIVERGENCE",
            "fileUrl", fileUrl
        );
    }
    
    public Map<String, Object> reconcile(UUID reconciliationId) {
        log.info("🔵 [RECON-SERVICE] Concilando - reconciliationId: {}", reconciliationId);
        
        // TODO: Processar divergências e ajustar transações
        return Map.of(
            "reconciliationId", reconciliationId.toString(),
            "status", "RECONCILED",
            "adjustedTransactions", 2,
            "processedAt", java.time.LocalDateTime.now().toString()
        );
    }
}
