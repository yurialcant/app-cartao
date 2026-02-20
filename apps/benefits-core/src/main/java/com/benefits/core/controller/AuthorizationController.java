package com.benefits.core.controller;

import com.benefits.core.dto.AuthorizeRequest;
import com.benefits.core.dto.AuthorizeResponse;
import com.benefits.core.entity.Merchant;
import com.benefits.core.repository.MerchantRepository;
import com.benefits.core.service.AuthorizationService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Authorization Controller
 *
 * REST endpoints for POS payment authorization (F06)
 */
@RestController
@RequestMapping("/internal/authorize")
public class AuthorizationController {

    private static final Logger log = LoggerFactory.getLogger(AuthorizationController.class);

    private final AuthorizationService authorizationService;
    private final MerchantRepository merchantRepository;

    public AuthorizationController(AuthorizationService authorizationService, MerchantRepository merchantRepository) {
        this.authorizationService = authorizationService;
        this.merchantRepository = merchantRepository;
    }

    /**
     * POST /internal/authorize
     *
     * Authorize POS payment
     *
     * Headers required:
     * - X-Tenant-Id: UUID
     * - X-Person-Id: UUID (from JWT)
     */
    @PostMapping
    public Mono<ResponseEntity<AuthorizeResponse>> authorizePayment(
            @RequestHeader(value = "X-Tenant-Id", required = false) UUID tenantId,
            @RequestHeader(value = "X-Person-Id", required = false) UUID personId,
            @RequestBody AuthorizeRequest request) {

        log.info("[F06] ===== POST /internal/authorize REQUEST RECEIVED =====");
        log.info("[F06] Headers received - X-Tenant-Id: {}, X-Person-Id: {}", tenantId, personId);

        // For testing: if headers are not present, try to get from request body
        UUID finalTenantId = tenantId != null ? tenantId : request.getTenantId();
        UUID finalPersonId = personId != null ? personId : request.getPersonId();

        log.info("[F06] Final IDs - Tenant: {}, Person: {}", finalTenantId, finalPersonId);
        log.info("[F06] Request body - Terminal: {}, Merchant: {}, Wallet: {}, Amount: {}, IdempotencyKey: {}",
                request.getTerminalId(), request.getMerchantId(), request.getWalletId(), request.getAmount(),
                request.getIdempotencyKey());

        // Override person_id from header (JWT) for security, fallback to request
        request.setPersonId(finalPersonId);
        log.info("[F06] Person ID set in request: {}", request.getPersonId());

        log.info("[F06] Calling authorizationService.authorizePayment...");
        return authorizationService.authorizePayment(finalTenantId, request)
                .doOnNext(response -> log.info("[F06] Authorization service returned: {}", response))
                .map(response -> {
                    if ("APPROVED".equals(response.getStatus())) {
                        log.info("[F06] Returning 200 OK with APPROVED response");
                        return ResponseEntity.ok(response);
                    } else {
                        log.info("[F06] Returning 402 PAYMENT REQUIRED with {} response", response.getStatus());
                        return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(response);
                    }
                })
                .doOnError(error -> log.error("[F06] Error in authorization flow: {}", error.getMessage(), error))
                .onErrorResume(error -> {
                    log.error("[F06] Authorization error: {}", error.getMessage(), error);
                    AuthorizeResponse errorResponse = AuthorizeResponse.declined("internal_error",
                            "Internal server error");
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
                });
    }

    /**
     * GET /internal/authorize/test/status - Test endpoint to check repository
     * injection
     */
    @GetMapping("/test/status")
    public Mono<ResponseEntity<String>> testStatus() {
        log.info("[F06] Testing repository injection status");
        String status = String.format(
                "AuthorizationService: %s, MerchantRepository: %s, TerminalRepository: %s, WalletRepository: %s, LedgerEntryRepository: %s",
                authorizationService != null ? "OK" : "NULL",
                merchantRepository != null ? "OK" : "NULL",
                "N/A", "N/A", "N/A");
        log.info("[F06] Injection status: {}", status);
        return Mono.just(ResponseEntity.ok(status));
    }

    /**
     * POST /internal/authorize/test/simple - Simple test endpoint
     */
    @PostMapping("/test/simple")
    public Mono<ResponseEntity<String>> testSimple() {
        log.info("[F06] Simple test endpoint called");
        return Mono.just(ResponseEntity.ok("Simple test successful"));
    }

    /**
     * POST /internal/authorize/test/no-validation - Test endpoint without
     * validation
     */
    @PostMapping("/test/no-validation")
    public Mono<ResponseEntity<AuthorizeResponse>> testNoValidation(@RequestBody AuthorizeRequest request) {
        log.info("[F06] ===== TEST NO VALIDATION ENDPOINT =====");
        log.info("[F06] Raw request body: {}", request);

        // First, test a simple database query to check connection
        log.info("[F06] Testing database connection with simple merchant query...");
        return merchantRepository.findByTenantIdAndMerchantId(
                UUID.fromString("550e8400-e29b-41d4-a716-446655440000"), "MERCH001")
                .doOnNext(merchant -> log.info("[F06] Database connection successful! Found merchant: {}",
                        merchant.getName()))
                .doOnError(error -> log.error("[F06] Database connection failed: {}", error.getMessage(), error))
                .then(Mono.defer(() -> {
                    // If database works, proceed with full test
                    log.info("[F06] Database OK, proceeding with authorization test");

                    // Hardcoded test data for debugging
                    UUID hardcodedTenantId = UUID.fromString("550e8400-e29b-41d4-a716-446655440000"); // origami tenant
                    UUID hardcodedPersonId = UUID.fromString("550e8400-e29b-41d4-a716-446655440001"); // Lucas

                    // Create a test request with valid data
                    AuthorizeRequest testRequest = new AuthorizeRequest();
                    testRequest.setTerminalId("TERM001");
                    testRequest.setMerchantId("MERCH001"); // Origami merchant code
                    testRequest.setPersonId(hardcodedPersonId);
                    testRequest.setWalletId(UUID.fromString("550e8400-e29b-41d4-a716-446655440200")); // MEAL wallet
                    testRequest.setAmount(new java.math.BigDecimal("10.00"));
                    testRequest.setIdempotencyKey("test-" + System.currentTimeMillis());
                    testRequest.setTenantId(hardcodedTenantId);

                    log.info(
                            "[F06] Test request created - TerminalId: {}, MerchantId: {}, PersonId: {}, WalletId: {}, Amount: {}, IdempotencyKey: {}",
                            testRequest.getTerminalId(), testRequest.getMerchantId(), testRequest.getPersonId(),
                            testRequest.getWalletId(), testRequest.getAmount(), testRequest.getIdempotencyKey());

                    return authorizationService.authorizePayment(hardcodedTenantId, testRequest)
                            .doOnNext(response -> log.info("[F06] Test authorization successful: {}", response))
                            .map(response -> {
                                if ("APPROVED".equals(response.getStatus())) {
                                    return ResponseEntity.ok(response);
                                } else {
                                    return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(response);
                                }
                            });
                }))
                .doOnError(error -> log.error("[F06] Test failed: {}", error.getMessage(), error))
                .onErrorResume(error -> {
                    log.error("[F06] Test error: {}", error.getMessage(), error);
                    AuthorizeResponse errorResponse = AuthorizeResponse.declined("db_error",
                            "Database connection failed: " + error.getMessage());
                    return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse));
                });
    }
}