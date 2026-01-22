package com.benefits.tenant.repository;

import com.benefits.tenant.entity.Employer;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * Employer Repository
 */
public interface EmployerRepository extends ReactiveCrudRepository<Employer, UUID> {
    Mono<Boolean> existsByTenantIdAndEmployerCode(UUID tenantId, String employerCode);
    Mono<Employer> findByTenantIdAndEmployerCode(UUID tenantId, String employerCode);
}