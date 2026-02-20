package com.benefits.core.repository;

import com.benefits.core.entity.Person;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * Person Repository
 *
 * Reactive repository for Person entity operations in Benefits Core
 */
public interface PersonRepository extends ReactiveCrudRepository<Person, UUID> {

    /**
     * Find person by tenant and ID
     */
    Mono<Person> findByTenantIdAndId(UUID tenantId, UUID personId);

    /**
     * Find person by email
     */
    Mono<Person> findByTenantIdAndEmail(UUID tenantId, String email);
}