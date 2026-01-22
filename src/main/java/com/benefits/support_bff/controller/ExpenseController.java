package com.benefits.support_bff.controller;

import com.benefits.support_bff.dto.*;
import com.benefits.support_bff.service.AuthService;
import com.benefits.support_bff.service.ExpenseService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/expenses")
public class ExpenseController {

    private static final Logger log = LoggerFactory.getLogger(ExpenseController.class);

    private final ExpenseService expenseService;
    private final AuthService authService;

    public ExpenseController(ExpenseService expenseService, AuthService authService) {
        this.expenseService = expenseService;
        this.authService = authService;
    }

    // ===============================
    // USER ENDPOINTS (Employees)
    // ===============================

    // Submit new expense
    @PostMapping
    public Mono<ResponseEntity<PublicExpenseResponse>> submitExpense(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @Valid @RequestBody ExpenseSubmitRequest request) {

        log.info("[Support-BFF] POST /api/v1/expenses - Submit expense");

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.submitExpense(token, request)
                    .map(response -> ResponseEntity.status(HttpStatus.CREATED).body(response))
                    .onErrorResume(this::handleError);
            });
    }

    // Get user's expense by ID
    @GetMapping("/{expenseId}")
    public Mono<ResponseEntity<PublicExpenseResponse>> getExpense(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable UUID expenseId) {

        log.info("[Support-BFF] GET /api/v1/expenses/{} - Get expense", expenseId);

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.getUserExpense(token, expenseId)
                    .map(ResponseEntity::ok)
                    .defaultIfEmpty(ResponseEntity.notFound().build())
                    .onErrorResume(this::handleError);
            });
    }

    // List user's expenses
    @GetMapping
    public Mono<ResponseEntity<PublicExpenseListResponse>> listUserExpenses(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        log.info("[Support-BFF] GET /api/v1/expenses - List user expenses");

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.listUserExpenses(token, status, page, size)
                    .map(ResponseEntity::ok)
                    .onErrorResume(this::handleError);
            });
    }

    // Add receipt to expense
    @PostMapping("/{expenseId}/receipts")
    public Mono<ResponseEntity<PublicReceiptResponse>> addReceipt(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable UUID expenseId,
            @Valid @RequestBody ExpenseReceiptUpload upload) {

        log.info("[Support-BFF] POST /api/v1/expenses/{}/receipts - Add receipt", expenseId);

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.addReceipt(token, expenseId, upload)
                    .map(response -> ResponseEntity.status(HttpStatus.CREATED).body(response))
                    .onErrorResume(this::handleError);
            });
    }

    // ===============================
    // EMPLOYER ADMIN ENDPOINTS
    // ===============================

    // List pending expenses for approval
    @GetMapping("/employer/pending")
    public Mono<ResponseEntity<PublicExpenseListResponse>> listPendingExpenses(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        log.info("[Support-BFF] GET /api/v1/expenses/employer/pending - List pending expenses");

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.listEmployerPendingExpenses(token, page, size)
                    .map(ResponseEntity::ok)
                    .onErrorResume(this::handleError);
            });
    }

    // Approve expense
    @PutMapping("/employer/{expenseId}/approve")
    public Mono<ResponseEntity<PublicExpenseResponse>> approveExpense(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable UUID expenseId) {

        log.info("[Support-BFF] PUT /api/v1/expenses/employer/{}/approve - Approve expense", expenseId);

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.approveExpense(token, expenseId)
                    .map(ResponseEntity::ok)
                    .onErrorResume(this::handleError);
            });
    }

    // Reject expense
    @PutMapping("/employer/{expenseId}/reject")
    public Mono<ResponseEntity<PublicExpenseResponse>> rejectExpense(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable UUID expenseId) {

        log.info("[Support-BFF] PUT /api/v1/expenses/employer/{}/reject - Reject expense", expenseId);

        String token = extractToken(authHeader);
        return authService.validateToken(token)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
                }

                return expenseService.rejectExpense(token, expenseId)
                    .map(ResponseEntity::ok)
                    .onErrorResume(this::handleError);
            });
    }

    // ===============================
    // HELPER METHODS
    // ===============================

    private String extractToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return authHeader; // For mock purposes
    }

    private <T> Mono<ResponseEntity<T>> handleError(Throwable error) {
        log.error("[Support-BFF] Error in expense operation", error);

        if (error instanceof SecurityException) {
            return Mono.just(ResponseEntity.status(HttpStatus.FORBIDDEN).build());
        } else if (error instanceof IllegalArgumentException) {
            return Mono.just(ResponseEntity.badRequest().build());
        } else if (error instanceof IllegalStateException) {
            return Mono.just(ResponseEntity.status(HttpStatus.CONFLICT).build());
        } else {
            return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
        }
    }
}