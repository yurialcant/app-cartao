package com.benefits.core.dto;

import java.util.List;

public class ExpenseListResponse {

    private List<ExpenseResponse> expenses;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;

    // Default constructor
    public ExpenseListResponse() {}

    // Constructor with fields
    public ExpenseListResponse(List<ExpenseResponse> expenses, int page, int size, long totalElements, int totalPages) {
        this.expenses = expenses;
        this.page = page;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
    }

    // Getters and Setters
    public List<ExpenseResponse> getExpenses() {
        return expenses;
    }

    public void setExpenses(List<ExpenseResponse> expenses) {
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
}