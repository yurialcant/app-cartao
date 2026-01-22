package com.benefits.core.service;

import com.benefits.core.dto.AuthorizeRequest;
import com.benefits.core.dto.AuthorizeResponse;
import com.benefits.core.entity.*;
import com.benefits.core.repository.LedgerEntryRepository;
import com.benefits.core.repository.MerchantRepository;
import com.benefits.core.repository.TerminalRepository;
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
 * Authorization Service
 *
 * Handles POS payment authorization logic (F06)
 */
@Service
public class AuthorizationService {

    private static final Logger log = LoggerFactory.getLogger(AuthorizationService.class);

    private final MerchantRepository merchantRepository;
    private final TerminalRepository terminalRepository;
    private final WalletRepository walletRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    public AuthorizationService(MerchantRepository merchantRepository,
            TerminalRepository terminalRepository,
            WalletRepository walletRepository,
            LedgerEntryRepository ledgerEntryRepository) {
        this.merchantRepository = merchantRepository;
        this.terminalRepository = terminalRepository;
        this.walletRepository = walletRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    /**
     * Authorize POS payment
     *
     * @param tenantId Tenant ID from JWT
     * @param request  Authorization request
     * @return Mono<AuthorizeResponse>
     */
    public Mono<AuthorizeResponse> authorizePayment(UUID tenantId, AuthorizeRequest request) {

        log.info(
                "[F06] Starting payment authorization - Tenant: {}, Terminal: {}, Merchant: {}, Wallet: {}, Person: {}, Amount: {}",
                tenantId, request.getTerminalId(), request.getMerchantId(), request.getWalletId(),
                request.getPersonId(), request.getAmount());

        return validateTerminalAndMerchant(tenantId, request)
                .flatMap(validationResult -> {
                    if (!validationResult.isValid()) {
                        log.warn("[F06] Terminal/merchant validation failed - Code: {}, Message: {}",
                                validationResult.getErrorCode(), validationResult.getErrorMessage());
                        return Mono.just(AuthorizeResponse.declined(validationResult.getErrorCode(),
                                validationResult.getErrorMessage()));
                    }

                    log.info("[F06] Terminal/merchant validation passed, proceeding to wallet validation");

                    // Terminal and merchant are valid, proceed with wallet validation
                    return validateWalletAndBalance(tenantId, request)
                            .flatMap(walletValidation -> {
                                if (!walletValidation.isValid()) {
                                    log.warn("[F06] Wallet validation failed - Code: {}, Message: {}",
                                            walletValidation.getErrorCode(), walletValidation.getErrorMessage());
                                    return Mono.just(AuthorizeResponse.declined(walletValidation.getErrorCode(),
                                            walletValidation.getErrorMessage()));
                                }

                                log.info("[F06] All validations passed, creating authorization");

                                // Everything is valid, create authorization
                                return createAuthorization(tenantId, request, walletValidation.getWallet());
                            });
                })
                .doOnError(error -> log.error("[F06] Authorization failed: {}", error.getMessage(), error));
    }

    private Mono<ValidationResult> validateTerminalAndMerchant(UUID tenantId, AuthorizeRequest request) {
        log.info("[F06] Validating terminal and merchant - Tenant: {}, Merchant: {}, Terminal: {}",
                tenantId, request.getMerchantId(), request.getTerminalId());

        // Find merchant
        log.debug("[F06] Looking for merchant with tenantId={} and merchantId={}", tenantId, request.getMerchantId());
        return merchantRepository.findByTenantIdAndMerchantId(tenantId, request.getMerchantId())
                .doOnNext(merchant -> log.info("[F06] Merchant found: {} - Status: {}", merchant.getId(),
                        merchant.getStatus()))
                .switchIfEmpty(Mono.defer(() -> {
                    log.error("[F06] Merchant not found - Tenant: {}, MerchantId: {}", tenantId,
                            request.getMerchantId());
                    return Mono.error(new RuntimeException("Merchant not found"));
                }))
                .flatMap(merchant -> {
                    if (!"ACTIVE".equals(merchant.getStatus())) {
                        log.warn("[F06] Merchant inactive - Merchant: {}, Status: {}", merchant.getId(),
                                merchant.getStatus());
                        return Mono.just(new ValidationResult(false, "inactive_merchant", "Merchant is not active"));
                    }

                    log.info("[F06] Merchant active, validating terminal - Merchant: {}, Terminal: {}",
                            merchant.getId(), request.getTerminalId());

                    // Find terminal
                    return terminalRepository.findByMerchantIdAndTerminalId(merchant.getId(), request.getTerminalId())
                            .doOnNext(terminal -> log.info("[F06] Terminal found: {} - Status: {}", terminal.getId(),
                                    terminal.getStatus()))
                            .switchIfEmpty(Mono.defer(() -> {
                                log.error("[F06] Terminal not found - Merchant: {}, TerminalId: {}", merchant.getId(),
                                        request.getTerminalId());
                                return Mono.error(new RuntimeException("Terminal not found"));
                            }))
                            .map(terminal -> {
                                if (!"ACTIVE".equals(terminal.getStatus())) {
                                    log.warn("[F06] Terminal inactive - Terminal: {}, Status: {}", terminal.getId(),
                                            terminal.getStatus());
                                    return new ValidationResult(false, "inactive_terminal", "Terminal is not active");
                                }
                                log.info("[F06] Terminal validation successful - Terminal: {}", terminal.getId());
                                return new ValidationResult(true, null, null);
                            });
                })
                .onErrorResume(error -> {
                    log.error("[F06] Validation error: {}", error.getMessage(), error);
                    if (error.getMessage().contains("Merchant not found")) {
                        return Mono.just(new ValidationResult(false, "invalid_merchant", "Merchant not found"));
                    } else if (error.getMessage().contains("Terminal not found")) {
                        return Mono.just(new ValidationResult(false, "invalid_terminal", "Terminal not found"));
                    }
                    return Mono.just(new ValidationResult(false, "validation_error", error.getMessage()));
                });
    }

    private Mono<WalletValidationResult> validateWalletAndBalance(UUID tenantId, AuthorizeRequest request) {
        log.info("[F06] Validating wallet and balance - Tenant: {}, Wallet: {}, Person: {}, Amount: {}",
                tenantId, request.getWalletId(), request.getPersonId(), request.getAmount());

        return walletRepository.findByIdAndTenantId(request.getWalletId(), tenantId.toString())
                .doOnNext(wallet -> log.info("[F06] Wallet found: {} - UserId: {}, Balance: {}", wallet.getId(),
                        wallet.getUserId(), wallet.getBalance()))
                .flatMap(wallet -> {
                    // Check if wallet belongs to the person
                    if (!wallet.getUserId().equals(request.getPersonId())) {
                        log.error("[F06] Wallet ownership mismatch - Wallet UserId: {}, Request PersonId: {}",
                                wallet.getUserId(), request.getPersonId());
                        return Mono.just(new WalletValidationResult(false, "wallet_not_owned",
                                "Wallet does not belong to user", null));
                    }

                    // Check balance
                    BigDecimal currentBalance = wallet.getBalance() != null ? wallet.getBalance() : BigDecimal.ZERO;
                    log.info("[F06] Wallet balance check - Current: {}, Required: {}", currentBalance,
                            request.getAmount());

                    if (currentBalance.compareTo(request.getAmount()) < 0) {
                        log.warn("[F06] Insufficient funds - Current: {}, Required: {}", currentBalance,
                                request.getAmount());
                        return Mono.just(new WalletValidationResult(false, "insufficient_funds",
                                "Insufficient funds in wallet", wallet));
                    }

                    log.info("[F06] Wallet validation successful - Wallet: {}", wallet.getId());
                    return Mono.just(new WalletValidationResult(true, null, null, wallet));
                })
                .switchIfEmpty(Mono.defer(() -> {
                    log.error("[F06] Wallet not found - Tenant: {}, WalletId: {}", tenantId, request.getWalletId());
                    return Mono.just(new WalletValidationResult(false, "wallet_not_found", "Wallet not found", null));
                }));
    }

    private Mono<AuthorizeResponse> createAuthorization(UUID tenantId, AuthorizeRequest request, Wallet wallet) {
        // Generate authorization code
        String authorizationCode = "AUTH-" + Instant.now().toEpochMilli();
        UUID transactionId = UUID.randomUUID();

        // Get current balance
        BigDecimal balanceBefore = wallet.getBalance() != null ? wallet.getBalance() : BigDecimal.ZERO;
        BigDecimal balanceAfter = balanceBefore.subtract(request.getAmount());

        log.info("[F06] Creating authorization - Code: {}, TransactionId: {}, Balance: {} -> {}",
                authorizationCode, transactionId, balanceBefore, balanceAfter);

        // Create ledger entry for DEBIT
        LedgerEntry debitEntry = new LedgerEntry();
        debitEntry.setId(transactionId);
        debitEntry.setTenantId(tenantId.toString()); // Convert UUID to String
        debitEntry.setWalletId(request.getWalletId());
        debitEntry.setEntryType("DEBIT");
        debitEntry.setAmount(request.getAmount()); // Positive amount, entry type indicates debit
        debitEntry.setDescription(request.getDescription() != null ? request.getDescription()
                : "POS Authorization: " + authorizationCode);
        debitEntry.setReferenceId("POS_AUTH_" + authorizationCode);
        debitEntry.setReferenceType("PAYMENT");
        debitEntry.setCreatedAt(Instant.now());

        log.info("[F06] Created ledger entry - Type: {}, Amount: {}, Reference: {}",
                debitEntry.getEntryType(), debitEntry.getAmount(), debitEntry.getReferenceId());

        // Update wallet balance
        wallet.setBalance(balanceAfter);
        wallet.setUpdatedAt(Instant.now());

        log.info("[F06] Updated wallet balance - Wallet: {}, New Balance: {}", wallet.getId(), balanceAfter);

        // Save both ledger entry and wallet update
        return ledgerEntryRepository.save(debitEntry)
                .doOnNext(savedEntry -> log.info("[F06] Ledger entry saved - Id: {}", savedEntry.getId()))
                .then(walletRepository.save(wallet))
                .doOnNext(savedWallet -> log.info("[F06] Wallet updated - Id: {}, Balance: {}", savedWallet.getId(),
                        savedWallet.getBalance()))
                .then(Mono.just(AuthorizeResponse.approved(authorizationCode, request.getAmount(),
                        balanceBefore, balanceAfter, transactionId)))
                .doOnSuccess(response -> log.info(
                        "[F06] Payment authorized successfully - Code: {}, Amount: {}, Balance: {} -> {}",
                        authorizationCode, request.getAmount(), balanceBefore, balanceAfter));
    }

    // Inner classes for validation results
    private static class ValidationResult {
        private final boolean valid;
        private final String errorCode;
        private final String errorMessage;

        public ValidationResult(boolean valid, String errorCode, String errorMessage) {
            this.valid = valid;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
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
    }

    private static class WalletValidationResult {
        private final boolean valid;
        private final String errorCode;
        private final String errorMessage;
        private final Wallet wallet;

        public WalletValidationResult(boolean valid, String errorCode, String errorMessage, Wallet wallet) {
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