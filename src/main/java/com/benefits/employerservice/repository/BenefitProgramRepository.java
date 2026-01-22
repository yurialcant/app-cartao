package com.benefits.employerservice.repository;

import com.benefits.employerservice.entity.BenefitProgram;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BenefitProgramRepository extends JpaRepository<BenefitProgram, String> {
    List<BenefitProgram> findByTenantId(String tenantId);
    List<BenefitProgram> findByEmployerId(String employerId);
    List<BenefitProgram> findByEmployerIdAndActiveTrue(String employerId);
}
