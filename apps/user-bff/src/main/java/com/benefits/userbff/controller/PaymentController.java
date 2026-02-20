package com.benefits.userbff.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/payments")
public class PaymentController {

    @PostMapping("/create-qr")
    public ResponseEntity<Map<String, Object>> createQRPayment(@RequestBody Map<String, Object> request) {
        // Simplified version - TODO: Integrate with payment service
        return ResponseEntity.ok(Map.of("qrCode", "sample-qr-code", "paymentId", "123"));
    }

    @PostMapping("/scan-qr")
    public ResponseEntity<Map<String, Object>> scanQR(@RequestBody Map<String, Object> request) {
        // Simplified version - TODO: Integrate with payment service
        return ResponseEntity.ok(Map.of("status", "processed", "amount", 100.0));
    }

    @GetMapping("/history")
    public ResponseEntity<Map<String, Object>> getPaymentHistory() {
        // Simplified version - TODO: Integrate with payment service
        return ResponseEntity.ok(Map.of("transactions", java.util.List.of()));
    }
}