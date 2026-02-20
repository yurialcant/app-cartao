package com.benefits.merchant.repository;

import com.benefits.merchant.entity.Merchant;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface MerchantRepository extends R2dbcRepository<Merchant, UUID> {

    // Find merchants by tenant
    Flux<Merchant> findByTenantId(UUID tenantId);

    // Find merchant by tenant and merchant ID
    Mono<Merchant> findByTenantIdAndMerchantId(UUID tenantId, String merchantId);

    // Find merchants by tenant and status
    Flux<Merchant> findByTenantIdAndStatus(UUID tenantId, String status);

    // Find merchants by tenant and category
    Flux<Merchant> findByTenantIdAndCategory(UUID tenantId, String category);

    // Find merchants by tenant and risk level
    Flux<Merchant> findByTenantIdAndRiskLevel(UUID tenantId, String riskLevel);

    // Find merchants by tenant and name (partial match)
    Flux<Merchant> findByTenantIdAndNameContainingIgnoreCase(UUID tenantId, String name);

    // Check if merchant exists by tenant and merchant ID
    Mono<Boolean> existsByTenantIdAndMerchantId(UUID tenantId, String merchantId);

    // Check if merchant exists by tenant and document
    Mono<Boolean> existsByTenantIdAndDocument(UUID tenantId, String document);

    // Find merchants by tenant and email
    Flux<Merchant> findByTenantIdAndEmail(UUID tenantId, String email);
}