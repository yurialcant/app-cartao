package com.benefits.acquirerstub.adapter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

/**
 * Stub baseado na API real do PagSeguro
 * Documentação: https://dev.pagseguro.uol.com.br/docs
 * 
 * Este stub imita a estrutura de resposta da API real do PagSeguro.
 */
@Slf4j
@Component
public class PagSeguroStubAdapter {
    
    private final Random random = new Random();
    private static final DateTimeFormatter PAGSEGURO_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
    /**
     * Autorização baseada na API real do PagSeguro
     * Endpoint real: POST /charges
     */
    public Map<String, Object> authorize(Map<String, Object> request) {
        log.info("🔵 [PAGSEGURO-STUB] Simulando autorização PagSeguro - Amount: {}", request.get("amount"));
        
        BigDecimal amount = new BigDecimal(request.get("amount").toString());
        boolean approved = random.nextInt(100) < 90;
        
        String chargeId = UUID.randomUUID().toString();
        String status = approved ? "PAID" : "DECLINED";
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", chargeId);
        response.put("reference_id", request.getOrDefault("referenceId", UUID.randomUUID().toString()));
        response.put("status", status);
        response.put("created_at", LocalDateTime.now().format(PAGSEGURO_DATE_FORMAT));
        
        Map<String, Object> amountInfo = new HashMap<>();
        amountInfo.put("value", amount);
        amountInfo.put("currency", "BRL");
        response.put("amount", amountInfo);
        
        if (approved) {
            Map<String, Object> paymentResponse = new HashMap<>();
            paymentResponse.put("id", UUID.randomUUID().toString());
            paymentResponse.put("status", "APPROVED");
            paymentResponse.put("authorization_code", String.format("%06d", random.nextInt(999999)));
            response.put("payment_response", paymentResponse);
        } else {
            Map<String, Object> paymentResponse = new HashMap<>();
            paymentResponse.put("status", "DECLINED");
            paymentResponse.put("code", getDeclineCode());
            paymentResponse.put("message", getDeclineMessage(paymentResponse.get("code").toString()));
            response.put("payment_response", paymentResponse);
        }
        
        return response;
    }
    
    /**
     * Captura baseada na API real do PagSeguro
     */
    public Map<String, Object> capture(String chargeId, Map<String, Object> request) {
        log.info("🔵 [PAGSEGURO-STUB] Simulando captura PagSeguro - ChargeId: {}", chargeId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", chargeId);
        response.put("status", "PAID");
        response.put("paid_at", LocalDateTime.now().format(PAGSEGURO_DATE_FORMAT));
        
        return response;
    }
    
    /**
     * Reembolso baseado na API real do PagSeguro
     */
    public Map<String, Object> refund(String chargeId, Map<String, Object> request) {
        log.info("🔵 [PAGSEGURO-STUB] Simulando reembolso PagSeguro - ChargeId: {}", chargeId);
        
        String refundId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", refundId);
        response.put("charge_id", chargeId);
        response.put("status", "REFUNDED");
        response.put("refunded_at", LocalDateTime.now().format(PAGSEGURO_DATE_FORMAT));
        
        return response;
    }
    
    private String getDeclineCode() {
        String[] codes = {"INSUFFICIENT_FUNDS", "CARD_BLOCKED", "INVALID_CARD", "PROCESSING_ERROR"};
        return codes[random.nextInt(codes.length)];
    }
    
    private String getDeclineMessage(String code) {
        Map<String, String> messages = Map.of(
            "INSUFFICIENT_FUNDS", "Saldo insuficiente",
            "CARD_BLOCKED", "Cartão bloqueado",
            "INVALID_CARD", "Cartão inválido",
            "PROCESSING_ERROR", "Erro no processamento"
        );
        return messages.getOrDefault(code, "Erro desconhecido");
    }
}
