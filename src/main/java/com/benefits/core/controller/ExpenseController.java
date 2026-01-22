package com.benefits.core.controller;

import com.benefits.core.dto.*;
import com.benefits.core.service.ExpenseService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.UUID;

@RestController
@RequestMapping("/internal/expenses")
public class ExpenseController {

    private static final Logger log = LoggerFactory.getLogger(ExpenseController.class);

    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    // Submit new expense
    @PostMapping
    public Mono<ResponseEntity<ExpenseResponse>> submitExpense(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestHeader(value = "X-Person-Id", required = false) String personIdHeader,
            @RequestHeader(value = "X-Employer-Id", required = false) String employerIdHeader,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey,
            @Valid @RequestBody ExpenseRequest request) {

        log.info("[F09] POST /internal/expenses - Submitting expense");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            UUID personId = UUID.fromString(personIdHeader);
            UUID employerId = UUID.fromString(employerIdHeader);

            return expenseService.submitExpense(tenantId, personId, employerId, request, idempotencyKey)
                .map(response -> ResponseEntity.status(HttpStatus.CREATED).body(response))
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // Get expense by ID
    @GetMapping("/{expenseId}")
    public Mono<ResponseEntity<ExpenseResponse>> getExpense(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID expenseId) {

        log.info("[F09] GET /internal/expenses/{} - Getting expense", expenseId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            return expenseService.getExpense(tenantId, expenseId)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // List expenses
    @GetMapping
    public Mono<ResponseEntity<ExpenseListResponse>> listExpenses(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam(required = false) String personId,
            @RequestParam(required = false) String employerId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        log.info("[F09] GET /internal/expenses - Listing expenses");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            UUID personUUID = personId != null ? UUID.fromString(personId) : null;
            UUID employerUUID = employerId != null ? UUID.fromString(employerId) : null;

            return expenseService.listExpenses(tenantId, personUUID, employerUUID, status, page, size)
                .map(ResponseEntity::ok)
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // Approve expense
    @PutMapping("/{expenseId}/approve")
    public Mono<ResponseEntity<ExpenseResponse>> approveExpense(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestHeader(value = "X-Person-Id", required = false) String personIdHeader,
            @PathVariable UUID expenseId) {

        log.info("[F09] PUT /internal/expenses/{}/approve - Approving expense", expenseId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            UUID approvedBy = UUID.fromString(personIdHeader);

            return expenseService.approveExpense(tenantId, expenseId, approvedBy)
                .map(ResponseEntity::ok)
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // Reject expense
    @PutMapping("/{expenseId}/reject")
    public Mono<ResponseEntity<ExpenseResponse>> rejectExpense(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestHeader(value = "X-Person-Id", required = false) String personIdHeader,
            @PathVariable UUID expenseId) {

        log.info("[F09] PUT /internal/expenses/{}/reject - Rejecting expense", expenseId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            UUID rejectedBy = UUID.fromString(personIdHeader);

            return expenseService.rejectExpense(tenantId, expenseId, rejectedBy)
                .map(ResponseEntity::ok)
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // Reimburse expense
    @PutMapping("/{expenseId}/reimburse")
    public Mono<ResponseEntity<ExpenseResponse>> reimburseExpense(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID expenseId) {

        log.info("[F09] PUT /internal/expenses/{}/reimburse - Reimbursing expense", expenseId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return expenseService.reimburseExpense(tenantId, expenseId)
                .map(ResponseEntity::ok)
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // Add receipt to expense
    @PostMapping("/{expenseId}/receipts")
    public Mono<ResponseEntity<ExpenseReceiptResponse>> addReceipt(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID expenseId,
            @Valid @RequestBody ExpenseReceiptRequest request) {

        log.info("[F09] POST /internal/expenses/{}/receipts - Adding receipt", expenseId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return expenseService.addReceipt(tenantId, expenseId, request)
                .map(response -> ResponseEntity.status(HttpStatus.CREATED).body(response))
                .onErrorResume(this::handleError);
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // Error handling
    private <T> Mono<ResponseEntity<T>> handleError(Throwable error) {
        log.error("[F09] Error in expense operation", error);

        if (error instanceof IllegalArgumentException) {
            return Mono.just(ResponseEntity.badRequest().build());
        } else if (error instanceof IllegalStateException) {
            return Mono.just(ResponseEntity.status(HttpStatus.CONFLICT).build());
        } else {
            return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
        }
    }
}