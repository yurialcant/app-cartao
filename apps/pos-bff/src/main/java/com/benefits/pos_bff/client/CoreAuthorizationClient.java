package com.benefits.pos_bff.client;

import com.benefits.pos_bff.dto.AuthorizeRequest;
import com.benefits.pos_bff.dto.AuthorizeResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

import java.util.UUID;

/**
 * Feign Client for benefits-core Authorization Service
 *
 * Handles communication with benefits-core for POS authorization (F06)
 */
@FeignClient(name = "benefits-core", url = "${benefits-core.url:http://localhost:8091}")
public interface CoreAuthorizationClient {

    /**
     * Authorize POS payment
     *
     * @param tenantId Tenant ID from JWT
     * @param request Authorization request
     * @return Authorization response
     */
    @PostMapping("/internal/authorize")
    ResponseEntity<AuthorizeResponse> authorize(
            @RequestHeader("X-Tenant-Id") UUID tenantId,
            @RequestBody AuthorizeRequest request
    );
}