package com.benefits.identity.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * Link Identity Request DTO
 */
public class LinkIdentityRequest {

    @NotNull(message = "personId is required")
    private UUID personId;

    @NotBlank(message = "issuer is required")
    private String issuer;

    @NotBlank(message = "subject is required")
    private String subject;

    @NotBlank(message = "tenantId is required")
    private String tenantId;

    private Boolean verified = false;

    public LinkIdentityRequest() {
    }

    public LinkIdentityRequest(UUID personId, String issuer, String subject, String tenantId) {
        this.personId = personId;
        this.issuer = issuer;
        this.subject = subject;
        this.tenantId = tenantId;
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

    @Override
    public String toString() {
        return "LinkIdentityRequest{" +
                "personId=" + personId +
                ", issuer='" + issuer + '\'' +
                ", subject='" + subject + '\'' +
                ", tenantId='" + tenantId + '\'' +
                ", verified=" + verified +
                '}';
    }
}