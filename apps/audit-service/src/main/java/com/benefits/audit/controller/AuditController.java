package com.benefits.audit.controller;

import com.benefits.audit.entity.ComplianceEvent;
import com.benefits.audit.repository.ComplianceEventRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/audit")
public class AuditController {

    private static final Logger log = LoggerFactory.getLogger(AuditController.class);

    private final ComplianceEventRepository eventRepository;

    public AuditController(ComplianceEventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    @PostMapping("/events")
    public Mono<ResponseEntity<ComplianceEvent>> createEvent(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String eventType,
            @RequestParam(defaultValue = "INFO") String severity,
            @RequestParam String description) {

        log.info("[Audit] Creating compliance event: {}", eventType);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);
            ComplianceEvent event = new ComplianceEvent(tenantId, eventType, severity, description);

            return eventRepository.save(event)
                .map(saved -> ResponseEntity.status(HttpStatus.CREATED).body(saved))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/events")
    public Mono<ResponseEntity<List<ComplianceEvent>>> listEvents(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Audit] Listing compliance events");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return eventRepository.findByTenantId(tenantId)
                .collectList()
                .map(events -> ResponseEntity.ok(events))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}