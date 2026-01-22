package com.benefits.core.controller;

import com.benefits.core.service.DataSynchronizationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.Map;
import java.util.UUID;

/**
 * Data Synchronization Controller
 *
 * Handles cross-service data synchronization events
 * Receives events from other services to maintain data consistency
 */
@RestController
@RequestMapping("/internal/sync")
public class DataSyncController {

    private static final Logger log = LoggerFactory.getLogger(DataSyncController.class);

    private final DataSynchronizationService dataSyncService;

    public DataSyncController(DataSynchronizationService dataSyncService) {
        this.dataSyncService = dataSyncService;
    }

    /**
     * Synchronize person data from Identity Service
     * Called when person data changes in Identity Service
     */
    @PostMapping("/person/{personId}")
    public Mono<ResponseEntity<Map<String, String>>> synchronizePersonData(
            @RequestHeader("X-Tenant-Id") String tenantId,
            @PathVariable UUID personId,
            @RequestBody PersonSyncRequest request) {

        log.info("[DataSync] Received person sync request: tenant={}, person={}", tenantId, personId);

        return dataSyncService.synchronizePersonData(UUID.fromString(tenantId), personId,
                mapToSyncData(request))
            .then(Mono.just(ResponseEntity.ok(Map.of("status", "synchronized"))))
            .onErrorResume(error -> {
                log.error("[DataSync] Failed to synchronize person data: {}", error.getMessage());
                return Mono.just(ResponseEntity.internalServerError()
                    .body(Map.of("error", "synchronization_failed")));
            });
    }

    /**
     * Synchronize wallet creation for new person
     */
    @PostMapping("/person/{personId}/wallet")
    public Mono<ResponseEntity<Map<String, String>>> synchronizeWalletCreation(
            @RequestHeader("X-Tenant-Id") String tenantId,
            @PathVariable UUID personId,
            @RequestBody WalletCreationRequest request) {

        log.info("[DataSync] Received wallet creation request: tenant={}, person={}", tenantId, personId);

        return dataSyncService.synchronizeWalletCreation(UUID.fromString(tenantId), personId,
                UUID.fromString(request.getEmployerId()))
            .then(Mono.just(ResponseEntity.ok(Map.of("status", "wallet_created"))))
            .onErrorResume(error -> {
                log.error("[DataSync] Failed to create wallet: {}", error.getMessage());
                return Mono.just(ResponseEntity.internalServerError()
                    .body(Map.of("error", "wallet_creation_failed")));
            });
    }

    /**
     * Synchronize membership data changes
     */
    @PostMapping("/membership/{personId}")
    public Mono<ResponseEntity<Map<String, String>>> synchronizeMembershipData(
            @RequestHeader("X-Tenant-Id") String tenantId,
            @PathVariable UUID personId,
            @RequestBody MembershipSyncRequest request) {

        log.info("[DataSync] Received membership sync request: tenant={}, person={}", tenantId, personId);

        return dataSyncService.synchronizeMembershipData(UUID.fromString(tenantId), personId,
                UUID.fromString(request.getEmployerId()), mapToMembershipSyncData(request))
            .then(Mono.just(ResponseEntity.ok(Map.of("status", "membership_synchronized"))))
            .onErrorResume(error -> {
                log.error("[DataSync] Failed to synchronize membership: {}", error.getMessage());
                return Mono.just(ResponseEntity.internalServerError()
                    .body(Map.of("error", "membership_sync_failed")));
            });
    }

    // Request DTOs
    public static class PersonSyncRequest {
        private String name;
        private String email;
        private String documentNumber;
        private String personType;
        private String createdAt;
        private String updatedAt;

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

    public static class WalletCreationRequest {
        private String employerId;

        public String getEmployerId() { return employerId; }
        public void setEmployerId(String employerId) { this.employerId = employerId; }
    }

    public static class MembershipSyncRequest {
        private String employerId;
        private boolean active;
        private String updatedAt;

        public String getEmployerId() { return employerId; }
        public void setEmployerId(String employerId) { this.employerId = employerId; }

        public boolean isActive() { return active; }
        public void setActive(boolean active) { this.active = active; }

        public String getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    }

    // Helper methods (simplified)
    private DataSynchronizationService.PersonSyncData mapToSyncData(PersonSyncRequest request) {
        return new DataSynchronizationService.PersonSyncData();
    }

    private DataSynchronizationService.MembershipSyncData mapToMembershipSyncData(MembershipSyncRequest request) {
        return new DataSynchronizationService.MembershipSyncData();
    }
}