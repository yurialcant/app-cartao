package com.benefits.userbff.client;

import com.benefits.userbff.dto.WalletDto;
import com.benefits.userbff.dto.StatementEntryDto;
import com.benefits.userbff.dto.WalletDetailDto;
import com.benefits.userbff.dto.ExportRequestDto;
import com.benefits.userbff.dto.ExportJobDto;
import com.benefits.userbff.dto.ExportStatusDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;

@FeignClient(name = "benefits-core", url = "${services.benefits-core}")
public interface BenefitsCoreClient {

    @GetMapping("/api/v1/wallets")
    Flux<WalletDto> getWallets(
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @GetMapping("/api/v1/wallets/{walletId}")
    Mono<WalletDetailDto> getWalletDetail(
        @PathVariable String walletId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @GetMapping("/api/v1/statement")
    Flux<StatementEntryDto> getStatement(
        @RequestParam(required = false) String walletId,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) String filter,
        @RequestParam(required = false) String startDate,
        @RequestParam(required = false) String endDate,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @PostMapping("/api/v1/statement/export")
    Mono<ExportJobDto> exportStatement(
        @RequestBody ExportRequestDto request,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );

    @GetMapping("/api/v1/exports/{jobId}")
    Mono<ExportStatusDto> getExportStatus(
        @PathVariable String jobId,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    );
}