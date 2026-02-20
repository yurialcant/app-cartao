package com.benefits.adminbff.dto;

import java.time.LocalDateTime;

public class TenantResponse {
    
    private String id;
    private String name;
    private String domain;
    private String programType;
    private String status;
    private Integer usersCount;
    private Integer employersCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public TenantResponse() {}

    public TenantResponse(String id, String name, String domain, String programType) {
        this.id = id;
        this.name = name;
        this.domain = domain;
        this.programType = programType;
    }

    public TenantResponse(String id, String name, String domain, String programType, String status,
                         Integer usersCount, Integer employersCount, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.domain = domain;
        this.programType = programType;
        this.status = status;
        this.usersCount = usersCount;
        this.employersCount = employersCount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Builder
    public static TenantResponseBuilder builder() {
        return new TenantResponseBuilder();
    }

    public static class TenantResponseBuilder {
        private String id;
        private String name;
        private String domain;
        private String programType;
        private String status;
        private Integer usersCount;
        private Integer employersCount;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public TenantResponseBuilder id(String id) { this.id = id; return this; }
        public TenantResponseBuilder name(String name) { this.name = name; return this; }
        public TenantResponseBuilder domain(String domain) { this.domain = domain; return this; }
        public TenantResponseBuilder programType(String programType) { this.programType = programType; return this; }
        public TenantResponseBuilder status(String status) { this.status = status; return this; }
        public TenantResponseBuilder usersCount(Integer usersCount) { this.usersCount = usersCount; return this; }
        public TenantResponseBuilder employersCount(Integer employersCount) { this.employersCount = employersCount; return this; }
        public TenantResponseBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public TenantResponseBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public TenantResponse build() {
            return new TenantResponse(id, name, domain, programType, status, usersCount, employersCount, createdAt, updatedAt);
        }
    }

    // Getters
    public String getId() { return id; }
    public String getName() { return name; }
    public String getDomain() { return domain; }
    public String getProgramType() { return programType; }
    public String getStatus() { return status; }
    public Integer getUsersCount() { return usersCount; }
    public Integer getEmployersCount() { return employersCount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    // Setters
    public void setId(String id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setDomain(String domain) { this.domain = domain; }
    public void setProgramType(String programType) { this.programType = programType; }
    public void setStatus(String status) { this.status = status; }
    public void setUsersCount(Integer usersCount) { this.usersCount = usersCount; }
    public void setEmployersCount(Integer employersCount) { this.employersCount = employersCount; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "TenantResponse{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", domain='" + domain + '\'' +
                ", programType='" + programType + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}

