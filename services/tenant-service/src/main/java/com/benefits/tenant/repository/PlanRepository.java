package com.benefits.tenant.repository;

import com.benefits.tenant.entity.Plan;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * Plan Repository
 */
public interface PlanRepository extends ReactiveCrudRepository<Plan, UUID> {
    Mono<Plan> findByTenantIdAndPlanCodeAndStatus(UUID tenantId, String planCode, String status);
}