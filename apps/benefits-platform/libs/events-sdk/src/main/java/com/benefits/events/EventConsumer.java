package com.benefits.events;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.r2dbc.core.R2dbcEntityTemplate;
import reactor.core.publisher.Mono;
import software.amazon.awssdk.services.sqs.model.Message;

public abstract class EventConsumer {
    
    protected final Logger log = LoggerFactory.getLogger(getClass());
    
    protected final R2dbcEntityTemplate template;
    protected final ObjectMapper objectMapper;
    
    public EventConsumer(R2dbcEntityTemplate template, ObjectMapper objectMapper) {
        this.template = template;
        this.objectMapper = objectMapper;
    }
    
    public abstract String getEventType();
    
    public Mono<Void> processMessage(Message message) {
        return Mono.fromCallable(() -> {
            String body = message.body();
            // Parse SQS message and extract event details
            // This is a simplified version - in practice, you'd parse the EventBridge message format
            
            log.info("Processing event: {}", getEventType());
            
            // Check if already processed
            return isAlreadyProcessed(message)
                    .flatMap(alreadyProcessed -> {
                        if (alreadyProcessed) {
                            log.debug("Event already processed: {}", message.messageId());
                            return Mono.empty();
                        }
                        
                        return handleEvent(body)
                                .then(markAsProcessed(message));
                    });
        })
        .then();
    }
    
    protected abstract Mono<Void> handleEvent(String payload);
    
    private Mono<Boolean> isAlreadyProcessed(Message message) {
        String sql = "SELECT COUNT(*) > 0 FROM event_processed_events WHERE message_id = $1";
        return template.getDatabaseClient()
                .sql(sql)
                .bind("$1", message.messageId())
                .map(row -> row.get(0, Boolean.class))
                .one()
                .defaultIfEmpty(false);
    }
    
    private Mono<Void> markAsProcessed(Message message) {
        String sql = "INSERT INTO event_processed_events (message_id, processed_at) VALUES ($1, $2)";
        return template.getDatabaseClient()
                .sql(sql)
                .bind("$1", message.messageId())
                .bind("$2", java.time.LocalDateTime.now())
                .then();
    }
}