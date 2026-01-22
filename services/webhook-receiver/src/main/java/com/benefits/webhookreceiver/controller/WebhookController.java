package com.benefits.webhookreceiver.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class WebhookController {
    
    @PostMapping("/api/webhooks/cielo")
    public ResponseEntity<Map<String, Object>> createWebhookscielo(
            @RequestBody(required = false) Map<String, Object> body,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [WEBHOOK-RECEIVER] POST /api/webhooks/cielo - Request-ID: {}", requestId);
        
        if (body != null) {
            log.info("🔵 [WEBHOOK-RECEIVER] Recebido webhook - Type: {}, TxnId: {}", 
                body.get("type"), body.get("acquirerTxnId"));
        }
        
        // Processar webhook e atualizar transação no Core Service
        // TODO: Chamar Core Service para atualizar status da transação
        
        return ResponseEntity.ok(Map.of(
            "status", "PROCESSED",
            "message", "Webhook processado com sucesso"
        ));
    }    
    @PostMapping("/api/webhooks/stone")
    public ResponseEntity<Map<String, Object>> createWebhooksstone(
            @RequestBody(required = false) Map<String, Object> body,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [WEBHOOK-RECEIVER] POST /api/webhooks/stone - Request-ID: {}", requestId);
        
        if (body != null) {
            log.info("🔵 [WEBHOOK-RECEIVER] Recebido webhook - Type: {}, TxnId: {}", 
                body.get("type"), body.get("acquirerTxnId"));
        }
        
        // Processar webhook e atualizar transação no Core Service
        // TODO: Chamar Core Service para atualizar status da transação
        
        return ResponseEntity.ok(Map.of(
            "status", "PROCESSED",
            "message", "Webhook processado com sucesso"
        ));
    }    
    @GetMapping("/api/webhooks")
    public ResponseEntity<Map<String, Object>> getWebhooks(
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [WEBHOOK-RECEIVER] GET /api/webhooks - Request-ID: {}", requestId);
        
        // TODO: Retornar lista de webhooks recebidos
        
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação",
            "webhooks", java.util.List.of()
        );
        return ResponseEntity.ok(response);
    }
}

