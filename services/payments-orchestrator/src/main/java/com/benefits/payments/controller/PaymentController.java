package com.benefits.payments.controller;

import com.benefits.payments.entity.Transaction;
import com.benefits.payments.service.PaymentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/payments")
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    // ===============================
    // TRANSACTION ENDPOINTS
    // ===============================

    @PostMapping("/transactions")
    public Mono<ResponseEntity<Transaction>> createTransaction(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String transactionId,
            @RequestParam UUID personId,
            @RequestParam UUID employerId,
            @RequestParam BigDecimal amount,
            @RequestParam(required = false) String description) {

        log.info("[Payment] Creating transaction: {}", transactionId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.createTransaction(tenantId, transactionId, personId, employerId, amount, description)
                .map(transaction -> ResponseEntity.status(HttpStatus.CREATED).body(transaction))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/transactions/{transactionId}")
    public Mono<ResponseEntity<Transaction>> getTransaction(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID transactionId) {

        log.info("[Payment] Getting transaction: {}", transactionId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.getTransaction(tenantId, transactionId)
                .map(transaction -> ResponseEntity.ok(transaction))
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/transactions")
    public Mono<ResponseEntity<List<Transaction>>> listTransactions(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Payment] Listing transactions");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.listTransactions(tenantId)
                .collectList()
                .map((List<Transaction> transactions) -> ResponseEntity.ok(transactions))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/persons/{personId}/transactions")
    public Mono<ResponseEntity<List<Transaction>>> listPersonTransactions(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID personId) {

        log.info("[Payment] Listing transactions for person: {}", personId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.listPersonTransactions(tenantId, personId)
                .collectList()
                .map(transactions -> ResponseEntity.ok(transactions))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // PAYMENT PROCESSING ENDPOINTS
    // ===============================

    @PutMapping("/transactions/{transactionId}/authorize")
    public Mono<ResponseEntity<Transaction>> authorizePayment(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID transactionId) {

        log.info("[Payment] Authorizing payment: {}", transactionId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.authorizePayment(tenantId, transactionId)
                .map(transaction -> ResponseEntity.ok(transaction))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/transactions/{transactionId}/complete")
    public Mono<ResponseEntity<Transaction>> completePayment(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID transactionId) {

        log.info("[Payment] Completing payment: {}", transactionId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.completePayment(tenantId, transactionId)
                .map(transaction -> ResponseEntity.ok(transaction))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/transactions/{transactionId}/cancel")
    public Mono<ResponseEntity<Transaction>> cancelPayment(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID transactionId) {

        log.info("[Payment] Cancelling payment: {}", transactionId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.cancelPayment(tenantId, transactionId)
                .map(transaction -> ResponseEntity.ok(transaction))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // STATISTICS ENDPOINTS
    // ===============================

    @GetMapping("/stats")
    public Mono<ResponseEntity<PaymentService.TransactionStats>> getTransactionStats(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Payment] Getting transaction stats");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return paymentService.getTransactionStats(tenantId)
                .map(stats -> ResponseEntity.ok(stats))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}