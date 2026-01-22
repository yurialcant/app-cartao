package com.benefits.tenant;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;

/**
 * Tenant Service - SSOT para white-label e configurações
 * Port: 9000
 *
 * Responsibilities:
 * - Tenant white-label configuration (branding, UI composition)
 * - Employer and contract management
 * - Plans and policies definition
 * - Wallet definitions and rules
 */
@SpringBootApplication
@EnableR2dbcRepositories
@EnableFeignClients
public class TenantServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TenantServiceApplication.class, args);
    }
}
