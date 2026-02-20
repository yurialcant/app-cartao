package com.benefits.events;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import software.amazon.awssdk.services.eventbridge.EventBridgeClient;
import software.amazon.awssdk.services.eventbridge.model.PutEventsRequest;
import software.amazon.awssdk.services.eventbridge.model.PutEventsRequestEntry;

@Service
public class EventPublisher {
    
    private static final Logger log = LoggerFactory.getLogger(EventPublisher.class);
    
    private final OutboxEventRepository outboxRepository;
    private final EventBridgeClient eventBridgeClient;
    private final ObjectMapper objectMapper;
    
    public EventPublisher(OutboxEventRepository outboxRepository, 
                         EventBridgeClient eventBridgeClient,
                         ObjectMapper objectMapper) {
        this.outboxRepository = outboxRepository;
        this.eventBridgeClient = eventBridgeClient;
        this.objectMapper = objectMapper;
    }
    
    public Mono<OutboxEvent> publishEvent(String aggregateType, String aggregateId, 
                                         String eventType, Object payload) {
        return Mono.fromCallable(() -> {
            try {
                String payloadJson = objectMapper.writeValueAsString(payload);
                OutboxEvent event = new OutboxEvent(aggregateType, aggregateId, eventType, payloadJson);
                return event;
            } catch (Exception e) {
                throw new RuntimeException("Failed to serialize event payload", e);
            }
        })
        .flatMap(outboxRepository::save)
        .doOnSuccess(event -> log.info("Event saved to outbox: {} - {}", eventType, aggregateId));
    }
    
    public Mono<Void> processPendingEvents() {
        return outboxRepository.findByStatusOrderByCreatedAtAsc("PENDING")
                .flatMap(event -> sendToEventBridge(event)
                        .then(outboxRepository.save(event))
                        .onErrorResume(e -> {
                            log.error("Failed to process event {}: {}", event.getId(), e.getMessage());
                            return Mono.empty();
                        }))
                .then();
    }
    
    private Mono<OutboxEvent> sendToEventBridge(OutboxEvent event) {
        return Mono.fromCallable(() -> {
            PutEventsRequestEntry entry = PutEventsRequestEntry.builder()
                    .source("benefits-platform")
                    .detailType(event.getEventType())
                    .detail(event.getPayload())
                    .eventBusName("domain-bus")
                    .build();
            
            PutEventsRequest request = PutEventsRequest.builder()
                    .entries(entry)
                    .build();
            
            eventBridgeClient.putEvents(request);
            
            event.setStatus("PUBLISHED");
            event.setProcessedAt(java.time.LocalDateTime.now());
            
            log.info("Event published to EventBridge: {} - {}", event.getEventType(), event.getAggregateId());
            
            return event;
        });
    }
}