package com.benefits.core.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

/**
 * Outbox Processor
 *
 * Periodically processes pending events from the outbox table
 * Publishes events to message broker for cross-service communication
 */
@Component
public class OutboxProcessor {

    private static final Logger log = LoggerFactory.getLogger(OutboxProcessor.class);

    private final OutboxService outboxService;
    private final EventPublisherService eventPublisher;

    public OutboxProcessor(OutboxService outboxService, EventPublisherService eventPublisher) {
        this.outboxService = outboxService;
        this.eventPublisher = eventPublisher;
    }

    /**
     * Process pending events every 30 seconds
     */
    @Scheduled(fixedDelay = 30000)
    public void processPendingEvents() {
        log.debug("[OutboxProcessor] Processing pending events...");

        outboxService.getPendingEvents(50) // Process up to 50 events per batch
            .flatMap(outbox -> {
                log.debug("[OutboxProcessor] Processing event: {} - {}", outbox.getId(), outbox.getEventType());

                // Publish event to message broker
                return eventPublisher.publishEvent(outbox)
                    .flatMap(success -> {
                        if (success) {
                            // Mark as processed
                            return outboxService.markEventProcessed(outbox.getId())
                                .doOnSuccess(v -> log.info("[OutboxProcessor] Event processed successfully: {}", outbox.getId()))
                                .thenReturn(true);
                        } else {
                            log.warn("[OutboxProcessor] Failed to publish event: {}", outbox.getId());
                            return Mono.just(false);
                        }
                    })
                    .onErrorResume(error -> {
                        log.error("[OutboxProcessor] Error processing event {}: {}", outbox.getId(), error.getMessage());
                        return Mono.just(false);
                    });
            })
            .count()
            .subscribe(
                processedCount -> log.info("[OutboxProcessor] Processed {} events in this batch", processedCount),
                error -> log.error("[OutboxProcessor] Error in event processing batch: {}", error.getMessage())
            );
    }
}