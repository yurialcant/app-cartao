package com.benefits.kycservice.controller;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/kyc")
@RequiredArgsConstructor
public class KycController {
    
    private static final Logger log = LoggerFactory.getLogger(KycController.class);
    
    @PostMapping("/submit")
    public ResponseEntity<Map<String, Object>> submit(
            @RequestBody(required = false) Map<String, Object> body,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [KYC-SERVICE] POST /api/kyc/submit - Request-ID: {}", requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }    
    
    @GetMapping("/{userId}")
    public ResponseEntity<Map<String, Object>> getKyc(
            @PathVariable String userId,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [KYC-SERVICE] GET /api/kyc/{} - Request-ID: {}", userId, requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação",
            "userId", userId
        );
        return ResponseEntity.ok(response);
    }    
    
    @PutMapping("/{id}/verify")
    public ResponseEntity<Map<String, Object>> verify(
            @PathVariable String id,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [KYC-SERVICE] PUT /api/kyc/{}/verify - Request-ID: {}", id, requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "id", id,
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }
}
