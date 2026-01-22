package com.benefits.tenant.service;

import com.benefits.tenant.entity.*;
import com.benefits.tenant.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * TenantService - SSOT para white-label e configurações
 * Implementa regras de negócio do tenant-service conforme especificação
 */
@Service
public class TenantService {

    private static final Logger log = LoggerFactory.getLogger(TenantService.class);

    private final TenantRepository tenantRepository;
    private final EmployerRepository employerRepository;
    private final ContractRepository contractRepository;
    private final PlanRepository planRepository;
    private final BrandingRepository brandingRepository;
    private final UICompositionRepository uiCompositionRepository;
    private final WalletDefinitionRepository walletDefinitionRepository;
    private final PolicyRepository policyRepository;

    // Regex patterns for validation
    private static final Pattern SLUG_PATTERN = Pattern.compile("^[a-z0-9-]{3,32}$");

    public TenantService(
            TenantRepository tenantRepository,
            EmployerRepository employerRepository,
            ContractRepository contractRepository,
            PlanRepository planRepository,
            BrandingRepository brandingRepository,
            UICompositionRepository uiCompositionRepository,
            WalletDefinitionRepository walletDefinitionRepository,
            PolicyRepository policyRepository) {
        this.tenantRepository = tenantRepository;
        this.employerRepository = employerRepository;
        this.contractRepository = contractRepository;
        this.planRepository = planRepository;
        this.brandingRepository = brandingRepository;
        this.uiCompositionRepository = uiCompositionRepository;
        this.walletDefinitionRepository = walletDefinitionRepository;
        this.policyRepository = policyRepository;
    }

    // ============================================
    // TENANT MANAGEMENT
    // ============================================

    /**
     * Create tenant with validation
     */
    public Mono<Tenant> createTenant(String slug, String name, String description, UUID ownerPersonId) {
        log.info("[Tenant] Creating tenant: {}", slug);

        return validateTenantSlug(slug)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.error(new IllegalArgumentException("Invalid tenant slug"));
                }
                return tenantRepository.existsBySlug(slug);
            })
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Tenant slug already exists"));
                }
                Tenant tenant = new Tenant(slug, name, description, ownerPersonId);
                return tenantRepository.save(tenant);
            });
    }

    /**
     * Get tenant catalog (branding + modules + ui + policies)
     */
    public Mono<TenantCatalog> getTenantCatalog(UUID tenantId) {
        log.info("[Tenant] Getting catalog for tenant: {}", tenantId);

        return Mono.zip(
            brandingRepository.findByTenantIdAndStatus(tenantId, "ACTIVE").switchIfEmpty(Mono.empty()),
            uiCompositionRepository.findByTenantIdAndStatus(tenantId, "ACTIVE").switchIfEmpty(Mono.empty()),
            policyRepository.findByTenantIdAndStatusOrderByPriorityDesc(tenantId, "ACTIVE").collectList(),
            walletDefinitionRepository.findByTenantIdAndStatus(tenantId, "ACTIVE").collectList()
        ).map(tuple -> {
            TenantCatalog catalog = new TenantCatalog();
            catalog.setBranding(tuple.getT1());
            catalog.setUiComposition(tuple.getT2());
            catalog.setPolicies(tuple.getT3());
            catalog.setWalletDefinitions(tuple.getT4());
            return catalog;
        });
    }

    // ============================================
    // EMPLOYER MANAGEMENT
    // ============================================

    /**
     * Create employer with validation
     */
    public Mono<Employer> createEmployer(UUID tenantId, String employerCode, String companyName,
                                       String documentNumber, String email) {
        log.info("[Tenant] Creating employer: {} for tenant: {}", employerCode, tenantId);

        return validateEmployerCode(employerCode)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.error(new IllegalArgumentException("Invalid employer code"));
                }
                return employerRepository.existsByTenantIdAndEmployerCode(tenantId, employerCode);
            })
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Employer code already exists"));
                }
                Employer employer = new Employer(tenantId, employerCode, companyName, documentNumber, email);
                return employerRepository.save(employer);
            });
    }

    // ============================================
    // CONTRACT MANAGEMENT
    // ============================================

    /**
     * Create contract with validation
     */
    public Mono<Contract> createContract(UUID tenantId, UUID employerId, String planCode,
                                       java.time.LocalDate startDate, java.time.LocalDate endDate) {
        log.info("[Tenant] Creating contract for employer: {} with plan: {}", employerId, planCode);

        return validateContractDates(startDate, endDate)
            .flatMap(valid -> {
                if (!valid) {
                    return Mono.error(new IllegalArgumentException("Invalid contract dates"));
                }
                // Check if employer exists and is active
                return employerRepository.findById(employerId);
            })
            .flatMap(employer -> {
                if (employer == null || !employer.isActive()) {
                    return Mono.error(new IllegalArgumentException("Employer not found or inactive"));
                }
                // Check if plan exists
                return planRepository.findByTenantIdAndPlanCodeAndStatus(tenantId, planCode, "ACTIVE");
            })
            .flatMap(plan -> {
                if (plan == null) {
                    return Mono.error(new IllegalArgumentException("Plan not found or inactive"));
                }
                Contract contract = new Contract(tenantId, employerId, planCode, startDate, endDate);
                return contractRepository.save(contract);
            });
    }

    // ============================================
    // UI COMPOSITION MANAGEMENT
    // ============================================

    /**
     * Publish UI composition with validation
     */
    public Mono<UIComposition> publishUIComposition(UUID tenantId, UUID compositionId) {
        log.info("[Tenant] Publishing UI composition: {} for tenant: {}", compositionId, tenantId);

        return uiCompositionRepository.findById(compositionId)
            .flatMap(composition -> {
                if (!tenantId.equals(composition.getTenantId())) {
                    return Mono.error(new IllegalArgumentException("Composition not found"));
                }

                // Validate JSON schema (simplified)
                if (isValidHomeJson(composition.getHomeJson())) {
                    composition.publish();
                    return uiCompositionRepository.save(composition);
                } else {
                    composition.markAsFailed("Invalid JSON schema");
                    return uiCompositionRepository.save(composition)
                        .flatMap(saved -> Mono.error(new IllegalArgumentException("Invalid JSON schema")));
                }
            });
    }

    // ============================================
    // VALIDATION METHODS
    // ============================================

    /**
     * Validate tenant slug format
     */
    private Mono<Boolean> validateTenantSlug(String slug) {
        return Mono.fromCallable(() -> SLUG_PATTERN.matcher(slug).matches());
    }

    /**
     * Validate employer code
     */
    private Mono<Boolean> validateEmployerCode(String code) {
        return Mono.fromCallable(() -> code != null && code.length() >= 3 && code.length() <= 20);
    }

    /**
     * Validate contract dates
     */
    private Mono<Boolean> validateContractDates(java.time.LocalDate start, java.time.LocalDate end) {
        return Mono.fromCallable(() -> {
            if (start == null) return false;
            if (end != null && end.isBefore(start)) return false;
            return true;
        });
    }

    /**
     * Validate home JSON (simplified)
     */
    private boolean isValidHomeJson(String json) {
        if (json == null || json.trim().isEmpty()) return false;
        // Simplified validation - in real implementation would use JSON Schema
        return json.contains("blocks") || json.contains("components");
    }

    // ============================================
    // DTOs
    // ============================================

    /**
     * Tenant Catalog DTO - resposta completa do /catalog
     */
    public static class TenantCatalog {
        private Branding branding;
        private UIComposition uiComposition;
        private List<Policy> policies;
        private List<WalletDefinition> walletDefinitions;

        // Getters and setters
        public Branding getBranding() { return branding; }
        public void setBranding(Branding branding) { this.branding = branding; }

        public UIComposition getUiComposition() { return uiComposition; }
        public void setUiComposition(UIComposition uiComposition) { this.uiComposition = uiComposition; }

        public List<Policy> getPolicies() { return policies; }
        public void setPolicies(List<Policy> policies) { this.policies = policies; }

        public List<WalletDefinition> getWalletDefinitions() { return walletDefinitions; }
        public void setWalletDefinitions(List<WalletDefinition> walletDefinitions) { this.walletDefinitions = walletDefinitions; }
    }
}