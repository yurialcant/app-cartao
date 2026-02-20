package com.benefits.core.controller;

import com.benefits.core.entity.CreditBatch;
import com.benefits.core.repository.CreditBatchRepository;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Mono;
import java.math.BigDecimal;
import java.util.UUID;

@WebFluxTest(InternalBatchController.class)
class InternalBatchControllerIntegrationTest {

    @Autowired
    private WebTestClient webTestClient;

    @MockBean
    private CreditBatchRepository creditBatchRepository;

    @Test
    void createCreditBatch_shouldReturnCreated() {
        // Given
        UUID tenantId = UUID.randomUUID();
        UUID employerId = UUID.randomUUID();
        UUID personId = UUID.randomUUID();

        String requestJson = String.format("""
            {
                "employerId": "%s",
                "items": [
                    {
                        "personId": "%s",
                        "amount": 1000.00,
                        "description": "Test credit"
                    }
                ]
            }
            """, employerId, personId);

        CreditBatch savedBatch = new CreditBatch();
        savedBatch.setId(UUID.randomUUID());
        savedBatch.setTenantId(tenantId);
        savedBatch.setEmployerId(employerId);
        savedBatch.setTotalAmount(BigDecimal.valueOf(1000.00));
        savedBatch.setTotalItems(1);

        // When & Then
        webTestClient.post()
            .uri("/internal/batches/credits")
            .header("X-Tenant-Id", tenantId.toString())
            .header("X-Employer-Id", employerId.toString())
            .header("Idempotency-Key", UUID.randomUUID().toString())
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(requestJson)
            .exchange()
            .expectStatus().isCreated()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody()
            .jsonPath("$.tenantId").isEqualTo(tenantId.toString())
            .jsonPath("$.employerId").isEqualTo(employerId.toString())
            .jsonPath("$.totalAmount").isEqualTo(1000.00)
            .jsonPath("$.totalItems").isEqualTo(1);
    }

    @Test
    void createCreditBatch_missingTenantId_shouldReturnBadRequest() {
        // Given
        String requestJson = """
            {
                "employerId": "550e8400-e29b-41d4-a716-446655440001",
                "items": [
                    {
                        "personId": "550e8400-e29b-41d4-a716-446655440002",
                        "amount": 500.00
                    }
                ]
            }
            """;

        // When & Then
        webTestClient.post()
            .uri("/internal/batches/credits")
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(requestJson)
            .exchange()
            .expectStatus().isBadRequest();
    }

    @Test
    void createCreditBatch_emptyItems_shouldReturnBadRequest() {
        // Given
        UUID tenantId = UUID.randomUUID();
        UUID employerId = UUID.randomUUID();

        String requestJson = String.format("""
            {
                "employerId": "%s",
                "items": []
            }
            """, employerId);

        // When & Then
        webTestClient.post()
            .uri("/internal/batches/credits")
            .header("X-Tenant-Id", tenantId.toString())
            .header("X-Employer-Id", employerId.toString())
            .header("Idempotency-Key", UUID.randomUUID().toString())
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(requestJson)
            .exchange()
            .expectStatus().isBadRequest();
    }
}