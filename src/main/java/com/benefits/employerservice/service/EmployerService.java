package com.benefits.employerservice.service;

import com.benefits.employerservice.entity.Employer;
import com.benefits.employerservice.repository.EmployerRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EmployerService {
    
    private static final Logger log = LoggerFactory.getLogger(EmployerService.class);
    private final EmployerRepository employerRepository;
    
    @Transactional
    public Employer createEmployer(Employer employer) {
        log.info("🔵 [EMPLOYER] Criando employer: {} - Tenant: {}", employer.getName(), employer.getTenantId());
        return employerRepository.save(employer);
    }
    
    public List<Employer> getEmployersByTenant(String tenantId) {
        log.debug("🔵 [EMPLOYER] Buscando employers para tenant: {}", tenantId);
        return employerRepository.findByTenantIdAndActiveTrue(tenantId);
    }
    
    public Employer getEmployerById(String id) {
        log.debug("🔵 [EMPLOYER] Buscando employer por ID: {}", id);
        return employerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employer not found: " + id));
    }
    
    @Transactional
    public Employer updateEmployer(String id, Employer employer) {
        log.info("🔵 [EMPLOYER] Atualizando employer: {}", id);
        Employer existing = employerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employer not found: " + id));
        
        existing.setName(employer.getName());
        existing.setContactEmail(employer.getContactEmail());
        existing.setContactPhone(employer.getContactPhone());
        existing.setActive(employer.getActive());
        
        return employerRepository.save(existing);
    }
}
