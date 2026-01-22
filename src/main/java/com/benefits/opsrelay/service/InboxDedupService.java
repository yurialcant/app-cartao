package com.benefits.opsrelay.service;

import com.benefits.opsrelay.entity.Inbox;
import com.benefits.opsrelay.entity.Outbox;
import com.benefits.opsrelay.repository.InboxRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

/**
 * Inbox Deduplication Service
 * 
 * Responsibilities:
 * - Check if event was already processed (deduplication)
 * - Store incoming events in inbox table
 * - Prevent duplicate processing
 */
@Service
public class InboxDedupService {

    private static final Logger log = LoggerFactory.getLogger(InboxDedupService.class);

    private final InboxRepository inboxRepository;

    public InboxDedupService(InboxRepository inboxRepository) {
        this.inboxRepository = inboxRepository;
    }

    /**
     * Check if event was already processed (deduplication)
     * Returns true if event is new (not processed), false if already processed
     */
    public Mono<Boolean> isEventNew(UUID eventId) {
        return inboxRepository.findByEventId(eventId)
                .map(inbox -> {
                    if (inbox.getProcessed()) {
                        log.debug("[InboxDedup] Event {} already processed", eventId);
                        return false;
                    } else {
                        log.debug("[InboxDedup] Event {} found but not processed yet", eventId);
                        return false; // Found but not processed = duplicate
                    }
                })
                .defaultIfEmpty(true) // Not found = new event
                .doOnNext(isNew -> {
                    if (isNew) {
                        log.debug("[InboxDedup] Event {} is new (not in inbox)", eventId);
                    }
                });
    }

    /**
     * Store event in inbox for deduplication
     * This should be called when receiving an event from EventBridge/SQS
     */
    public Mono<Inbox> storeEvent(Outbox outboxEvent) {
        log.info("[InboxDedup] Storing event in inbox: eventId={}, type={}", 
                outboxEvent.getId(), outboxEvent.getEventType());

        Inbox inbox = new Inbox();
        inbox.setEventId(outboxEvent.getId());
        inbox.setEventType(outboxEvent.getEventType());
        inbox.setAggregateType(outboxEvent.getAggregateType());
        inbox.setAggregateId(outboxEvent.getAggregateId());
        inbox.setTenantId(outboxEvent.getTenantId());
        inbox.setActorId(outboxEvent.getActorId());
        inbox.setCorrelationId(outboxEvent.getCorrelationId());
        inbox.setPayload(outboxEvent.getPayload());
        inbox.setOccurredAt(outboxEvent.getOccurredAt());
        inbox.setProcessed(false);
        inbox.setCreatedAt(Instant.now());

        return inboxRepository.save(inbox)
                .doOnSuccess(saved -> log.info("[InboxDedup] Event stored in inbox: id={}", saved.getId()))
                .doOnError(error -> log.error("[InboxDedup] Error storing event in inbox: {}", error.getMessage()));
    }

    /**
     * Mark event as processed
     */
    public Mono<Void> markAsProcessed(UUID inboxId) {
        return inboxRepository.markAsProcessed(inboxId)
                .doOnSuccess(v -> log.info("[InboxDedup] Event marked as processed: inboxId={}", inboxId))
                .doOnError(error -> log.error("[InboxDedup] Error marking event as processed: {}", error.getMessage()));
    }
}
