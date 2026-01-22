package com.benefits.tenant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Employer Entity - Cadastro da empresa
 * Representa uma empresa cliente do tenant
 */
@Table("employers")
public class Employer {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("employer_code")
    private String employerCode; // Unique within tenant

    @Column("company_name")
    private String companyName;

    @Column("business_name")
    private String businessName; // Razão social

    @Column("document_type")
    private String documentType; // CNPJ

    @Column("document_number")
    private String documentNumber;

    @Column("email")
    private String email;

    @Column("phone")
    private String phone;

    @Column("address")
    private String address;

    @Column("city")
    private String city;

    @Column("state")
    private String state;

    @Column("zip_code")
    private String zipCode;

    @Column("status")
    private String status; // ACTIVE, INACTIVE, SUSPENDED

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Employer() {}

    // Constructor
    public Employer(UUID tenantId, String employerCode, String companyName,
                   String documentNumber, String email) {
        this.tenantId = tenantId;
        this.employerCode = employerCode;
        this.companyName = companyName;
        this.documentNumber = documentNumber;
        this.email = email;
        this.status = "ACTIVE";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public String getEmployerCode() { return employerCode; }
    public void setEmployerCode(String employerCode) { this.employerCode = employerCode; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getBusinessName() { return businessName; }
    public void setBusinessName(String businessName) { this.businessName = businessName; }

    public String getDocumentType() { return documentType; }
    public void setDocumentType(String documentType) { this.documentType = documentType; }

    public String getDocumentNumber() { return documentNumber; }
    public void setDocumentNumber(String documentNumber) { this.documentNumber = documentNumber; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; this.updatedAt = LocalDateTime.now(); }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Business methods
    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isInactive() { return "INACTIVE".equals(status); }
    public boolean isSuspended() { return "SUSPENDED".equals(status); }
}