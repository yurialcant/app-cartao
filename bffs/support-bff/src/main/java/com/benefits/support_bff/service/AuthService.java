package com.benefits.support_bff.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    // Mock user info for development
    // In production, this would decode JWT and extract claims
    public Mono<UserInfo> extractUserInfo(String token) {
        log.debug("[Support-BFF] Extracting user info from token");

        // Mock implementation - in production this would validate JWT
        return Mono.fromCallable(() -> {
            // For now, return mock user info
            // This would normally decode JWT claims like:
            // - tenant_id (tid)
            // - person_id (pid)
            // - employer_ids
            // - roles

            return new UserInfo(
                UUID.fromString("550e8400-e29b-41d4-a716-446655440000"), // tenantId
                UUID.fromString("550e8400-e29b-41d4-a716-446655440001"), // personId
                UUID.fromString("550e8400-e29b-41d4-a716-446655440003"), // employerId
                List.of("user", "employee"), // roles
                List.of(UUID.fromString("550e8400-e29b-41d4-a716-446655440003")) // employerIds
            );
        });
    }

    // Mock token validation
    public Mono<Boolean> validateToken(String token) {
        // In production, this would validate JWT signature and expiration
        return Mono.just(token != null && !token.isEmpty());
    }

    // User info container
    public static class UserInfo {
        private final UUID tenantId;
        private final UUID personId;
        private final UUID employerId;
        private final List<String> roles;
        private final List<UUID> employerIds;

        public UserInfo(UUID tenantId, UUID personId, UUID employerId, List<String> roles, List<UUID> employerIds) {
            this.tenantId = tenantId;
            this.personId = personId;
            this.employerId = employerId;
            this.roles = roles;
            this.employerIds = employerIds;
        }

        public UUID getTenantId() {
            return tenantId;
        }

        public UUID getPersonId() {
            return personId;
        }

        public UUID getEmployerId() {
            return employerId;
        }

        public List<String> getRoles() {
            return roles;
        }

        public boolean hasRole(String role) {
            return roles.contains(role);
        }

        public List<UUID> getEmployerIds() {
            return employerIds;
        }

        public boolean hasEmployerAccess(UUID employerId) {
            return employerIds.contains(employerId);
        }
    }
}