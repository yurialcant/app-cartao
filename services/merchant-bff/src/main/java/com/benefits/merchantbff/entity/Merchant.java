package com.benefits.merchantbff.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;

@Table("merchants")
public class Merchant {
    
    @Id
    private String id;
        @Column("name")
    private String name;

    @Column("merchant_type")
    private String merchantType;

    @Column("active")
    private Boolean active;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    public Merchant() {}

    public Merchant(String id, String name, String merchantType, Boolean active, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.merchantType = merchantType;
        this.active = active;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public static MerchantBuilder builder() {
        return new MerchantBuilder();
    }

    public static class MerchantBuilder {
        private String id;
        private String name;
        private String merchantType;
        private Boolean active;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public MerchantBuilder id(String id) { this.id = id; return this; }
        public MerchantBuilder name(String name) { this.name = name; return this; }
        public MerchantBuilder merchantType(String merchantType) { this.merchantType = merchantType; return this; }
        public MerchantBuilder active(Boolean active) { this.active = active; return this; }
        public MerchantBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public MerchantBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public Merchant build() {
            return new Merchant(id, name, merchantType, active, createdAt, updatedAt);
        }
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getMerchantType() { return merchantType; }
    public Boolean getActive() { return active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public void setId(String id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setMerchantType(String merchantType) { this.merchantType = merchantType; }
    public void setActive(Boolean active) { this.active = active; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}

