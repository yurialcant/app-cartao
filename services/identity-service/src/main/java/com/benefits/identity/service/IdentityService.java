package com.benefits.identity.service;

import com.benefits.identity.client.BenefitsCoreSyncClient;
import com.benefits.identity.entity.IdentityLink;
import com.benefits.identity.entity.Membership;
import com.benefits.identity.entity.Person;
import com.benefits.identity.repository.IdentityLinkRepository;
import com.benefits.identity.repository.MembershipRepository;
import com.benefits.identity.repository.PersonRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class IdentityService {

    private static final Logger log = LoggerFactory.getLogger(IdentityService.class);

    private final PersonRepository personRepository;
    private final IdentityLinkRepository identityLinkRepository;
    private final MembershipRepository membershipRepository;
    private final JwtService jwtService;
    private final BenefitsCoreSyncClient benefitsCoreSyncClient;

    public IdentityService(PersonRepository personRepository,
                          IdentityLinkRepository identityLinkRepository,
                          MembershipRepository membershipRepository,
                          JwtService jwtService,
                          BenefitsCoreSyncClient benefitsCoreSyncClient) {
        this.personRepository = personRepository;
        this.identityLinkRepository = identityLinkRepository;
        this.membershipRepository = membershipRepository;
        this.jwtService = jwtService;
        this.benefitsCoreSyncClient = benefitsCoreSyncClient;
    }

    // Person operations
    public Mono<Person> createPerson(UUID tenantId, String name, String email,
                                   String documentNumber, LocalDate birthDate) {
        log.info("[Identity] Creating person: {} in tenant: {}", name, tenantId);

        Person person = new Person(tenantId, name, email, documentNumber, birthDate);
        return personRepository.save(person)
            .flatMap(savedPerson -> {
                // Synchronize person data to Benefits Core
                var syncRequest = new BenefitsCoreSyncClient.PersonSyncRequest(
                    savedPerson.getName(),
                    savedPerson.getEmail(),
                    savedPerson.getDocumentNumber(),
                    savedPerson.getPersonType(),
                    savedPerson.getCreatedAt().toString(),
                    savedPerson.getUpdatedAt().toString()
                );

                return benefitsCoreSyncClient.synchronizePersonData(
                        tenantId.toString(), savedPerson.getId(), syncRequest)
                    .doOnSuccess(response -> log.info("[Identity] Person data synchronized to Benefits Core: {}", savedPerson.getId()))
                    .doOnError(error -> log.error("[Identity] Failed to sync person data: {}", error.getMessage()))
                    .thenReturn(savedPerson);
            });
    }

    public Mono<Person> getPerson(UUID tenantId, UUID personId) {
        log.info("[Identity] Getting person: {} in tenant: {}", personId, tenantId);

        return personRepository.findById(personId)
            .filter(person -> tenantId.equals(person.getTenantId()));
    }

    public Flux<Person> listPersons(UUID tenantId) {
        log.info("[Identity] Listing persons in tenant: {}", tenantId);

        return personRepository.findByTenantId(tenantId);
    }

    // Identity Link operations
    public Mono<IdentityLink> createIdentityLink(UUID tenantId, UUID personId,
                                               String issuer, String subject, String email) {
        log.info("[Identity] Creating identity link for person: {} with issuer: {}", personId, issuer);

        return identityLinkRepository.existsByTenantIdAndIssuerAndSubject(tenantId, issuer, subject)
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Identity link already exists"));
                }

                IdentityLink identityLink = new IdentityLink(tenantId, personId, issuer, subject, email);
                return identityLinkRepository.save(identityLink);
            });
    }

    public Mono<IdentityLink> findIdentityLink(UUID tenantId, String issuer, String subject) {
        log.info("[Identity] Finding identity link for issuer: {} subject: {}", issuer, subject);

        return identityLinkRepository.findByTenantIdAndIssuerAndSubject(tenantId, issuer, subject);
    }

    public Mono<IdentityLink> verifyIdentityLink(UUID tenantId, String issuer, String subject) {
        log.info("[Identity] Verifying identity link for issuer: {} subject: {}", issuer, subject);

        return identityLinkRepository.findByTenantIdAndIssuerAndSubject(tenantId, issuer, subject)
            .flatMap(identityLink -> {
                identityLink.markAsVerified();
                return identityLinkRepository.save(identityLink);
            });
    }

    // Membership operations
    public Mono<Membership> createMembership(UUID tenantId, UUID personId, UUID employerId,
                                           String role, LocalDate startDate) {
        log.info("[Identity] Creating membership for person: {} in employer: {}", personId, employerId);

        return membershipRepository.existsByPersonIdAndEmployerIdAndStatus(personId, employerId, "ACTIVE")
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Active membership already exists"));
                }

                Membership membership = new Membership(tenantId, personId, employerId, role, startDate);
                return membershipRepository.save(membership)
                    .flatMap(savedMembership -> {
                        // Synchronize wallet creation to Benefits Core
                        var walletRequest = new BenefitsCoreSyncClient.WalletCreationRequest(
                            savedMembership.getEmployerId().toString()
                        );

                        return benefitsCoreSyncClient.synchronizeWalletCreation(
                                tenantId.toString(), personId, walletRequest)
                            .doOnSuccess(response -> log.info("[Identity] Wallet creation synchronized for membership: {}", savedMembership.getId()))
                            .doOnError(error -> log.error("[Identity] Failed to sync wallet creation: {}", error.getMessage()))
                            .thenReturn(savedMembership);
                    });
            });
    }

    public Flux<Membership> getPersonMemberships(UUID personId) {
        log.info("[Identity] Getting memberships for person: {}", personId);

        return membershipRepository.findByPersonIdAndStatus(personId, "ACTIVE");
    }

    public Mono<Membership> updateMembershipStatus(UUID membershipId, String status) {
        log.info("[Identity] Updating membership: {} to status: {}", membershipId, status);

        return membershipRepository.findById(membershipId)
            .flatMap(membership -> {
                membership.setStatus(status);
                return membershipRepository.save(membership);
            });
    }

    // Authentication operations
    public Mono<AuthResult> authenticate(UUID tenantId, String issuer, String subject) {
        log.info("[Identity] Authenticating issuer: {} subject: {} in tenant: {}", issuer, subject, tenantId);

        return identityLinkRepository.findByTenantIdAndIssuerAndSubject(tenantId, issuer, subject)
            .flatMap(identityLink -> {
                // Update last login
                identityLink.recordLogin();
                return identityLinkRepository.save(identityLink)
                    .flatMap(saved -> {
                        // Get person and memberships
                        return personRepository.findById(saved.getPersonId())
                            .flatMap(person -> {
                                return membershipRepository.findByPersonIdAndStatus(saved.getPersonId(), "ACTIVE")
                                    .collectList()
                                    .map(memberships -> {
                                        String roles = memberships.stream()
                                            .map(Membership::getRole)
                                            .distinct()
                                            .reduce("", (a, b) -> a.isEmpty() ? b : a + "," + b);

                                        String jwt = jwtService.generateToken(
                                            person.getId(),
                                            person.getEmail(),
                                            tenantId.toString(),
                                            roles
                                        );

                                        return new AuthResult(jwt, person, memberships);
                                    });
                            });
                    });
            });
    }

    // JWT operations
    public Mono<JwtClaims> validateToken(String token) {
        log.debug("[Identity] Validating JWT token");

        if (!jwtService.validateToken(token)) {
            return Mono.error(new IllegalArgumentException("Invalid token"));
        }

        UUID personId = jwtService.extractPersonId(token);
        String email = jwtService.extractEmail(token);
        String tenantId = jwtService.extractTenantId(token);
        String roles = jwtService.extractRoles(token);

        return Mono.just(new JwtClaims(personId, email, tenantId, roles));
    }

    public Mono<String> refreshToken(String token) {
        log.info("[Identity] Refreshing JWT token");

        return Mono.fromCallable(() -> jwtService.refreshToken(token));
    }

    // DTO classes for responses
    public static class AuthResult {
        private final String jwt;
        private final Person person;
        private final java.util.List<Membership> memberships;

        public AuthResult(String jwt, Person person, java.util.List<Membership> memberships) {
            this.jwt = jwt;
            this.person = person;
            this.memberships = memberships;
        }

        public String getJwt() {
            return jwt;
        }

        public Person getPerson() {
            return person;
        }

        public java.util.List<Membership> getMemberships() {
            return memberships;
        }
    }

    public static class JwtClaims {
        private final UUID personId;
        private final String email;
        private final String tenantId;
        private final String roles;

        public JwtClaims(UUID personId, String email, String tenantId, String roles) {
            this.personId = personId;
            this.email = email;
            this.tenantId = tenantId;
            this.roles = roles;
        }

        public UUID getPersonId() {
            return personId;
        }

        public String getEmail() {
            return email;
        }

        public String getTenantId() {
            return tenantId;
        }

        public String getRoles() {
            return roles;
        }
    }

    // ============================================
    // VALIDATION METHODS
    // ============================================

    /**
     * Validate employee code format: [A-Z0-9]{3,20}
     */
    private boolean isValidEmployeeCode(String code) {
        if (code == null) return false;
        return code.matches("^[A-Z0-9]{3,20}$");
    }
}