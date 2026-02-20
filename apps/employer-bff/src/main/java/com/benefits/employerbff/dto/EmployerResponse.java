package com.benefits.employerbff.dto;

import java.time.LocalDateTime;

public class EmployerResponse {
    private String id;
    private String name;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public EmployerResponse() {}
    
    public EmployerResponse(String id, String name, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    public static EmployerResponseBuilder builder() {
        return new EmployerResponseBuilder();
    }
    
    public static class EmployerResponseBuilder {
        private String id;
        private String name;
        private String status;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        
        public EmployerResponseBuilder id(String id) { this.id = id; return this; }
        public EmployerResponseBuilder name(String name) { this.name = name; return this; }
        public EmployerResponseBuilder status(String status) { this.status = status; return this; }
        public EmployerResponseBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public EmployerResponseBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        
        public EmployerResponse build() {
            return new EmployerResponse(id, name, status, createdAt, updatedAt);
        }
    }
    
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
