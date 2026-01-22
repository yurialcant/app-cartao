package com.benefits.merchantportalbff.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api")
public class MerchantApiController {
    
    private static final Logger log = LoggerFactory.getLogger(MerchantApiController.class);
    
    @GetMapping("/dashboard/sales")
    public Mono<Map<String, Object>> getSalesDashboard() {
        log.info("GET /api/dashboard/sales");
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of(
                "todaySales", 2500.00,
                "weekSales", 15800.00,
                "monthSales", 68500.00,
                "transactionCount", 145,
                "averageTicket", 45.50,
                "topCategories", List.of(
                    Map.of("name", "Alimentação", "amount", 35000.00, "percentage", 0.51),
                    Map.of("name", "Refeição", "amount", 28000.00, "percentage", 0.41),
                    Map.of("name", "Outros", "amount", 5500.00, "percentage", 0.08)
                )
            )
        ));
    }
    
    @GetMapping("/dashboard/operators")
    public Mono<Map<String, Object>> getOperatorsDashboard() {
        log.info("GET /api/dashboard/operators");
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of(
                "activeOperators", 5,
                "totalTransactions", 145,
                "topOperators", List.of(
                    Map.of("name", "Carlos", "transactions", 45, "amount", 2100.00),
                    Map.of("name", "Maria", "transactions", 38, "amount", 1850.00),
                    Map.of("name", "João", "transactions", 32, "amount", 1500.00)
                )
            )
        ));
    }
    
    @GetMapping("/merchant/terminals")
    public Mono<Map<String, Object>> getTerminals() {
        log.info("GET /api/merchant/terminals");
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(
                Map.of("id", "TERM001", "name", "Terminal Caixa 1", "status", "ACTIVE", "lastActivity", LocalDateTime.now().toString()),
                Map.of("id", "TERM002", "name", "Terminal Caixa 2", "status", "ACTIVE", "lastActivity", LocalDateTime.now().minusHours(2).toString()),
                Map.of("id", "TERM003", "name", "Terminal Delivery", "status", "INACTIVE", "lastActivity", LocalDateTime.now().minusDays(1).toString())
            )
        ));
    }
    
    @GetMapping("/merchant/terminals/{terminalId}")
    public Mono<Map<String, Object>> getTerminal(@PathVariable String terminalId) {
        log.info("GET /api/merchant/terminals/{}", terminalId);
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of(
                "id", terminalId,
                "name", "Terminal " + terminalId,
                "status", "ACTIVE",
                "lastActivity", LocalDateTime.now().toString(),
                "todayTransactions", 25,
                "todayAmount", 1250.00
            )
        ));
    }
    
    @PutMapping("/merchant/terminals/{terminalId}")
    public Mono<Map<String, Object>> updateTerminal(@PathVariable String terminalId, @RequestBody Map<String, Object> terminal) {
        log.info("PUT /api/merchant/terminals/{}", terminalId);
        Map<String, Object> updated = new HashMap<>(terminal);
        updated.put("id", terminalId);
        updated.put("updatedAt", LocalDateTime.now().toString());
        return Mono.just(Map.of("success", true, "data", updated));
    }
    
    @GetMapping("/merchant/operators")
    public Mono<Map<String, Object>> getOperators() {
        log.info("GET /api/merchant/operators");
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(
                Map.of("id", UUID.randomUUID().toString(), "name", "Carlos Silva", "email", "carlos@merchant.com", "status", "ACTIVE", "transactions", 45),
                Map.of("id", UUID.randomUUID().toString(), "name", "Maria Santos", "email", "maria@merchant.com", "status", "ACTIVE", "transactions", 38),
                Map.of("id", UUID.randomUUID().toString(), "name", "João Costa", "email", "joao@merchant.com", "status", "ACTIVE", "transactions", 32)
            )
        ));
    }
    
    @PostMapping("/merchant/operators")
    public Mono<Map<String, Object>> createOperator(@RequestBody Map<String, Object> operator) {
        log.info("POST /api/merchant/operators");
        Map<String, Object> created = new HashMap<>(operator);
        created.put("id", UUID.randomUUID().toString());
        created.put("status", "ACTIVE");
        created.put("createdAt", LocalDateTime.now().toString());
        return Mono.just(Map.of("success", true, "data", created));
    }
    
    @GetMapping("/merchant/transactions")
    public Mono<Map<String, Object>> getTransactions(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        log.info("GET /api/merchant/transactions - status={}, page={}", status, page);
        
        List<Map<String, Object>> transactions = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            transactions.add(Map.of(
                "id", UUID.randomUUID().toString(),
                "amount", 25.00 + Math.random() * 100,
                "status", i % 5 == 0 ? "PENDING" : "COMPLETED",
                "customerName", "Cliente " + (i + 1),
                "terminalId", "TERM00" + (i % 3 + 1),
                "createdAt", LocalDateTime.now().minusHours(i).toString()
            ));
        }
        
        return Mono.just(Map.of(
            "success", true,
            "data", transactions,
            "total", 145,
            "page", page,
            "pageSize", pageSize
        ));
    }
    
    @GetMapping("/transfers/merchant/{merchantId}")
    public Mono<Map<String, Object>> getMerchantTransfers(@PathVariable String merchantId) {
        log.info("GET /api/transfers/merchant/{}", merchantId);
        return Mono.just(Map.of(
            "success", true,
            "data", List.of(
                Map.of("id", UUID.randomUUID().toString(), "amount", 5000.00, "status", "COMPLETED", "date", LocalDateTime.now().minusDays(1).toString()),
                Map.of("id", UUID.randomUUID().toString(), "amount", 4500.00, "status", "COMPLETED", "date", LocalDateTime.now().minusDays(8).toString()),
                Map.of("id", UUID.randomUUID().toString(), "amount", 5200.00, "status", "COMPLETED", "date", LocalDateTime.now().minusDays(15).toString())
            )
        ));
    }
    
    @PostMapping("/transfers")
    public Mono<Map<String, Object>> createTransfer(@RequestBody Map<String, Object> transfer) {
        log.info("POST /api/transfers");
        return Mono.just(Map.of(
            "success", true,
            "data", Map.of(
                "id", UUID.randomUUID().toString(),
                "amount", transfer.get("amount"),
                "destination", transfer.get("destination"),
                "status", "PROCESSING",
                "createdAt", LocalDateTime.now().toString()
            )
        ));
    }
}
