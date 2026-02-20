package com.benefits.employerservice.repository;

import com.benefits.employerservice.entity.CostCenter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CostCenterRepository extends JpaRepository<CostCenter, String> {
    List<CostCenter> findByTenantId(String tenantId);
    List<CostCenter> findByEmployerId(String employerId);
    List<CostCenter> findByEmployerIdAndActiveTrue(String employerId);
    List<CostCenter> findByParentId(String parentId);
}
