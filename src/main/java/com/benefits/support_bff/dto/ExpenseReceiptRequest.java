package com.benefits.support_bff.dto;

import jakarta.validation.constraints.*;

// DTO matching the benefits-core internal receipt request
public class ExpenseReceiptRequest {

    @NotBlank(message = "Filename is required")
    @Size(max = 255, message = "Filename must be less than 255 characters")
    private String filename;

    @NotBlank(message = "Content type is required")
    @Size(max = 100, message = "Content type must be less than 100 characters")
    private String contentType;

    @NotNull(message = "File size is required")
    @Min(value = 1, message = "File size must be greater than 0")
    @Max(value = 10485760, message = "File size must be less than 10MB")
    private Long fileSize;

    // Getters and Setters
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
}