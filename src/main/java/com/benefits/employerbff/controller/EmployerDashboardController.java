package com.benefits.employerbff.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/employer")
public class EmployerDashboardController {
    
    private static final Logger log = LoggerFactory.getLogger(EmployerDashboardController.class);
    
    @GetMapping("/dashboard")
    public Mono<Map<String, Object>> getDashboard() {
        log.info("GET /api/employer/dashboard");
        Map<String, Object> data = new HashMap<>();
        data.put("totalEmployees", 125);
        data.put("activeEmployees", 118);
        data.put("pendingApprovals", 5);
        data.put("totalBenefits", 45000.00);
        data.put("monthlyUsage", 32500.00);
        data.put("utilizationRate", 0.72);
        
        return Mono.just(data);
    }
    
    @GetMapping("/employees")
    public Mono<List<Map<String, Object>>> getEmployees() {
        log.info("GET /api/employer/employees");
        return Mono.just(List.of(
            createEmployee("João Silva", "joao.silva@empresa.com", "TI", "Desenvolvedor", "ACTIVE"),
            createEmployee("Maria Santos", "maria.santos@empresa.com", "RH", "Analista", "ACTIVE"),
            createEmployee("Pedro Costa", "pedro.costa@empresa.com", "Financeiro", "Gerente", "ACTIVE"),
            createEmployee("Ana Oliveira", "ana.oliveira@empresa.com", "Marketing", "Coordenadora", "ACTIVE"),
            createEmployee("Carlos Lima", "carlos.lima@empresa.com", "TI", "Tech Lead", "PENDING")
        ));
    }
    
    @GetMapping("/approvals/pending")
    public Mono<List<Map<String, Object>>> getPendingApprovals() {
        log.info("GET /api/employer/approvals/pending");
        return Mono.just(List.of(
            Map.of(
                "id", UUID.randomUUID().toString(),
                "type", "NEW_EMPLOYEE",
                "employeeName", "Carlos Lima",
                "requestedBy", "Maria Santos",
                "requestedAt", LocalDateTime.now().minusDays(1).toString(),
                "status", "PENDING"
            ),
            Map.of(
                "id", UUID.randomUUID().toString(),
                "type", "BENEFIT_CHANGE",
                "employeeName", "João Silva",
                "requestedBy", "RH",
                "requestedAt", LocalDateTime.now().minusDays(2).toString(),
                "status", "PENDING"
            )
        ));
    }
    
    @GetMapping("/departments")
    public Mono<List<Map<String, Object>>> getDepartments() {
        log.info("GET /api/employer/departments");
        return Mono.just(List.of(
            Map.of("id", "dept-1", "name", "TI", "employeeCount", 25, "manager", "Carlos Lima"),
            Map.of("id", "dept-2", "name", "RH", "employeeCount", 10, "manager", "Maria Santos"),
            Map.of("id", "dept-3", "name", "Financeiro", "employeeCount", 15, "manager", "Pedro Costa"),
            Map.of("id", "dept-4", "name", "Marketing", "employeeCount", 20, "manager", "Ana Oliveira"),
            Map.of("id", "dept-5", "name", "Comercial", "employeeCount", 30, "manager", "Fernando Dias")
        ));
    }
    
    @GetMapping("/cost-centers")
    public Mono<List<Map<String, Object>>> getCostCenters() {
        log.info("GET /api/employer/cost-centers");
        return Mono.just(List.of(
            Map.of("id", "cc-1", "name", "Centro de Custo 1", "budget", 50000.00, "used", 35000.00),
            Map.of("id", "cc-2", "name", "Centro de Custo 2", "budget", 30000.00, "used", 22000.00),
            Map.of("id", "cc-3", "name", "Centro de Custo 3", "budget", 45000.00, "used", 40000.00)
        ));
    }
    
    @GetMapping("/policies")
    public Mono<List<Map<String, Object>>> getPolicies() {
        log.info("GET /api/employer/policies");
        return Mono.just(List.of(
            Map.of("id", "pol-1", "name", "Alimentação", "type", "FOOD", "dailyLimit", 50.00, "active", true),
            Map.of("id", "pol-2", "name", "Refeição", "type", "MEAL", "dailyLimit", 40.00, "active", true),
            Map.of("id", "pol-3", "name", "Transporte", "type", "TRANSPORT", "dailyLimit", 30.00, "active", true)
        ));
    }
    
    @GetMapping("/topups/history")
    public Mono<List<Map<String, Object>>> getTopupHistory() {
        log.info("GET /api/employer/topups/history");
        return Mono.just(List.of(
            Map.of("id", UUID.randomUUID().toString(), "date", LocalDateTime.now().minusDays(1).toString(), 
                "amount", 50000.00, "employeesCount", 100, "status", "COMPLETED"),
            Map.of("id", UUID.randomUUID().toString(), "date", LocalDateTime.now().minusDays(15).toString(), 
                "amount", 48000.00, "employeesCount", 96, "status", "COMPLETED"),
            Map.of("id", UUID.randomUUID().toString(), "date", LocalDateTime.now().minusDays(30).toString(), 
                "amount", 52000.00, "employeesCount", 104, "status", "COMPLETED")
        ));
    }
    
    @PostMapping("/topups")
    public Mono<Map<String, Object>> createTopup(@RequestBody Map<String, Object> request) {
        log.info("POST /api/employer/topups");
        return Mono.just(Map.of(
            "success", true,
            "topupId", UUID.randomUUID().toString(),
            "amount", request.getOrDefault("amount", 0),
            "employeesCount", request.getOrDefault("employeesCount", 0),
            "status", "PROCESSING"
        ));
    }
    
    @GetMapping("/reports/usage")
    public Mono<Map<String, Object>> getUsageReport() {
        log.info("GET /api/employer/reports/usage");
        return Mono.just(Map.of(
            "period", "2026-01",
            "totalCredits", 125000.00,
            "totalUsed", 98500.00,
            "utilizationRate", 0.788,
            "byCategory", Map.of(
                "FOOD", 45000.00,
                "MEAL", 35000.00,
                "TRANSPORT", 18500.00
            )
        ));
    }
    
    private Map<String, Object> createEmployee(String name, String email, String department, String position, String status) {
        return Map.of(
            "id", UUID.randomUUID().toString(),
            "name", name,
            "email", email,
            "department", department,
            "position", position,
            "status", status,
            "balance", Math.random() * 500,
            "createdAt", LocalDateTime.now().minusDays((long)(Math.random() * 365)).toString()
        );
    }
}
