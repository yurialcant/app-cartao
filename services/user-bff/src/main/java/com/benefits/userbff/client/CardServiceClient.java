package com.benefits.userbff.client;

import com.benefits.userbff.dto.CardDto;
import com.benefits.userbff.dto.VirtualCardRequestDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@FeignClient(name = "card-service", url = "${services.card-service}")
public interface CardServiceClient {

    @GetMapping("/api/v1/cards")
    Flux<CardDto> getCards(
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PostMapping("/api/v1/cards/virtual")
    Mono<CardDto> createVirtualCard(
        @RequestBody VirtualCardRequestDto request,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PutMapping("/api/v1/cards/{cardId}/freeze")
    Mono<Void> freezeCard(
        @PathVariable String cardId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PutMapping("/api/v1/cards/{cardId}/unfreeze")
    Mono<Void> unfreezeCard(
        @PathVariable String cardId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PutMapping("/api/v1/cards/{cardId}/cancel")
    Mono<Void> cancelCard(
        @PathVariable String cardId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );
}