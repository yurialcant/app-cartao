package com.benefits.support_bff.controller;

import com.benefits.support_bff.dto.ExpenseSubmitRequest;
import com.benefits.support_bff.dto.ExpenseResponse;
import com.benefits.support_bff.service.ExpenseService;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.reactive.server.WebTestClient;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@WebFluxTest(ExpenseController.class)
@WithMockUser(roles = "EMPLOYEE")
class ExpenseControllerTest {

    @Autowired
    private WebTestClient webTestClient;

    @MockBean
    private ExpenseService expenseService;

    @Test
    void submitExpense_shouldReturnCreated() {
        // Given
        UUID expenseId = UUID.randomUUID();
        ExpenseSubmitRequest request = new ExpenseSubmitRequest();
        request.setAmount(BigDecimal.valueOf(150.00));
        request.setDescription("Business lunch");
        request.setCategory("Meals");
        request.setCurrency("BRL");

        ExpenseResponse response = new ExpenseResponse();
        response.setId(expenseId);
        response.setAmount(BigDecimal.valueOf(150.00));
        response.setDescription("Business lunch");
        response.setStatus("PENDING");

        when(expenseService.submitExpense(any(), any(ExpenseSubmitRequest.class)))
            .thenReturn(Mono.just(response));

        // When & Then
        webTestClient.post()
            .uri("/api/v1/expenses")
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(request)
            .exchange()
            .expectStatus().isCreated()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody()
            .jsonPath("$.id").isEqualTo(expenseId.toString())
            .jsonPath("$.amount").isEqualTo(150.00)
            .jsonPath("$.status").isEqualTo("PENDING");
    }

    @Test
    void getExpense_shouldReturnExpense() {
        // Given
        UUID expenseId = UUID.randomUUID();
        ExpenseResponse response = new ExpenseResponse();
        response.setId(expenseId);
        response.setAmount(BigDecimal.valueOf(200.00));
        response.setDescription("Taxi fare");
        response.setStatus("APPROVED");

        when(expenseService.getExpense(eq(expenseId)))
            .thenReturn(Mono.just(response));

        // When & Then
        webTestClient.get()
            .uri("/api/v1/expenses/{id}", expenseId)
            .exchange()
            .expectStatus().isOk()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody()
            .jsonPath("$.id").isEqualTo(expenseId.toString())
            .jsonPath("$.amount").isEqualTo(200.00)
            .jsonPath("$.status").isEqualTo("APPROVED");
    }

    @Test
    void listExpenses_shouldReturnExpensesList() {
        // Given
        ExpenseResponse expense1 = new ExpenseResponse();
        expense1.setId(UUID.randomUUID());
        expense1.setAmount(BigDecimal.valueOf(100.00));
        expense1.setStatus("PENDING");

        ExpenseResponse expense2 = new ExpenseResponse();
        expense2.setId(UUID.randomUUID());
        expense2.setAmount(BigDecimal.valueOf(250.00));
        expense2.setStatus("APPROVED");

        when(expenseService.listExpenses())
            .thenReturn(Mono.just(java.util.List.of(expense1, expense2)));

        // When & Then
        webTestClient.get()
            .uri("/api/v1/expenses")
            .exchange()
            .expectStatus().isOk()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody()
            .jsonPath("$[0].amount").isEqualTo(100.00)
            .jsonPath("$[0].status").isEqualTo("PENDING")
            .jsonPath("$[1].amount").isEqualTo(250.00)
            .jsonPath("$[1].status").isEqualTo("APPROVED");
    }

    @Test
    void updateExpenseStatus_shouldReturnUpdatedExpense() {
        // Given
        UUID expenseId = UUID.randomUUID();
        ExpenseResponse response = new ExpenseResponse();
        response.setId(expenseId);
        response.setAmount(BigDecimal.valueOf(300.00));
        response.setStatus("APPROVED");

        when(expenseService.updateExpenseStatus(eq(expenseId), eq("APPROVED")))
            .thenReturn(Mono.just(response));

        // When & Then
        webTestClient.put()
            .uri("/api/v1/expenses/{id}/status?status=APPROVED", expenseId)
            .exchange()
            .expectStatus().isOk()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
            .expectBody()
            .jsonPath("$.id").isEqualTo(expenseId.toString())
            .jsonPath("$.status").isEqualTo("APPROVED");
    }
}