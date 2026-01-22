package com.benefits.support.repository;

import com.benefits.support.entity.SupportTicket;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface SupportTicketRepository extends R2dbcRepository<SupportTicket, UUID> {

    // Find tickets by tenant
    Flux<SupportTicket> findByTenantId(UUID tenantId);

    // Find ticket by tenant and ticket number
    Mono<SupportTicket> findByTenantIdAndTicketNumber(UUID tenantId, String ticketNumber);

    // Find tickets by person
    Flux<SupportTicket> findByPersonId(UUID personId);

    // Find tickets by status
    Flux<SupportTicket> findByTenantIdAndStatus(UUID tenantId, String status);

    // Find tickets by priority
    Flux<SupportTicket> findByTenantIdAndPriority(UUID tenantId, String priority);

    // Find tickets by category
    Flux<SupportTicket> findByTenantIdAndCategory(UUID tenantId, String category);

    // Check if ticket exists by ticket number
    Mono<Boolean> existsByTicketNumber(String ticketNumber);
}