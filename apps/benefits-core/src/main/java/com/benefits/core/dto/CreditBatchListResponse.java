package com.benefits.core.dto;

import java.util.List;

/**
 * Response DTO for listing credit batches with pagination.
 */
public class CreditBatchListResponse {
    private List<CreditBatchResponse> batches;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;

    public CreditBatchListResponse() {}

    public CreditBatchListResponse(List<CreditBatchResponse> batches, int page, int size, long totalElements, int totalPages) {
        this.batches = batches;
        this.page = page;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
    }

    // Getters and setters
    public List<CreditBatchResponse> getBatches() { return batches; }
    public void setBatches(List<CreditBatchResponse> batches) { this.batches = batches; }

    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }

    public int getSize() { return size; }
    public void setSize(int size) { this.size = size; }

    public long getTotalElements() { return totalElements; }
    public void setTotalElements(long totalElements) { this.totalElements = totalElements; }

    public int getTotalPages() { return totalPages; }
    public void setTotalPages(int totalPages) { this.totalPages = totalPages; }
}