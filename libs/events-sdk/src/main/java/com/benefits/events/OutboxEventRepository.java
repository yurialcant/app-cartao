package com.benefits.events;

import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;

public interface OutboxEventRepository extends ReactiveCrudRepository<OutboxEvent, String> {
    
    Flux<OutboxEvent> findByStatus(String status);
    
    Flux<OutboxEvent> findByStatusOrderByCreatedAtAsc(String status);
}