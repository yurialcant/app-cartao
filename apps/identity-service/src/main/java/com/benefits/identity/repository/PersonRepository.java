package com.benefits.identity.repository;

import com.benefits.identity.entity.Person;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface PersonRepository extends R2dbcRepository<Person, UUID> {

    // Find persons by tenant
    Flux<Person> findByTenantId(UUID tenantId);

    // Find person by tenant and email
    Mono<Person> findByTenantIdAndEmail(UUID tenantId, String email);

    // Find person by tenant and document
    Mono<Person> findByTenantIdAndDocumentTypeAndDocumentNumber(UUID tenantId, String documentType, String documentNumber);

    // Find persons by tenant and name (partial match)
    Flux<Person> findByTenantIdAndNameContainingIgnoreCase(UUID tenantId, String name);

    // Check if person exists by tenant and email
    Mono<Boolean> existsByTenantIdAndEmail(UUID tenantId, String email);

    // Check if person exists by tenant and document
    Mono<Boolean> existsByTenantIdAndDocumentTypeAndDocumentNumber(UUID tenantId, String documentType, String documentNumber);
}