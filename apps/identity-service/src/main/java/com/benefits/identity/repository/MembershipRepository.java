package com.benefits.identity.repository;

import com.benefits.identity.entity.Membership;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface MembershipRepository extends R2dbcRepository<Membership, UUID> {

    // Find memberships by tenant
    Flux<Membership> findByTenantId(UUID tenantId);

    // Find memberships by person
    Flux<Membership> findByPersonId(UUID personId);

    // Find memberships by employer
    Flux<Membership> findByEmployerId(UUID employerId);

    // Find active memberships by person
    Flux<Membership> findByPersonIdAndStatus(UUID personId, String status);

    // Find memberships by tenant and employer
    Flux<Membership> findByTenantIdAndEmployerId(UUID tenantId, UUID employerId);

    // Find memberships by tenant, employer and status
    Flux<Membership> findByTenantIdAndEmployerIdAndStatus(UUID tenantId, UUID employerId, String status);

    // Find memberships by tenant, person and employer
    Mono<Membership> findByTenantIdAndPersonIdAndEmployerId(UUID tenantId, UUID personId, UUID employerId);

    // Check if active membership exists
    Mono<Boolean> existsByPersonIdAndEmployerIdAndStatus(UUID personId, UUID employerId, String status);

    // Find memberships by role
    Flux<Membership> findByEmployerIdAndRole(UUID employerId, String role);
}