package com.benefits.adminbff.service;

import com.benefits.adminbff.client.TenantServiceClient;
import com.benefits.adminbff.dto.TenantResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.util.List;

@Service
public class TenantService {
    
    private static final Logger log = LoggerFactory.getLogger(TenantService.class);
    private final TenantServiceClient tenantServiceClient;
    
    public TenantService(TenantServiceClient tenantServiceClient) {
        this.tenantServiceClient = tenantServiceClient;
    }
    
    public Flux<TenantResponse> getAllTenants() {
        log.debug("Fetching all tenants from tenant-service");
        return Mono.fromCallable(() -> tenantServiceClient.getAllTenants("default"))
                .flatMapMany(Flux::fromIterable)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Flux<TenantResponse> getAllTenantsByDate() {
        log.debug("Fetching all tenants ordered by date from tenant-service");
        return getAllTenants(); // TODO: order by date if needed
    }
    
    public Flux<TenantResponse> getActiveTenants() {
        log.debug("Fetching active tenants from tenant-service");
        return getAllTenants()
                .filter(tenant -> "ACTIVE".equals(tenant.getStatus()));
    }
    
    public Mono<TenantResponse> getTenantById(String id) {
        log.debug("Fetching tenant with id: {} from tenant-service", id);
        return Mono.fromCallable(() -> tenantServiceClient.getTenantById(id, "default"))
                .subscribeOn(Schedulers.boundedElastic());
    }
}
