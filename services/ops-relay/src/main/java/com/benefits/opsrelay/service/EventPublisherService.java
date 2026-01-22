package com.benefits.opsrelay.service;

import com.benefits.opsrelay.entity.Outbox;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.eventbridge.EventBridgeClient;
import software.amazon.awssdk.services.eventbridge.model.PutEventsRequest;
import software.amazon.awssdk.services.eventbridge.model.PutEventsRequestEntry;
import software.amazon.awssdk.services.eventbridge.model.PutEventsResponse;

import java.util.List;

/**
 * Event Publisher Service
 * 
 * Publishes events to AWS EventBridge (LocalStack)
 */
@Service
public class EventPublisherService {

    private static final Logger log = LoggerFactory.getLogger(EventPublisherService.class);

    @Value("${aws.endpoint:http://localhost:4566}")
    private String awsEndpoint;

    @Value("${aws.region:us-east-1}")
    private String awsRegion;

    @Value("${aws.eventbridge.bus:benefits-events}")
    private String eventBusName;

    private EventBridgeClient eventBridgeClient;

    /**
     * Initialize EventBridge client (LocalStack)
     */
    private EventBridgeClient getEventBridgeClient() {
        if (eventBridgeClient == null) {
            eventBridgeClient = EventBridgeClient.builder()
                    .endpointOverride(java.net.URI.create(awsEndpoint))
                    .region(Region.of(awsRegion))
                    .credentialsProvider(DefaultCredentialsProvider.create())
                    .httpClient(UrlConnectionHttpClient.builder().build())
                    .build();
            log.info("[EventPublisher] EventBridge client initialized: endpoint={}, region={}, bus={}", 
                    awsEndpoint, awsRegion, eventBusName);
        }
        return eventBridgeClient;
    }

    /**
     * Publish event to EventBridge
     */
    public Mono<Boolean> publishEvent(Outbox event) {
        return Mono.fromCallable(() -> {
            try {
                log.debug("[EventPublisher] Publishing event to EventBridge: id={}, type={}", 
                        event.getId(), event.getEventType());

                PutEventsRequestEntry entry = PutEventsRequestEntry.builder()
                        .source("benefits.ops-relay")
                        .detailType(event.getEventType())
                        .detail(event.getPayload())
                        .eventBusName(eventBusName)
                        .build();

                PutEventsRequest request = PutEventsRequest.builder()
                        .entries(entry)
                        .build();

                PutEventsResponse response = getEventBridgeClient().putEvents(request);

                if (response.failedEntryCount() > 0) {
                    log.error("[EventPublisher] Failed to publish event {}: {}", 
                            event.getId(), response.entries().get(0).errorMessage());
                    return false;
                } else {
                    log.info("[EventPublisher] Event {} published successfully", event.getId());
                    return true;
                }
            } catch (Exception e) {
                log.error("[EventPublisher] Error publishing event {}: {}", event.getId(), e.getMessage(), e);
                return false;
            }
        });
    }
}
