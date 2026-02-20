package com.benefits.userbff.client;

import com.benefits.userbff.dto.UserResponse;
import com.benefits.userbff.dto.WalletSummaryDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@FeignClient(name = "benefits-core", url = "${core.service.url:http://benefits-core:8091}")
public interface CoreServiceClient {

    @GetMapping("/api/users")
    Flux<UserResponse> getAllUsers(@RequestHeader("X-Tenant-Id") String tenantId);

    @GetMapping("/api/users/{id}")
    Mono<UserResponse> getUserById(@PathVariable String id, @RequestHeader("X-Tenant-Id") String tenantId);

    @GetMapping("/api/wallets/{userId}/summary")
    Mono<WalletSummaryDto> getWalletSummary(@PathVariable String userId, @RequestHeader("X-Tenant-Id") String tenantId);
}