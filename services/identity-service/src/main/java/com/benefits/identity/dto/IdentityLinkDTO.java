package com.benefits.identity.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Identity Link Data Transfer Object
 */
public class IdentityLinkDTO {

    private Long id;
    private UUID personId;
    private String issuer;
    private String subject;
    private String tenantId;
    private Boolean verified;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long version;

    public IdentityLinkDTO() {
    }

    public IdentityLinkDTO(Long id, UUID personId, String issuer, String subject, String tenantId,
            Boolean verified, LocalDateTime createdAt, LocalDateTime updatedAt, Long version) {
        this.id = id;
        this.personId = personId;
        this.issuer = issuer;
        this.subject = subject;
        this.tenantId = tenantId;
        this.verified = verified;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.version = version;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public UUID getPersonId() {
        return personId;
    }

    public void setPersonId(UUID personId) {
        this.personId = personId;
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

    public String getTenantId() {
        return tenantId;
    }

    public void setTenantId(String tenantId) {
        this.tenantId = tenantId;
    }

    public Boolean getVerified() {
        return verified;
    }

    public void setVerified(Boolean verified) {
        this.verified = verified;
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

    public Long getVersion() {
        return version;
    }

    public void setVersion(Long version) {
        this.version = version;
    }

    @Override
    public String toString() {
        return "IdentityLinkDTO{" +
                "id=" + id +
                ", personId=" + personId +
                ", issuer='" + issuer + '\'' +
                ", subject='" + subject + '\'' +
                ", tenantId='" + tenantId + '\'' +
                ", verified=" + verified +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", version=" + version +
                '}';
    }
}