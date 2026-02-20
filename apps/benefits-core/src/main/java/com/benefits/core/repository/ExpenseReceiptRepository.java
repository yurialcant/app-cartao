package com.benefits.core.repository;

import com.benefits.core.entity.ExpenseReceipt;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface ExpenseReceiptRepository extends R2dbcRepository<ExpenseReceipt, UUID> {

    // Find receipts by expense
    Flux<ExpenseReceipt> findByExpenseId(UUID expenseId);

    // Check if receipt exists for expense
    Mono<Boolean> existsByExpenseIdAndFilename(UUID expenseId, String filename);
}