package com.benefits.userbff;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableScheduling;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;

@SpringBootApplication
@EnableFeignClients
@EnableScheduling
@OpenAPIDefinition(
    info = @Info(
        title = "User BFF API",
        version = "1.0",
        description = "Backend for Frontend - User App (Flutter)"
    )
)
public class UserBffApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserBffApplication.class, args);
    }
}