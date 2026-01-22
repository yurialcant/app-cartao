package com.benefits.employerservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "employees")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Employee {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(name = "tenant_id", nullable = false)
    private String tenantId;
    
    @Column(name = "employer_id", nullable = false)
    private String employerId;
    
    @Column(nullable = false)
    private String name;
    
    @Column(unique = true)
    private String cpf;
    
    @Column(name = "registration_number")
    private String registrationNumber; // Matrícula
    
    @Column(name = "email")
    private String email;
    
    @Column(name = "phone")
    private String phone;
    
    @Column(name = "cost_center_id")
    private String costCenterId;
    
    @Column(name = "department")
    private String department;
    
    @Column(name = "position")
    private String position;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EmployeeStatus status = EmployeeStatus.ACTIVE;
    
    @Column(name = "hire_date")
    private LocalDate hireDate;
    
    @Column(name = "termination_date")
    private LocalDate terminationDate;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum EmployeeStatus {
        ACTIVE,
        ON_LEAVE,
        TERMINATED,
        TRANSFERRED
    }
    
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
