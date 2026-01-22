package com.benefits.tenant.repository;

import com.benefits.tenant.entity.Tenant;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * Tenant Repository
 */
public interface TenantRepository extends ReactiveCrudRepository<Tenant, UUID> {
    Mono<Boolean> existsBySlug(String slug);
    Mono<Tenant> findBySlug(String slug);
}