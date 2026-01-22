package com.benefits.support_bff.client;

import com.benefits.support_bff.dto.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

@FeignClient(name = "benefits-core", url = "${benefits-core.url}")
public interface BenefitsCoreExpenseClient {

    // Submit expense
    @PostMapping("/internal/expenses")
    Mono<ExpenseResponse> submitExpense(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @RequestHeader("X-Person-Id") String personId,
        @RequestHeader("X-Employer-Id") String employerId,
        @RequestHeader("Idempotency-Key") String idempotencyKey,
        @RequestBody com.benefits.support_bff.dto.InternalExpenseSubmitRequest request
    );

    // Get expense by ID
    @GetMapping("/internal/expenses/{expenseId}")
    Mono<ExpenseResponse> getExpense(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @PathVariable UUID expenseId
    );

    // List expenses
    @GetMapping("/internal/expenses")
    Mono<ExpenseListResponse> listExpenses(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @RequestParam(required = false) String personId,
        @RequestParam(required = false) String employerId,
        @RequestParam(required = false) String status,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    );

    // Approve expense
    @PutMapping("/internal/expenses/{expenseId}/approve")
    Mono<ExpenseResponse> approveExpense(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @RequestHeader("X-Person-Id") String approverId,
        @PathVariable UUID expenseId
    );

    // Reject expense
    @PutMapping("/internal/expenses/{expenseId}/reject")
    Mono<ExpenseResponse> rejectExpense(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @RequestHeader("X-Person-Id") String rejectorId,
        @PathVariable UUID expenseId
    );

    // Reimburse expense
    @PutMapping("/internal/expenses/{expenseId}/reimburse")
    Mono<ExpenseResponse> reimburseExpense(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @PathVariable UUID expenseId
    );

    // Add receipt
    @PostMapping("/internal/expenses/{expenseId}/receipts")
    Mono<ExpenseReceiptResponse> addReceipt(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @PathVariable UUID expenseId,
        @RequestBody ExpenseReceiptRequest request
    );
}