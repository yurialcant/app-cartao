package com.benefits.identity.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Create Person Request DTO
 */
public class CreatePersonRequest {

    @NotBlank(message = "tenantId is required")
    private String tenantId;

    public CreatePersonRequest() {
    }

    public CreatePersonRequest(String tenantId) {
        this.tenantId = tenantId;
    }

    public String getTenantId() {
        return tenantId;
    }

    public void setTenantId(String tenantId) {
        this.tenantId = tenantId;
    }

    @Override
    public String toString() {
        return "CreatePersonRequest{" +
                "tenantId='" + tenantId + '\'' +
                '}';
    }
}