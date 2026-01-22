package com.benefits.core.dto;

import jakarta.validation.constraints.NotBlank;

public class ExpenseApprovalRequest {

    @NotBlank(message = "Action is required")
    private String action; // "APPROVE" or "REJECT"

    private String comments;

    // Default constructor
    public ExpenseApprovalRequest() {}

    // Constructor with action
    public ExpenseApprovalRequest(String action) {
        this.action = action;
    }

    // Constructor with action and comments
    public ExpenseApprovalRequest(String action, String comments) {
        this.action = action;
        this.comments = comments;
    }

    // Getters and Setters
    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    // Validation methods
    public boolean isApprove() {
        return "APPROVE".equalsIgnoreCase(action);
    }

    public boolean isReject() {
        return "REJECT".equalsIgnoreCase(action);
    }
}