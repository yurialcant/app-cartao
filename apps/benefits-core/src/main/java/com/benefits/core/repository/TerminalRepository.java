package com.benefits.core.repository;

import com.benefits.core.entity.Terminal;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Terminal Repository
 *
 * Reactive repository for Terminal entity operations.
 */
@Repository
public interface TerminalRepository extends R2dbcRepository<Terminal, UUID> {

    /**
     * Find terminal by merchant and terminal_id
     */
    Mono<Terminal> findByMerchantIdAndTerminalId(@Param("merchantId") UUID merchantId,
            @Param("terminalId") String terminalId);

    /**
     * Check if terminal exists by merchant and terminal_id
     */
    Mono<Boolean> existsByMerchantIdAndTerminalId(@Param("merchantId") UUID merchantId,
            @Param("terminalId") String terminalId);
}