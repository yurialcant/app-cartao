package com.benefits.opsrelay;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Ops Relay Application
 * 
 * Service responsible for:
 * - Reading events from outbox table
 * - Publishing events to EventBridge/SQS (LocalStack)
 * - Implementing inbox deduplication
 * - Providing replay mechanism
 * - Handling DLQ (Dead Letter Queue)
 */
@SpringBootApplication
@EnableR2dbcRepositories
@EnableScheduling
public class OpsRelayApplication {

    public static void main(String[] args) {
        SpringApplication.run(OpsRelayApplication.class, args);
    }
}
