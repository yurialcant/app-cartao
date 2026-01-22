package com.benefits.tenant.repository;

import com.benefits.tenant.entity.WalletDefinition;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import java.util.UUID;

/**
 * WalletDefinition Repository
 */
public interface WalletDefinitionRepository extends ReactiveCrudRepository<WalletDefinition, UUID> {
    Flux<WalletDefinition> findByTenantIdAndStatus(UUID tenantId, String status);
}