package com.benefits.settlement.controller;

import com.benefits.settlement.entity.Settlement;
import com.benefits.settlement.repository.SettlementRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/settlement")
public class SettlementController {

    private static final Logger log = LoggerFactory.getLogger(SettlementController.class);

    private final SettlementRepository settlementRepository;

    public SettlementController(SettlementRepository settlementRepository) {
        this.settlementRepository = settlementRepository;
    }

    @PostMapping("/settlements")
    public Mono<ResponseEntity<Settlement>> createSettlement(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String settlementId,
            @RequestParam UUID merchantId,
            @RequestParam String periodStart,
            @RequestParam String periodEnd) {

        log.info("[Settlement] Creating settlement: {}", settlementId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            LocalDate start = LocalDate.parse(periodStart);
            LocalDate end = LocalDate.parse(periodEnd);

            Settlement settlement = new Settlement(tenantId, settlementId, merchantId, start, end);

            return settlementRepository.save(settlement)
                .map(saved -> ResponseEntity.status(HttpStatus.CREATED).body(saved))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/settlements")
    public Mono<ResponseEntity<List<Settlement>>> listSettlements(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Settlement] Listing settlements");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return settlementRepository.findByTenantId(tenantId)
                .collectList()
                .map(settlements -> ResponseEntity.ok(settlements))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/settlements/{settlementId}/complete")
    public Mono<ResponseEntity<Settlement>> completeSettlement(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable String settlementId) {

        log.info("[Settlement] Completing settlement: {}", settlementId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return settlementRepository.findByTenantIdAndSettlementId(tenantId, settlementId)
                .flatMap(settlement -> {
                    settlement.setStatus("COMPLETED");
                    return settlementRepository.save(settlement);
                })
                .map(updated -> ResponseEntity.ok(updated))
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}