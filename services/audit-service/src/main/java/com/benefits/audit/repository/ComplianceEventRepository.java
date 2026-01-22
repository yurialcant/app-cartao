package com.benefits.audit.repository;

import com.benefits.audit.entity.ComplianceEvent;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface ComplianceEventRepository extends R2dbcRepository<ComplianceEvent, UUID> {

    // Find events by tenant
    Flux<ComplianceEvent> findByTenantId(UUID tenantId);

    // Find events by event type
    Flux<ComplianceEvent> findByTenantIdAndEventType(UUID tenantId, String eventType);

    // Find events by severity
    Flux<ComplianceEvent> findByTenantIdAndSeverity(UUID tenantId, String severity);

    // Find events by user
    Flux<ComplianceEvent> findByTenantIdAndUserId(UUID tenantId, UUID userId);
}