package com.benefits.privacyservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "data_subject_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DataSubjectRequest {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false)
    private String userId;
    
    @Column(nullable = false, unique = true)
    private String requestNumber; // DSR-2024-0001
    
    @Column(nullable = false)
    private String requestType; // ACCESS, RECTIFICATION, ERASURE, PORTABILITY, OBJECTION
    
    @Column(nullable = false)
    private String status; // PENDING, IN_PROGRESS, COMPLETED, REJECTED
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    // Processamento
    @Column(nullable = false)
    private LocalDateTime submittedAt;
    
    private LocalDateTime dueDate; // Legal deadline (ex: 30 dias)
    
    private LocalDateTime completedAt;
    
    // Resultado
    private String resultFileUrl; // URL do arquivo com os dados exportados
    private String resultFormat; // JSON, CSV, PDF
    
    @Column(columnDefinition = "TEXT")
    private String processingNotes;
    
    // Aprovação (pode requerer aprovação manual)
    private String approvedBy;
    private LocalDateTime approvedAt;
    
    private String rejectedBy;
    private LocalDateTime rejectedAt;
    private String rejectionReason;
}
