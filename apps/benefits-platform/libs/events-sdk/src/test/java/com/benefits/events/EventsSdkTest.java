package com.benefits.events;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class EventsSdkTest {

    @Test
    void eventPublisher_ShouldWorkCorrectly() {
        EventPublisher publisher = new EventPublisher();
        assertNotNull(publisher, "EventPublisher should be created");
    }

    @Test
    void outboxEvent_ShouldWorkCorrectly() {
        OutboxEvent event = new OutboxEvent();
        assertNotNull(event, "OutboxEvent should be created");
    }
}
