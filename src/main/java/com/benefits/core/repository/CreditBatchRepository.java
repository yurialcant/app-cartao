package com.benefits.core.repository;

import com.benefits.core.entity.CreditBatch;
import io.r2dbc.spi.Row;
import io.r2dbc.spi.RowMetadata;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.function.BiFunction;

/**
 * Repository for credit_batches table.
 */
@Repository
public interface CreditBatchRepository extends R2dbcRepository<CreditBatch, UUID> {

    // Note: R2DBC Spring Data automatically maps entities, so this mapper is not
    // used
    // Keeping for reference but CreditBatch entity uses @Column annotations for
    // mapping
    // The @Id is Long (database primary key), but batch_id is UUID (public
    // identifier)

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId AND id = :batchId")
    Mono<CreditBatch> findByTenantIdAndBatchId(UUID tenantId, UUID batchId);

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId AND idempotency_key = :idempotencyKey")
    Mono<CreditBatch> findByTenantIdAndIdempotencyKey(UUID tenantId, String idempotencyKey);

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId ORDER BY created_at DESC LIMIT :size OFFSET :offset")
    Flux<CreditBatch> findByTenantIdOrderByCreatedAtDesc(UUID tenantId, int size, int offset);

    @Query("SELECT COUNT(*) FROM credit_batches WHERE tenant_id = :tenantId")
    Mono<Long> countByTenantId(UUID tenantId);

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId AND status = :status ORDER BY created_at DESC LIMIT :size OFFSET :offset")
    Flux<CreditBatch> findByTenantIdAndStatusOrderByCreatedAtDesc(UUID tenantId, String status, int size, int offset);

    @Query("SELECT COUNT(*) FROM credit_batches WHERE tenant_id = :tenantId AND (:status IS NULL OR status = :status)")
    Mono<Long> countByTenantIdAndOptionalStatus(UUID tenantId, String status);

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId AND (:status IS NULL OR status = :status) ORDER BY created_at DESC LIMIT :limit OFFSET :offset")
    Flux<CreditBatch> findByTenantIdAndOptionalStatusOrderByCreatedAtDesc(UUID tenantId, String status, int limit,
            int offset);

    // Methods for CreditBatchService
    @Query("SELECT * FROM credit_batches WHERE id = :batchId")
    Mono<CreditBatch> findByBatchId(UUID batchId);

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId ORDER BY created_at DESC LIMIT :size OFFSET :offset")
    Flux<CreditBatch> findByTenantId(UUID tenantId, int offset, int size);

    @Query("SELECT * FROM credit_batches WHERE tenant_id = :tenantId AND employer_id = :employerId ORDER BY created_at DESC LIMIT :size OFFSET :offset")
    Flux<CreditBatch> findByTenantIdAndEmployerId(UUID tenantId, UUID employerId, int offset, int size);

    @Query("SELECT COUNT(*) FROM credit_batches WHERE tenant_id = :tenantId AND employer_id = :employerId")
    Mono<Long> countByTenantIdAndEmployerId(UUID tenantId, UUID employerId);
}