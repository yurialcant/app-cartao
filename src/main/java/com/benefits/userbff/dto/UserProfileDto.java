package com.benefits.userbff.dto;

import java.time.Instant;
import java.util.List;

public class UserProfileDto {
    private String personId;
    private String displayName;
    private String email;
    private String employerName;
    private String employeeCode;
    private String department;
    private List<String> roles;
    private boolean isActive;
    private Instant lastLogin;

    public UserProfileDto() {}

    public UserProfileDto(
        String personId,
        String displayName,
        String email,
        String employerName,
        String employeeCode,
        String department,
        List<String> roles,
        boolean isActive,
        Instant lastLogin
    ) {
        this.personId = personId;
        this.displayName = displayName;
        this.email = email;
        this.employerName = employerName;
        this.employeeCode = employeeCode;
        this.department = department;
        this.roles = roles;
        this.isActive = isActive;
        this.lastLogin = lastLogin;
    }

    // Getters and setters
    public String getPersonId() { return personId; }
    public void setPersonId(String personId) { this.personId = personId; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getEmployerName() { return employerName; }
    public void setEmployerName(String employerName) { this.employerName = employerName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public List<String> getRoles() { return roles; }
    public void setRoles(List<String> roles) { this.roles = roles; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Instant getLastLogin() { return lastLogin; }
    public void setLastLogin(Instant lastLogin) { this.lastLogin = lastLogin; }
}