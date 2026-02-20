package com.benefits.userbff.client;

import com.benefits.userbff.dto.UserProfileDto;
import com.benefits.userbff.dto.VerificationCodeDto;
import com.benefits.userbff.dto.EmploymentDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import reactor.core.publisher.Mono;

@FeignClient(name = "identity-service", url = "${services.identity-service}")
public interface IdentityServiceClient {

    @GetMapping("/api/v1/persons/{personId}")
    Mono<UserProfileDto> getUserProfile(
        @PathVariable String personId,
        @RequestHeader("X-Tenant-ID") String tenantId
    );

    @GetMapping("/api/v1/persons/{personId}/employments")
    Mono<EmploymentDto> getEmployment(
        @PathVariable String personId,
        @RequestHeader("X-Tenant-ID") String tenantId
    );

    @GetMapping("/api/v1/persons/{personId}/verification-code")
    Mono<VerificationCodeDto> getVerificationCode(
        @PathVariable String personId,
        @RequestHeader("X-Tenant-ID") String tenantId
    );

    @GetMapping("/api/v1/persons/{personId}/verification-code/refresh")
    Mono<VerificationCodeDto> refreshVerificationCode(
        @PathVariable String personId,
        @RequestHeader("X-Tenant-ID") String tenantId
    );
}