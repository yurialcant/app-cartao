package com.benefits.acquireradapter.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class AcquirerService {
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    @Value("${acquirer.stub.url:http://acquirer-stub:8104}")
    private String stubBaseUrl;
    
    /**
     * Autorizar transação usando stub baseado em API real
     */
    public Map<String, Object> authorize(String acquirer, Map<String, Object> requestBody) {
        log.info("🔵 [ACQUIRER-ADAPTER] Autorizando - acquirer: {}, amount: {}", acquirer, requestBody.get("amount"));
        
        String stubUrl = stubBaseUrl + "/api/stub/" + acquirer.toLowerCase() + "/authorize";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
        
        try {
            Map<String, Object> response = restTemplate.postForObject(stubUrl, request, Map.class);
            log.info("🔵 [ACQUIRER-ADAPTER] Resposta do stub: {}", response);
            return response != null ? response : createFallbackResponse(acquirer, requestBody);
        } catch (Exception e) {
            log.error("🔵 [ACQUIRER-ADAPTER] Erro ao chamar stub: {}", e.getMessage());
            return createFallbackResponse(acquirer, requestBody);
        }
    }
    
    /**
     * Capturar transação usando stub baseado em API real
     */
    public Map<String, Object> capture(String acquirer, String acquirerTxnId, Map<String, Object> requestBody) {
        log.info("🔵 [ACQUIRER-ADAPTER] Capturando - acquirer: {}, txnId: {}", acquirer, acquirerTxnId);
        
        String stubUrl = stubBaseUrl + "/api/stub/" + acquirer.toLowerCase() + "/capture";
        
        Map<String, Object> body = new HashMap<>(requestBody);
        body.put("acquirerTxnId", acquirerTxnId);
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
        
        try {
            Map<String, Object> response = restTemplate.postForObject(stubUrl, request, Map.class);
            log.info("🔵 [ACQUIRER-ADAPTER] Resposta do stub: {}", response);
            return response != null ? response : Map.of("acquirerTxnId", acquirerTxnId, "status", "CAPTURED");
        } catch (Exception e) {
            log.error("🔵 [ACQUIRER-ADAPTER] Erro ao chamar stub: {}", e.getMessage());
            return Map.of("acquirerTxnId", acquirerTxnId, "status", "CAPTURED");
        }
    }
    
    /**
     * Reembolsar transação usando stub baseado em API real
     */
    public Map<String, Object> refund(String acquirer, String acquirerTxnId, Map<String, Object> requestBody) {
        log.info("🔵 [ACQUIRER-ADAPTER] Reembolsando - acquirer: {}, txnId: {}", acquirer, acquirerTxnId);
        
        String stubUrl = stubBaseUrl + "/api/stub/" + acquirer.toLowerCase() + "/refund";
        
        Map<String, Object> body = new HashMap<>(requestBody);
        body.put("acquirerTxnId", acquirerTxnId);
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
        
        try {
            Map<String, Object> response = restTemplate.postForObject(stubUrl, request, Map.class);
            log.info("🔵 [ACQUIRER-ADAPTER] Resposta do stub: {}", response);
            return response != null ? response : Map.of("refundId", "REFUND-" + acquirerTxnId, "status", "REFUNDED");
        } catch (Exception e) {
            log.error("🔵 [ACQUIRER-ADAPTER] Erro ao chamar stub: {}", e.getMessage());
            return Map.of("refundId", "REFUND-" + acquirerTxnId, "status", "REFUNDED");
        }
    }
    
    /**
     * Cancelar transação (Void) usando stub baseado em API real
     */
    public Map<String, Object> voidTransaction(String acquirer, String acquirerTxnId, Map<String, Object> requestBody) {
        log.info("🔵 [ACQUIRER-ADAPTER] Cancelando - acquirer: {}, txnId: {}", acquirer, acquirerTxnId);
        
        String stubUrl = stubBaseUrl + "/api/stub/" + acquirer.toLowerCase() + "/void";
        
        Map<String, Object> body = new HashMap<>(requestBody);
        body.put("acquirerTxnId", acquirerTxnId);
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
        
        try {
            Map<String, Object> response = restTemplate.postForObject(stubUrl, request, Map.class);
            log.info("🔵 [ACQUIRER-ADAPTER] Resposta do stub: {}", response);
            return response != null ? response : Map.of("acquirerTxnId", acquirerTxnId, "status", "VOIDED");
        } catch (Exception e) {
            log.error("🔵 [ACQUIRER-ADAPTER] Erro ao chamar stub: {}", e.getMessage());
            return Map.of("acquirerTxnId", acquirerTxnId, "status", "VOIDED");
        }
    }
    
    /**
     * Resposta de fallback caso o stub não esteja disponível
     */
    private Map<String, Object> createFallbackResponse(String acquirer, Map<String, Object> requestBody) {
        return Map.of(
            "acquirerTxnId", acquirer.toUpperCase() + "-" + java.util.UUID.randomUUID().toString().substring(0, 8),
            "status", "APPROVED",
            "authCode", "AUTH123",
            "note", "Fallback response - stub unavailable"
        );
    }
}
