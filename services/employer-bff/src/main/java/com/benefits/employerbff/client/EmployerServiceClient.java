package com.benefits.employerbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@FeignClient(name = "employer-service", url = "${employerservice.service.url:http://employer-service:8107}")
public interface EmployerServiceClient {
    
    @GetMapping("/api/employers/tenant/{tenantId}")
    List<Map<String, Object>> getEmployersByTenant(@PathVariable String tenantId);
    
    @GetMapping("/api/employers/{id}")
    Map<String, Object> getEmployer(@PathVariable String id);
    
    @PostMapping("/api/employers")
    Map<String, Object> createEmployer(@RequestBody Map<String, Object> employer);
    
    @PutMapping("/api/employers/{id}")
    Map<String, Object> updateEmployer(@PathVariable String id, @RequestBody Map<String, Object> employer);
}


