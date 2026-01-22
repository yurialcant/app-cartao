package com.benefits.reconservice.controller;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/reconciliation")
@RequiredArgsConstructor
public class ReconciliationController {
    
    private static final Logger log = LoggerFactory.getLogger(ReconciliationController.class);
    
    @PostMapping("/import")
    public ResponseEntity<Map<String, Object>> importStatement(
            @RequestBody(required = false) Map<String, Object> body,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [RECON-SERVICE] POST /api/reconciliation/import - Request-ID: {}", requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }    
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> getReconciliation(
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [RECON-SERVICE] GET /api/reconciliation - Request-ID: {}", requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }    
    
    @PostMapping("/{id}/reconcile")
    public ResponseEntity<Map<String, Object>> reconcile(
            @PathVariable String id,
            HttpServletRequest request) {
        String requestId = request.getHeader("X-Request-Id");
        log.info("🔵 [RECON-SERVICE] POST /api/reconciliation/{}/reconcile - Request-ID: {}", id, requestId);
        
        // TODO: Implementar lógica
        Map<String, Object> response = Map.of(
            "id", id,
            "status", "OK",
            "message", "Endpoint em implementação"
        );
        return ResponseEntity.ok(response);
    }
}
