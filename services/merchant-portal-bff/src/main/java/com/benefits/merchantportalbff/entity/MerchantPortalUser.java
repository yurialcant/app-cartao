package com.benefits.merchantportalbff.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;

@Table("merchantportalusers")
public class MerchantPortalUser {
    
    @Id
    private String id;
        @Column("username")
    private String username;

    @Column("email")
    private String email;

    @Column("merchant_id")
    private String merchantId;

    @Column("role")
    private String role;

    @Column("active")
    private Boolean active;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    public MerchantPortalUser() {}

    public MerchantPortalUser(String id, String username, String email, String merchantId, String role, Boolean active, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.merchantId = merchantId;
        this.role = role;
        this.active = active;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public static MerchantPortalUserBuilder builder() {
        return new MerchantPortalUserBuilder();
    }

    public static class MerchantPortalUserBuilder {
        private String id;
        private String username;
        private String email;
        private String merchantId;
        private String role;
        private Boolean active;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public MerchantPortalUserBuilder id(String id) { this.id = id; return this; }
        public MerchantPortalUserBuilder username(String username) { this.username = username; return this; }
        public MerchantPortalUserBuilder email(String email) { this.email = email; return this; }
        public MerchantPortalUserBuilder merchantId(String merchantId) { this.merchantId = merchantId; return this; }
        public MerchantPortalUserBuilder role(String role) { this.role = role; return this; }
        public MerchantPortalUserBuilder active(Boolean active) { this.active = active; return this; }
        public MerchantPortalUserBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public MerchantPortalUserBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public MerchantPortalUser build() {
            return new MerchantPortalUser(id, username, email, merchantId, role, active, createdAt, updatedAt);
        }
    }

    public String getId() { return id; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public String getMerchantId() { return merchantId; }
    public String getRole() { return role; }
    public Boolean getActive() { return active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public void setId(String id) { this.id = id; }
    public void setUsername(String username) { this.username = username; }
    public void setEmail(String email) { this.email = email; }
    public void setMerchantId(String merchantId) { this.merchantId = merchantId; }
    public void setRole(String role) { this.role = role; }
    public void setActive(Boolean active) { this.active = active; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}

