package com.benefits.employerservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "benefit_programs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BenefitProgram {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(name = "tenant_id", nullable = false)
    private String tenantId;
    
    @Column(name = "employer_id", nullable = false)
    private String employerId;
    
    @Column(nullable = false)
    private String name; // VR, VA, etc.
    
    @Column(name = "program_type")
    private String programType; // A, B, C
    
    @Column(name = "monthly_limit")
    private BigDecimal monthlyLimit;
    
    @Column(name = "daily_limit")
    private BigDecimal dailyLimit;
    
    @Column(name = "transaction_limit")
    private BigDecimal transactionLimit;
    
    @Column(name = "eligible_categories", columnDefinition = "jsonb")
    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    private Map<String, Object> eligibleCategories; // MCC codes
    
    @Column(name = "eligible_locations", columnDefinition = "jsonb")
    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    private Map<String, Object> eligibleLocations; // Regiões
    
    @Column(nullable = false)
    private Boolean active = true;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
