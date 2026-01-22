package com.benefits.opsrelay.service;

import com.benefits.opsrelay.entity.Outbox;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageResponse;

import java.time.Instant;
import java.util.UUID;

/**
 * DLQ Service
 * 
 * Responsibilities:
 * - Send failed events to Dead Letter Queue (SQS)
 * - Track DLQ events for monitoring
 * - Provide metrics and alerts
 */
@Service
public class DLQService {

    private static final Logger log = LoggerFactory.getLogger(DLQService.class);

    private final SqsClient sqsClient;
    
    @Value("${aws.sqs.dlq:benefits-events-dlq}")
    private String dlqQueueName;

    public DLQService(SqsClient sqsClient) {
        this.sqsClient = sqsClient;
    }

    /**
     * Send event to DLQ
     * This should be called when an event exceeds max retries
     */
    public Mono<Boolean> sendToDLQ(Outbox event, String errorMessage) {
        log.warn("[DLQ] Sending event to DLQ: id={}, type={}, retryCount={}, error={}", 
                event.getId(), event.getEventType(), event.getRetryCount(), errorMessage);

        try {
            // Build DLQ message with full event details
            String dlqMessage = buildDLQMessage(event, errorMessage);
            
            // Get DLQ URL (LocalStack format: http://localhost:4566/000000000000/benefits-events-dlq)
            String dlqUrl = String.format("http://localhost:4566/000000000000/%s", dlqQueueName);
            
            SendMessageRequest request = SendMessageRequest.builder()
                    .queueUrl(dlqUrl)
                    .messageBody(dlqMessage)
                    .messageAttributes(java.util.Map.of(
                            "eventId", software.amazon.awssdk.services.sqs.model.MessageAttributeValue.builder()
                                    .dataType("String")
                                    .stringValue(event.getId().toString())
                                    .build(),
                            "eventType", software.amazon.awssdk.services.sqs.model.MessageAttributeValue.builder()
                                    .dataType("String")
                                    .stringValue(event.getEventType())
                                    .build(),
                            "tenantId", software.amazon.awssdk.services.sqs.model.MessageAttributeValue.builder()
                                    .dataType("String")
                                    .stringValue(event.getTenantId())
                                    .build(),
                            "retryCount", software.amazon.awssdk.services.sqs.model.MessageAttributeValue.builder()
                                    .dataType("Number")
                                    .stringValue(String.valueOf(event.getRetryCount() != null ? event.getRetryCount() : 0))
                                    .build()
                    ))
                    .build();

            SendMessageResponse response = sqsClient.sendMessage(request);
            
            log.info("[DLQ] Event sent to DLQ successfully: id={}, messageId={}", 
                    event.getId(), response.messageId());
            
            return Mono.just(true);
        } catch (Exception error) {
            log.error("[DLQ] Error sending event to DLQ: id={}, error={}", 
                    event.getId(), error.getMessage(), error);
            return Mono.just(false);
        }
    }

    /**
     * Build DLQ message with full event details
     */
    private String buildDLQMessage(Outbox event, String errorMessage) {
        return String.format(
                "{\"eventId\":\"%s\",\"eventType\":\"%s\",\"aggregateType\":\"%s\",\"aggregateId\":\"%s\"," +
                "\"tenantId\":\"%s\",\"actorId\":\"%s\",\"correlationId\":\"%s\"," +
                "\"payload\":%s,\"occurredAt\":\"%s\",\"retryCount\":%d,\"errorMessage\":\"%s\"," +
                "\"sentToDLQAt\":\"%s\"}",
                event.getId(),
                event.getEventType(),
                event.getAggregateType(),
                event.getAggregateId(),
                event.getTenantId(),
                event.getActorId() != null ? event.getActorId() : "",
                event.getCorrelationId() != null ? event.getCorrelationId() : "",
                event.getPayload(),
                event.getOccurredAt(),
                event.getRetryCount() != null ? event.getRetryCount() : 0,
                errorMessage != null ? errorMessage.replace("\"", "\\\"") : "",
                Instant.now()
        );
    }

    /**
     * Get DLQ queue URL
     */
    public String getDLQUrl() {
        return String.format("http://localhost:4566/000000000000/%s", dlqQueueName);
    }
}
