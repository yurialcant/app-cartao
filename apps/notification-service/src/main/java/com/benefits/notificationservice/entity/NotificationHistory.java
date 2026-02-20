package com.benefits.notificationservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "notification_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationHistory {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false)
    private String userId; // Destinatário
    
    @Column(nullable = false)
    private String channel; // EMAIL, SMS, PUSH, IN_APP
    
    @Column(nullable = false)
    private String templateCode;
    
    private String subject;
    
    @Column(columnDefinition = "TEXT")
    private String body;
    
    private String recipient; // Email, phone number, ou device token
    
    @Column(nullable = false)
    private String status; // PENDING, SENT, DELIVERED, FAILED, BOUNCED
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime sentAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime failedAt;
    
    private String provider; // FCM, APNS, TWILIO, AWS_SES, etc
    private String externalId; // ID retornado pelo provider
    
    private String errorMessage;
    private Integer retryCount = 0;
    
    @Column(columnDefinition = "TEXT")
    private String metadata; // JSON com dados extras
}
