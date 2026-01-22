package com.benefits.opsrelay.service;

import com.benefits.opsrelay.entity.Inbox;
import com.benefits.opsrelay.repository.InboxRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

/**
 * Replay Service
 * 
 * Responsibilities:
 * - Replay events from inbox
 * - Filter by tenant_id, event_type, date range
 * - Validate permissions
 */
@Service
public class ReplayService {

    private static final Logger log = LoggerFactory.getLogger(ReplayService.class);

    private final InboxRepository inboxRepository;
    private final EventProcessorService eventProcessorService;

    public ReplayService(InboxRepository inboxRepository, EventProcessorService eventProcessorService) {
        this.inboxRepository = inboxRepository;
        this.eventProcessorService = eventProcessorService;
    }

    /**
     * Replay events with filters
     */
    public Flux<Inbox> replayEvents(String tenantId, String eventType, Instant fromDate, Instant toDate) {
        log.info("[Replay] Replaying events - tenantId={}, eventType={}, fromDate={}, toDate={}", 
                tenantId, eventType, fromDate, toDate);

        // If eventType is null, replay all event types
        if (eventType == null || eventType.isEmpty()) {
            // TODO: Implement query without eventType filter
            return inboxRepository.findEventsForReplay(tenantId, "", fromDate, toDate);
        } else {
            return inboxRepository.findEventsForReplay(tenantId, eventType, fromDate, toDate);
        }
    }

    /**
     * Replay a specific event by ID
     */
    public Mono<Boolean> replayEvent(String tenantId, UUID eventId) {
        log.info("[Replay] Replaying single event - tenantId={}, eventId={}", tenantId, eventId);

        return inboxRepository.findByEventId(eventId)
                .flatMap(inbox -> {
                    // Validate tenant_id matches
                    if (!inbox.getTenantId().equals(tenantId)) {
                        log.warn("[Replay] Tenant mismatch - requested: {}, event: {}", tenantId, inbox.getTenantId());
                        return Mono.just(false);
                    }

                    // Process the event
                    return eventProcessorService.processEvent(inbox)
                            .thenReturn(true);
                })
                .defaultIfEmpty(false)
                .doOnSuccess(success -> {
                    if (success) {
                        log.info("[Replay] Event {} replayed successfully", eventId);
                    } else {
                        log.warn("[Replay] Event {} not found or tenant mismatch", eventId);
                    }
                });
    }
}
