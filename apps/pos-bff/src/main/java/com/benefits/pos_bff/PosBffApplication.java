package com.benefits.pos_bff;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class PosBffApplication {

    public static void main(String[] args) {
        SpringApplication.run(PosBffApplication.class, args);
    }
}