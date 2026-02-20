package com.benefits.paymentsorchestrator;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class PaymentsOrchestratorApplication {
    public static void main(String[] args) {
        SpringApplication.run(PaymentsOrchestratorApplication.class, args);
    }
}
