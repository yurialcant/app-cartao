package com.benefits.merchant.service;

import com.benefits.merchant.entity.Merchant;
import com.benefits.merchant.entity.Terminal;
import com.benefits.merchant.repository.MerchantRepository;
import com.benefits.merchant.repository.TerminalRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Service
public class MerchantService {

    private static final Logger log = LoggerFactory.getLogger(MerchantService.class);

    private final MerchantRepository merchantRepository;
    private final TerminalRepository terminalRepository;

    public MerchantService(MerchantRepository merchantRepository, TerminalRepository terminalRepository) {
        this.merchantRepository = merchantRepository;
        this.terminalRepository = terminalRepository;
    }

    // ===============================
    // MERCHANT OPERATIONS
    // ===============================

    // Create merchant
    public Mono<Merchant> createMerchant(UUID tenantId, String merchantId, String name, String businessName, String document) {
        log.info("[Merchant] Creating merchant: {} for tenant: {}", merchantId, tenantId);

        return merchantRepository.existsByTenantIdAndMerchantId(tenantId, merchantId)
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Merchant ID already exists"));
                }

                Merchant merchant = new Merchant(tenantId, merchantId, name);
                merchant.setBusinessName(businessName);
                merchant.setDocument(document);
                return merchantRepository.save(merchant);
            });
    }

    // Get merchant by ID
    public Mono<Merchant> getMerchant(UUID tenantId, UUID merchantId) {
        log.info("[Merchant] Getting merchant: {} for tenant: {}", merchantId, tenantId);

        return merchantRepository.findById(merchantId)
            .filter(merchant -> tenantId.equals(merchant.getTenantId()));
    }

    // Get merchant by merchant ID
    public Mono<Merchant> getMerchantByMerchantId(UUID tenantId, String merchantId) {
        log.info("[Merchant] Getting merchant by ID: {} for tenant: {}", merchantId, tenantId);

        return merchantRepository.findByTenantIdAndMerchantId(tenantId, merchantId);
    }

    // List merchants
    public Flux<Merchant> listMerchants(UUID tenantId) {
        log.info("[Merchant] Listing merchants for tenant: {}", tenantId);

        return merchantRepository.findByTenantId(tenantId);
    }

    // Update merchant
    public Mono<Merchant> updateMerchant(UUID tenantId, UUID merchantId, Merchant updates) {
        log.info("[Merchant] Updating merchant: {} for tenant: {}", merchantId, tenantId);

        return merchantRepository.findById(merchantId)
            .filter(merchant -> tenantId.equals(merchant.getTenantId()))
            .flatMap(merchant -> {
                if (updates.getName() != null) merchant.setName(updates.getName());
                if (updates.getBusinessName() != null) merchant.setBusinessName(updates.getBusinessName());
                if (updates.getDocument() != null) merchant.setDocument(updates.getDocument());
                if (updates.getEmail() != null) merchant.setEmail(updates.getEmail());
                if (updates.getPhone() != null) merchant.setPhone(updates.getPhone());
                if (updates.getCategory() != null) merchant.setCategory(updates.getCategory());
                if (updates.getMccCode() != null) merchant.setMccCode(updates.getMccCode());
                if (updates.getRiskLevel() != null) merchant.setRiskLevel(updates.getRiskLevel());

                return merchantRepository.save(merchant);
            });
    }

    // Update merchant status
    public Mono<Merchant> updateMerchantStatus(UUID tenantId, UUID merchantId, String status) {
        log.info("[Merchant] Updating merchant status: {} for merchant: {}", status, merchantId);

        return merchantRepository.findById(merchantId)
            .filter(merchant -> tenantId.equals(merchant.getTenantId()))
            .flatMap(merchant -> {
                merchant.setStatus(status);
                return merchantRepository.save(merchant);
            });
    }

    // ===============================
    // TERMINAL OPERATIONS
    // ===============================

    // Create terminal
    public Mono<Terminal> createTerminal(UUID tenantId, UUID merchantId, String terminalId,
                                       String locationName, String locationAddress) {
        log.info("[Merchant] Creating terminal: {} for merchant: {}", terminalId, merchantId);

        return terminalRepository.existsByTenantIdAndTerminalId(tenantId, terminalId)
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Terminal ID already exists"));
                }

                Terminal terminal = new Terminal(tenantId, merchantId, terminalId, locationName);
                terminal.setLocationAddress(locationAddress);
                return terminalRepository.save(terminal);
            });
    }

    // Get terminal by ID
    public Mono<Terminal> getTerminal(UUID tenantId, UUID terminalId) {
        log.info("[Merchant] Getting terminal: {} for tenant: {}", terminalId, tenantId);

        return terminalRepository.findById(terminalId)
            .filter(terminal -> tenantId.equals(terminal.getTenantId()));
    }

    // Get terminal by terminal ID
    public Mono<Terminal> getTerminalByTerminalId(UUID tenantId, String terminalId) {
        log.info("[Merchant] Getting terminal by ID: {} for tenant: {}", terminalId, tenantId);

        return terminalRepository.findByTenantIdAndTerminalId(tenantId, terminalId);
    }

    // List terminals for merchant
    public Flux<Terminal> listMerchantTerminals(UUID tenantId, UUID merchantId) {
        log.info("[Merchant] Listing terminals for merchant: {}", merchantId);

        return terminalRepository.findByTenantIdAndMerchantId(tenantId, merchantId);
    }

    // List all terminals for tenant
    public Flux<Terminal> listTerminals(UUID tenantId) {
        log.info("[Merchant] Listing all terminals for tenant: {}", tenantId);

        return terminalRepository.findByTenantId(tenantId);
    }

    // Update terminal
    public Mono<Terminal> updateTerminal(UUID tenantId, UUID terminalId, Terminal updates) {
        log.info("[Merchant] Updating terminal: {} for tenant: {}", terminalId, tenantId);

        return terminalRepository.findById(terminalId)
            .filter(terminal -> tenantId.equals(terminal.getTenantId()))
            .flatMap(terminal -> {
                if (updates.getModel() != null) terminal.setModel(updates.getModel());
                if (updates.getSerialNumber() != null) terminal.setSerialNumber(updates.getSerialNumber());
                if (updates.getFirmwareVersion() != null) terminal.setFirmwareVersion(updates.getFirmwareVersion());
                if (updates.getLocationName() != null) terminal.setLocationName(updates.getLocationName());
                if (updates.getLocationAddress() != null) terminal.setLocationAddress(updates.getLocationAddress());
                if (updates.getCapabilities() != null) terminal.setCapabilities(updates.getCapabilities());

                return terminalRepository.save(terminal);
            });
    }

    // Update terminal status
    public Mono<Terminal> updateTerminalStatus(UUID tenantId, UUID terminalId, String status) {
        log.info("[Merchant] Updating terminal status: {} for terminal: {}", status, terminalId);

        return terminalRepository.findById(terminalId)
            .filter(terminal -> tenantId.equals(terminal.getTenantId()))
            .flatMap(terminal -> {
                terminal.setStatus(status);
                return terminalRepository.save(terminal);
            });
    }

    // Record terminal ping
    public Mono<Terminal> recordTerminalPing(UUID tenantId, String terminalId) {
        log.debug("[Merchant] Recording ping for terminal: {}", terminalId);

        return terminalRepository.findByTenantIdAndTerminalId(tenantId, terminalId)
            .flatMap(terminal -> {
                terminal.recordPing();
                return terminalRepository.save(terminal);
            });
    }

    // Record terminal transaction
    public Mono<Terminal> recordTerminalTransaction(UUID tenantId, String terminalId) {
        log.debug("[Merchant] Recording transaction for terminal: {}", terminalId);

        return terminalRepository.findByTenantIdAndTerminalId(tenantId, terminalId)
            .flatMap(terminal -> {
                terminal.recordTransaction();
                return terminalRepository.save(terminal);
            });
    }

    // Get terminal statistics
    public Mono<TerminalStats> getTerminalStats(UUID tenantId) {
        log.info("[Merchant] Getting terminal stats for tenant: {}", tenantId);

        return terminalRepository.findByTenantId(tenantId)
            .collectList()
            .map(terminals -> {
                long total = terminals.size();
                long active = terminals.stream().filter(Terminal::isActive).count();
                long inactive = terminals.stream().filter(Terminal::isInactive).count();
                long maintenance = terminals.stream().filter(Terminal::isMaintenance).count();
                long decommissioned = terminals.stream().filter(Terminal::isDecommissioned).count();
                long online = terminals.stream().filter(Terminal::isOnline).count();

                return new TerminalStats(total, active, inactive, maintenance, decommissioned, online);
            });
    }

    // DTO for statistics
    public static class TerminalStats {
        private final long total;
        private final long active;
        private final long inactive;
        private final long maintenance;
        private final long decommissioned;
        private final long online;

        public TerminalStats(long total, long active, long inactive, long maintenance, long decommissioned, long online) {
            this.total = total;
            this.active = active;
            this.inactive = inactive;
            this.maintenance = maintenance;
            this.decommissioned = decommissioned;
            this.online = online;
        }

        public long getTotal() { return total; }
        public long getActive() { return active; }
        public long getInactive() { return inactive; }
        public long getMaintenance() { return maintenance; }
        public long getDecommissioned() { return decommissioned; }
        public long getOnline() { return online; }
    }
}