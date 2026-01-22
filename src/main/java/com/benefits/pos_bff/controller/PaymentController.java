package com.benefits.pos_bff.controller;

import com.benefits.pos_bff.dto.AuthorizeRequest;
import com.benefits.pos_bff.dto.AuthorizeResponse;
import com.benefits.pos_bff.service.AuthorizationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * F06 POS Terminal Payment Controller
 *
 * Endpoints for POS terminal payment operations:
 * - Payment authorization
 * - Payment confirmation
 * - Terminal status
 */
@RestController
@RequestMapping("/api/v1/pos")
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

    private final AuthorizationService authorizationService;

    public PaymentController(AuthorizationService authorizationService) {
        this.authorizationService = authorizationService;
    }

    @GetMapping("/test")
    public Mono<ResponseEntity<String>> test() {
        return Mono.just(ResponseEntity.ok("POS BFF is running!"));
    }

    /**
     * POST /api/v1/pos/authorize
     *
     * Authorize payment at POS terminal (F06)
     */
    @PostMapping("/authorize")
    public Mono<ResponseEntity<AuthorizeResponse>> authorizePayment(
            @RequestHeader("X-Tenant-Id") UUID tenantId,
            @RequestBody AuthorizeRequest request) {

        log.info("[F06] POST /pos/authorize - Terminal: {}, Merchant: {}, Amount: {}",
                request.getTerminalId(), request.getMerchantId(), request.getAmount());

        return authorizationService.authorize(tenantId, request)
                .map(response -> {
                    if ("APPROVED".equals(response.getStatus())) {
                        log.info("[F06] Authorization approved: {}", response.getAuthorizationCode());
                        return ResponseEntity.ok(response);
                    } else {
                        log.warn("[F06] Authorization declined: {}", response.getErrorCode());
                        return ResponseEntity.badRequest().body(response);
                    }
                })
                .onErrorResume(error -> {
                    log.error("[F06] Authorization error: {}", error.getMessage(), error);
                    AuthorizeResponse errorResponse = AuthorizeResponse.declined("SYSTEM_ERROR",
                            "Internal server error");
                    return Mono.just(ResponseEntity.status(500).body(errorResponse));
                });
    }
    
    /**
     * POST /api/v1/pos/confirm
     * 
     * Confirm payment at POS terminal
     */
    @PostMapping("/confirm")
    public Mono<ResponseEntity<String>> confirmPayment(@RequestBody String payload) {
        
        log.info("[F10] POST /pos/confirm - Payload: {}", payload);
        
        // Mock response for testing
        String mockResponse = "{\"status\":\"confirmed\",\"payment_id\":\"mock-123\"}";
        return Mono.just(ResponseEntity.ok(mockResponse));
    }
    
    /**
     * GET /api/v1/pos/status
     * 
     * Get terminal status
     */
    @GetMapping("/status")
    public Mono<ResponseEntity<String>> getStatus() {
        
        log.info("[F10] GET /pos/status");
        
        // Mock response for testing
        String mockResponse = "{\"status\":\"online\",\"terminal_id\":\"mock-terminal-1\"}";
        return Mono.just(ResponseEntity.ok(mockResponse));
    }
}
