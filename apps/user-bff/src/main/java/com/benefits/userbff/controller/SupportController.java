package com.benefits.userbff.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/support")
public class SupportController {

    @PostMapping("/tickets")
    public ResponseEntity<Map<String, Object>> createSupportTicket(@RequestBody Map<String, Object> request) {
        // Simplified version - TODO: Integrate with support service
        return ResponseEntity.ok(Map.of("ticketId", "ticket-123", "status", "created"));
    }

    @GetMapping("/tickets")
    public ResponseEntity<Map<String, Object>> getSupportTickets() {
        // Simplified version - TODO: Integrate with support service
        return ResponseEntity.ok(Map.of("tickets", java.util.List.of()));
    }

    @GetMapping("/tickets/{ticketId}")
    public ResponseEntity<Map<String, Object>> getSupportTicket(@PathVariable String ticketId) {
        // Simplified version - TODO: Integrate with support service
        return ResponseEntity.ok(Map.of("ticketId", ticketId, "status", "open"));
    }
}