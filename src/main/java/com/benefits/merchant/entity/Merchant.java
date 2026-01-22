package com.benefits.merchant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("merchants")
public class Merchant {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("merchant_id")
    private String merchantId;

    @Column("name")
    private String name;

    @Column("business_name")
    private String businessName;

    @Column("document")
    private String document;

    @Column("email")
    private String email;

    @Column("phone")
    private String phone;

    @Column("address_street")
    private String addressStreet;

    @Column("address_number")
    private String addressNumber;

    @Column("address_complement")
    private String addressComplement;

    @Column("address_city")
    private String addressCity;

    @Column("address_state")
    private String addressState;

    @Column("address_zip")
    private String addressZip;

    @Column("address_country")
    private String addressCountry;

    @Column("category")
    private String category;

    @Column("mcc_code")
    private String mccCode;

    @Column("status")
    private String status;

    @Column("risk_level")
    private String riskLevel;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Merchant() {}

    // Constructor
    public Merchant(UUID tenantId, String merchantId, String name) {
        this.tenantId = tenantId;
        this.merchantId = merchantId;
        this.name = name;
        this.status = "ACTIVE";
        this.riskLevel = "LOW";
        this.addressCountry = "Brazil";
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

    public String getMerchantId() {
        return merchantId;
    }

    public void setMerchantId(String merchantId) {
        this.merchantId = merchantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        this.updatedAt = LocalDateTime.now();
    }

    public String getBusinessName() {
        return businessName;
    }

    public void setBusinessName(String businessName) {
        this.businessName = businessName;
        this.updatedAt = LocalDateTime.now();
    }

    public String getDocument() {
        return document;
    }

    public void setDocument(String document) {
        this.document = document;
        this.updatedAt = LocalDateTime.now();
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
        this.updatedAt = LocalDateTime.now();
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressStreet() {
        return addressStreet;
    }

    public void setAddressStreet(String addressStreet) {
        this.addressStreet = addressStreet;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressNumber() {
        return addressNumber;
    }

    public void setAddressNumber(String addressNumber) {
        this.addressNumber = addressNumber;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressComplement() {
        return addressComplement;
    }

    public void setAddressComplement(String addressComplement) {
        this.addressComplement = addressComplement;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressCity() {
        return addressCity;
    }

    public void setAddressCity(String addressCity) {
        this.addressCity = addressCity;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressState() {
        return addressState;
    }

    public void setAddressState(String addressState) {
        this.addressState = addressState;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressZip() {
        return addressZip;
    }

    public void setAddressZip(String addressZip) {
        this.addressZip = addressZip;
        this.updatedAt = LocalDateTime.now();
    }

    public String getAddressCountry() {
        return addressCountry;
    }

    public void setAddressCountry(String addressCountry) {
        this.addressCountry = addressCountry;
        this.updatedAt = LocalDateTime.now();
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
        this.updatedAt = LocalDateTime.now();
    }

    public String getMccCode() {
        return mccCode;
    }

    public void setMccCode(String mccCode) {
        this.mccCode = mccCode;
        this.updatedAt = LocalDateTime.now();
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
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
    public boolean isActive() {
        return "ACTIVE".equals(status);
    }

    public boolean isInactive() {
        return "INACTIVE".equals(status);
    }

    public boolean isSuspended() {
        return "SUSPENDED".equals(status);
    }

    public void activate() {
        this.status = "ACTIVE";
        this.updatedAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.status = "INACTIVE";
        this.updatedAt = LocalDateTime.now();
    }

    public void suspend() {
        this.status = "SUSPENDED";
        this.updatedAt = LocalDateTime.now();
    }

    public String getFullAddress() {
        StringBuilder address = new StringBuilder();
        if (addressStreet != null) address.append(addressStreet);
        if (addressNumber != null) address.append(", ").append(addressNumber);
        if (addressComplement != null) address.append(" ").append(addressComplement);
        if (addressCity != null) address.append(", ").append(addressCity);
        if (addressState != null) address.append(", ").append(addressState);
        if (addressZip != null) address.append(" - ").append(addressZip);
        if (addressCountry != null && !"Brazil".equals(addressCountry)) address.append(", ").append(addressCountry);
        return address.toString();
    }
}