package com.benefits.merchant.controller;

import com.benefits.merchant.entity.Merchant;
import com.benefits.merchant.entity.Terminal;
import com.benefits.merchant.service.MerchantService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/merchants")
public class MerchantController {

    private static final Logger log = LoggerFactory.getLogger(MerchantController.class);

    private final MerchantService merchantService;

    public MerchantController(MerchantService merchantService) {
        this.merchantService = merchantService;
    }

    // ===============================
    // MERCHANT ENDPOINTS
    // ===============================

    @PostMapping("/merchants")
    public Mono<ResponseEntity<Merchant>> createMerchant(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String merchantId,
            @RequestParam String name,
            @RequestParam(required = false) String businessName,
            @RequestParam(required = false) String document) {

        log.info("[Merchant] Creating merchant: {}", merchantId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.createMerchant(tenantId, merchantId, name, businessName, document)
                .map(merchant -> ResponseEntity.status(HttpStatus.CREATED).body(merchant))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/merchants/{merchantId}")
    public Mono<ResponseEntity<Merchant>> getMerchant(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID merchantId) {

        log.info("[Merchant] Getting merchant: {}", merchantId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.getMerchant(tenantId, merchantId)
                .map(merchant -> ResponseEntity.ok(merchant))
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/merchants")
    public Mono<ResponseEntity<List<Merchant>>> listMerchants(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Merchant] Listing merchants");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.listMerchants(tenantId)
                .collectList()
                .map(merchants -> ResponseEntity.ok(merchants))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/merchants/{merchantId}")
    public Mono<ResponseEntity<Merchant>> updateMerchant(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID merchantId,
            @RequestBody Merchant updates) {

        log.info("[Merchant] Updating merchant: {}", merchantId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.updateMerchant(tenantId, merchantId, updates)
                .map(merchant -> ResponseEntity.ok(merchant))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/merchants/{merchantId}/status")
    public Mono<ResponseEntity<Merchant>> updateMerchantStatus(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID merchantId,
            @RequestParam String status) {

        log.info("[Merchant] Updating merchant status: {}", status);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.updateMerchantStatus(tenantId, merchantId, status)
                .map(merchant -> ResponseEntity.ok(merchant))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // TERMINAL ENDPOINTS
    // ===============================

    @PostMapping("/terminals")
    public Mono<ResponseEntity<Terminal>> createTerminal(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam UUID merchantId,
            @RequestParam String terminalId,
            @RequestParam String locationName,
            @RequestParam(required = false) String locationAddress) {

        log.info("[Merchant] Creating terminal: {} for merchant: {}", terminalId, merchantId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.createTerminal(tenantId, merchantId, terminalId, locationName, locationAddress)
                .map(terminal -> ResponseEntity.status(HttpStatus.CREATED).body(terminal))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/terminals/{terminalId}")
    public Mono<ResponseEntity<Terminal>> getTerminal(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID terminalId) {

        log.info("[Merchant] Getting terminal: {}", terminalId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.getTerminal(tenantId, terminalId)
                .map(terminal -> ResponseEntity.ok(terminal))
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/terminals")
    public Mono<ResponseEntity<List<Terminal>>> listTerminals(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Merchant] Listing terminals");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.listTerminals(tenantId)
                .collectList()
                .map(terminals -> ResponseEntity.ok(terminals))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/merchants/{merchantId}/terminals")
    public Mono<ResponseEntity<List<Terminal>>> listMerchantTerminals(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID merchantId) {

        log.info("[Merchant] Listing terminals for merchant: {}", merchantId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.listMerchantTerminals(tenantId, merchantId)
                .collectList()
                .map(terminals -> ResponseEntity.ok(terminals))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/terminals/{terminalId}")
    public Mono<ResponseEntity<Terminal>> updateTerminal(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID terminalId,
            @RequestBody Terminal updates) {

        log.info("[Merchant] Updating terminal: {}", terminalId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.updateTerminal(tenantId, terminalId, updates)
                .map(terminal -> ResponseEntity.ok(terminal))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/terminals/{terminalId}/status")
    public Mono<ResponseEntity<Terminal>> updateTerminalStatus(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID terminalId,
            @RequestParam String status) {

        log.info("[Merchant] Updating terminal status: {}", status);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.updateTerminalStatus(tenantId, terminalId, status)
                .map(terminal -> ResponseEntity.ok(terminal))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PostMapping("/terminals/{terminalId}/ping")
    public Mono<ResponseEntity<Terminal>> recordTerminalPing(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable String terminalId) {

        log.debug("[Merchant] Recording ping for terminal: {}", terminalId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.recordTerminalPing(tenantId, terminalId)
                .map(terminal -> ResponseEntity.ok(terminal))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PostMapping("/terminals/{terminalId}/transaction")
    public Mono<ResponseEntity<Terminal>> recordTerminalTransaction(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable String terminalId) {

        log.debug("[Merchant] Recording transaction for terminal: {}", terminalId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.recordTerminalTransaction(tenantId, terminalId)
                .map(terminal -> ResponseEntity.ok(terminal))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // STATISTICS ENDPOINTS
    // ===============================

    @GetMapping("/stats")
    public Mono<ResponseEntity<MerchantService.TerminalStats>> getTerminalStats(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Merchant] Getting terminal stats");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return merchantService.getTerminalStats(tenantId)
                .map(stats -> ResponseEntity.ok(stats))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}