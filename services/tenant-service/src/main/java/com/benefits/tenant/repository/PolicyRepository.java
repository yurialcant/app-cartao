package com.benefits.tenant.repository;

import com.benefits.tenant.entity.Policy;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import java.util.UUID;

/**
 * Policy Repository
 */
public interface PolicyRepository extends ReactiveCrudRepository<Policy, UUID> {
    Flux<Policy> findByTenantIdAndStatusOrderByPriorityDesc(UUID tenantId, String status);
}