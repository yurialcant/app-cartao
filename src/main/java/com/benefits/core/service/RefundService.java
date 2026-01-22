package com.benefits.core.service;

import com.benefits.core.dto.RefundRequest;
import com.benefits.core.dto.RefundResponse;
import com.benefits.core.entity.LedgerEntry;
import com.benefits.core.entity.Refund;
import com.benefits.core.entity.Wallet;
import com.benefits.core.repository.LedgerEntryRepository;
import com.benefits.core.repository.RefundRepository;
import com.benefits.core.repository.WalletRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Refund Service
 *
 * Handles refund processing logic (F07)
 */
@Service
public class RefundService {

    private static final Logger log = LoggerFactory.getLogger(RefundService.class);

    private final RefundRepository refundRepository;
    private final WalletRepository walletRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    public RefundService(RefundRepository refundRepository,
            WalletRepository walletRepository,
            LedgerEntryRepository ledgerEntryRepository) {
        this.refundRepository = refundRepository;
        this.walletRepository = walletRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    /**
     * Process a refund request
     *
     * @param tenantId Tenant ID
     * @param request  Refund request
     * @return Mono<RefundResponse>
     */
    public Mono<RefundResponse> processRefund(UUID tenantId, RefundRequest request) {

        log.info("[F07] ===== STARTING REFUND PROCESSING =====");
        log.info("[F07] Tenant ID: {}", tenantId);
        log.info("[F07] Person ID: {}", request.getPersonId());
        log.info("[F07] Wallet ID: {}", request.getWalletId());
        log.info("[F07] Original Transaction: {}", request.getOriginalTransactionId());
        log.info("[F07] Amount: {}", request.getAmount());
        log.info("[F07] Idempotency Key: {}", request.getIdempotencyKey());
        log.info("[F07] Request object: {}", request);

        // Check for idempotency
        return refundRepository.existsByTenantIdAndIdempotencyKey(tenantId, request.getIdempotencyKey())
                .flatMap(exists -> {
                    if (exists) {
                        log.warn("[F07] Refund already exists for idempotency key: {}", request.getIdempotencyKey());
                        return refundRepository.findByTenantIdAndIdempotencyKey(tenantId, request.getIdempotencyKey())
                                .map(existingRefund -> {
                                    if ("APPROVED".equals(existingRefund.getStatus())) {
                                        return RefundResponse.approved(existingRefund.getId(),
                                                existingRefund.getAuthorizationCode(),
                                                existingRefund.getAmount(), existingRefund.getOriginalTransactionId(),
                                                existingRefund.getProcessedAt());
                                    } else {
                                        return RefundResponse.declined("already_processed",
                                                "Refund already processed with status: " + existingRefund.getStatus());
                                    }
                                });
                    }

                    // Validate wallet and balance
                    log.info("[F07] Looking for wallet: {} in tenant: {}", request.getWalletId(), tenantId);
                    return walletRepository.findById(request.getWalletId())
                        .doOnNext(wallet -> log.info("[F07] Found wallet: {} with tenant: {}, status: {}", wallet.getId(), wallet.getTenantId(), wallet.getStatus()))
                        .flatMap(wallet -> {
                            if (!tenantId.toString().equals(wallet.getTenantId())) {
                                log.warn("[F07] Wallet {} does not belong to tenant {} (belongs to {})", request.getWalletId(), tenantId, wallet.getTenantId());
                                return Mono.just(RefundResponse.declined("invalid_wallet", "Wallet not found"));
                            }
                            if (!request.getPersonId().toString().equals(wallet.getUserId())) {
                                log.warn("[F07] Person {} does not own wallet {} (owned by {})", request.getPersonId(), request.getWalletId(), wallet.getUserId());
                                return Mono.just(RefundResponse.declined("invalid_wallet", "Wallet not found"));
                            }
                            if (!"ACTIVE".equals(wallet.getStatus())) {
                                log.warn("[F07] Wallet inactive - Wallet: {}, Status: {}", wallet.getId(), wallet.getStatus());
                                return Mono.just(RefundResponse.declined("inactive_wallet", "Wallet is not active"));
                            }

                            log.info("[F07] Validation passed, creating refund record");

                            // Create refund record
                            return createRefundRecord(tenantId, request, wallet);
                        })
                        .switchIfEmpty(Mono.defer(() -> {
                            log.error("[F07] Wallet not found - Tenant: {}, Wallet: {}", tenantId, request.getWalletId());
                            return Mono.just(RefundResponse.declined("invalid_wallet", "Wallet not found"));
                        }));
                })
                .doOnError(error -> log.error("[F07] Refund processing failed: {}", error.getMessage(), error));
    }


    private Mono<RefundResponse> createRefundRecord(UUID tenantId, RefundRequest request, Wallet wallet) {
        // Generate authorization code
        String authorizationCode = "REF" + System.currentTimeMillis();

        // Create refund entity
        Refund refund = new Refund(
                tenantId,
                request.getPersonId(),
                request.getWalletId(),
                request.getOriginalTransactionId(),
                request.getAmount(),
                request.getReason(),
                request.getIdempotencyKey());
        refund.setStatus("APPROVED"); // For simplicity, approve immediately
        refund.setAuthorizationCode(authorizationCode);
        refund.setProcessedAt(Instant.now());

        log.info("[F07] Creating refund record: {}", refund);

        return refundRepository.save(refund)
                .flatMap(savedRefund -> {
                    log.info("[F07] Refund record saved, creating ledger entry");

                    // Create ledger entry (CREDIT for refund)
                    return createLedgerEntry(tenantId, savedRefund, wallet)
                            .thenReturn(savedRefund);
                })
                .map(savedRefund -> RefundResponse.approved(savedRefund.getId(), authorizationCode,
                        savedRefund.getAmount(), savedRefund.getOriginalTransactionId(),
                        savedRefund.getProcessedAt()))
                .onErrorResume(error -> {
                    log.error("[F07] Failed to create refund record: {}", error.getMessage(), error);
                    log.error("[F07] Error type: {}", error.getClass().getSimpleName());
                    log.error("[F07] Full stack trace:", error);
                    return Mono.just(RefundResponse.declined("creation_failed", "Failed to create refund record: " + error.getMessage()));
                });
    }

    private Mono<Void> createLedgerEntry(UUID tenantId, Refund refund, Wallet wallet) {
        LedgerEntry ledgerEntry = new LedgerEntry(
                tenantId.toString(), // tenantId as String
                refund.getWalletId(),
                "CREDIT", // Refund is a credit to the wallet
                refund.getAmount(),
                "Refund for transaction: " + refund.getOriginalTransactionId(),
                "REFUND_" + refund.getAuthorizationCode(), // referenceId
                "REFUND" // referenceType
        );

        log.info("[F07] Creating ledger entry: {}", ledgerEntry);

        return ledgerEntryRepository.save(ledgerEntry)
                .doOnNext(saved -> log.info("[F07] Ledger entry created successfully"))
                .then();
    }

    /**
     * Get refund status by ID
     */
    public Mono<RefundResponse> getRefundStatus(UUID tenantId, UUID refundId) {
        log.info("[F07] Getting refund status - Tenant: {}, RefundId: {}", tenantId, refundId);

        return refundRepository.findByTenantIdAndId(tenantId, refundId)
                .map(refund -> {
                    if ("APPROVED".equals(refund.getStatus())) {
                        return RefundResponse.approved(refund.getId(), refund.getAuthorizationCode(),
                                refund.getAmount(), refund.getOriginalTransactionId(),
                                refund.getProcessedAt());
                    } else {
                        return RefundResponse.declined("not_approved", "Refund status: " + refund.getStatus());
                    }
                })
                .switchIfEmpty(Mono.just(RefundResponse.declined("not_found", "Refund not found")));
    }

    // Inner class for validation results
    private static class ValidationResult {
        private final boolean valid;
        private final String errorCode;
        private final String errorMessage;
        private final Wallet wallet;

        public ValidationResult(boolean valid, String errorCode, String errorMessage) {
            this(valid, errorCode, errorMessage, null);
        }

        public ValidationResult(boolean valid, String errorCode, String errorMessage, Wallet wallet) {
            this.valid = valid;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
            this.wallet = wallet;
        }

        public boolean isValid() {
            return valid;
        }

        public String getErrorCode() {
            return errorCode;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public Wallet getWallet() {
            return wallet;
        }
    }
}