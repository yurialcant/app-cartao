package com.benefits.support_bff.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public class PublicReceiptResponse {

    private UUID receiptId;
    private String filename;
    private String contentType;
    private Long fileSize;
    private LocalDateTime uploadedAt;
    private String downloadUrl; // For UI to download the file

    // Default constructor
    public PublicReceiptResponse() {}

    // Constructor
    public PublicReceiptResponse(UUID receiptId, String filename, String contentType,
                               Long fileSize, LocalDateTime uploadedAt) {
        this.receiptId = receiptId;
        this.filename = filename;
        this.contentType = contentType;
        this.fileSize = fileSize;
        this.uploadedAt = uploadedAt;
        this.downloadUrl = "/api/v1/expenses/receipts/" + receiptId + "/download";
    }

    // Getters and Setters
    public UUID getReceiptId() {
        return receiptId;
    }

    public void setReceiptId(UUID receiptId) {
        this.receiptId = receiptId;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(LocalDateTime uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    public String getDownloadUrl() {
        return downloadUrl;
    }

    public void setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
    }
}