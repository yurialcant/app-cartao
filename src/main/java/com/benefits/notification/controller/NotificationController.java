package com.benefits.notification.controller;

import com.benefits.notification.entity.Notification;
import com.benefits.notification.repository.NotificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/notifications")
public class NotificationController {

    private static final Logger log = LoggerFactory.getLogger(NotificationController.class);

    private final NotificationRepository notificationRepository;

    public NotificationController(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @PostMapping
    public Mono<ResponseEntity<Notification>> createNotification(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam UUID userId,
            @RequestParam String type,
            @RequestParam String title,
            @RequestParam(required = false) String message) {

        log.info("[Notification] Creating notification for user: {}", userId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            Notification notification = new Notification(tenantId, userId, type, title, message);

            return notificationRepository.save(notification)
                .map(saved -> ResponseEntity.status(HttpStatus.CREATED).body(saved))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping
    public Mono<ResponseEntity<List<Notification>>> getUserNotifications(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam UUID userId) {

        log.info("[Notification] Getting notifications for user: {}", userId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return notificationRepository.findByTenantIdAndUserId(tenantId, userId)
                .collectList()
                .map(notifications -> ResponseEntity.ok(notifications))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/{notificationId}/read")
    public Mono<ResponseEntity<Notification>> markAsRead(
            @PathVariable UUID notificationId) {

        log.info("[Notification] Marking notification as read: {}", notificationId);

        return notificationRepository.findById(notificationId)
            .flatMap(notification -> {
                notification.markAsRead();
                return notificationRepository.save(notification);
            })
            .map(updated -> ResponseEntity.ok(updated))
            .defaultIfEmpty(ResponseEntity.notFound().build())
            .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
    }
}