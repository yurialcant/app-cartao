package com.benefits.privacyservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "consent_records")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ConsentRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false)
    private String userId;
    
    @Column(nullable = false)
    private String consentType; // TERMS_OF_SERVICE, PRIVACY_POLICY, MARKETING, DATA_SHARING
    
    @Column(nullable = false)
    private String version; // Versão dos termos aceitos
    
    @Column(nullable = false)
    private Boolean granted; // true = aceito, false = negado
    
    @Column(nullable = false)
    private LocalDateTime timestamp;
    
    // Contexto
    private String ipAddress;
    private String userAgent;
    private String consentMethod; // CHECKBOX, BUTTON, API, IMPLICIT
    
    // Texto aceito (para auditoria)
    @Column(columnDefinition = "TEXT")
    private String consentText;
    
    // Revogação
    private LocalDateTime revokedAt;
    private String revokedReason;
}
