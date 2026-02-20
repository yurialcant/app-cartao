package com.benefits.opsrelay.controller;

import com.benefits.opsrelay.entity.Inbox;
import com.benefits.opsrelay.service.ReplayService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

/**
 * Replay Controller
 * 
 * Provides endpoints for replaying events from inbox
 */
@RestController
@RequestMapping("/api/v1/replay")
public class ReplayController {

    private static final Logger log = LoggerFactory.getLogger(ReplayController.class);

    private final ReplayService replayService;

    public ReplayController(ReplayService replayService) {
        this.replayService = replayService;
    }

    /**
     * Replay events with filters
     * GET /api/v1/replay?tenantId=...&eventType=...&fromDate=...&toDate=...
     */
    @GetMapping
    public Mono<ResponseEntity<ReplayResponse>> replayEvents(
            @RequestHeader("X-Tenant-Id") String tenantId,
            @RequestParam(required = false) String eventType,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant toDate) {

        log.info("[Replay] Replay request - tenantId={}, eventType={}, fromDate={}, toDate={}", 
                tenantId, eventType, fromDate, toDate);

        // Default date range: last 24 hours if not specified
        if (fromDate == null) {
            fromDate = Instant.now().minusSeconds(86400); // 24 hours ago
        }
        if (toDate == null) {
            toDate = Instant.now();
        }

        return replayService.replayEvents(tenantId, eventType, fromDate, toDate)
                .collectList()
                .map(events -> {
                    ReplayResponse response = new ReplayResponse();
                    response.setCount(events.size());
                    response.setEvents(events);
                    return ResponseEntity.ok(response);
                })
                .onErrorResume(error -> {
                    log.error("[Replay] Error replaying events: {}", error.getMessage());
                    return Mono.just(ResponseEntity.internalServerError().build());
                });
    }

    /**
     * Replay a specific event by ID
     * POST /api/v1/replay/{eventId}
     */
    @PostMapping("/{eventId}")
    public Mono<ResponseEntity<String>> replayEvent(
            @RequestHeader("X-Tenant-Id") String tenantId,
            @PathVariable UUID eventId) {

        log.info("[Replay] Replay single event - tenantId={}, eventId={}", tenantId, eventId);

        return replayService.replayEvent(tenantId, eventId)
                .map(success -> {
                    if (success) {
                        return ResponseEntity.ok("Event replayed successfully");
                    } else {
                        return ResponseEntity.status(404).body("Event not found");
                    }
                })
                .onErrorResume(error -> {
                    log.error("[Replay] Error replaying event {}: {}", eventId, error.getMessage());
                    return Mono.just(ResponseEntity.status(500).body("Internal server error"));
                });
    }

    /**
     * Response DTO for replay
     */
    public static class ReplayResponse {
        private int count;
        private java.util.List<Inbox> events;

        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }

        public java.util.List<Inbox> getEvents() { return events; }
        public void setEvents(java.util.List<Inbox> events) { this.events = events; }
    }
}
