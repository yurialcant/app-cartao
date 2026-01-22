package com.benefits.support.controller;

import com.benefits.support.entity.SupportTicket;
import com.benefits.support.service.SupportService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/internal/support")
public class SupportController {

    private static final Logger log = LoggerFactory.getLogger(SupportController.class);

    private final SupportService supportService;

    public SupportController(SupportService supportService) {
        this.supportService = supportService;
    }

    // ===============================
    // SUPPORT TICKET ENDPOINTS
    // ===============================

    @PostMapping("/tickets")
    public Mono<ResponseEntity<SupportTicket>> createTicket(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @RequestParam String ticketNumber,
            @RequestParam UUID personId,
            @RequestParam String category,
            @RequestParam(defaultValue = "MEDIUM") String priority,
            @RequestParam String title,
            @RequestParam(required = false) String description) {

        log.info("[Support] Creating ticket: {}", ticketNumber);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return supportService.createTicket(tenantId, ticketNumber, personId, category, priority, title, description)
                .map(ticket -> ResponseEntity.status(HttpStatus.CREATED).body(ticket))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/tickets/{ticketId}")
    public Mono<ResponseEntity<SupportTicket>> getTicket(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID ticketId) {

        log.info("[Support] Getting ticket: {}", ticketId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return supportService.getTicket(tenantId, ticketId)
                .map(ticket -> ResponseEntity.ok(ticket))
                .defaultIfEmpty(ResponseEntity.notFound().build())
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @GetMapping("/tickets")
    public Mono<ResponseEntity<List<SupportTicket>>> listTickets(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Support] Listing tickets");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return supportService.listTickets(tenantId)
                .collectList()
                .map(tickets -> ResponseEntity.ok(tickets))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/tickets/{ticketId}/status")
    public Mono<ResponseEntity<SupportTicket>> updateTicketStatus(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID ticketId,
            @RequestParam String status) {

        log.info("[Support] Updating ticket status: {}", status);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return supportService.updateTicketStatus(tenantId, ticketId, status)
                .map(ticket -> ResponseEntity.ok(ticket))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    @PutMapping("/tickets/{ticketId}")
    public Mono<ResponseEntity<SupportTicket>> updateTicket(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader,
            @PathVariable UUID ticketId,
            @RequestBody SupportTicket updates) {

        log.info("[Support] Updating ticket: {}", ticketId);

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return supportService.updateTicket(tenantId, ticketId, updates)
                .map(ticket -> ResponseEntity.ok(ticket))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }

    // ===============================
    // STATISTICS ENDPOINTS
    // ===============================

    @GetMapping("/stats")
    public Mono<ResponseEntity<SupportService.TicketStats>> getTicketStats(
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantIdHeader) {

        log.info("[Support] Getting ticket stats");

        try {
            UUID tenantId = UUID.fromString(tenantIdHeader);

            return supportService.getTicketStats(tenantId)
                .map(stats -> ResponseEntity.ok(stats))
                .onErrorResume(error -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
        } catch (IllegalArgumentException e) {
            return Mono.just(ResponseEntity.badRequest().build());
        }
    }
}