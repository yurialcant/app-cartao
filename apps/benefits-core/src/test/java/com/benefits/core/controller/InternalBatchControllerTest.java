package com.benefits.core.controller;

import com.benefits.core.dto.CreditBatchRequest;
import com.benefits.core.dto.CreditBatchResponse;
import com.benefits.core.dto.CreditBatchListResponse;
import com.benefits.core.dto.CreditBatchRequest.CreditBatchItemRequest;
import com.benefits.core.service.CreditBatchService;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@WebFluxTest(InternalBatchController.class)
public class InternalBatchControllerTest {

    @Autowired
    private WebTestClient webTestClient;

    @MockBean
    private CreditBatchService creditBatchService;

    @Test
    public void submitBatch_shouldReturnCreatedBatch() {
        // Given
        UUID tenantId = UUID.randomUUID();
        UUID employerId = UUID.randomUUID();
        UUID personId = UUID.randomUUID();
        String idempotencyKey = "test-key-123";

        CreditBatchItemRequest item = new CreditBatchItemRequest();
        item.setPersonId(UUID.randomUUID().toString());
        item.setWalletId(UUID.randomUUID().toString());
        item.setAmount(BigDecimal.valueOf(100.50));

        CreditBatchRequest request = new CreditBatchRequest();
        request.setItems(List.of(item));

        CreditBatchResponse expectedResponse = new CreditBatchResponse();
        expectedResponse.setId(UUID.randomUUID().toString());
        expectedResponse.setStatus("SUBMITTED");

        when(creditBatchService.submitBatch(eq(tenantId), eq(employerId), any(), eq(idempotencyKey), eq(personId)))
            .thenReturn(Mono.just(expectedResponse));

        // When & Then
        webTestClient.post()
            .uri("/internal/batches/credits")
            .header("X-Tenant-Id", tenantId.toString())
            .header("X-Employer-Id", employerId.toString())
            .header("X-Person-Id", personId.toString())
            .header("X-Idempotency-Key", idempotencyKey)
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(request)
            .exchange()
            .expectStatus().isCreated()
            .expectBody(CreditBatchResponse.class);
    }

    @Test
    public void getBatch_shouldReturnBatch() {
        // Given
        UUID tenantId = UUID.randomUUID();
        UUID batchId = UUID.randomUUID();

        CreditBatchResponse expectedResponse = new CreditBatchResponse();
        expectedResponse.setId(batchId.toString());
        expectedResponse.setStatus("SUBMITTED");

        when(creditBatchService.getBatchDetail(tenantId, batchId))
            .thenReturn(Mono.just(expectedResponse));

        // When & Then
        webTestClient.get()
            .uri("/internal/batches/credits/{batchId}", batchId)
            .header("X-Tenant-Id", tenantId.toString())
            .exchange()
            .expectStatus().isOk()
            .expectBody(CreditBatchResponse.class);
    }

    @Test
    public void listBatches_shouldReturnBatches() {
        // Given
        UUID tenantId = UUID.randomUUID();
        UUID employerId = UUID.randomUUID();

        CreditBatchListResponse expectedResponse = new CreditBatchListResponse();
        expectedResponse.setPage(1);
        expectedResponse.setSize(20);
        expectedResponse.setTotalElements(0);
        expectedResponse.setTotalPages(0);
        expectedResponse.setBatches(List.of());

        when(creditBatchService.listBatches(eq(tenantId), eq(employerId), any(), any()))
            .thenReturn(Mono.just(expectedResponse));

        // When & Then
        webTestClient.get()
            .uri("/internal/batches/credits?page=1&size=20")
            .header("X-Tenant-Id", tenantId.toString())
            .header("X-Employer-Id", employerId.toString())
            .exchange()
            .expectStatus().isOk()
            .expectBody(CreditBatchListResponse.class);
    }
}