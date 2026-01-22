package com.benefits.userbff.dto;

import java.time.Instant;
import java.util.Map;

public class NotificationDto {
    private String id;
    private String type;
    private String title;
    private String message;
    private boolean isRead;
    private Instant createdAt;
    private Map<String, Object> metadata;
    private String actionUrl;

    public NotificationDto() {}

    public NotificationDto(
        String id,
        String type,
        String title,
        String message,
        boolean isRead,
        Instant createdAt,
        Map<String, Object> metadata,
        String actionUrl
    ) {
        this.id = id;
        this.type = type;
        this.title = title;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
        this.metadata = metadata;
        this.actionUrl = actionUrl;
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Map<String, Object> getMetadata() { return metadata; }
    public void setMetadata(Map<String, Object> metadata) { this.metadata = metadata; }

    public String getActionUrl() { return actionUrl; }
    public void setActionUrl(String actionUrl) { this.actionUrl = actionUrl; }

    // Computed properties
    public String getTimeAgo() {
        Instant now = Instant.now();
        long diffSeconds = now.getEpochSecond() - createdAt.getEpochSecond();

        if (diffSeconds < 60) return "Agora";
        if (diffSeconds < 3600) return (diffSeconds / 60) + "min atrás";
        if (diffSeconds < 86400) return (diffSeconds / 3600) + "h atrás";
        return (diffSeconds / 86400) + "d atrás";
    }

    public String getDisplayIcon() {
        switch (type) {
            case "PAYMENT": return "💳";
            case "CREDIT": return "💰";
            case "EXPENSE": return "📄";
            case "SYSTEM": return "ℹ️";
            default: return "🔔";
        }
    }

    public boolean hasAction() {
        return actionUrl != null && !actionUrl.isEmpty();
    }
}