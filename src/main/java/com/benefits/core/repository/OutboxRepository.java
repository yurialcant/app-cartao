package com.benefits.core.repository;

import com.benefits.core.entity.Outbox;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import java.util.UUID;

/**
 * Outbox Repository
 *
 * Reactive repository for Outbox entity operations
 */
public interface OutboxRepository extends ReactiveCrudRepository<Outbox, UUID> {

    /**
     * Find pending events ordered by creation time
     */
    @Query("SELECT * FROM outbox WHERE status = 'PENDING' ORDER BY created_at ASC")
    Flux<Outbox> findByStatusOrderByCreatedAtAsc(String status);

    /**
     * Find pending events by tenant ordered by creation time
     */
    @Query("SELECT * FROM outbox WHERE tenant_id = :tenantId AND status = 'PENDING' ORDER BY created_at ASC")
    Flux<Outbox> findByTenantIdAndStatusOrderByCreatedAtAsc(UUID tenantId, String status);

    /**
     * Count pending events
     */
    @Query("SELECT COUNT(*) FROM outbox WHERE status = 'PENDING'")
    reactor.core.publisher.Mono<Long> countByStatus(String status);
}