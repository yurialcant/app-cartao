package com.benefits.core.service;

import com.benefits.core.entity.Outbox;
import com.benefits.core.repository.OutboxRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import java.util.Map;
import java.util.UUID;

/**
 * Outbox Service
 *
 * Implements the Outbox pattern for reliable event publishing
 * Stores events in database before publishing to message broker
 */
@Service
public class OutboxService {

    private static final Logger log = LoggerFactory.getLogger(OutboxService.class);

    private final OutboxRepository outboxRepository;

    public OutboxService(OutboxRepository outboxRepository) {
        this.outboxRepository = outboxRepository;
    }

    /**
     * Publish event using outbox pattern
     */
    public Mono<Void> publishEvent(String eventType, Map<String, Object> payload) {
        log.debug("[Outbox] Publishing event: {}", eventType);

        Outbox outbox = new Outbox();
        outbox.setId(UUID.randomUUID());
        outbox.setEventType(eventType);
        outbox.setPayload(serializePayload(payload));
        outbox.setStatus("PENDING");
        outbox.setCreatedAt(java.time.LocalDateTime.now());

        return outboxRepository.save(outbox)
            .doOnSuccess(saved -> log.info("[Outbox] Event stored in outbox: {} - {}", eventType, saved.getId()))
            .doOnError(error -> log.error("[Outbox] Failed to store event in outbox: {}", error.getMessage()))
            .then();
    }

    /**
     * Mark event as processed
     */
    public Mono<Void> markEventProcessed(UUID eventId) {
        return outboxRepository.findById(eventId)
            .flatMap(outbox -> {
                outbox.setStatus("PROCESSED");
                outbox.setProcessedAt(java.time.LocalDateTime.now());
                return outboxRepository.save(outbox);
            })
            .doOnSuccess(outbox -> log.debug("[Outbox] Event marked as processed: {}", eventId))
            .then();
    }

    /**
     * Get pending events for processing
     */
    public reactor.core.publisher.Flux<Outbox> getPendingEvents(int limit) {
        return outboxRepository.findByStatusOrderByCreatedAtAsc("PENDING")
            .take(limit);
    }

    /**
     * Serialize payload to JSON
     */
    private String serializePayload(Map<String, Object> payload) {
        try {
            // Simple JSON serialization - in production use Jackson ObjectMapper
            StringBuilder json = new StringBuilder("{");
            boolean first = true;
            for (Map.Entry<String, Object> entry : payload.entrySet()) {
                if (!first) json.append(",");
                json.append("\"").append(entry.getKey()).append("\":");
                if (entry.getValue() instanceof String) {
                    json.append("\"").append(entry.getValue()).append("\"");
                } else {
                    json.append(entry.getValue());
                }
                first = false;
            }
            json.append("}");
            return json.toString();
        } catch (Exception e) {
            log.error("[Outbox] Failed to serialize payload: {}", e.getMessage());
            return "{}";
        }
    }
}