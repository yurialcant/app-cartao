package com.benefits.notification.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import com.fasterxml.jackson.databind.JsonNode;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("notifications")
public class Notification {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("user_id")
    private UUID userId;

    @Column("type")
    private String type;

    @Column("title")
    private String title;

    @Column("message")
    private String message;

    @Column("data")
    private JsonNode data;

    @Column("read_at")
    private LocalDateTime readAt;

    @Column("sent_at")
    private LocalDateTime sentAt;

    @Column("created_at")
    private LocalDateTime createdAt;

    // Default constructor
    public Notification() {}

    // Constructor
    public Notification(UUID tenantId, UUID userId, String type, String title, String message) {
        this.tenantId = tenantId;
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.message = message;
        this.sentAt = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }

    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public JsonNode getData() { return data; }
    public void setData(JsonNode data) { this.data = data; }

    public LocalDateTime getReadAt() { return readAt; }
    public void setReadAt(LocalDateTime readAt) { this.readAt = readAt; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Business methods
    public boolean isRead() { return readAt != null; }
    public void markAsRead() { this.readAt = LocalDateTime.now(); }
}