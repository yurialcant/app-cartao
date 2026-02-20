package com.benefits.tenant_bff;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class TenantBffApplication {

    public static void main(String[] args) {
        SpringApplication.run(TenantBffApplication.class, args);
    }
}