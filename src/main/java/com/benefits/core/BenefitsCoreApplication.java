package com.benefits.core;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableR2dbcRepositories
@EnableScheduling
public class BenefitsCoreApplication {

    private static final Logger log = LoggerFactory.getLogger(BenefitsCoreApplication.class);

    public static void main(String[] args) {
        log.info("Starting BenefitsCoreApplication with {} arguments", args.length);
        SpringApplication.run(BenefitsCoreApplication.class, args);
    }
}