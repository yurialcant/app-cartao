package com.benefits.employerservice.controller;

import com.benefits.employerservice.entity.Employee;
import com.benefits.employerservice.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/employees")
@RequiredArgsConstructor
public class EmployeeController {
    
    private static final Logger log = LoggerFactory.getLogger(EmployeeController.class);
    private final EmployeeService employeeService;
    
    @PostMapping
    public ResponseEntity<Employee> createEmployee(@RequestBody Employee employee) {
        log.info("🔵 [EMPLOYEE] POST /api/employees");
        return ResponseEntity.ok(employeeService.createEmployee(employee));
    }
    
    @GetMapping("/employer/{employerId}")
    public ResponseEntity<List<Employee>> getEmployeesByEmployer(@PathVariable String employerId) {
        log.info("🔵 [EMPLOYEE] GET /api/employees/employer/{}", employerId);
        return ResponseEntity.ok(employeeService.getEmployeesByEmployer(employerId));
    }
    
    @GetMapping("/employer/{employerId}/active")
    public ResponseEntity<List<Employee>> getActiveEmployeesByEmployer(@PathVariable String employerId) {
        log.info("🔵 [EMPLOYEE] GET /api/employees/employer/{}/active", employerId);
        return ResponseEntity.ok(employeeService.getActiveEmployeesByEmployer(employerId));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Employee> getEmployee(@PathVariable String id) {
        log.info("🔵 [EMPLOYEE] GET /api/employees/{}", id);
        return ResponseEntity.ok(employeeService.getEmployeeById(id));
    }
    
    @PutMapping("/{id}/status")
    public ResponseEntity<Employee> updateEmployeeStatus(
            @PathVariable String id,
            @RequestBody Map<String, String> request) {
        log.info("🔵 [EMPLOYEE] PUT /api/employees/{}/status", id);
        Employee.EmployeeStatus status = Employee.EmployeeStatus.valueOf(request.get("status"));
        return ResponseEntity.ok(employeeService.updateEmployeeStatus(id, status));
    }
    
    @PutMapping("/{id}/transfer")
    public ResponseEntity<Employee> transferEmployee(
            @PathVariable String id,
            @RequestBody Map<String, String> request) {
        log.info("🔵 [EMPLOYEE] PUT /api/employees/{}/transfer", id);
        employeeService.transferEmployee(
                id,
                request.get("newEmployerId"),
                request.get("newCostCenterId")
        );
        return ResponseEntity.ok(employeeService.getEmployeeById(id));
    }
}
