package com.benefits.core.service;

import com.benefits.core.entity.Outbox;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.eventbridge.EventBridgeClient;
import software.amazon.awssdk.services.eventbridge.model.PutEventsRequest;
import software.amazon.awssdk.services.eventbridge.model.PutEventsRequestEntry;
import software.amazon.awssdk.services.eventbridge.model.PutEventsResponse;

import java.util.List;

/**
 * Event Publisher Service
 *
 * Publishes events to AWS EventBridge for cross-service communication
 */
@Service
public class EventPublisherService // TODO: Consider using EventPublisher from events-sdk {

    private static final Logger log = LoggerFactory.getLogger(EventPublisherService.class);

    @Value("${aws.eventbridge.endpoint:http://localhost:4566}")
    private String eventBridgeEndpoint;

    @Value("${aws.region:us-east-1}")
    private String awsRegion;

    @Value("${aws.eventbridge.bus:benefits-events}")
    private String eventBusName;

    private EventBridgeClient eventBridgeClient;

    /**
     * Get or create EventBridge client
     */
    private EventBridgeClient getEventBridgeClient() {
        if (eventBridgeClient == null) {
            eventBridgeClient = EventBridgeClient.builder()
                .endpointOverride(java.net.URI.create(eventBridgeEndpoint))
                .region(Region.of(awsRegion))
                .credentialsProvider(DefaultCredentialsProvider.create())
                .httpClient(ApacheHttpClient.builder().build())
                .build();

            log.info("[EventPublisher] EventBridge client initialized: endpoint={}, region={}, bus={}",
                eventBridgeEndpoint, awsRegion, eventBusName);
        }
        return eventBridgeClient;
    }

    /**
     * Publish outbox event to EventBridge
     */
    public Mono<Boolean> publishEvent(Outbox outbox) {
        return Mono.fromCallable(() -> {
            try {
                log.debug("[EventPublisher] Publishing event to EventBridge: id={}, type={}",
                    outbox.getId(), outbox.getEventType());

                PutEventsRequestEntry entry = PutEventsRequestEntry.builder()
                    .source("benefits.benefits-core")
                    .detailType(outbox.getEventType())
                    .detail(outbox.getPayload())
                    .eventBusName(eventBusName)
                    .build();

                PutEventsRequest request = PutEventsRequest.builder()
                    .entries(entry)
                    .build();

                PutEventsResponse response = getEventBridgeClient().putEvents(request);

                if (response.failedEntryCount() > 0) {
                    log.error("[EventPublisher] Failed to publish event {}: {}",
                        outbox.getId(), response.entries().get(0).errorMessage());
                    return false;
                } else {
                    log.info("[EventPublisher] Event {} published successfully", outbox.getId());
                    return true;
                }
            } catch (Exception e) {
                log.error("[EventPublisher] Error publishing event {}: {}", outbox.getId(), e.getMessage(), e);
                return false;
            }
        });
    }
}