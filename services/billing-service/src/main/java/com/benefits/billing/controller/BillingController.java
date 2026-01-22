package com.benefits.billing.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;

@RestController
@RequestMapping("/internal/billing")
public class BillingController {

    private static final Logger log = LoggerFactory.getLogger(BillingController.class);

    @PostMapping("/invoices")
    public Mono<ResponseEntity<String>> createInvoice(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String invoiceNumber,
            @RequestParam String employerId,
            @RequestParam String periodStart,
            @RequestParam String periodEnd) {

        log.info("[Billing] Creating invoice: {}", invoiceNumber);

        try {
            // In a real implementation, this would save to database
            return Mono.just(ResponseEntity.status(HttpStatus.CREATED)
                .body("Invoice created: " + invoiceNumber));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().body("Invalid request"));
        }
    }

    @GetMapping("/invoices")
    public Mono<ResponseEntity<List<String>>> listInvoices(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Billing] Listing invoices");

        try {
            // In a real implementation, this would query database
            return Mono.just(ResponseEntity.ok(List.of("Sample invoice 1", "Sample invoice 2")));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}