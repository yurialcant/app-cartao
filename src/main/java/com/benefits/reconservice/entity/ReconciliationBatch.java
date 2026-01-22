package com.benefits.reconservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "reconciliation_batches")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReconciliationBatch {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false)
    private String tenantId;
    
    @Column(nullable = false, unique = true)
    private String batchNumber; // RECON-2024-01-001
    
    @Column(nullable = false)
    private String type; // DAILY, WEEKLY, MONTHLY, MANUAL
    
    @Column(nullable = false)
    private LocalDateTime periodStart;
    
    @Column(nullable = false)
    private LocalDateTime periodEnd;
    
    @Column(nullable = false)
    private String status; // PENDING, PROCESSING, COMPLETED, FAILED, PARTIAL
    
    // Totais do nosso sistema
    private BigDecimal systemTotalAmount;
    private Integer systemTransactionCount;
    
    // Totais do arquivo externo (acquirer, banco, etc)
    private BigDecimal externalTotalAmount;
    private Integer externalTransactionCount;
    
    // Diferenças
    private BigDecimal amountDifference; // systemTotal - externalTotal
    private Integer transactionDifference;
    
    // Matching
    private Integer matchedCount = 0;
    private Integer unmatchedSystemCount = 0;
    private Integer unmatchedExternalCount = 0;
    
    // Arquivo externo
    private String externalFileUrl;
    private String externalFileFormat; // CSV, JSON, XML
    private String externalSource; // ACQUIRER, BANK, PAYMENT_GATEWAY
    
    // Processamento
    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    
    private String errorMessage;
    
    @Column(columnDefinition = "TEXT")
    private String summary; // JSON com resumo detalhado
    
    // Auto-reconciliation
    private Boolean autoReconciled = false;
    private Integer autoMatchedCount = 0;
}
