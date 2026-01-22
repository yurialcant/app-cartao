package com.benefits.privacy.controller;

import com.benefits.privacy.entity.DataSubjectRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/privacy")
public class PrivacyController {

    private static final Logger log = LoggerFactory.getLogger(PrivacyController.class);

    @PostMapping("/requests")
    public Mono<ResponseEntity<String>> createRequest(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String requestId,
            @RequestParam UUID personId,
            @RequestParam String requestType,
            @RequestParam(required = false) String description) {

        log.info("[Privacy] Creating data subject request: {}", requestId);

        try {
            UUID.fromString(tenantIdHeader);
            // In a real implementation, this would save to database
            return Mono.just(ResponseEntity.status(HttpStatus.CREATED)
                .body("Data subject request created: " + requestId));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().body("Invalid request"));
        }
    }

    @GetMapping("/requests")
    public Mono<ResponseEntity<List<String>>> listRequests(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Privacy] Listing data subject requests");

        try {
            UUID.fromString(tenantIdHeader);
            // In a real implementation, this would query database
            return Mono.just(ResponseEntity.ok(List.of("Sample request 1", "Sample request 2")));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}