package com.benefits.payments.repository;

import com.benefits.payments.entity.Transaction;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface TransactionRepository extends R2dbcRepository<Transaction, UUID> {

    // Find transactions by tenant
    Flux<Transaction> findByTenantId(UUID tenantId);

    // Find transaction by tenant and transaction ID
    Mono<Transaction> findByTenantIdAndTransactionId(UUID tenantId, String transactionId);

    // Find transactions by person
    Flux<Transaction> findByPersonId(UUID personId);

    // Find transactions by employer
    Flux<Transaction> findByEmployerId(UUID employerId);

    // Find transactions by status
    Flux<Transaction> findByStatus(String status);

    // Find transactions by tenant and status
    Flux<Transaction> findByTenantIdAndStatus(UUID tenantId, String status);

    // Check if transaction exists by transaction ID
    Mono<Boolean> existsByTransactionId(String transactionId);

    // Find transactions by tenant and person
    Flux<Transaction> findByTenantIdAndPersonId(UUID tenantId, UUID personId);
}