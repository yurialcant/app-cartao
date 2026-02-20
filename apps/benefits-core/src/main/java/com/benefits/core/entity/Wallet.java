package com.benefits.core.entity;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Wallet Entity
 *
 * Represents a user's wallet/balance in the benefits system.
 * Part of F06 POS Authorize flow - debit transactions.
 *
 * Source of Truth for user balances.
 */
@Table("wallets")
public class Wallet {

    @Id
    @Column("id")
    private UUID id;

    @Column("tenant_id")
    private String tenantId;

    @Column("user_id")
    private String userId;

    @Column("wallet_type")
    private String walletType;

    @Column("balance")
    private BigDecimal balance;

    @Column("daily_limit")
    private BigDecimal dailyLimit;

    @Column("daily_spent")
    private BigDecimal dailySpent;

    @Column("last_daily_reset")
    private Instant lastDailyReset;

    @Column("currency")
    private String currency;

    @Column("status")
    private String status;

    @CreatedDate
    @Column("created_at")
    private Instant createdAt;

    @LastModifiedDate
    @Column("updated_at")
    private Instant updatedAt;

    @Version
    @Column("version")
    private Integer version;

    public Wallet() {}

    public Wallet(String tenantId, String userId, String walletType, BigDecimal balance) {
        this.id = UUID.randomUUID();
        this.tenantId = tenantId;
        this.userId = userId;
        this.walletType = walletType != null ? walletType : "FLEX";
        this.balance = balance != null ? balance : BigDecimal.ZERO;
        this.dailySpent = BigDecimal.ZERO;
        this.currency = "BRL";
        this.status = "ACTIVE";
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
        this.version = 0;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getTenantId() {
        return tenantId;
    }

    public void setTenantId(String tenantId) {
        this.tenantId = tenantId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getWalletType() {
        return walletType;
    }

    public void setWalletType(String walletType) {
        this.walletType = walletType;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public BigDecimal getDailyLimit() {
        return dailyLimit;
    }

    public void setDailyLimit(BigDecimal dailyLimit) {
        this.dailyLimit = dailyLimit;
    }

    public BigDecimal getDailySpent() {
        return dailySpent;
    }

    public void setDailySpent(BigDecimal dailySpent) {
        this.dailySpent = dailySpent;
    }

    public Instant getLastDailyReset() {
        return lastDailyReset;
    }

    public void setLastDailyReset(Instant lastDailyReset) {
        this.lastDailyReset = lastDailyReset;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }

    @Override
    public String toString() {
        return "Wallet{" +
                "id=" + id +
                ", tenantId='" + tenantId + '\'' +
                ", userId='" + userId + '\'' +
                ", walletType='" + walletType + '\'' +
                ", balance=" + balance +
                ", currency='" + currency + '\'' +
                ", status='" + status + '\'' +
                ", version=" + version +
                '}';
    }
}