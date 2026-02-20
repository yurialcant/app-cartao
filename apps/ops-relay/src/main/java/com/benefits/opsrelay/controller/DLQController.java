package com.benefits.opsrelay.controller;

import com.benefits.opsrelay.service.DLQService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.GetQueueAttributesRequest;
import software.amazon.awssdk.services.sqs.model.GetQueueAttributesResponse;
import software.amazon.awssdk.services.sqs.model.QueueAttributeName;

import java.util.HashMap;
import java.util.Map;

/**
 * DLQ Controller
 * 
 * Provides endpoints for monitoring and managing DLQ
 */
@RestController
@RequestMapping("/api/v1/dlq")
public class DLQController {

    private static final Logger log = LoggerFactory.getLogger(DLQController.class);

    private final DLQService dlqService;
    private final SqsClient sqsClient;

    public DLQController(DLQService dlqService, SqsClient sqsClient) {
        this.dlqService = dlqService;
        this.sqsClient = sqsClient;
    }

    /**
     * Get DLQ statistics
     * GET /api/v1/dlq/stats
     */
    @GetMapping("/stats")
    public Mono<ResponseEntity<DLQStats>> getDLQStats() {
        log.info("[DLQ] Getting DLQ statistics");

        try {
            String dlqUrl = dlqService.getDLQUrl();
            
            GetQueueAttributesRequest request = GetQueueAttributesRequest.builder()
                    .queueUrl(dlqUrl)
                    .attributeNames(
                            QueueAttributeName.APPROXIMATE_NUMBER_OF_MESSAGES,
                            QueueAttributeName.APPROXIMATE_NUMBER_OF_MESSAGES_NOT_VISIBLE,
                            QueueAttributeName.APPROXIMATE_NUMBER_OF_MESSAGES_DELAYED
                    )
                    .build();

            GetQueueAttributesResponse response = sqsClient.getQueueAttributes(request);
            Map<QueueAttributeName, String> attributesMap = response.attributes();
            Map<String, String> attributes = new HashMap<>();
            attributesMap.forEach((key, value) -> attributes.put(key.toString(), value));

            DLQStats stats = new DLQStats();
            stats.setQueueUrl(dlqUrl);
            stats.setApproximateNumberOfMessages(
                    Long.parseLong(attributes.getOrDefault(QueueAttributeName.APPROXIMATE_NUMBER_OF_MESSAGES.toString(), "0"))
            );
            stats.setApproximateNumberOfMessagesNotVisible(
                    Long.parseLong(attributes.getOrDefault(QueueAttributeName.APPROXIMATE_NUMBER_OF_MESSAGES_NOT_VISIBLE.toString(), "0"))
            );
            stats.setApproximateNumberOfMessagesDelayed(
                    Long.parseLong(attributes.getOrDefault(QueueAttributeName.APPROXIMATE_NUMBER_OF_MESSAGES_DELAYED.toString(), "0"))
            );

            return Mono.just(ResponseEntity.ok(stats));
        } catch (Exception error) {
            log.error("[DLQ] Error getting DLQ statistics: {}", error.getMessage());
            return Mono.just(ResponseEntity.internalServerError().build());
        }
    }

    /**
     * DLQ Statistics DTO
     */
    public static class DLQStats {
        private String queueUrl;
        private long approximateNumberOfMessages;
        private long approximateNumberOfMessagesNotVisible;
        private long approximateNumberOfMessagesDelayed;

        public String getQueueUrl() { return queueUrl; }
        public void setQueueUrl(String queueUrl) { this.queueUrl = queueUrl; }

        public long getApproximateNumberOfMessages() { return approximateNumberOfMessages; }
        public void setApproximateNumberOfMessages(long approximateNumberOfMessages) { 
            this.approximateNumberOfMessages = approximateNumberOfMessages; 
        }

        public long getApproximateNumberOfMessagesNotVisible() { return approximateNumberOfMessagesNotVisible; }
        public void setApproximateNumberOfMessagesNotVisible(long approximateNumberOfMessagesNotVisible) { 
            this.approximateNumberOfMessagesNotVisible = approximateNumberOfMessagesNotVisible; 
        }

        public long getApproximateNumberOfMessagesDelayed() { return approximateNumberOfMessagesDelayed; }
        public void setApproximateNumberOfMessagesDelayed(long approximateNumberOfMessagesDelayed) { 
            this.approximateNumberOfMessagesDelayed = approximateNumberOfMessagesDelayed; 
        }
    }
}
