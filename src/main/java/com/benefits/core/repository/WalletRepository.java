package com.benefits.core.repository;

import com.benefits.core.entity.Wallet;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Wallet Repository
 *
 * Reactive repository for Wallet entity operations.
 * Part of F06 POS Authorize flow.
 */
@Repository
public interface WalletRepository extends R2dbcRepository<Wallet, UUID> {

    /**
     * Find wallet by tenant and user
     */
    Mono<Wallet> findByTenantIdAndUserId(@Param("tenantId") String tenantId, @Param("userId") String userId);

    /**
     * Find all wallets for a user in a tenant
     */
    Flux<Wallet> findByTenantIdAndUserIdOrderByCreatedAtDesc(@Param("tenantId") String tenantId, @Param("userId") String userId);

    /**
     * Check if wallet exists by tenant and user
     */
    Mono<Boolean> existsByTenantIdAndUserId(@Param("tenantId") String tenantId, @Param("userId") String userId);

    /**
     * Find wallet by tenant, user and wallet type
     */
    Mono<Wallet> findByTenantIdAndUserIdAndWalletType(@Param("tenantId") String tenantId,
                                                       @Param("userId") String userId,
                                                       @Param("walletType") String walletType);

    /**
     * Find all active wallets for a user
     */
    Flux<Wallet> findByTenantIdAndUserIdAndStatus(@Param("tenantId") String tenantId,
                                                   @Param("userId") String userId,
                                                   @Param("status") String status);

    /**
     * Find wallet by ID and tenant (for authorization validation)
     */
    Mono<Wallet> findByIdAndTenantId(@Param("id") UUID id, @Param("tenantId") String tenantId);
}