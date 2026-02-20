package com.benefits.core.repository;

import com.benefits.core.entity.Refund;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Refund Repository
 *
 * Reactive repository for Refund entity operations.
 */
@Repository
public interface RefundRepository extends R2dbcRepository<Refund, UUID> {

    /**
     * Find refund by tenant and ID
     */
    Mono<Refund> findByTenantIdAndId(@Param("tenantId") UUID tenantId, @Param("id") UUID id);

    /**
     * Find refund by tenant and idempotency key
     */
    Mono<Refund> findByTenantIdAndIdempotencyKey(@Param("tenantId") UUID tenantId,
            @Param("idempotencyKey") String idempotencyKey);

    /**
     * Check if refund exists by tenant and idempotency key
     */
    Mono<Boolean> existsByTenantIdAndIdempotencyKey(@Param("tenantId") UUID tenantId,
            @Param("idempotencyKey") String idempotencyKey);
}