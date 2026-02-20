package com.benefits.support_bff.dto;

import java.util.List;

public class PublicExpenseListResponse {

    private List<PublicExpenseResponse> expenses;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean hasNext;
    private boolean hasPrevious;

    // Default constructor
    public PublicExpenseListResponse() {}

    // Constructor
    public PublicExpenseListResponse(List<PublicExpenseResponse> expenses, int page, int size,
                                   long totalElements, int totalPages) {
        this.expenses = expenses;
        this.page = page;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.hasNext = page < totalPages - 1;
        this.hasPrevious = page > 0;
    }

    // Getters and Setters
    public List<PublicExpenseResponse> getExpenses() {
        return expenses;
    }

    public void setExpenses(List<PublicExpenseResponse> expenses) {
        this.expenses = expenses;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public long getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(long totalElements) {
        this.totalElements = totalElements;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public boolean isHasNext() {
        return hasNext;
    }

    public void setHasNext(boolean hasNext) {
        this.hasNext = hasNext;
    }

    public boolean isHasPrevious() {
        return hasPrevious;
    }

    public void setHasPrevious(boolean hasPrevious) {
        this.hasPrevious = hasPrevious;
    }
}