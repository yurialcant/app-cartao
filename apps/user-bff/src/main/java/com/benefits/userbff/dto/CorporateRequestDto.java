package com.benefits.userbff.dto;

import java.time.Instant;

public class CorporateRequestDto {
    private String id;
    private String type;
    private String status;
    private String justification;
    private String attachmentUrl;
    private String approverComment;
    private Instant createdAt;
    private Instant approvedAt;
    private String approvedBy;

    public CorporateRequestDto() {}

    public CorporateRequestDto(
        String id,
        String type,
        String status,
        String justification,
        String attachmentUrl,
        String approverComment,
        Instant createdAt,
        Instant approvedAt,
        String approvedBy
    ) {
        this.id = id;
        this.type = type;
        this.status = status;
        this.justification = justification;
        this.attachmentUrl = attachmentUrl;
        this.approverComment = approverComment;
        this.createdAt = createdAt;
        this.approvedAt = approvedAt;
        this.approvedBy = approvedBy;
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getJustification() { return justification; }
    public void setJustification(String justification) { this.justification = justification; }

    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }

    public String getApproverComment() { return approverComment; }
    public void setApproverComment(String approverComment) { this.approverComment = approverComment; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Instant approvedAt) { this.approvedAt = approvedAt; }

    public String getApprovedBy() { return approvedBy; }
    public void setApprovedBy(String approvedBy) { this.approvedBy = approvedBy; }

    // Computed properties
    public boolean isPending() {
        return "PENDING".equals(status);
    }

    public boolean isApproved() {
        return "APPROVED".equals(status);
    }

    public boolean isRejected() {
        return "REJECTED".equals(status);
    }

    public String getDisplayStatus() {
        switch (status) {
            case "PENDING": return "Pendente";
            case "APPROVED": return "Aprovado";
            case "REJECTED": return "Rejeitado";
            default: return status;
        }
    }

    public String getDisplayType() {
        switch (type) {
            case "CARD_ACTIVATION": return "Ativação de Cartão";
            case "WALLET_LIMIT_INCREASE": return "Aumento de Limite";
            case "CORPORATE_WALLET": return "Carteira Corporativa";
            default: return type;
        }
    }
}