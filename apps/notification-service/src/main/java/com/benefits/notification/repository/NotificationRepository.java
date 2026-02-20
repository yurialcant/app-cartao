package com.benefits.notification.repository;

import com.benefits.notification.entity.Notification;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Repository
public interface NotificationRepository extends R2dbcRepository<Notification, UUID> {

    // Find notifications by tenant
    Flux<Notification> findByTenantId(UUID tenantId);

    // Find notifications by user
    Flux<Notification> findByUserId(UUID userId);

    // Find notifications by tenant and user
    Flux<Notification> findByTenantIdAndUserId(UUID tenantId, UUID userId);

    // Find unread notifications
    Flux<Notification> findByUserIdAndReadAtIsNull(UUID userId);

    // Find notifications by type
    Flux<Notification> findByTenantIdAndType(UUID tenantId, String type);
}