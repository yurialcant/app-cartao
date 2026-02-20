package com.benefits.opsrelay.service;

import com.benefits.opsrelay.entity.Inbox;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Event Processor Service
 * 
 * Responsibilities:
 * - Process events from inbox
 * - Route to appropriate handlers based on event type
 * - Mark events as processed after successful handling
 */
@Service
public class EventProcessorService {

    private static final Logger log = LoggerFactory.getLogger(EventProcessorService.class);

    private final InboxDedupService inboxDedupService;

    public EventProcessorService(InboxDedupService inboxDedupService) {
        this.inboxDedupService = inboxDedupService;
    }

    /**
     * Process an event from inbox
     */
    public Mono<Void> processEvent(Inbox inbox) {
        log.info("[EventProcessor] Processing event: id={}, type={}, aggregate={}/{}", 
                inbox.getId(), inbox.getEventType(), inbox.getAggregateType(), inbox.getAggregateId());

        // TODO: Route to appropriate handler based on event_type
        // For now, just mark as processed
        return inboxDedupService.markAsProcessed(inbox.getId())
                .doOnSuccess(v -> log.info("[EventProcessor] Event {} processed successfully", inbox.getId()))
                .doOnError(error -> log.error("[EventProcessor] Error processing event {}: {}", inbox.getId(), error.getMessage()));
    }
}
