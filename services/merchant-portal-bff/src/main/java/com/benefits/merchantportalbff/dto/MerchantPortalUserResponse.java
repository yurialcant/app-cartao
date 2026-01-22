package com.benefits.merchantportalbff.dto;

import java.time.LocalDateTime;

public class MerchantPortalUserResponse {
    private String id;
    private String name;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public MerchantPortalUserResponse() {}
    
    public MerchantPortalUserResponse(String id, String name, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    public static MerchantPortalUserResponseBuilder builder() {
        return new MerchantPortalUserResponseBuilder();
    }
    
    public static class MerchantPortalUserResponseBuilder {
        private String id;
        private String name;
        private String status;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        
        public MerchantPortalUserResponseBuilder id(String id) { this.id = id; return this; }
        public MerchantPortalUserResponseBuilder name(String name) { this.name = name; return this; }
        public MerchantPortalUserResponseBuilder status(String status) { this.status = status; return this; }
        public MerchantPortalUserResponseBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public MerchantPortalUserResponseBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        
        public MerchantPortalUserResponse build() {
            return new MerchantPortalUserResponse(id, name, status, createdAt, updatedAt);
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
