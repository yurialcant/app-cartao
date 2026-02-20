package com.benefits.opsrelay.repository;

import com.benefits.opsrelay.entity.Inbox;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

/**
 * Repository for inbox table.
 * Handles event deduplication.
 */
@Repository
public interface InboxRepository extends R2dbcRepository<Inbox, UUID> {

    /**
     * Check if event already exists (deduplication)
     */
    @Query("SELECT * FROM inbox WHERE event_id = :eventId")
    Mono<Inbox> findByEventId(UUID eventId);

    /**
     * Find unprocessed events ordered by occurred_at (oldest first)
     */
    @Query("SELECT * FROM inbox WHERE processed = false ORDER BY occurred_at ASC LIMIT :limit")
    Flux<Inbox> findUnprocessedEvents(Integer limit);

    /**
     * Mark event as processed
     */
    @Query("UPDATE inbox SET processed = true, processed_at = NOW() WHERE id = :id")
    Mono<Void> markAsProcessed(UUID id);

    /**
     * Find events for replay (with filters)
     * If eventType is empty, returns all event types
     */
    @Query("SELECT * FROM inbox WHERE tenant_id = :tenantId AND (:eventType = '' OR event_type = :eventType) AND occurred_at >= :fromDate AND occurred_at <= :toDate ORDER BY occurred_at ASC")
    Flux<Inbox> findEventsForReplay(String tenantId, String eventType, Instant fromDate, Instant toDate);
}
