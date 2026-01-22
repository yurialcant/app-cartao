package com.benefits.userbff.controller;

import com.benefits.userbff.client.*;
import com.benefits.userbff.dto.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "User BFF", description = "Backend for Frontend - User App APIs")
public class UserBffController {

    @Autowired
    private TenantServiceClient tenantServiceClient;

    @Autowired
    private IdentityServiceClient identityServiceClient;

    @Autowired
    private BenefitsCoreClient benefitsCoreClient;

    @Autowired
    private CardServiceClient cardServiceClient;

    @Autowired
    private NotificationServiceClient notificationServiceClient;

    @Autowired
    private SupportServiceClient supportServiceClient;

    @GetMapping("/bootstrap")
    @Operation(summary = "Bootstrap user app", description = "Load all initial data for user app")
    public Mono<BootstrapResponseDto> bootstrap(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId,
        @RequestParam("tenantSlug") String tenantSlug
    ) {
        // Parallel calls to all services
        Mono<TenantConfigDto> tenantConfig = tenantServiceClient
            .getTenantConfig(tenantSlug, tenantId);

        Mono<UserProfileDto> userProfile = identityServiceClient
            .getUserProfile(personId, tenantId);

        Mono<List<WalletDto>> wallets = benefitsCoreClient
            .getWallets(tenantId, personId)
            .collectList();

        Mono<List<CardDto>> cards = cardServiceClient
            .getCards(tenantId, personId)
            .collectList();

        Mono<UnreadCountDto> unreadCount = notificationServiceClient
            .getUnreadCount(tenantId, personId);

        return Mono.zip(tenantConfig, userProfile, wallets, cards, unreadCount)
            .map(tuple -> new BootstrapResponseDto(
                tuple.getT1(), // tenantConfig
                tuple.getT2(), // userProfile
                tuple.getT3(), // wallets
                tuple.getT4(), // cards
                tuple.getT5().getCount() // unreadCount
            ));
    }

    @GetMapping("/wallets")
    @Operation(summary = "Get user wallets")
    public Flux<WalletDto> getWallets(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return benefitsCoreClient.getWallets(tenantId, personId);
    }

    @GetMapping("/wallets/{walletId}")
    @Operation(summary = "Get wallet details")
    public Mono<WalletDetailDto> getWalletDetail(
        @PathVariable String walletId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return benefitsCoreClient.getWalletDetail(walletId, tenantId, personId);
    }

    @GetMapping("/statement")
    @Operation(summary = "Get statement entries")
    public Flux<StatementEntryDto> getStatement(
        @RequestParam(required = false) String walletId,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) String filter,
        @RequestParam(required = false) String startDate,
        @RequestParam(required = false) String endDate,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return benefitsCoreClient.getStatement(
            walletId, page, size, filter, startDate, endDate, tenantId, personId
        );
    }

    @PostMapping("/statement/export")
    @Operation(summary = "Export statement")
    public Mono<ExportJobDto> exportStatement(
        @RequestBody ExportRequestDto request,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return benefitsCoreClient.exportStatement(request, tenantId, personId);
    }

    @GetMapping("/exports/{jobId}")
    @Operation(summary = "Get export status")
    public Mono<ExportStatusDto> getExportStatus(
        @PathVariable String jobId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return benefitsCoreClient.getExportStatus(jobId, tenantId, personId);
    }

    @GetMapping("/cards")
    @Operation(summary = "Get user cards")
    public Flux<CardDto> getCards(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return cardServiceClient.getCards(tenantId, personId);
    }

    @PostMapping("/cards/virtual")
    @Operation(summary = "Create virtual card")
    public Mono<CardDto> createVirtualCard(
        @RequestBody VirtualCardRequestDto request,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return cardServiceClient.createVirtualCard(request, tenantId, personId);
    }

    @PutMapping("/cards/{cardId}/freeze")
    @Operation(summary = "Freeze card")
    public Mono<Void> freezeCard(
        @PathVariable String cardId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return cardServiceClient.freezeCard(cardId, tenantId, personId);
    }

    @PutMapping("/cards/{cardId}/unfreeze")
    @Operation(summary = "Unfreeze card")
    public Mono<Void> unfreezeCard(
        @PathVariable String cardId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return cardServiceClient.unfreezeCard(cardId, tenantId, personId);
    }

    @PutMapping("/cards/{cardId}/cancel")
    @Operation(summary = "Cancel card")
    public Mono<Void> cancelCard(
        @PathVariable String cardId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return cardServiceClient.cancelCard(cardId, tenantId, personId);
    }

    @GetMapping("/verification-code")
    @Operation(summary = "Get verification code")
    public Mono<VerificationCodeDto> getVerificationCode(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return identityServiceClient.getVerificationCode(personId, tenantId);
    }

    @PostMapping("/verification-code/refresh")
    @Operation(summary = "Refresh verification code")
    public Mono<VerificationCodeDto> refreshVerificationCode(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return identityServiceClient.refreshVerificationCode(personId, tenantId);
    }

    @GetMapping("/notifications")
    @Operation(summary = "Get notifications")
    public Flux<NotificationDto> getNotifications(
        @RequestParam(defaultValue = "20") int limit,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return notificationServiceClient.getNotifications(limit, tenantId, personId);
    }

    @PutMapping("/notifications/{notificationId}/read")
    @Operation(summary = "Mark notification as read")
    public Mono<Void> markNotificationAsRead(
        @PathVariable String notificationId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return notificationServiceClient.markAsRead(notificationId, tenantId, personId);
    }

    @PutMapping("/notifications/mark-all-read")
    @Operation(summary = "Mark all notifications as read")
    public Mono<Void> markAllNotificationsAsRead(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return notificationServiceClient.markAllAsRead(tenantId, personId);
    }

    @PostMapping("/corporate-requests")
    @Operation(summary = "Create corporate request")
    public Mono<CorporateRequestDto> createCorporateRequest(
        @RequestBody CorporateRequestCreateDto request,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return supportServiceClient.createCorporateRequest(request, tenantId, personId);
    }

    @GetMapping("/corporate-requests")
    @Operation(summary = "Get corporate requests")
    public Flux<CorporateRequestDto> getCorporateRequests(
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return supportServiceClient.getCorporateRequests(tenantId, personId);
    }

    @GetMapping("/corporate-requests/{requestId}")
    @Operation(summary = "Get corporate request")
    public Mono<CorporateRequestDto> getCorporateRequest(
        @PathVariable String requestId,
        @RequestHeader("Authorization") String token,
        @RequestHeader("X-Tenant-ID") String tenantId,
        @RequestHeader("X-Person-ID") String personId
    ) {
        return supportServiceClient.getCorporateRequest(requestId, tenantId, personId);
    }
}