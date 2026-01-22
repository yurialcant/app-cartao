package com.benefits.core.repository;

import com.benefits.core.entity.Merchant;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Merchant Repository
 *
 * Reactive repository for Merchant entity operations.
 */
@Repository
public interface MerchantRepository extends R2dbcRepository<Merchant, UUID> {

    /**
     * Find merchant by tenant and merchant_id
     */
    Mono<Merchant> findByTenantIdAndMerchantId(@Param("tenantId") UUID tenantId,
            @Param("merchantId") String merchantId);

    /**
     * Check if merchant exists by tenant and merchant_id
     */
    Mono<Boolean> existsByTenantIdAndMerchantId(@Param("tenantId") UUID tenantId,
            @Param("merchantId") String merchantId);
}