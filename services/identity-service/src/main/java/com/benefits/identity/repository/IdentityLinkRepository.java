package com.benefits.identity.repository;

import com.benefits.identity.entity.IdentityLink;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface IdentityLinkRepository extends R2dbcRepository<IdentityLink, UUID> {

    // Find identity links by tenant
    Flux<IdentityLink> findByTenantId(UUID tenantId);

    // Find identity links by person
    Flux<IdentityLink> findByPersonId(UUID personId);

    // Find identity link by tenant, issuer and subject
    Mono<IdentityLink> findByTenantIdAndIssuerAndSubject(UUID tenantId, String issuer, String subject);

    // Find identity link by tenant and person
    Flux<IdentityLink> findByTenantIdAndPersonId(UUID tenantId, UUID personId);

    // Find verified identity links by person
    Flux<IdentityLink> findByPersonIdAndVerified(UUID personId, Boolean verified);

    // Check if identity link exists by tenant, issuer and subject
    Mono<Boolean> existsByTenantIdAndIssuerAndSubject(UUID tenantId, String issuer, String subject);

    // Find identity links by issuer
    Flux<IdentityLink> findByIssuer(String issuer);
}