package com.benefits.identity.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("identity_links")
public class IdentityLink {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("person_id")
    private UUID personId;

    @Column("issuer")
    private String issuer; // GOOGLE, MICROSOFT, KEYCLOAK, etc.

    @Column("subject")
    private String subject; // External ID from identity provider

    @Column("email")
    private String email;

    @Column("verified")
    private Boolean verified;

    @Column("last_login")
    private LocalDateTime lastLogin;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public IdentityLink() {}

    // Constructor
    public IdentityLink(UUID tenantId, UUID personId, String issuer, String subject, String email) {
        this.tenantId = tenantId;
        this.personId = personId;
        this.issuer = issuer;
        this.subject = subject;
        this.email = email;
        this.verified = false;
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
        this.updatedAt = LocalDateTime.now();
    }

    public String getIssuer() {
        return issuer;
    }

    public void setIssuer(String issuer) {
        this.issuer = issuer;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
        this.updatedAt = LocalDateTime.now();
    }

    public Boolean getVerified() {
        return verified;
    }

    public void setVerified(Boolean verified) {
        this.verified = verified;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(LocalDateTime lastLogin) {
        this.lastLogin = lastLogin;
        this.updatedAt = LocalDateTime.now();
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
    public void markAsVerified() {
        this.verified = true;
        this.updatedAt = LocalDateTime.now();
    }

    public void recordLogin() {
        this.lastLogin = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isVerified() {
        return Boolean.TRUE.equals(verified);
    }
}