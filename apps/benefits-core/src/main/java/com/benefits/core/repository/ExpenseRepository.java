package com.benefits.core.repository;

import com.benefits.core.entity.Expense;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface ExpenseRepository extends R2dbcRepository<Expense, UUID> {

    // Find expenses by tenant (for tenant owners and admins)
    Flux<Expense> findByTenantId(UUID tenantId);

    // Find expenses by person (for users)
    Flux<Expense> findByTenantIdAndPersonId(UUID tenantId, UUID personId);

    // Find expenses by employer (for employer admins)
    Flux<Expense> findByTenantIdAndEmployerId(UUID tenantId, UUID employerId);

    // Find pending expenses by employer (for approval workflow)
    Flux<Expense> findByTenantIdAndEmployerIdAndStatus(UUID tenantId, UUID employerId, String status);

    // Find expenses by status (for admin operations)
    Flux<Expense> findByTenantIdAndStatus(UUID tenantId, String status);

    // Check if expense exists and belongs to tenant
    Mono<Boolean> existsByIdAndTenantId(UUID id, UUID tenantId);

    // Find expense with tenant validation
    Mono<Expense> findByIdAndTenantId(UUID id, UUID tenantId);
}