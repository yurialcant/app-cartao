package com.benefits.notificationservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "notification_preferences")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPreference {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String userId;
    
    @Column(nullable = false)
    private String tenantId;
    
    // Canais habilitados
    @Column(nullable = false)
    private Boolean emailEnabled = true;
    
    @Column(nullable = false)
    private Boolean smsEnabled = true;
    
    @Column(nullable = false)
    private Boolean pushEnabled = true;
    
    @Column(nullable = false)
    private Boolean inAppEnabled = true;
    
    // Categorias de notificações
    private Boolean transactionalEnabled = true;
    private Boolean marketingEnabled = false;
    private Boolean alertsEnabled = true;
    private Boolean promotionsEnabled = false;
    
    // Horário de envio (quiet hours)
    private String quietHoursStart; // "22:00"
    private String quietHoursEnd; // "08:00"
    
    // Frequência
    private String digestFrequency; // REAL_TIME, HOURLY, DAILY, WEEKLY
    
    private LocalDateTime updatedAt;
}
