package com.benefits.identity.controller;

import com.benefits.identity.entity.IdentityLink;
import com.benefits.identity.entity.Membership;
import com.benefits.identity.entity.Person;
import com.benefits.identity.service.IdentityService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/internal/identity")
public class IdentityController {

    private static final Logger log = LoggerFactory.getLogger(IdentityController.class);

    private final IdentityService identityService;

    public IdentityController(IdentityService identityService) {
        this.identityService = identityService;
    }

    // ===============================
    // PERSON ENDPOINTS
    // ===============================

    @PostMapping("/persons")
    public Mono<ResponseEntity<Person>> createPerson(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String documentNumber,
            @RequestParam(required = false) String birthDate) {

        log.info("[Identity] Creating person: {}", name);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            LocalDate birthDateParsed = birthDate != null ? LocalDate.parse(birthDate) : null;

            return identityService.createPerson(tenantId, name, email, documentNumber, birthDateParsed)
                .map(person -> ResponseEntity.status(HttpStatus.CREATED).body(person))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/persons/{personId}")
    public Mono<ResponseEntity<Person>> getPerson(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID personId) {

        log.info("[Identity] Getting person: {}", personId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return identityService.getPerson(tenantId, personId)
                .map(person -> ResponseEntity.ok(person))
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/persons")
    public Mono<ResponseEntity<List<Person>>> listPersons(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Identity] Listing persons");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return identityService.listPersons(tenantId)
                .collectList()
                .map(persons -> ResponseEntity.ok(persons))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // IDENTITY LINK ENDPOINTS
    // ===============================

    @PostMapping("/identity-links")
    public Mono<ResponseEntity<IdentityLink>> createIdentityLink(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam UUID personId,
            @RequestParam String issuer,
            @RequestParam String subject,
            @RequestParam(required = false) String email) {

        log.info("[Identity] Creating identity link for person: {}", personId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return identityService.createIdentityLink(tenantId, personId, issuer, subject, email)
                .map(link -> ResponseEntity.status(HttpStatus.CREATED).body(link))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/identity-links/verify")
    public Mono<ResponseEntity<IdentityLink>> verifyIdentityLink(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String issuer,
            @RequestParam String subject) {

        log.info("[Identity] Verifying identity link");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return identityService.verifyIdentityLink(tenantId, issuer, subject)
                .map(link -> ResponseEntity.ok(link))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // MEMBERSHIP ENDPOINTS
    // ===============================

    @PostMapping("/memberships")
    public Mono<ResponseEntity<Membership>> createMembership(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam UUID personId,
            @RequestParam UUID employerId,
            @RequestParam(defaultValue = "EMPLOYEE") String role,
            @RequestParam String startDate) {

        log.info("[Identity] Creating membership");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            LocalDate startDateParsed = LocalDate.parse(startDate);

            return identityService.createMembership(tenantId, personId, employerId, role, startDateParsed)
                .map(membership -> ResponseEntity.status(HttpStatus.CREATED).body(membership))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/persons/{personId}/memberships")
    public Mono<ResponseEntity<List<Membership>>> getPersonMemberships(@PathVariable UUID personId) {

        log.info("[Identity] Getting memberships for person: {}", personId);

        return identityService.getPersonMemberships(personId)
            .collectList()
            .map(memberships -> ResponseEntity.ok(memberships))
            .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
    }

    // ===============================
    // AUTHENTICATION ENDPOINTS
    // ===============================

    @PostMapping("/auth")
    public Mono<ResponseEntity<IdentityService.AuthResult>> authenticate(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String issuer,
            @RequestParam String subject) {

        log.info("[Identity] Authenticating user");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return identityService.authenticate(tenantId, issuer, subject)
                .map(result -> ResponseEntity.ok(result))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PostMapping("/auth/validate")
    public Mono<ResponseEntity<IdentityService.JwtClaims>> validateToken(@RequestParam String token) {

        log.info("[Identity] Validating JWT token");

        return identityService.validateToken(token)
            .map(claims -> ResponseEntity.ok(claims))
            .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build()));
    }

    @PostMapping("/auth/refresh")
    public Mono<ResponseEntity<Map<String, String>>> refreshToken(@RequestParam String token) {

        log.info("[Identity] Refreshing JWT token");

        return identityService.refreshToken(token)
            .map(newToken -> ResponseEntity.ok(Map.of("token", newToken)))
            .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build()));
    }
}