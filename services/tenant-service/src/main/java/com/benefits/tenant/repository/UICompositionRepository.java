package com.benefits.tenant.repository;

import com.benefits.tenant.entity.UIComposition;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * UIComposition Repository
 */
public interface UICompositionRepository extends ReactiveCrudRepository<UIComposition, UUID> {
    Mono<UIComposition> findByTenantIdAndStatus(UUID tenantId, String status);
}