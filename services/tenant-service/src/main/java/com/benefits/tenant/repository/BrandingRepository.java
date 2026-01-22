package com.benefits.tenant.repository;

import com.benefits.tenant.entity.Branding;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * Branding Repository
 */
public interface BrandingRepository extends ReactiveCrudRepository<Branding, UUID> {
    Mono<Branding> findByTenantIdAndStatus(UUID tenantId, String status);
}