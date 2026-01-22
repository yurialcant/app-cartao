package com.benefits.merchant.repository;

import com.benefits.merchant.entity.Terminal;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface TerminalRepository extends R2dbcRepository<Terminal, UUID> {

    // Find terminals by tenant
    Flux<Terminal> findByTenantId(UUID tenantId);

    // Find terminals by merchant
    Flux<Terminal> findByMerchantId(UUID merchantId);

    // Find terminal by tenant and terminal ID
    Mono<Terminal> findByTenantIdAndTerminalId(UUID tenantId, String terminalId);

    // Find terminals by tenant and merchant
    Flux<Terminal> findByTenantIdAndMerchantId(UUID tenantId, UUID merchantId);

    // Find terminals by tenant and status
    Flux<Terminal> findByTenantIdAndStatus(UUID tenantId, String status);

    // Find terminals by tenant and model
    Flux<Terminal> findByTenantIdAndModel(UUID tenantId, String model);

    // Find terminals by serial number
    Mono<Terminal> findBySerialNumber(String serialNumber);

    // Find terminals by tenant and location (partial match)
    Flux<Terminal> findByTenantIdAndLocationNameContainingIgnoreCase(UUID tenantId, String locationName);

    // Check if terminal exists by tenant and terminal ID
    Mono<Boolean> existsByTenantIdAndTerminalId(UUID tenantId, String terminalId);

    // Check if terminal exists by serial number
    Mono<Boolean> existsBySerialNumber(String serialNumber);

    // Find online terminals (pinged within last 5 minutes)
    Flux<Terminal> findByTenantIdAndStatusAndLastPingGreaterThan(
        UUID tenantId, String status, java.time.LocalDateTime since);
}