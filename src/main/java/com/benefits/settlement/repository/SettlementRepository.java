package com.benefits.settlement.repository;

import com.benefits.settlement.entity.Settlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, UUID> {

    // Find settlements by tenant
    List<Settlement> findByTenantId(UUID tenantId);

    // Find settlement by tenant and settlement ID
    Optional<Settlement> findByTenantIdAndSettlementId(UUID tenantId, String settlementId);

    // Find settlements by merchant
    List<Settlement> findByMerchantId(UUID merchantId);

    // Find settlements by status
    List<Settlement> findByTenantIdAndStatus(UUID tenantId, String status);

    // Check if settlement exists by settlement ID
    boolean existsBySettlementId(String settlementId);
}