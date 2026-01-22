package com.benefits.employerservice.controller;

import com.benefits.employerservice.entity.Employer;
import com.benefits.employerservice.service.EmployerService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/employers")
@RequiredArgsConstructor
public class EmployerController {
    
    private static final Logger log = LoggerFactory.getLogger(EmployerController.class);
    private final EmployerService employerService;
    
    @PostMapping
    public ResponseEntity<Employer> createEmployer(@RequestBody Employer employer) {
        log.info("🔵 [EMPLOYER] POST /api/employers");
        return ResponseEntity.ok(employerService.createEmployer(employer));
    }
    
    @GetMapping("/tenant/{tenantId}")
    public ResponseEntity<List<Employer>> getEmployersByTenant(@PathVariable String tenantId) {
        log.info("🔵 [EMPLOYER] GET /api/employers/tenant/{}", tenantId);
        return ResponseEntity.ok(employerService.getEmployersByTenant(tenantId));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Employer> getEmployer(@PathVariable String id) {
        log.info("🔵 [EMPLOYER] GET /api/employers/{}", id);
        return ResponseEntity.ok(employerService.getEmployerById(id));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Employer> updateEmployer(@PathVariable String id, @RequestBody Employer employer) {
        log.info("🔵 [EMPLOYER] PUT /api/employers/{}", id);
        return ResponseEntity.ok(employerService.updateEmployer(id, employer));
    }
}
