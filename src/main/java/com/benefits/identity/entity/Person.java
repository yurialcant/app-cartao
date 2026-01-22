package com.benefits.identity.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Table("persons")
public class Person {

    @Id
    private UUID id;

    @Column("tenant_id")
    private UUID tenantId;

    @Column("person_type")
    private String personType; // NATURAL, LEGAL

    @Column("name")
    private String name;

    @Column("email")
    private String email;

    @Column("phone")
    private String phone;

    @Column("document_type")
    private String documentType; // CPF, CNPJ, PASSPORT

    @Column("document_number")
    private String documentNumber;

    @Column("birth_date")
    private LocalDate birthDate;

    @Column("nationality")
    private String nationality;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    // Default constructor
    public Person() {}

    // Constructor for natural person
    public Person(UUID tenantId, String name, String email, String documentNumber, LocalDate birthDate) {
        this.tenantId = tenantId;
        this.personType = "NATURAL";
        this.name = name;
        this.email = email;
        this.documentType = "CPF";
        this.documentNumber = documentNumber;
        this.birthDate = birthDate;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor for legal person
    public Person(UUID tenantId, String name, String email, String documentNumber) {
        this.tenantId = tenantId;
        this.personType = "LEGAL";
        this.name = name;
        this.email = email;
        this.documentType = "CNPJ";
        this.documentNumber = documentNumber;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
        this.updatedAt = LocalDateTime.now();
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    public String getPersonType() {
        return personType;
    }

    public void setPersonType(String personType) {
        this.personType = personType;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        this.updatedAt = LocalDateTime.now();
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
        this.updatedAt = LocalDateTime.now();
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
        this.updatedAt = LocalDateTime.now();
    }

    public String getDocumentType() {
        return documentType;
    }

    public void setDocumentType(String documentType) {
        this.documentType = documentType;
    }

    public String getDocumentNumber() {
        return documentNumber;
    }

    public void setDocumentNumber(String documentNumber) {
        this.documentNumber = documentNumber;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public String getNationality() {
        return nationality;
    }

    public void setNationality(String nationality) {
        this.nationality = nationality;
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

    // Business methods
    public boolean isNaturalPerson() {
        return "NATURAL".equals(personType);
    }

    public boolean isLegalPerson() {
        return "LEGAL".equals(personType);
    }
}