package com.benefits.userbff.client;

import com.benefits.userbff.dto.TenantConfigDto;
import com.benefits.userbff.dto.TenantDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import reactor.core.publisher.Mono;

@FeignClient(name = "tenant-service", url = "${services.tenant-service}")
public interface TenantServiceClient {

    @GetMapping("/api/v1/tenants/{tenantSlug}/config")
    Mono<TenantConfigDto> getTenantConfig(
        @PathVariable String tenantSlug,
        @RequestHeader("X-Tenant-ID") String tenantId
    );

    @GetMapping("/api/v1/tenants/{tenantId}")
    Mono<TenantDto> getTenant(
        @PathVariable String tenantId,
        @RequestHeader("X-Tenant-ID") String tenantIdHeader
    );
}