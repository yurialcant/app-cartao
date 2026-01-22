package com.benefits.userbff.client;

import com.benefits.userbff.dto.NotificationDto;
import com.benefits.userbff.dto.UnreadCountDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@FeignClient(name = "notification-service", url = "${services.notification-service}")
public interface NotificationServiceClient {

    @GetMapping("/api/v1/notifications")
    Flux<NotificationDto> getNotifications(
        @RequestParam(defaultValue = "20") int limit,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PutMapping("/api/v1/notifications/{notificationId}/read")
    Mono<Void> markAsRead(
        @PathVariable String notificationId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PutMapping("/api/v1/notifications/mark-all-read")
    Mono<Void> markAllAsRead(
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @GetMapping("/api/v1/notifications/unread-count")
    Mono<UnreadCountDto> getUnreadCount(
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );
}