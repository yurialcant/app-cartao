package com.benefits.core.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Person Entity for Benefits Core
 *
 * Replica of person data from Identity Service for data synchronization
 * Used to maintain consistency between services
 */
@Table("person")
public class Person {

    @Id
    private UUID id;
    private UUID tenantId;
    private String name;
    private String email;
    private String documentNumber;
    private String personType;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public Person() {}

    // Constructor for synchronization
    public Person(UUID tenantId, String name, String email, String documentNumber, LocalDate birthDate) {
        this.tenantId = tenantId;
        this.name = name;
        this.email = email;
        this.documentNumber = documentNumber;
        this.personType = "NATURAL"; // Default
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDocumentNumber() {
        return documentNumber;
    }

    public void setDocumentNumber(String documentNumber) {
        this.documentNumber = documentNumber;
    }

    public String getPersonType() {
        return personType;
    }

    public void setPersonType(String personType) {
        this.personType = personType;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Person{" +
                "id=" + id +
                ", tenantId=" + tenantId +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", documentNumber='" + documentNumber + '\'' +
                ", personType='" + personType + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}