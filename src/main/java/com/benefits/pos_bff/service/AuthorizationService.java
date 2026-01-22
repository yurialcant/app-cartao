package com.benefits.pos_bff.service;

import com.benefits.pos_bff.client.CoreAuthorizationClient;
import com.benefits.pos_bff.dto.AuthorizeRequest;
import com.benefits.pos_bff.dto.AuthorizeResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * POS Authorization Service
 *
 * Orchestrates POS payment authorization with benefits-core (F06)
 */
@Service
public class AuthorizationService {

    private static final Logger log = LoggerFactory.getLogger(AuthorizationService.class);

    private final CoreAuthorizationClient coreAuthorizationClient;

    public AuthorizationService(CoreAuthorizationClient coreAuthorizationClient) {
        this.coreAuthorizationClient = coreAuthorizationClient;
    }

    /**
     * Authorize POS payment
     *
     * @param tenantId Tenant ID from JWT
     * @param request Authorization request
     * @return Authorization response
     */
    public Mono<AuthorizeResponse> authorize(UUID tenantId, AuthorizeRequest request) {
        log.info("[F06] Authorizing POS payment: terminal={}, merchant={}, amount={}",
                request.getTerminalId(), request.getMerchantId(), request.getAmount());

        try {
            // Call benefits-core
            ResponseEntity<AuthorizeResponse> response = coreAuthorizationClient.authorize(tenantId, request);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                log.info("[F06] Authorization successful: code={}, status={}",
                        response.getBody().getAuthorizationCode(), response.getBody().getStatus());
                return Mono.just(response.getBody());
            } else {
                log.warn("[F06] Authorization failed: status={}", response.getStatusCode());
                return Mono.just(AuthorizeResponse.declined("AUTH_FAILED",
                        "Authorization failed: " + response.getStatusCode()));
            }

        } catch (Exception e) {
            log.error("[F06] Authorization error: {}", e.getMessage(), e);
            return Mono.just(AuthorizeResponse.declined("SYSTEM_ERROR",
                    "System error during authorization"));
        }
    }
}