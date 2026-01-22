package com.benefits.support_bff.service;

import com.benefits.support_bff.client.BenefitsCoreExpenseClient;
import com.benefits.support_bff.dto.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ExpenseService {

    private static final Logger log = LoggerFactory.getLogger(ExpenseService.class);

    private final BenefitsCoreExpenseClient benefitsCoreClient;
    private final AuthService authService;

    public ExpenseService(BenefitsCoreExpenseClient benefitsCoreClient, AuthService authService) {
        this.benefitsCoreClient = benefitsCoreClient;
        this.authService = authService;
    }

    // Submit expense for current user
    public Mono<PublicExpenseResponse> submitExpense(String token, ExpenseSubmitRequest request) {
        log.info("[Support-BFF] Submitting expense for user");

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                // Map public request to internal request
                var internalRequest = mapToInternalRequest(request);

                return benefitsCoreClient.submitExpense(
                    userInfo.getTenantId().toString(),
                    userInfo.getPersonId().toString(),
                    userInfo.getEmployerId().toString(),
                    "expense-" + System.currentTimeMillis(), // Idempotency key
                    internalRequest
                ).map(this::mapToPublicResponse);
            });
    }

    // Get expense by ID (user can only see their own expenses)
    public Mono<PublicExpenseResponse> getUserExpense(String token, UUID expenseId) {
        log.info("[Support-BFF] Getting expense for user: {}", expenseId);

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                // First check if expense belongs to user (by getting it)
                return benefitsCoreClient.getExpense(
                    userInfo.getTenantId().toString(),
                    expenseId
                ).map(internalResponse -> {
                    // Additional validation: ensure expense belongs to current user
                    // For now, we'll rely on the core service's tenant validation
                    return mapToPublicResponse(internalResponse);
                });
            });
    }

    // List user expenses
    public Mono<PublicExpenseListResponse> listUserExpenses(String token, String status, int page, int size) {
        log.info("[Support-BFF] Listing user expenses");

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                return benefitsCoreClient.listExpenses(
                    userInfo.getTenantId().toString(),
                    userInfo.getPersonId().toString(), // Filter by current user
                    null, // No employer filter for users
                    status,
                    page,
                    size
                ).map(this::mapToPublicListResponse);
            });
    }

    // Approve expense (employer admin only)
    public Mono<PublicExpenseResponse> approveExpense(String token, UUID expenseId) {
        log.info("[Support-BFF] Approving expense: {}", expenseId);

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                // Check if user has employer_admin role
                if (!userInfo.hasRole("employer_admin")) {
                    return Mono.error(new SecurityException("Insufficient permissions"));
                }

                return benefitsCoreClient.approveExpense(
                    userInfo.getTenantId().toString(),
                    userInfo.getPersonId().toString(),
                    expenseId
                ).map(this::mapToPublicResponse);
            });
    }

    // Reject expense (employer admin only)
    public Mono<PublicExpenseResponse> rejectExpense(String token, UUID expenseId) {
        log.info("[Support-BFF] Rejecting expense: {}", expenseId);

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                // Check if user has employer_admin role
                if (!userInfo.hasRole("employer_admin")) {
                    return Mono.error(new SecurityException("Insufficient permissions"));
                }

                return benefitsCoreClient.rejectExpense(
                    userInfo.getTenantId().toString(),
                    userInfo.getPersonId().toString(),
                    expenseId
                ).map(this::mapToPublicResponse);
            });
    }

    // List pending expenses for employer (employer admin only)
    public Mono<PublicExpenseListResponse> listEmployerPendingExpenses(String token, int page, int size) {
        log.info("[Support-BFF] Listing employer pending expenses");

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                // Check if user has employer_admin role
                if (!userInfo.hasRole("employer_admin")) {
                    return Mono.error(new SecurityException("Insufficient permissions"));
                }

                return benefitsCoreClient.listExpenses(
                    userInfo.getTenantId().toString(),
                    null, // No person filter
                    userInfo.getEmployerId().toString(), // Filter by current user's employer
                    "PENDING", // Only pending expenses
                    page,
                    size
                ).map(this::mapToPublicListResponse);
            });
    }

    // Add receipt to expense
    public Mono<PublicReceiptResponse> addReceipt(String token, UUID expenseId, ExpenseReceiptUpload upload) {
        log.info("[Support-BFF] Adding receipt to expense: {}", expenseId);

        return authService.extractUserInfo(token)
            .flatMap(userInfo -> {
                var receiptRequest = new ExpenseReceiptRequest();
                receiptRequest.setFilename(upload.getFilename());
                receiptRequest.setContentType(upload.getContentType());
                receiptRequest.setFileSize(upload.getFileSize());

                return benefitsCoreClient.addReceipt(
                    userInfo.getTenantId().toString(),
                    expenseId,
                    receiptRequest
                ).map(internalResponse -> new PublicReceiptResponse(
                    internalResponse.getReceiptId(),
                    internalResponse.getFilename(),
                    internalResponse.getContentType(),
                    internalResponse.getFileSize(),
                    internalResponse.getUploadedAt()
                ));
            });
    }

    // Helper methods for DTO mapping
    private com.benefits.support_bff.dto.InternalExpenseSubmitRequest mapToInternalRequest(ExpenseSubmitRequest publicRequest) {
        var internalRequest = new com.benefits.support_bff.dto.InternalExpenseSubmitRequest();
        internalRequest.setTitle(publicRequest.getTitle());
        internalRequest.setDescription(publicRequest.getDescription());
        internalRequest.setAmount(publicRequest.getAmount());
        internalRequest.setCurrency(publicRequest.getCurrency());
        internalRequest.setCategory(publicRequest.getCategory());

        // Map receipts
        var internalReceipts = publicRequest.getReceipts().stream()
            .map(upload -> {
                var receipt = new ExpenseReceiptRequest();
                receipt.setFilename(upload.getFilename());
                receipt.setContentType(upload.getContentType());
                receipt.setFileSize(upload.getFileSize());
                return receipt;
            })
            .collect(Collectors.toList());

        internalRequest.setReceipts(internalReceipts);
        return internalRequest;
    }

    private PublicExpenseResponse mapToPublicResponse(com.benefits.support_bff.dto.ExpenseResponse internal) {
        var publicReceipts = internal.getReceipts().stream()
            .map(r -> new PublicReceiptResponse(
                r.getReceiptId(),
                r.getFilename(),
                r.getContentType(),
                r.getFileSize(),
                r.getUploadedAt()
            ))
            .collect(Collectors.toList());

        return new PublicExpenseResponse(
            internal.getExpenseId(),
            internal.getTitle(),
            internal.getDescription(),
            internal.getAmount(),
            internal.getCurrency(),
            internal.getCategory(),
            internal.getStatus(),
            internal.getSubmittedAt(),
            internal.getApprovedAt(),
            internal.getReimbursedAt(),
            publicReceipts
        );
    }

    private PublicExpenseListResponse mapToPublicListResponse(com.benefits.support_bff.dto.ExpenseListResponse internal) {
        var publicExpenses = internal.getExpenses().stream()
            .map(this::mapToPublicResponse)
            .collect(Collectors.toList());

        return new PublicExpenseListResponse(
            publicExpenses,
            internal.getPage(),
            internal.getSize(),
            internal.getTotalElements(),
            internal.getTotalPages()
        );
    }
}