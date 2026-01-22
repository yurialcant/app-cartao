package com.benefits.pos_bff.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

/**
 * F7 POS Terminal Controller
 * 
 * Endpoints for POS operations:
 * - Payment authorization
 * - Transaction confirmation
 * - Terminal status
 */
@RestController
@RequestMapping("/api/v1/pos")
public class PosController {
    
    private static final Logger log = LoggerFactory.getLogger(PosController.class);
    
    @GetMapping("/test")
    public Mono<ResponseEntity<String>> test() {
        return Mono.just(ResponseEntity.ok("POS BFF is running!"));
    }
    
    /**
     * POST /api/v1/pos/authorize
     * 
     * Authorize a payment transaction at POS terminal
     */
    @PostMapping("/authorize")
    public Mono<ResponseEntity<String>> authorizePayment(@RequestBody String requestBody) {
        log.info("[F7] POST /pos/authorize - Request: {}", requestBody);
        
        // Mock response for testing
        String mockResponse = "{\"status\":\"success\",\"authorization_code\":\"AUTH123\",\"approved\":true}";
        return Mono.just(ResponseEntity.ok(mockResponse));
    }
    
    /**
     * POST /api/v1/pos/confirm
     * 
     * Confirm a payment transaction
     */
    @PostMapping("/confirm")
    public Mono<ResponseEntity<String>> confirmPayment(@RequestBody String requestBody) {
        log.info("[F7] POST /pos/confirm - Request: {}", requestBody);
        
        String mockResponse = "{\"status\":\"success\",\"transaction_id\":\"TXN123\",\"confirmed\":true}";
        return Mono.just(ResponseEntity.ok(mockResponse));
    }
    
    /**
     * GET /api/v1/pos/status
     * 
     * Get terminal status and configuration
     */
    @GetMapping("/status")
    public Mono<ResponseEntity<String>> getTerminalStatus() {
        log.info("[F7] GET /pos/status");
        
        String mockResponse = "{\"status\":\"online\",\"terminal_id\":\"TERM001\",\"merchant_id\":\"MERCH001\"}";
        return Mono.just(ResponseEntity.ok(mockResponse));
    }
}
