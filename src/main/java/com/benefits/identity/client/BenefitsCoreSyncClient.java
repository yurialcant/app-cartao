package com.benefits.identity.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.Map;
import java.util.UUID;

/**
 * Feign client for Benefits Core data synchronization
 * Publishes data change events to maintain cross-service consistency
 */
@FeignClient(
    name = "benefits-core-sync",
    url = "${benefits.core.url:http://localhost:8091}"
)
public interface BenefitsCoreSyncClient {

    /**
     * Synchronize person data to Benefits Core
     */
    @PostMapping("/internal/sync/person/{personId}")
    Mono<Map<String, String>> synchronizePersonData(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @PathVariable("personId") UUID personId,
        @RequestBody PersonSyncRequest request
    );

    /**
     * Notify Benefits Core to create wallet for new person
     */
    @PostMapping("/internal/sync/person/{personId}/wallet")
    Mono<Map<String, String>> synchronizeWalletCreation(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @PathVariable("personId") UUID personId,
        @RequestBody WalletCreationRequest request
    );

    /**
     * Synchronize membership changes to Benefits Core
     */
    @PostMapping("/internal/sync/membership/{personId}")
    Mono<Map<String, String>> synchronizeMembershipData(
        @RequestHeader("X-Tenant-Id") String tenantId,
        @PathVariable("personId") UUID personId,
        @RequestBody MembershipSyncRequest request
    );

    // Request DTOs
    class PersonSyncRequest {
        private String name;
        private String email;
        private String documentNumber;
        private String personType;
        private String createdAt;
        private String updatedAt;

        public PersonSyncRequest() {}

        public PersonSyncRequest(String name, String email, String documentNumber,
                               String personType, String createdAt, String updatedAt) {
            this.name = name;
            this.email = email;
            this.documentNumber = documentNumber;
            this.personType = personType;
            this.createdAt = createdAt;
            this.updatedAt = updatedAt;
        }

        // Getters and setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getDocumentNumber() { return documentNumber; }
        public void setDocumentNumber(String documentNumber) { this.documentNumber = documentNumber; }

        public String getPersonType() { return personType; }
        public void setPersonType(String personType) { this.personType = personType; }

        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

        public String getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    }

    class WalletCreationRequest {
        private String employerId;

        public WalletCreationRequest() {}

        public WalletCreationRequest(String employerId) {
            this.employerId = employerId;
        }

        public String getEmployerId() { return employerId; }
        public void setEmployerId(String employerId) { this.employerId = employerId; }
    }

    class MembershipSyncRequest {
        private String employerId;
        private boolean active;
        private String updatedAt;

        public MembershipSyncRequest() {}

        public MembershipSyncRequest(String employerId, boolean active, String updatedAt) {
            this.employerId = employerId;
            this.active = active;
            this.updatedAt = updatedAt;
        }

        public String getEmployerId() { return employerId; }
        public void setEmployerId(String employerId) { this.employerId = employerId; }

        public boolean isActive() { return active; }
        public void setActive(boolean active) { this.active = active; }

        public String getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    }
}