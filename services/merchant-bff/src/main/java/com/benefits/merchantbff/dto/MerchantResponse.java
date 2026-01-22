package com.benefits.merchantbff.dto;

import java.time.LocalDateTime;

public class MerchantResponse {
    private String id;
    private String name;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public MerchantResponse() {}
    
    public MerchantResponse(String id, String name, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    public static MerchantResponseBuilder builder() {
        return new MerchantResponseBuilder();
    }
    
    public static class MerchantResponseBuilder {
        private String id;
        private String name;
        private String status;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        
        public MerchantResponseBuilder id(String id) { this.id = id; return this; }
        public MerchantResponseBuilder name(String name) { this.name = name; return this; }
        public MerchantResponseBuilder status(String status) { this.status = status; return this; }
        public MerchantResponseBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public MerchantResponseBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        
        public MerchantResponse build() {
            return new MerchantResponse(id, name, status, createdAt, updatedAt);
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
