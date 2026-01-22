package com.benefits.webhookreceiver.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "webhook_deliveries")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WebhookDelivery {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String subscriptionId;
    
    @Column(nullable = false)
    private String eventType; // transaction.created, payment.approved, etc
    
    @Column(nullable = false)
    private String status; // PENDING, DELIVERED, FAILED, RETRYING
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String payload; // JSON do evento
    
    private String signature; // HMAC signature
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime deliveredAt;
    
    // Retry
    private Integer attemptCount = 0;
    private LocalDateTime lastAttemptAt;
    private LocalDateTime nextRetryAt;
    
    // Response
    private Integer httpStatus;
    
    @Column(columnDefinition = "TEXT")
    private String responseBody;
    
    @Column(columnDefinition = "TEXT")
    private String errorMessage;
    
    // Dead letter queue
    private Boolean movedToDlq = false;
    private LocalDateTime movedToDlqAt;
}
