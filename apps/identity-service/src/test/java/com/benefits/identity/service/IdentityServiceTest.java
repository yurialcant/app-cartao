package com.benefits.identity.service;

import com.benefits.identity.entity.Person;
import com.benefits.identity.entity.IdentityLink;
import com.benefits.identity.repository.PersonRepository;
import com.benefits.identity.repository.IdentityLinkRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;
import java.time.LocalDate;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class IdentityServiceTest {

    @Mock
    private PersonRepository personRepository;

    @Mock
    private IdentityLinkRepository identityLinkRepository;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private IdentityService identityService;

    private UUID tenantId;
    private UUID personId;
    private Person person;
    private IdentityLink identityLink;

    @BeforeEach
    void setUp() {
        tenantId = UUID.randomUUID();
        personId = UUID.randomUUID();

        person = new Person();
        person.setId(personId);
        person.setTenantId(tenantId);
        person.setName("John Doe");
        person.setEmail("john@example.com");
        person.setDocumentNumber("12345678901");
        person.setPersonType("NATURAL");

        identityLink = new IdentityLink();
        identityLink.setId(UUID.randomUUID());
        identityLink.setTenantId(tenantId);
        identityLink.setPersonId(personId);
        identityLink.setIssuer("GOOGLE");
        identityLink.setSubject("google-user-123");
        identityLink.setEmail("john@example.com");
    }

    @Test
    void createPerson_shouldSaveAndReturnPerson() {
        // Given
        when(personRepository.save(any(Person.class))).thenReturn(Mono.just(person));

        // When
        Mono<Person> result = identityService.createPerson(
            tenantId, "John Doe", "john@example.com", "12345678901", LocalDate.of(1990, 1, 1));

        // Then
        StepVerifier.create(result)
            .expectNext(person)
            .verifyComplete();
    }

    @Test
    void getPerson_shouldReturnPerson() {
        // Given
        when(personRepository.findById(personId)).thenReturn(Mono.just(person));

        // When
        Mono<Person> result = identityService.getPerson(tenantId, personId);

        // Then
        StepVerifier.create(result)
            .expectNext(person)
            .verifyComplete();
    }

    @Test
    void createIdentityLink_shouldSaveAndReturnLink() {
        // Given
        when(identityLinkRepository.existsByTenantIdAndIssuerAndSubject(tenantId, "GOOGLE", "google-user-123"))
            .thenReturn(Mono.just(false));
        when(identityLinkRepository.save(any(IdentityLink.class))).thenReturn(Mono.just(identityLink));

        // When
        Mono<IdentityLink> result = identityService.createIdentityLink(
            tenantId, personId, "GOOGLE", "google-user-123", "john@example.com");

        // Then
        StepVerifier.create(result)
            .expectNext(identityLink)
            .verifyComplete();
    }

    @Test
    void createIdentityLink_duplicate_shouldThrowException() {
        // Given
        when(identityLinkRepository.existsByTenantIdAndIssuerAndSubject(tenantId, "GOOGLE", "google-user-123"))
            .thenReturn(Mono.just(true));

        // When
        Mono<IdentityLink> result = identityService.createIdentityLink(
            tenantId, personId, "GOOGLE", "google-user-123", "john@example.com");

        // Then
        StepVerifier.create(result)
            .expectError(IllegalArgumentException.class)
            .verify();
    }

    @Test
    void authenticate_shouldReturnAuthResult() {
        // Given
        when(identityLinkRepository.findByTenantIdAndIssuerAndSubject(tenantId, "GOOGLE", "google-user-123"))
            .thenReturn(Mono.just(identityLink));
        when(personRepository.findById(personId)).thenReturn(Mono.just(person));
        when(identityLinkRepository.save(any(IdentityLink.class))).thenReturn(Mono.just(identityLink));
        when(jwtService.generateToken(any(), any(), any(), any())).thenReturn("jwt-token");

        // When
        Mono<IdentityService.AuthResult> result = identityService.authenticate(tenantId, "GOOGLE", "google-user-123");

        // Then
        StepVerifier.create(result)
            .expectNextMatches(authResult ->
                authResult.getJwt().equals("jwt-token") &&
                authResult.getPerson().equals(person))
            .verifyComplete();
    }
}