package com.benefits.employerbff.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;

@Table("employers")
public class Employer {
    
    @Id
    private String id;
        @Column("name")
    private String name;

    @Column("contact_email")
    private String contactEmail;

    @Column("phone")
    private String phone;

    @Column("active")
    private Boolean active;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    public Employer() {}

    public Employer(String id, String name, String contactEmail, String phone, Boolean active, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.contactEmail = contactEmail;
        this.phone = phone;
        this.active = active;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public static EmployerBuilder builder() {
        return new EmployerBuilder();
    }

    public static class EmployerBuilder {
        private String id;
        private String name;
        private String contactEmail;
        private String phone;
        private Boolean active;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public EmployerBuilder id(String id) { this.id = id; return this; }
        public EmployerBuilder name(String name) { this.name = name; return this; }
        public EmployerBuilder contactEmail(String contactEmail) { this.contactEmail = contactEmail; return this; }
        public EmployerBuilder phone(String phone) { this.phone = phone; return this; }
        public EmployerBuilder active(Boolean active) { this.active = active; return this; }
        public EmployerBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public EmployerBuilder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public Employer build() {
            return new Employer(id, name, contactEmail, phone, active, createdAt, updatedAt);
        }
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getContactEmail() { return contactEmail; }
    public String getPhone() { return phone; }
    public Boolean getActive() { return active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public void setId(String id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setActive(Boolean active) { this.active = active; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}

