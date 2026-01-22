package com.benefits.riskservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "blocklists")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Blocklist {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    private String tenantId; // null = global
    
    @Column(nullable = false)
    private String listType; // USER, DEVICE, IP, EMAIL, PHONE, CARD, MERCHANT
    
    @Column(nullable = false)
    private String value; // O valor bloqueado (userId, IP, etc)
    
    @Column(nullable = false)
    private String reason; // FRAUD, SUSPICIOUS_ACTIVITY, REPEATED_FAILURES, MANUAL_BLOCK
    
    @Column(nullable = false)
    private String status; // ACTIVE, EXPIRED, REMOVED
    
    private String severity; // LOW, MEDIUM, HIGH
    
    private LocalDateTime expiresAt; // null = permanente
    
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    // Referências
    private String relatedTransactionIds; // Comma-separated
    private String relatedUserId;
    
    // Audit
    private String createdBy;
    private LocalDateTime createdAt;
    private String removedBy;
    private LocalDateTime removedAt;
}
