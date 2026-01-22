package com.benefits.privacyservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "data_retention_policies")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DataRetentionPolicy {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    private String tenantId; // null = global
    
    @Column(nullable = false)
    private String dataType; // TRANSACTION, AUDIT_LOG, USER_DATA, COMMUNICATION
    
    @Column(nullable = false)
    private Integer retentionDays; // Quantos dias manter
    
    @Column(nullable = false)
    private String actionOnExpiry; // DELETE, ANONYMIZE, ARCHIVE
    
    @Column(nullable = false)
    private Boolean isActive = true;
    
    private String legalBasis; // GDPR Art. 6(1)(a), LGPD Art. 7, etc
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    // Audit
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
}
