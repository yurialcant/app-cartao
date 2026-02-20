package com.benefits.adminbff.controller;

import com.benefits.adminbff.dto.TenantResponse;
import com.benefits.adminbff.service.TenantService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/tenants")
@Tag(name = "Tenants", description = "Tenant Management APIs")
public class TenantController {
    
    private static final Logger log = LoggerFactory.getLogger(TenantController.class);
    
    private final TenantService tenantService;
    
    public TenantController(TenantService tenantService) {
        this.tenantService = tenantService;
    }
    
    @GetMapping
    @Operation(summary = "List all tenants")
    public Flux<TenantResponse> listTenants() {
        log.info("GET /tenants");
        return tenantService.getAllTenants();
    }
    
    @GetMapping("/active")
    @Operation(summary = "List active tenants only")
    public Flux<TenantResponse> listActiveTenants() {
        log.info("GET /tenants/active");
        return tenantService.getActiveTenants();
    }
    
    @GetMapping("/sorted")
    @Operation(summary = "List tenants sorted by creation date")
    public Flux<TenantResponse> listTenantsSorted() {
        log.info("GET /tenants/sorted");
        return tenantService.getAllTenantsByDate();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get tenant by ID")
    public Mono<ResponseEntity<TenantResponse>> getTenant(@PathVariable String id) {
        log.info("GET /tenants/{}", id);
        return tenantService.getTenantById(id)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> {
                    log.error("Error fetching tenant {}", id, e);
                    return Mono.just(ResponseEntity.notFound().build());
                });
    }
}

