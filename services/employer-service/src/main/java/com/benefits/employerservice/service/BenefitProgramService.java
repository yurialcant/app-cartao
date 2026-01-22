package com.benefits.employerservice.service;

import com.benefits.employerservice.entity.BenefitProgram;
import com.benefits.employerservice.repository.BenefitProgramRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BenefitProgramService {
    
    private static final Logger log = LoggerFactory.getLogger(BenefitProgramService.class);
    private final BenefitProgramRepository programRepository;
    
    @Transactional
    public BenefitProgram createProgram(BenefitProgram program) {
        log.info("🔵 [PROGRAM] Criando programa: {} - Employer: {}", program.getName(), program.getEmployerId());
        return programRepository.save(program);
    }
    
    public List<BenefitProgram> getProgramsByEmployer(String employerId) {
        log.debug("🔵 [PROGRAM] Buscando programas para employer: {}", employerId);
        return programRepository.findByEmployerIdAndActiveTrue(employerId);
    }
    
    @Transactional
    public BenefitProgram updateProgram(String id, BenefitProgram program) {
        log.info("🔵 [PROGRAM] Atualizando programa: {}", id);
        BenefitProgram existing = programRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Program not found: " + id));
        
        existing.setName(program.getName());
        existing.setMonthlyLimit(program.getMonthlyLimit());
        existing.setDailyLimit(program.getDailyLimit());
        existing.setTransactionLimit(program.getTransactionLimit());
        existing.setEligibleCategories(program.getEligibleCategories());
        existing.setEligibleLocations(program.getEligibleLocations());
        existing.setActive(program.getActive());
        
        return programRepository.save(existing);
    }
}
