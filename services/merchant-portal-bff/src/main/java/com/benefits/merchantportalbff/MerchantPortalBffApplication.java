package com.benefits.merchantportalbff;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.reactive.config.EnableWebFlux;

@SpringBootApplication
@EnableWebFlux
public class MerchantPortalBffApplication {

    public static void main(String[] args) {
        SpringApplication.run(MerchantPortalBffApplication.class, args);
    }
}

