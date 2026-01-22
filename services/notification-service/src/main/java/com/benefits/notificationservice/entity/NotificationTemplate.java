package com.benefits.notificationservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "notification_templates")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationTemplate {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    private String tenantId; // null = template global
    
    @Column(nullable = false)
    private String code; // WELCOME_EMAIL, TRANSACTION_APPROVED, LOW_BALANCE_ALERT, etc
    
    @Column(nullable = false)
    private String channel; // EMAIL, SMS, PUSH, IN_APP
    
    @Column(nullable = false)
    private String language; // pt-BR, en-US, es-ES
    
    @Column(nullable = false)
    private String subject; // Para email
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String body; // Template com variáveis {{varName}}
    
    @Column(columnDefinition = "TEXT")
    private String htmlBody; // Para emails HTML
    
    // Metadata
    private String category; // TRANSACTIONAL, MARKETING, ALERTS
    
    @Column(nullable = false)
    private Boolean isActive = true;
    
    @Column(columnDefinition = "TEXT")
    private String variables; // JSON com lista de variáveis disponíveis
    
    // Audit
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
}
