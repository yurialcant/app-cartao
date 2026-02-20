package com.benefits.identity.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Employment Entity - Relação employer-funcionário
 * Define a relação de emprego entre pessoa e empresa
 */
@Table("employments")
public class Employment {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("employer_id")
    private UUID employerId;

    @Column("person_id")
    private UUID personId;

    @Column("employee_code")
    private String employeeCode; // Unique within employer

    @Column("department")
    private String department;

    @Column("position")
    private String position;

    @Column("start_date")
    private LocalDate startDate;

    @Column("end_date")
    private LocalDate endDate; // Null if still active

    @Column("status")
    private String status; // ACTIVE, TERMINATED, SUSPENDED

    @Column("termination_reason")
    private String terminationReason;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Employment() {}

    // Constructor
    public Employment(UUID tenantId, UUID employerId, UUID personId,
                     String employeeCode, LocalDate startDate) {
        this.tenantId = tenantId;
        this.employerId = employerId;
        this.personId = personId;
        this.employeeCode = employeeCode;
        this.startDate = startDate;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public UUID getEmployerId() { return employerId; }
    public void setEmployerId(UUID employerId) { this.employerId = employerId; }

    public UUID getPersonId() { return personId; }
    public void setPersonId(UUID personId) { this.personId = personId; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public String getTerminationReason() { return terminationReason; }
    public void setTerminationReason(String terminationReason) { this.terminationReason = terminationReason; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isTerminated() { return "TERMINATED".equals(status); }
    public boolean isSuspended() { return "SUSPENDED".equals(status); }

    public void terminate(String reason) {
        this.status = "TERMINATED";
        this.endDate = LocalDate.now();
        this.terminationReason = reason;
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isCurrentlyEmployed() {
        return isActive() && (endDate == null || LocalDate.now().isBefore(endDate));
    }
}