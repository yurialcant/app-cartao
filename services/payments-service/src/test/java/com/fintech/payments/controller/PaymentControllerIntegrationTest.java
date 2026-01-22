package com.fintech.payments.controller;

import com.fintech.payments.entity.Payment;
import com.fintech.payments.service.PaymentService;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

@SpringBootTest
@AutoConfigureMockMvc
public class PaymentControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PaymentService paymentService;

    @Test
    void testGetAllPayments() throws Exception {
        Payment payment = new Payment();
        payment.setId(1L);
        payment.setUserId(100L);
        payment.setAmount(new BigDecimal("1500.00"));
        payment.setStatus("COMPLETED");

        when(paymentService.getAllPayments()).thenReturn(List.of(payment));

        mockMvc.perform(get("/api/payments")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id").value(1))
                .andExpect(jsonPath("$.data[0].amount").value(1500.00))
                .andExpect(jsonPath("$.data[0].status").value("COMPLETED"));
    }

    @Test
    void testGetPaymentById() throws Exception {
        Payment payment = new Payment();
        payment.setId(1L);
        payment.setUserId(100L);
        payment.setAmount(new BigDecimal("500.00"));
        payment.setStatus("PENDING");

        when(paymentService.getPaymentById(1L)).thenReturn(payment);

        mockMvc.perform(get("/api/payments/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.status").value("PENDING"));
    }

    @Test
    void testGetPaymentNotFound() throws Exception {
        when(paymentService.getPaymentById(999L))
                .thenThrow(new IllegalArgumentException("Payment not found"));

        mockMvc.perform(get("/api/payments/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }
}
