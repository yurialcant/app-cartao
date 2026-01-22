package com.benefits.platform_bff;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class PlatformBffApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlatformBffApplication.class, args);
    }
}