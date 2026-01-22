package com.benefits.payments.service;

import com.benefits.payments.entity.Transaction;
import com.benefits.payments.repository.TransactionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.math.BigDecimal;
import java.util.UUID;

@Service
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

    private final TransactionRepository transactionRepository;

    public PaymentService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    // Create new transaction
    public Mono<Transaction> createTransaction(UUID tenantId, String transactionId, UUID personId,
                                             UUID employerId, BigDecimal amount, String description) {
        log.info("[Payment] Creating transaction: {} for person: {}", transactionId, personId);

        return transactionRepository.existsByTransactionId(transactionId)
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Transaction ID already exists"));
                }

                Transaction transaction = new Transaction(tenantId, transactionId, personId, employerId, amount, description);
                return transactionRepository.save(transaction);
            });
    }

    // Get transaction by ID
    public Mono<Transaction> getTransaction(UUID tenantId, UUID transactionId) {
        log.info("[Payment] Getting transaction: {}", transactionId);

        return transactionRepository.findById(transactionId)
            .filter(transaction -> tenantId.equals(transaction.getTenantId()));
    }

    // Get transaction by transaction ID
    public Mono<Transaction> getTransactionByTransactionId(UUID tenantId, String transactionId) {
        log.info("[Payment] Getting transaction by ID: {}", transactionId);

        return transactionRepository.findByTenantIdAndTransactionId(tenantId, transactionId);
    }

    // List transactions for tenant
    public Flux<Transaction> listTransactions(UUID tenantId) {
        log.info("[Payment] Listing transactions for tenant: {}", tenantId);

        return transactionRepository.findByTenantId(tenantId);
    }

    // List transactions for person
    public Flux<Transaction> listPersonTransactions(UUID tenantId, UUID personId) {
        log.info("[Payment] Listing transactions for person: {}", personId);

        return transactionRepository.findByTenantIdAndPersonId(tenantId, personId);
    }

    // Process payment (authorize)
    public Mono<Transaction> authorizePayment(UUID tenantId, UUID transactionId) {
        log.info("[Payment] Authorizing payment: {}", transactionId);

        return transactionRepository.findById(transactionId)
            .filter(transaction -> tenantId.equals(transaction.getTenantId()))
            .flatMap(transaction -> {
                if (!transaction.isPending()) {
                    return Mono.error(new IllegalStateException("Transaction is not in PENDING state"));
                }

                transaction.markAsProcessing();
                // Simulate payment processing
                transaction.markAsAuthorized();

                return transactionRepository.save(transaction);
            });
    }

    // Complete payment
    public Mono<Transaction> completePayment(UUID tenantId, UUID transactionId) {
        log.info("[Payment] Completing payment: {}", transactionId);

        return transactionRepository.findById(transactionId)
            .filter(transaction -> tenantId.equals(transaction.getTenantId()))
            .flatMap(transaction -> {
                if (!transaction.isAuthorized()) {
                    return Mono.error(new IllegalStateException("Transaction is not AUTHORIZED"));
                }

                transaction.markAsCompleted();
                return transactionRepository.save(transaction);
            });
    }

    // Cancel payment
    public Mono<Transaction> cancelPayment(UUID tenantId, UUID transactionId) {
        log.info("[Payment] Cancelling payment: {}", transactionId);

        return transactionRepository.findById(transactionId)
            .filter(transaction -> tenantId.equals(transaction.getTenantId()))
            .flatMap(transaction -> {
                if (transaction.isCompleted()) {
                    return Mono.error(new IllegalStateException("Cannot cancel completed transaction"));
                }

                transaction.markAsCancelled();
                return transactionRepository.save(transaction);
            });
    }

    // Get transaction statistics
    public Mono<TransactionStats> getTransactionStats(UUID tenantId) {
        log.info("[Payment] Getting transaction stats for tenant: {}", tenantId);

        return transactionRepository.findByTenantId(tenantId)
            .collectList()
            .map(transactions -> {
                long total = transactions.size();
                long pending = transactions.stream().filter(Transaction::isPending).count();
                long processing = transactions.stream().filter(Transaction::isProcessing).count();
                long authorized = transactions.stream().filter(Transaction::isAuthorized).count();
                long completed = transactions.stream().filter(Transaction::isCompleted).count();
                long failed = transactions.stream().filter(Transaction::isFailed).count();
                long cancelled = transactions.stream().filter(Transaction::isCancelled).count();

                BigDecimal totalAmount = transactions.stream()
                    .filter(Transaction::isCompleted)
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

                return new TransactionStats(total, pending, processing, authorized, completed, failed, cancelled, totalAmount);
            });
    }

    // DTO for statistics
    public static class TransactionStats {
        private final long total;
        private final long pending;
        private final long processing;
        private final long authorized;
        private final long completed;
        private final long failed;
        private final long cancelled;
        private final BigDecimal totalAmount;

        public TransactionStats(long total, long pending, long processing, long authorized,
                              long completed, long failed, long cancelled, BigDecimal totalAmount) {
            this.total = total;
            this.pending = pending;
            this.processing = processing;
            this.authorized = authorized;
            this.completed = completed;
            this.failed = failed;
            this.cancelled = cancelled;
            this.totalAmount = totalAmount;
        }

        public long getTotal() { return total; }
        public long getPending() { return pending; }
        public long getProcessing() { return processing; }
        public long getAuthorized() { return authorized; }
        public long getCompleted() { return completed; }
        public long getFailed() { return failed; }
        public long getCancelled() { return cancelled; }
        public BigDecimal getTotalAmount() { return totalAmount; }
    }
}