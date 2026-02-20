package com.benefits.kybservice.controller;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/kyb")
@RequiredArgsConstructor
public class KybController {
    
    private static final Logger log = LoggerFactory.getLogger(KybController.class);
    
    @PostMapping("/submit")
    public ResponseEntity<Map<String, Object>> submit(
            @RequestBody(required = false) Map<String, Object> body,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [KYB-SERVICE] POST /api/kyb/submit - Request-ID: {}", requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }    
    
    @GetMapping("/{merchantId}")
    public ResponseEntity<Map<String, Object>> getKyb(
            @PathVariable String merchantId,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [KYB-SERVICE] GET /api/kyb/{} - Request-ID: {}", merchantId, requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação",
            "merchantId", merchantId
        );
        return ResponseEntity.ok(response);
    }    
    
    @PutMapping("/{id}/verify")
    public ResponseEntity<Map<String, Object>> verify(
            @PathVariable String id,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [KYB-SERVICE] PUT /api/kyb/{}/verify - Request-ID: {}", id, requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "id", id,
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }
}
