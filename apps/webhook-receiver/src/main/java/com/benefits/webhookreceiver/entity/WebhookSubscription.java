package com.benefits.webhookreceiver.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "webhook_subscriptions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WebhookSubscription {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false)
    private String url; // URL de callback
    
    @Column(nullable = false)
    private String events; // Comma-separated: transaction.created,transaction.completed
    
    @Column(nullable = false)
    private String status; // ACTIVE, PAUSED, DISABLED
    
    // Segurança
    @Column(nullable = false)
    private String secret; // Para HMAC signature
    
    private String signingAlgorithm = "SHA256"; // SHA256, SHA512
    
    // Retry policy
    private Integer maxRetries = 3;
    private Integer retryDelaySeconds = 60;
    
    // Headers customizados
    @Column(columnDefinition = "TEXT")
    private String customHeaders; // JSON
    
    // Estatísticas
    private Integer successCount = 0;
    private Integer failureCount = 0;
    private LocalDateTime lastSuccessAt;
    private LocalDateTime lastFailureAt;
    
    // Audit
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
}
