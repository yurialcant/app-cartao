package com.benefits.userbff.client;

import com.benefits.userbff.dto.CorporateRequestDto;
import com.benefits.userbff.dto.CorporateRequestCreateDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@FeignClient(name = "support-service", url = "${services.support-service}")
public interface SupportServiceClient {

    @PostMapping("/api/v1/corporate-requests")
    Mono<CorporateRequestDto> createCorporateRequest(
        @RequestBody CorporateRequestCreateDto request,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @GetMapping("/api/v1/corporate-requests")
    Flux<CorporateRequestDto> getCorporateRequests(
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @GetMapping("/api/v1/corporate-requests/{requestId}")
    Mono<CorporateRequestDto> getCorporateRequest(
        @PathVariable String requestId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );
}