package com.benefits.acquirerstub.controller;

import com.benefits.acquirerstub.adapter.CieloStubAdapter;
import com.benefits.acquirerstub.adapter.StoneStubAdapter;
import com.benefits.acquirerstub.adapter.PagSeguroStubAdapter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/stub")
@RequiredArgsConstructor
public class StubController {
    
    private final CieloStubAdapter cieloAdapter;
    private final StoneStubAdapter stoneAdapter;
    private final PagSeguroStubAdapter pagSeguroAdapter;
    
    // ============================================
    // CIELO STUB
    // ============================================
    
    // ============================================
    // CIELO - Baseado na API real da Cielo
    // ============================================
    
    @PostMapping("/cielo/authorize")
    public ResponseEntity<Map<String, Object>> cieloAuthorize(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Cielo Authorize - Amount: {}", requestBody.get("amount"));
        return ResponseEntity.ok(cieloAdapter.authorize(requestBody));
    }
    
    @PostMapping("/cielo/capture")
    public ResponseEntity<Map<String, Object>> cieloCapture(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String paymentId = (String) requestBody.get("acquirerTxnId");
        log.info("🔵 [ACQUIRER-STUB] Cielo Capture - PaymentId: {}", paymentId);
        return ResponseEntity.ok(cieloAdapter.capture(paymentId, requestBody));
    }
    
    @PostMapping("/cielo/void")
    public ResponseEntity<Map<String, Object>> cieloVoid(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String paymentId = (String) requestBody.get("acquirerTxnId");
        log.info("🔵 [ACQUIRER-STUB] Cielo Void - PaymentId: {}", paymentId);
        return ResponseEntity.ok(cieloAdapter.voidTransaction(paymentId, requestBody));
    }
    
    @PostMapping("/cielo/refund")
    public ResponseEntity<Map<String, Object>> cieloRefund(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String paymentId = (String) requestBody.get("acquirerTxnId");
        log.info("🔵 [ACQUIRER-STUB] Cielo Refund - PaymentId: {}", paymentId);
        return ResponseEntity.ok(cieloAdapter.refund(paymentId, requestBody));
    }
    
    // ============================================
    // STONE - Baseado na API real da Stone
    // ============================================
    
    @PostMapping("/stone/authorize")
    public ResponseEntity<Map<String, Object>> stoneAuthorize(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Stone Authorize - Amount: {}", requestBody.get("amount"));
        return ResponseEntity.ok(stoneAdapter.authorize(requestBody));
    }
    
    @PostMapping("/stone/capture")
    public ResponseEntity<Map<String, Object>> stoneCapture(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String transactionId = (String) requestBody.get("acquirerTxnId");
        log.info("🔵 [ACQUIRER-STUB] Stone Capture - TransactionId: {}", transactionId);
        return ResponseEntity.ok(stoneAdapter.capture(transactionId, requestBody));
    }
    
    @PostMapping("/stone/refund")
    public ResponseEntity<Map<String, Object>> stoneRefund(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String transactionId = (String) requestBody.get("acquirerTxnId");
        log.info("🔵 [ACQUIRER-STUB] Stone Refund - TransactionId: {}", transactionId);
        return ResponseEntity.ok(stoneAdapter.refund(transactionId, requestBody));
    }
    
    // ============================================
    // PAGSEGURO - Baseado na API real do PagSeguro
    // ============================================
    
    @PostMapping("/pagseguro/authorize")
    public ResponseEntity<Map<String, Object>> pagSeguroAuthorize(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] PagSeguro Authorize - Amount: {}", requestBody.get("amount"));
        return ResponseEntity.ok(pagSeguroAdapter.authorize(requestBody));
    }
    
    @PostMapping("/pagseguro/capture")
    public ResponseEntity<Map<String, Object>> pagSeguroCapture(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String chargeId = (String) requestBody.get("chargeId");
        log.info("🔵 [ACQUIRER-STUB] PagSeguro Capture - ChargeId: {}", chargeId);
        return ResponseEntity.ok(pagSeguroAdapter.capture(chargeId, requestBody));
    }
    
    @PostMapping("/pagseguro/refund")
    public ResponseEntity<Map<String, Object>> pagSeguroRefund(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        String chargeId = (String) requestBody.get("chargeId");
        log.info("🔵 [ACQUIRER-STUB] PagSeguro Refund - ChargeId: {}", chargeId);
        return ResponseEntity.ok(pagSeguroAdapter.refund(chargeId, requestBody));
    }
    
    // ============================================
    // WEBHOOK SIMULATOR
    // ============================================
    
    @PostMapping("/webhook")
    public ResponseEntity<Map<String, Object>> simulateWebhook(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Simulating webhook - Type: {}", requestBody.get("type"));
        
        // Simular recebimento de webhook e encaminhar para webhook-receiver
        // TODO: Chamar webhook-receiver service
        
        return ResponseEntity.ok(Map.of(
            "status", "OK",
            "message", "Webhook simulado e processado"
        ));
    }
}
