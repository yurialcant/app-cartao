package com.benefits.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("expenses")
public class Expense {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("person_id")
    private UUID personId;

    @Column("employer_id")
    private UUID employerId;

    @Column("title")
    private String title;

    @Column("description")
    private String description;

    @Column("amount")
    private BigDecimal amount;

    @Column("currency")
    private String currency;

    @Column("category")
    private String category;

    @Column("status")
    private String status;

    @Column("submitted_at")
    private LocalDateTime submittedAt;

    @Column("approved_at")
    private LocalDateTime approvedAt;

    @Column("approved_by")
    private UUID approvedBy;

    @Column("reimbursed_at")
    private LocalDateTime reimbursedAt;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Expense() {}

    // Constructor for creating new expense
    public Expense(UUID tenantId, UUID personId, UUID employerId, String title,
                   String description, BigDecimal amount, String currency, String category) {
        this.tenantId = tenantId;
        this.personId = personId;
        this.employerId = employerId;
        this.title = title;
        this.description = description;
        this.amount = amount;
        this.currency = currency != null ? currency : "BRL";
        this.category = category;
        this.status = "PENDING";
        this.submittedAt = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    public UUID getPersonId() {
        return personId;
    }

    public void setPersonId(UUID personId) {
        this.personId = personId;
    }

    public UUID getEmployerId() {
        return employerId;
    }

    public void setEmployerId(UUID employerId) {
        this.employerId = employerId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }

    public UUID getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(UUID approvedBy) {
        this.approvedBy = approvedBy;
    }

    public LocalDateTime getReimbursedAt() {
        return reimbursedAt;
    }

    public void setReimbursedAt(LocalDateTime reimbursedAt) {
        this.reimbursedAt = reimbursedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Business methods
    public void approve(UUID approvedBy) {
        this.status = "APPROVED";
        this.approvedAt = LocalDateTime.now();
        this.approvedBy = approvedBy;
        this.updatedAt = LocalDateTime.now();
    }

    public void reject(UUID approvedBy) {
        this.status = "REJECTED";
        this.approvedAt = LocalDateTime.now();
        this.approvedBy = approvedBy;
        this.updatedAt = LocalDateTime.now();
    }

    public void reimburse() {
        this.status = "REIMBURSED";
        this.reimbursedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
}