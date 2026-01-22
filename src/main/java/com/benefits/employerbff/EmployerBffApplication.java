package com.benefits.employerbff;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.reactive.config.EnableWebFlux;

@SpringBootApplication
@EnableWebFlux
public class EmployerBffApplication {

    public static void main(String[] args) {
        SpringApplication.run(EmployerBffApplication.class, args);
    }
}

