package com.benefits.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("expense_receipts")
public class ExpenseReceipt {

    @Id
    private UUID id;

    @Column("expense_id")
    private UUID expenseId;

    @Column("filename")
    private String filename;

    @Column("content_type")
    private String contentType;

    @Column("file_size")
    private Long fileSize;

    @Column("uploaded_at")
    private LocalDateTime uploadedAt;

    // Default constructor
    public ExpenseReceipt() {}

    // Constructor for creating new receipt
    public ExpenseReceipt(UUID expenseId, String filename, String contentType, Long fileSize) {
        this.expenseId = expenseId;
        this.filename = filename;
        this.contentType = contentType;
        this.fileSize = fileSize;
        this.uploadedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getExpenseId() {
        return expenseId;
    }

    public void setExpenseId(UUID expenseId) {
        this.expenseId = expenseId;
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
}