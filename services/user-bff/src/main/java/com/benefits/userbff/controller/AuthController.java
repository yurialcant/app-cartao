package com.benefits.userbff.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, Object> loginRequest) {
        // Simplified version - TODO: Implement proper authentication
        return ResponseEntity.ok(Map.of("token", "sample-jwt-token", "expiresIn", 3600));
    }

    @PostMapping("/refresh")
    public ResponseEntity<Map<String, Object>> refresh(@RequestBody Map<String, Object> refreshRequest) {
        // Simplified version - TODO: Implement token refresh
        return ResponseEntity.ok(Map.of("token", "refreshed-jwt-token", "expiresIn", 3600));
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, Object>> logout() {
        // Simplified version - TODO: Implement logout
        return ResponseEntity.ok(Map.of("status", "OK", "message", "Logged out"));
    }

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getCurrentUser() {
        // Simplified version - TODO: Implement user profile
        return ResponseEntity.ok(Map.of("userId", "123", "name", "John Doe"));
    }
}