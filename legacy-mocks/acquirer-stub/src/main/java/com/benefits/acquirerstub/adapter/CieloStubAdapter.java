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
 * Stub baseado na API real da Cielo E-Commerce
 * Documentação: https://developercielo.github.io/manual/cielo-ecommerce
 * 
 * Este stub imita a estrutura de resposta da API real da Cielo,
 * incluindo campos obrigatórios e códigos de retorno reais.
 */
@Slf4j
@Component
public class CieloStubAdapter {
    
    private final Random random = new Random();
    private static final DateTimeFormatter CIELO_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
    
    /**
     * Autorização baseada na API real da Cielo
     * Endpoint real: POST /1/sales
     */
    public Map<String, Object> authorize(Map<String, Object> request) {
        log.info("🔵 [CIELO-STUB] Simulando autorização Cielo - Amount: {}", request.get("amount"));
        
        BigDecimal amount = new BigDecimal(request.get("amount").toString());
        String cardToken = (String) request.getOrDefault("cardToken", "");
        String installments = String.valueOf(request.getOrDefault("installments", 1));
        
        // Simular aprovação (90% aprovação, 10% negação)
        boolean approved = random.nextInt(100) < 90;
        
        // Códigos de retorno reais da Cielo
        String returnCode = approved ? "00" : getDeclineCode();
        String returnMessage = getReturnMessage(returnCode);
        
        // PaymentId (Tid) - formato real da Cielo
        String paymentId = UUID.randomUUID().toString().replace("-", "").substring(0, 20);
        
        // AuthorizationCode - 6 dígitos
        String authorizationCode = approved ? String.format("%06d", random.nextInt(999999)) : null;
        
        // NSU e RRN - formatos reais
        String nsu = String.format("%012d", random.nextInt(999999999));
        String rrn = String.format("%012d", random.nextInt(999999999));
        
        Map<String, Object> response = new HashMap<>();
        response.put("MerchantOrderId", request.getOrDefault("merchantOrderId", UUID.randomUUID().toString()));
        response.put("Customer", Map.of(
            "Name", request.getOrDefault("customerName", "Cliente Teste")
        ));
        
        Map<String, Object> payment = new HashMap<>();
        payment.put("PaymentId", paymentId);
        payment.put("Type", "CreditCard");
        payment.put("Amount", amount.intValue() * 100); // Cielo usa centavos
        payment.put("Currency", "BRL");
        payment.put("Country", "BRA");
        payment.put("Installments", Integer.parseInt(installments));
        payment.put("Interest", "ByMerchant");
        payment.put("Capture", false);
        payment.put("Authenticate", false);
        payment.put("Recurrent", false);
        payment.put("CreditCard", Map.of(
            "CardToken", cardToken,
            "Brand", "Visa"
        ));
        
        // Status baseado na API real da Cielo
        Map<String, Object> status = new HashMap<>();
        status.put("Status", approved ? 1 : 3); // 1 = Authorized, 3 = Denied
        status.put("ReturnCode", returnCode);
        status.put("ReturnMessage", returnMessage);
        status.put("ProviderReturnCode", returnCode);
        status.put("ProviderReturnMessage", returnMessage);
        
        if (approved) {
            status.put("AuthorizationCode", authorizationCode);
            status.put("Tid", paymentId);
            status.put("Nsu", nsu);
            status.put("Rrn", rrn);
        }
        
        payment.put("PaymentId", paymentId);
        payment.put("Status", status.get("Status"));
        payment.put("ReturnCode", returnCode);
        payment.put("ReturnMessage", returnMessage);
        payment.put("ProviderReturnCode", returnCode);
        payment.put("ProviderReturnMessage", returnMessage);
        
        if (approved) {
            payment.put("AuthorizationCode", authorizationCode);
            payment.put("Tid", paymentId);
            payment.put("Nsu", nsu);
            payment.put("Rrn", rrn);
        }
        
        payment.put("ReceivedDate", LocalDateTime.now().format(CIELO_DATE_FORMAT));
        payment.put("CapturedDate", null);
        payment.put("VoidedDate", null);
        
        response.put("Payment", payment);
        
        log.info("🔵 [CIELO-STUB] Resposta simulada - Status: {}, ReturnCode: {}", 
                approved ? "APPROVED" : "DENIED", returnCode);
        
        return response;
    }
    
    /**
     * Captura baseada na API real da Cielo
     * Endpoint real: PUT /1/sales/{PaymentId}/capture
     */
    public Map<String, Object> capture(String paymentId, Map<String, Object> request) {
        log.info("🔵 [CIELO-STUB] Simulando captura Cielo - PaymentId: {}", paymentId);
        
        BigDecimal amount = request.containsKey("amount") 
                ? new BigDecimal(request.get("amount").toString()) 
                : null;
        
        Map<String, Object> response = new HashMap<>();
        response.put("PaymentId", paymentId);
        response.put("Status", 2); // 2 = Captured
        response.put("ReturnCode", "00");
        response.put("ReturnMessage", "Transação capturada com sucesso");
        response.put("ReceivedDate", LocalDateTime.now().format(CIELO_DATE_FORMAT));
        response.put("CapturedDate", LocalDateTime.now().format(CIELO_DATE_FORMAT));
        
        if (amount != null) {
            response.put("Amount", amount.intValue() * 100);
        }
        
        return response;
    }
    
    /**
     * Cancelamento (Void) baseado na API real da Cielo
     * Endpoint real: PUT /1/sales/{PaymentId}/void
     */
    public Map<String, Object> voidTransaction(String paymentId, Map<String, Object> request) {
        log.info("🔵 [CIELO-STUB] Simulando cancelamento Cielo - PaymentId: {}", paymentId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("PaymentId", paymentId);
        response.put("Status", 10); // 10 = Voided
        response.put("ReturnCode", "00");
        response.put("ReturnMessage", "Transação cancelada com sucesso");
        response.put("VoidedDate", LocalDateTime.now().format(CIELO_DATE_FORMAT));
        
        return response;
    }
    
    /**
     * Reembolso baseado na API real da Cielo
     * Endpoint real: PUT /1/sales/{PaymentId}/refund
     */
    public Map<String, Object> refund(String paymentId, Map<String, Object> request) {
        log.info("🔵 [CIELO-STUB] Simulando reembolso Cielo - PaymentId: {}", paymentId);
        
        BigDecimal amount = request.containsKey("amount") 
                ? new BigDecimal(request.get("amount").toString()) 
                : null;
        
        Map<String, Object> response = new HashMap<>();
        response.put("PaymentId", paymentId);
        response.put("Status", 11); // 11 = Refunded
        response.put("ReturnCode", "00");
        response.put("ReturnMessage", "Transação estornada com sucesso");
        response.put("RefundedDate", LocalDateTime.now().format(CIELO_DATE_FORMAT));
        
        if (amount != null) {
            response.put("Amount", amount.intValue() * 100);
        }
        
        return response;
    }
    
    /**
     * Códigos de negação reais da Cielo
     */
    private String getDeclineCode() {
        String[] declineCodes = {
            "51", // Saldo insuficiente
            "57", // Transação não permitida para o cartão
            "78", // Cartão bloqueado
            "96", // Falha no processamento
            "AE", // Tente novamente
            "AP", // Tente novamente
            "BL", // Cartão bloqueado
            "DA", // Tente novamente
            "DS", // Tente novamente
            "NP", // Portador não autenticado
            "NT", // Transação não autorizada
            "OP", // Operação não permitida
            "TA", // Tente novamente
            "TD", // Tente novamente
            "TU", // Tente novamente
        };
        return declineCodes[random.nextInt(declineCodes.length)];
    }
    
    /**
     * Mensagens de retorno reais da Cielo
     */
    private String getReturnMessage(String returnCode) {
        Map<String, String> messages = new HashMap<>();
        messages.put("00", "Transação autorizada com sucesso");
        messages.put("51", "Saldo insuficiente");
        messages.put("57", "Transação não permitida para o cartão");
        messages.put("78", "Cartão bloqueado");
        messages.put("96", "Falha no processamento");
        messages.put("AE", "Tente novamente");
        messages.put("AP", "Tente novamente");
        messages.put("BL", "Cartão bloqueado");
        messages.put("DA", "Tente novamente");
        messages.put("DS", "Tente novamente");
        messages.put("NP", "Portador não autenticado");
        messages.put("NT", "Transação não autorizada");
        messages.put("OP", "Operação não permitida");
        messages.put("TA", "Tente novamente");
        messages.put("TD", "Tente novamente");
        messages.put("TU", "Tente novamente");
        return messages.getOrDefault(returnCode, "Erro desconhecido");
    }
}
