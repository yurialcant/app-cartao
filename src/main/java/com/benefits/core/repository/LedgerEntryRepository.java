package com.benefits.core.repository;

import com.benefits.core.entity.LedgerEntry;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * LedgerEntry Repository
 *
 * Reactive repository for LedgerEntry entity operations.
 * Part of F06 POS Authorize flow - immutable transaction log.
 */
@Repository
public interface LedgerEntryRepository extends R2dbcRepository<LedgerEntry, UUID> {

    /**
     * Find ledger entries by wallet
     */
    Flux<LedgerEntry> findByWalletIdOrderByCreatedAtDesc(@Param("walletId") UUID walletId);

    /**
     * Find ledger entries by tenant and wallet
     */
    Flux<LedgerEntry> findByTenantIdAndWalletIdOrderByCreatedAtDesc(@Param("tenantId") String tenantId,
                                                                   @Param("walletId") UUID walletId);

    /**
     * Find ledger entries by reference (payment_id, etc.)
     */
    Flux<LedgerEntry> findByReferenceIdAndReferenceType(@Param("referenceId") String referenceId,
                                                        @Param("referenceType") String referenceType);

    /**
     * Find ledger entries by tenant and reference
     */
    Flux<LedgerEntry> findByTenantIdAndReferenceIdAndReferenceType(@Param("tenantId") String tenantId,
                                                                   @Param("referenceId") String referenceId,
                                                                   @Param("referenceType") String referenceType);

    /**
     * Find ledger entries by entry type (CREDIT, DEBIT)
     */
    Flux<LedgerEntry> findByTenantIdAndWalletIdAndEntryTypeOrderByCreatedAtDesc(@Param("tenantId") String tenantId,
                                                                                @Param("walletId") UUID walletId,
                                                                                @Param("entryType") String entryType);

    /**
     * Count transactions for a wallet
     */
    Mono<Long> countByWalletId(@Param("walletId") UUID walletId);

    /**
     * Check if reference already exists (for idempotency)
     */
    Mono<Boolean> existsByTenantIdAndReferenceIdAndReferenceType(@Param("tenantId") String tenantId,
                                                                 @Param("referenceId") String referenceId,
                                                                 @Param("referenceType") String referenceType);
}