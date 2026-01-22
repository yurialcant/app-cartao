package com.benefits.tenant.repository;

import com.benefits.tenant.entity.Contract;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;
import java.util.UUID;

/**
 * Contract Repository
 */
public interface ContractRepository extends ReactiveCrudRepository<Contract, UUID> {
    Mono<Contract> findByTenantIdAndEmployerId(UUID tenantId, UUID employerId);
}