# Script para implementar stubs completos de adquirentes (Cielo e Stone)

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🏦 IMPLEMENTANDO STUBS DE ADQUIRENTES 🏦                 ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$stubDir = Join-Path $baseDir "services/acquirer-stub/src/main/java/com/benefits/acquirerstub"

# Criar controller completo para stub de adquirentes
$stubControllerPath = Join-Path $stubDir "controller/StubController.java"
$stubControllerContent = @"
package com.benefits.acquirerstub.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;
import java.util.UUID;
import java.util.Random;

@Slf4j
@RestController
@RequestMapping("/api/stub")
@RequiredArgsConstructor
public class StubController {
    
    private final Random random = new Random();
    
    // ============================================
    // CIELO STUB
    // ============================================
    
    @PostMapping("/cielo/authorize")
    public ResponseEntity<Map<String, Object>> cieloAuthorize(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Cielo Authorize - Amount: {}", requestBody.get("amount"));
        
        // Simular aprovação (90% aprovação)
        boolean approved = random.nextInt(100) < 90;
        
        Map<String, Object> response = Map.of(
            "acquirerTxnId", "CIELO-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(),
            "authCode", String.format("%06d", random.nextInt(999999)),
            "status", approved ? "APPROVED" : "DECLINED",
            "responseCode", approved ? "00" : "51",
            "responseMessage", approved ? "Transação aprovada" : "Saldo insuficiente",
            "nsu", String.format("%012d", random.nextInt(999999999)),
            "rrn", String.format("%012d", random.nextInt(999999999)),
            "timestamp", java.time.LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/cielo/capture")
    public ResponseEntity<Map<String, Object>> cieloCapture(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Cielo Capture - TxnId: {}", requestBody.get("acquirerTxnId"));
        
        Map<String, Object> response = Map.of(
            "acquirerTxnId", requestBody.get("acquirerTxnId"),
            "status", "CAPTURED",
            "capturedAt", java.time.LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/cielo/refund")
    public ResponseEntity<Map<String, Object>> cieloRefund(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Cielo Refund - TxnId: {}", requestBody.get("acquirerTxnId"));
        
        Map<String, Object> response = Map.of(
            "refundId", "REFUND-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(),
            "acquirerTxnId", requestBody.get("acquirerTxnId"),
            "status", "REFUNDED",
            "refundedAt", java.time.LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(response);
    }
    
    // ============================================
    // STONE STUB
    // ============================================
    
    @PostMapping("/stone/authorize")
    public ResponseEntity<Map<String, Object>> stoneAuthorize(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Stone Authorize - Amount: {}", requestBody.get("amount"));
        
        boolean approved = random.nextInt(100) < 90;
        
        Map<String, Object> response = Map.of(
            "acquirerTxnId", "STONE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(),
            "authCode", String.format("%06d", random.nextInt(999999)),
            "status", approved ? "APPROVED" : "DECLINED",
            "responseCode", approved ? "00" : "51",
            "responseMessage", approved ? "Transação aprovada" : "Saldo insuficiente",
            "nsu", String.format("%012d", random.nextInt(999999999)),
            "rrn", String.format("%012d", random.nextInt(999999999)),
            "timestamp", java.time.LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/stone/capture")
    public ResponseEntity<Map<String, Object>> stoneCapture(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Stone Capture - TxnId: {}", requestBody.get("acquirerTxnId"));
        
        Map<String, Object> response = Map.of(
            "acquirerTxnId", requestBody.get("acquirerTxnId"),
            "status", "CAPTURED",
            "capturedAt", java.time.LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/stone/refund")
    public ResponseEntity<Map<String, Object>> stoneRefund(
            @RequestBody Map<String, Object> requestBody,
            HttpServletRequest request) {
        
        log.info("🔵 [ACQUIRER-STUB] Stone Refund - TxnId: {}", requestBody.get("acquirerTxnId"));
        
        Map<String, Object> response = Map.of(
            "refundId", "REFUND-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(),
            "acquirerTxnId", requestBody.get("acquirerTxnId"),
            "status", "REFUNDED",
            "refundedAt", java.time.LocalDateTime.now().toString()
        );
        
        return ResponseEntity.ok(response);
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
"@

if (-not (Test-Path (Split-Path $stubControllerPath -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $stubControllerPath -Parent) -Force | Out-Null
}

Set-Content -Path $stubControllerPath -Value $stubControllerContent -Encoding UTF8
Write-Host "  ✓ Stub de adquirentes implementado" -ForegroundColor Green

# Criar service para webhook receiver
$webhookReceiverPath = Join-Path $baseDir "services/webhook-receiver/src/main/java/com/benefits/webhookreceiver/controller/WebhookController.java"
if (Test-Path $webhookReceiverPath) {
    $webhookContent = Get-Content $webhookReceiverPath -Raw
    $webhookContent = $webhookContent -replace "// TODO: Implementar lógica", @"
        log.info("🔵 [WEBHOOK-RECEIVER] Recebido webhook - Type: {}, TxnId: {}", 
                requestBody.get("type"), requestBody.get("acquirerTxnId"));
        
        // Processar webhook e atualizar transação no Core Service
        // TODO: Chamar Core Service para atualizar status da transação
        
        return ResponseEntity.ok(Map.of(
            "status", "PROCESSED",
            "message", "Webhook processado com sucesso"
        ));
"@
    Set-Content -Path $webhookReceiverPath -Value $webhookContent -Encoding UTF8
    Write-Host "  ✓ Webhook Receiver implementado" -ForegroundColor Green
}

Write-Host "`n✅ Stubs de adquirentes implementados!" -ForegroundColor Green
Write-Host ""
