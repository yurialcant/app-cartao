package com.benefits.opsrelay.service;

import com.benefits.opsrelay.entity.Outbox;
import com.benefits.opsrelay.repository.OutboxRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Outbox Relay Service
 * 
 * Responsibilities:
 * - Polls outbox table for unpublished events
 * - Publishes events to EventBridge/SQS (LocalStack)
 * - Marks events as published after successful delivery
 * - Implements retry logic with exponential backoff
 * - Handles DLQ for failed events
 */
@Service
public class OutboxRelayService // TODO: Consider using OutboxEvent from events-sdk {

    private static final Logger log = LoggerFactory.getLogger(OutboxRelayService.class);

    private final OutboxRepository outboxRepository;
    private final EventPublisherService eventPublisherService;
    private final DLQService dlqService;

    @Value("${ops-relay.batch-size:10}")
    private int batchSize;

    @Value("${ops-relay.max-retries:3}")
    private int maxRetries;

    @Value("${ops-relay.retry-backoff-multiplier:2}")
    private double retryBackoffMultiplier;

    @Value("${ops-relay.initial-retry-delay:1000}")
    private long initialRetryDelay;

    public OutboxRelayService(OutboxRepository outboxRepository, EventPublisherService eventPublisherService, DLQService dlqService) {
        this.outboxRepository = outboxRepository;
        this.eventPublisherService = eventPublisherService;
        this.dlqService = dlqService;
    }

    /**
     * Poll outbox table and publish unpublished events
     * Runs every 5 seconds (configurable via ops-relay.polling-interval)
     */
    @Scheduled(fixedDelayString = "${ops-relay.polling-interval:5000}")
    public void pollAndPublishEvents() {
        log.debug("[OutboxRelay] Polling for unpublished events (batch size: {})", batchSize);

        outboxRepository.findUnpublishedEvents(Integer.valueOf(batchSize))
                .flatMap(this::publishEvent)
                .doOnError(error -> log.error("[OutboxRelay] Error polling events", error))
                .subscribe(
                        count -> log.debug("[OutboxRelay] Processed {} events", count),
                        error -> log.error("[OutboxRelay] Fatal error in polling", error)
                );
    }

    /**
     * Publish a single event to EventBridge/SQS
     */
    private Mono<Long> publishEvent(Outbox event) {
        log.info("[OutboxRelay] Publishing event: id={}, type={}, aggregate={}/{}", 
                event.getId(), event.getEventType(), event.getAggregateType(), event.getAggregateId());

        return eventPublisherService.publishEvent(event)
                .flatMap(success -> {
                    if (success) {
                        return markAsPublished(event.getId(), event.getRetryCount())
                                .thenReturn(1L);
                    } else {
                        return handlePublishFailure(event);
                    }
                })
                .onErrorResume(error -> {
                    log.error("[OutboxRelay] Error publishing event {}: {}", event.getId(), error.getMessage());
                    return handlePublishFailure(event);
                });
    }

    /**
     * Mark event as published
     */
    private Mono<Void> markAsPublished(UUID eventId, Integer currentRetryCount) {
        return outboxRepository.markAsPublished(eventId, currentRetryCount != null ? currentRetryCount : 0)
                .doOnSuccess(v -> log.info("[OutboxRelay] Event {} marked as published", eventId))
                .doOnError(error -> log.error("[OutboxRelay] Error marking event {} as published: {}", eventId, error.getMessage()));
    }

    /**
     * Handle publish failure - increment retry with exponential backoff or move to DLQ
     */
    private Mono<Long> handlePublishFailure(Outbox event) {
        int currentRetryCount = event.getRetryCount() != null ? event.getRetryCount() : 0;
        
        if (currentRetryCount >= maxRetries) {
            log.warn("[OutboxRelay] Event {} exceeded max retries ({}), moving to DLQ", event.getId(), maxRetries);
            String errorMessage = String.format("Max retries exceeded (%d/%d)", currentRetryCount, maxRetries);
            return dlqService.sendToDLQ(event, errorMessage)
                    .flatMap(sent -> {
                        if (sent) {
                            // Mark as published (even though it failed, it's in DLQ now)
                            return markAsPublished(event.getId(), currentRetryCount)
                                    .thenReturn(0L);
                        } else {
                            log.error("[OutboxRelay] Failed to send event {} to DLQ", event.getId());
                            return Mono.just(0L);
                        }
                    });
        } else {
            // Calculate exponential backoff delay
            long delay = calculateBackoffDelay(currentRetryCount);
            String errorMessage = String.format("Publish failed, retry %d/%d (next retry in %dms)", 
                    currentRetryCount + 1, maxRetries, delay);
            
            log.debug("[OutboxRelay] Event {} will retry in {}ms (attempt {}/{})", 
                    event.getId(), delay, currentRetryCount + 1, maxRetries);
            
            return outboxRepository.incrementRetry(event.getId(), errorMessage)
                    .thenReturn(0L);
        }
    }

    /**
     * Calculate exponential backoff delay
     * Formula: initialDelay * (multiplier ^ retryCount)
     */
    private long calculateBackoffDelay(int retryCount) {
        return (long) (initialRetryDelay * Math.pow(retryBackoffMultiplier, retryCount));
    }
}
