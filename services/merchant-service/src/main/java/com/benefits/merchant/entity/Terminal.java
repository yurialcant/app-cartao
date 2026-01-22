package com.benefits.merchant.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import com.fasterxml.jackson.databind.JsonNode;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Table("terminals")
public class Terminal {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("merchant_id")
    private UUID merchantId;

    @Column("terminal_id")
    private String terminalId;

    @Column("serial_number")
    private String serialNumber;

    @Column("model")
    private String model;

    @Column("firmware_version")
    private String firmwareVersion;

    @Column("location_name")
    private String locationName;

    @Column("location_address")
    private String locationAddress;

    @Column("latitude")
    private BigDecimal latitude;

    @Column("longitude")
    private BigDecimal longitude;

    @Column("timezone")
    private String timezone;

    @Column("currency")
    private String currency;

    @Column("capabilities")
    private String[] capabilities;

    @Column("status")
    private String status;

    @Column("last_ping")
    private LocalDateTime lastPing;

    @Column("last_transaction")
    private LocalDateTime lastTransaction;

    @Column("configuration")
    private JsonNode configuration;

    @Column("credentials")
    private JsonNode credentials;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Terminal() {}

    // Constructor
    public Terminal(UUID tenantId, UUID merchantId, String terminalId, String locationName) {
        this.tenantId = tenantId;
        this.merchantId = merchantId;
        this.terminalId = terminalId;
        this.locationName = locationName;
        this.status = "ACTIVE";
        this.currency = "BRL";
        this.timezone = "America/Sao_Paulo";
        this.capabilities = new String[]{"CONTACTLESS", "CHIP", "MAGSTRIPE"};
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

    public UUID getMerchantId() {
        return merchantId;
    }

    public void setMerchantId(UUID merchantId) {
        this.merchantId = merchantId;
    }

    public String getTerminalId() {
        return terminalId;
    }

    public void setTerminalId(String terminalId) {
        this.terminalId = terminalId;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
        this.updatedAt = LocalDateTime.now();
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
        this.updatedAt = LocalDateTime.now();
    }

    public String getFirmwareVersion() {
        return firmwareVersion;
    }

    public void setFirmwareVersion(String firmwareVersion) {
        this.firmwareVersion = firmwareVersion;
        this.updatedAt = LocalDateTime.now();
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
        this.updatedAt = LocalDateTime.now();
    }

    public String getLocationAddress() {
        return locationAddress;
    }

    public void setLocationAddress(String locationAddress) {
        this.locationAddress = locationAddress;
        this.updatedAt = LocalDateTime.now();
    }

    public BigDecimal getLatitude() {
        return latitude;
    }

    public void setLatitude(BigDecimal latitude) {
        this.latitude = latitude;
        this.updatedAt = LocalDateTime.now();
    }

    public BigDecimal getLongitude() {
        return longitude;
    }

    public void setLongitude(BigDecimal longitude) {
        this.longitude = longitude;
        this.updatedAt = LocalDateTime.now();
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
        this.updatedAt = LocalDateTime.now();
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
        this.updatedAt = LocalDateTime.now();
    }

    public String[] getCapabilities() {
        return capabilities;
    }

    public void setCapabilities(String[] capabilities) {
        this.capabilities = capabilities;
        this.updatedAt = LocalDateTime.now();
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getLastPing() {
        return lastPing;
    }

    public void setLastPing(LocalDateTime lastPing) {
        this.lastPing = lastPing;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getLastTransaction() {
        return lastTransaction;
    }

    public void setLastTransaction(LocalDateTime lastTransaction) {
        this.lastTransaction = lastTransaction;
        this.updatedAt = LocalDateTime.now();
    }

    public JsonNode getConfiguration() {
        return configuration;
    }

    public void setConfiguration(JsonNode configuration) {
        this.configuration = configuration;
        this.updatedAt = LocalDateTime.now();
    }

    public JsonNode getCredentials() {
        return credentials;
    }

    public void setCredentials(JsonNode credentials) {
        this.credentials = credentials;
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

    public boolean isMaintenance() {
        return "MAINTENANCE".equals(status);
    }

    public boolean isDecommissioned() {
        return "DECOMMISSIONED".equals(status);
    }

    public void activate() {
        this.status = "ACTIVE";
        this.updatedAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.status = "INACTIVE";
        this.updatedAt = LocalDateTime.now();
    }

    public void maintenance() {
        this.status = "MAINTENANCE";
        this.updatedAt = LocalDateTime.now();
    }

    public void decommission() {
        this.status = "DECOMMISSIONED";
        this.updatedAt = LocalDateTime.now();
    }

    public void recordPing() {
        this.lastPing = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void recordTransaction() {
        this.lastTransaction = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public boolean hasCapability(String capability) {
        if (capabilities == null) return false;
        return List.of(capabilities).contains(capability);
    }

    public boolean isOnline() {
        if (lastPing == null) return false;
        // Consider online if pinged within last 5 minutes
        return lastPing.isAfter(LocalDateTime.now().minusMinutes(5));
    }
}