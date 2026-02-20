package com.benefits.opsrelay.repository;

import com.benefits.opsrelay.entity.Outbox;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Repository for outbox table.
 * Reads unpublished events from benefits-core database.
 */
@Repository
public interface OutboxRepository extends R2dbcRepository<Outbox, UUID> {

    /**
     * Find all unpublished events ordered by creation time (oldest first)
     */
    @Query("SELECT * FROM outbox WHERE published = false ORDER BY created_at ASC LIMIT :limit")
    Flux<Outbox> findUnpublishedEvents(Integer limit);

    /**
     * Count unpublished events
     */
    @Query("SELECT COUNT(*) FROM outbox WHERE published = false")
    Mono<Long> countUnpublishedEvents();

    /**
     * Mark event as published
     */
    @Query("UPDATE outbox SET published = true, retry_count = :retryCount, last_retry_at = NOW() WHERE id = :id")
    Mono<Void> markAsPublished(UUID id, Integer retryCount);

    /**
     * Increment retry count and update error message
     */
    @Query("UPDATE outbox SET retry_count = retry_count + 1, last_retry_at = NOW(), error_message = :errorMessage WHERE id = :id")
    Mono<Void> incrementRetry(UUID id, String errorMessage);
}
