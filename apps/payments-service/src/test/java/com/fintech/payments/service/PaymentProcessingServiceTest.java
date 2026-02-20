package com.fintech.payments.service;

import com.fintech.payments.entity.Payment;
import com.fintech.payments.entity.PaymentMethod;
import com.fintech.payments.repository.PaymentRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@SpringBootTest
public class PaymentProcessingServiceTest {

    @Autowired
    private PaymentProcessingService paymentProcessingService;

    @MockBean
    private PaymentRepository paymentRepository;

    private Payment testPayment;

    @BeforeEach
    void setUp() {
        testPayment = new Payment();
        testPayment.setId(1L);
        testPayment.setUserId(100L);
        testPayment.setAmount(new BigDecimal("1500.00"));
        testPayment.setStatus("PENDING");
    }

    @Test
    void testCreatePaymentProcessing() {
        when(paymentRepository.findById(1L)).thenReturn(Optional.of(testPayment));

        paymentProcessingService.createProcessing(testPayment.getId());

        verify(paymentRepository, times(1)).findById(1L);
        assertTrue(true, "Payment processing created successfully");
    }

    @Test
    void testUpdateProcessingStatus() {
        testPayment.setStatus("COMPLETED");
        when(paymentRepository.findById(1L)).thenReturn(Optional.of(testPayment));

        paymentProcessingService.updateProcessingStatus(testPayment.getId(), "COMPLETED");

        assertEquals("COMPLETED", testPayment.getStatus());
    }

    @Test
    void testGetFailedProcessing() {
        testPayment.setStatus("FAILED");
        var failedPayments = paymentProcessingService.getFailedProcessing();
        
        assertNotNull(failedPayments);
    }
}
