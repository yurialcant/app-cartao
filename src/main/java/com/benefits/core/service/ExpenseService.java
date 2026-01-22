package com.benefits.core.service;

import com.benefits.core.dto.*;
import com.benefits.core.entity.Expense;
import com.benefits.core.entity.ExpenseReceipt;
import com.benefits.core.entity.LedgerEntry;
import com.benefits.core.entity.Wallet;
import com.benefits.core.repository.ExpenseRepository;
import com.benefits.core.repository.ExpenseReceiptRepository;
import com.benefits.core.repository.LedgerEntryRepository;
import com.benefits.core.repository.WalletRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Flux;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class ExpenseService {

    private static final Logger log = LoggerFactory.getLogger(ExpenseService.class);

    private final ExpenseRepository expenseRepository;
    private final ExpenseReceiptRepository expenseReceiptRepository;
    private final WalletRepository walletRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    public ExpenseService(ExpenseRepository expenseRepository,
                         ExpenseReceiptRepository expenseReceiptRepository,
                         WalletRepository walletRepository,
                         LedgerEntryRepository ledgerEntryRepository) {
        this.expenseRepository = expenseRepository;
        this.expenseReceiptRepository = expenseReceiptRepository;
        this.walletRepository = walletRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    // Submit new expense
    public Mono<ExpenseResponse> submitExpense(UUID tenantId, UUID personId, UUID employerId,
                                              ExpenseRequest request, String idempotencyKey) {
        log.info("[F09] Submitting expense for person: {} in tenant: {}", personId, tenantId);

        return validatePersonAndWallet(tenantId, personId)
            .flatMap(wallet -> {
                Expense expense = new Expense(tenantId, personId, employerId,
                                            request.getTitle(), request.getDescription(),
                                            request.getAmount(), request.getCurrency(),
                                            request.getCategory());

                return expenseRepository.save(expense)
                    .flatMap(savedExpense -> {
                        // Save receipts
                        Flux<ExpenseReceipt> receiptFlux = Flux.fromIterable(request.getReceipts())
                            .map(receiptReq -> new ExpenseReceipt(savedExpense.getId(),
                                                                receiptReq.getFilename(),
                                                                receiptReq.getContentType(),
                                                                receiptReq.getFileSize()))
                            .flatMap(expenseReceiptRepository::save);

                        return receiptFlux.collectList()
                            .map(receipts -> {
                                // Convert receipts to response DTOs
                                var receiptResponses = receipts.stream()
                                    .map(r -> new ExpenseReceiptResponse(r.getId(), r.getFilename(),
                                                                       r.getContentType(), r.getFileSize(),
                                                                       r.getUploadedAt()))
                                    .toList();
                                return new ExpenseResponse(savedExpense, receiptResponses);
                            });
                    });
            });
    }

    // Get expense by ID
    public Mono<ExpenseResponse> getExpense(UUID tenantId, UUID expenseId) {
        log.info("[F09] Getting expense: {} in tenant: {}", expenseId, tenantId);

        return expenseRepository.findByIdAndTenantId(expenseId, tenantId)
            .flatMap(expense -> {
                return expenseReceiptRepository.findByExpenseId(expense.getId())
                    .map(receipt -> new ExpenseReceiptResponse(receipt.getId(), receipt.getFilename(),
                                                             receipt.getContentType(), receipt.getFileSize(),
                                                             receipt.getUploadedAt()))
                    .collectList()
                    .map(receipts -> new ExpenseResponse(expense, receipts));
            });
    }

    // List expenses with filtering
    public Mono<ExpenseListResponse> listExpenses(UUID tenantId, UUID personId, UUID employerId,
                                                 String status, int page, int size) {
        log.info("[F09] Listing expenses in tenant: {} with filters", tenantId);

        Flux<Expense> expenseFlux;
        if (personId != null) {
            expenseFlux = expenseRepository.findByTenantIdAndPersonId(tenantId, personId);
        } else if (employerId != null) {
            expenseFlux = status != null ?
                expenseRepository.findByTenantIdAndEmployerIdAndStatus(tenantId, employerId, status) :
                expenseRepository.findByTenantIdAndEmployerId(tenantId, employerId);
        } else {
            expenseFlux = status != null ?
                expenseRepository.findByTenantIdAndStatus(tenantId, status) :
                expenseRepository.findByTenantId(tenantId);
        }

        return expenseFlux
            .skip((long) page * size)
            .take(size)
            .flatMap(expense -> {
                return expenseReceiptRepository.findByExpenseId(expense.getId())
                    .map(receipt -> new ExpenseReceiptResponse(receipt.getId(), receipt.getFilename(),
                                                             receipt.getContentType(), receipt.getFileSize(),
                                                             receipt.getUploadedAt()))
                    .collectList()
                    .map(receipts -> new ExpenseResponse(expense, receipts));
            })
            .collectList()
            .zipWith(expenseFlux.count())
            .map(tuple -> {
                var expenses = tuple.getT1();
                var totalElements = tuple.getT2();
                var totalPages = (int) Math.ceil((double) totalElements / size);
                return new ExpenseListResponse(expenses, page, size, totalElements, totalPages);
            });
    }

    // Approve expense
    public Mono<ExpenseResponse> approveExpense(UUID tenantId, UUID expenseId, UUID approvedBy) {
        log.info("[F09] Approving expense: {} by: {} in tenant: {}", expenseId, approvedBy, tenantId);

        return expenseRepository.findByIdAndTenantId(expenseId, tenantId)
            .flatMap(expense -> {
                if (!"PENDING".equals(expense.getStatus())) {
                    return Mono.error(new IllegalStateException("Expense is not in PENDING status"));
                }

                expense.approve(approvedBy);
                return expenseRepository.save(expense)
                    .flatMap(savedExpense -> getExpense(tenantId, savedExpense.getId()));
            });
    }

    // Reject expense
    public Mono<ExpenseResponse> rejectExpense(UUID tenantId, UUID expenseId, UUID rejectedBy) {
        log.info("[F09] Rejecting expense: {} by: {} in tenant: {}", expenseId, rejectedBy, tenantId);

        return expenseRepository.findByIdAndTenantId(expenseId, tenantId)
            .flatMap(expense -> {
                if (!"PENDING".equals(expense.getStatus())) {
                    return Mono.error(new IllegalStateException("Expense is not in PENDING status"));
                }

                expense.reject(rejectedBy);
                return expenseRepository.save(expense)
                    .flatMap(savedExpense -> getExpense(tenantId, savedExpense.getId()));
            });
    }

    // Reimburse expense
    public Mono<ExpenseResponse> reimburseExpense(UUID tenantId, UUID expenseId) {
        log.info("[F09] Reimbursing expense: {} in tenant: {}", expenseId, tenantId);

        return expenseRepository.findByIdAndTenantId(expenseId, tenantId)
            .flatMap(expense -> {
                if (!"APPROVED".equals(expense.getStatus())) {
                    return Mono.error(new IllegalStateException("Expense is not in APPROVED status"));
                }

                // Create ledger entry for reimbursement (CREDIT)
                return createReimbursementLedgerEntry(expense)
                    .flatMap(ledgerEntry -> {
                        expense.reimburse();
                        return expenseRepository.save(expense)
                            .flatMap(savedExpense -> getExpense(tenantId, savedExpense.getId()));
                    });
            });
    }

    // Add receipt to expense
    public Mono<ExpenseReceiptResponse> addReceipt(UUID tenantId, UUID expenseId, ExpenseReceiptRequest request) {
        log.info("[F09] Adding receipt to expense: {} in tenant: {}", expenseId, tenantId);

        return expenseRepository.existsByIdAndTenantId(expenseId, tenantId)
            .flatMap(exists -> {
                if (!exists) {
                    return Mono.error(new IllegalArgumentException("Expense not found"));
                }

                return expenseReceiptRepository.existsByExpenseIdAndFilename(expenseId, request.getFilename())
                    .flatMap(filenameExists -> {
                        if (filenameExists) {
                            return Mono.error(new IllegalArgumentException("Receipt filename already exists"));
                        }

                        ExpenseReceipt receipt = new ExpenseReceipt(expenseId, request.getFilename(),
                                                                  request.getContentType(), request.getFileSize());
                        return expenseReceiptRepository.save(receipt)
                            .map(saved -> new ExpenseReceiptResponse(saved.getId(), saved.getFilename(),
                                                                   saved.getContentType(), saved.getFileSize(),
                                                                   saved.getUploadedAt()));
                    });
            });
    }

    // Helper method to validate person and wallet
    private Mono<Wallet> validatePersonAndWallet(UUID tenantId, UUID personId) {
        return walletRepository.findByTenantIdAndUserId(tenantId.toString(), personId.toString())
            .switchIfEmpty(Mono.error(new IllegalArgumentException("Wallet not found for person")))
            .doOnNext(wallet -> log.info("[F09] Found wallet: {} for person: {}", wallet.getId(), personId));
    }

    // Helper method to create reimbursement ledger entry
    private Mono<LedgerEntry> createReimbursementLedgerEntry(Expense expense) {
        LedgerEntry ledgerEntry = new LedgerEntry();
        ledgerEntry.setTenantId(expense.getTenantId().toString());
        ledgerEntry.setWalletId(expense.getPersonId()); // Assuming person_id maps to wallet for simplicity
        ledgerEntry.setAmount(expense.getAmount());
        ledgerEntry.setEntryType("CREDIT");
        ledgerEntry.setDescription("Expense reimbursement: " + expense.getTitle());
        ledgerEntry.setReferenceId(expense.getId().toString());
        ledgerEntry.setReferenceType("EXPENSE_REIMBURSEMENT");
        // createdAt is automatically set by @CreatedDate

        return ledgerEntryRepository.save(ledgerEntry)
            .doOnNext(saved -> log.info("[F09] Created reimbursement ledger entry: {}", saved.getId()));
    }
}