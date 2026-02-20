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
 * Stub baseado na API real da Stone Pagamentos
 * Documentação: https://docs.stone.com.br/docs/api-stone-pagamentos
 * 
 * Este stub imita a estrutura de resposta da API real da Stone,
 * incluindo campos obrigatórios e códigos de retorno reais.
 */
@Slf4j
@Component
public class StoneStubAdapter {
    
    private final Random random = new Random();
    private static final DateTimeFormatter STONE_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
    /**
     * Autorização baseada na API real da Stone
     * Endpoint real: POST /api/v1/transactions
     */
    public Map<String, Object> authorize(Map<String, Object> request) {
        log.info("🔵 [STONE-STUB] Simulando autorização Stone - Amount: {}", request.get("amount"));
        
        BigDecimal amount = new BigDecimal(request.get("amount").toString());
        String cardToken = (String) request.getOrDefault("cardToken", "");
        
        // Simular aprovação (90% aprovação)
        boolean approved = random.nextInt(100) < 90;
        
        // Transaction ID da Stone
        String transactionId = UUID.randomUUID().toString();
        
        // Authorization Code - 6 dígitos
        String authorizationCode = approved ? String.format("%06d", random.nextInt(999999)) : null;
        
        // Response Code da Stone
        String responseCode = approved ? "00" : getDeclineCode();
        String responseMessage = getResponseMessage(responseCode);
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", transactionId);
        response.put("amount", amount);
        response.put("currency", "BRL");
        response.put("status", approved ? "approved" : "declined");
        response.put("response_code", responseCode);
        response.put("response_message", responseMessage);
        
        if (approved) {
            response.put("authorization_code", authorizationCode);
            response.put("acquirer_transaction_id", "STONE-" + transactionId.substring(0, 8).toUpperCase());
        }
        
        response.put("created_at", LocalDateTime.now().format(STONE_DATE_FORMAT));
        response.put("updated_at", LocalDateTime.now().format(STONE_DATE_FORMAT));
        
        // Payment method info
        Map<String, Object> paymentMethod = new HashMap<>();
        paymentMethod.put("type", "credit_card");
        paymentMethod.put("brand", "visa");
        paymentMethod.put("installments", request.getOrDefault("installments", 1));
        response.put("payment_method", paymentMethod);
        
        log.info("🔵 [STONE-STUB] Resposta simulada - Status: {}, ResponseCode: {}", 
                approved ? "approved" : "declined", responseCode);
        
        return response;
    }
    
    /**
     * Captura baseada na API real da Stone
     * Endpoint real: POST /api/v1/transactions/{id}/capture
     */
    public Map<String, Object> capture(String transactionId, Map<String, Object> request) {
        log.info("🔵 [STONE-STUB] Simulando captura Stone - TransactionId: {}", transactionId);
        
        BigDecimal amount = request.containsKey("amount") 
                ? new BigDecimal(request.get("amount").toString()) 
                : null;
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", transactionId);
        response.put("status", "captured");
        response.put("response_code", "00");
        response.put("response_message", "Transação capturada com sucesso");
        response.put("captured_at", LocalDateTime.now().format(STONE_DATE_FORMAT));
        response.put("updated_at", LocalDateTime.now().format(STONE_DATE_FORMAT));
        
        if (amount != null) {
            response.put("amount", amount);
        }
        
        return response;
    }
    
    /**
     * Reembolso baseado na API real da Stone
     * Endpoint real: POST /api/v1/transactions/{id}/refund
     */
    public Map<String, Object> refund(String transactionId, Map<String, Object> request) {
        log.info("🔵 [STONE-STUB] Simulando reembolso Stone - TransactionId: {}", transactionId);
        
        BigDecimal amount = request.containsKey("amount") 
                ? new BigDecimal(request.get("amount").toString()) 
                : null;
        
        String refundId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", refundId);
        response.put("transaction_id", transactionId);
        response.put("status", "refunded");
        response.put("response_code", "00");
        response.put("response_message", "Reembolso processado com sucesso");
        response.put("refunded_at", LocalDateTime.now().format(STONE_DATE_FORMAT));
        response.put("created_at", LocalDateTime.now().format(STONE_DATE_FORMAT));
        
        if (amount != null) {
            response.put("amount", amount);
        }
        
        return response;
    }
    
    /**
     * Códigos de negação reais da Stone
     */
    private String getDeclineCode() {
        String[] declineCodes = {
            "51", // Saldo insuficiente
            "57", // Transação não permitida
            "78", // Cartão bloqueado
            "96", // Falha no processamento
            "AE", // Tente novamente
            "BL", // Cartão bloqueado
            "NP", // Não autenticado
            "NT", // Não autorizado
            "OP", // Operação não permitida
        };
        return declineCodes[random.nextInt(declineCodes.length)];
    }
    
    /**
     * Mensagens de resposta reais da Stone
     */
    private String getResponseMessage(String responseCode) {
        Map<String, String> messages = Map.of(
            "00", "Transação aprovada",
            "51", "Saldo insuficiente",
            "57", "Transação não permitida",
            "78", "Cartão bloqueado",
            "96", "Falha no processamento",
            "AE", "Tente novamente",
            "BL", "Cartão bloqueado",
            "NP", "Não autenticado",
            "NT", "Não autorizado",
            "OP", "Operação não permitida"
        );
        return messages.getOrDefault(responseCode, "Erro desconhecido");
    }
}
