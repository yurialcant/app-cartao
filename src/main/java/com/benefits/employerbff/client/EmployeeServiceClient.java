package com.benefits.employerbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@FeignClient(name = "employer-service-employee", url = "${employerservice.service.url:http://employer-service:8107}")
public interface EmployeeServiceClient {
    
    @GetMapping("/api/employees/employer/{employerId}")
    List<Map<String, Object>> getEmployeesByEmployer(@PathVariable String employerId);
    
    @GetMapping("/api/employees/employer/{employerId}/active")
    List<Map<String, Object>> getActiveEmployeesByEmployer(@PathVariable String employerId);
    
    @GetMapping("/api/employees/{id}")
    Map<String, Object> getEmployee(@PathVariable String id);
    
    @PostMapping("/api/employees")
    Map<String, Object> createEmployee(@RequestBody Map<String, Object> employee);
    
    @PutMapping("/api/employees/{id}/status")
    Map<String, Object> updateEmployeeStatus(@PathVariable String id, @RequestBody Map<String, String> request);
    
    @PutMapping("/api/employees/{id}/transfer")
    Map<String, Object> transferEmployee(@PathVariable String id, @RequestBody Map<String, String> request);
}


