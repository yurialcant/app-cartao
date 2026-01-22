package com.benefits.merchantportalbff.repository;

import com.benefits.merchantportalbff.entity.MerchantPortalUser;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface MerchantPortalUserRepository extends R2dbcRepository<MerchantPortalUser, String> {
    
    Flux<MerchantPortalUser> findByActiveTrue();
    
    Mono<MerchantPortalUser> findByUsernameIgnoreCase(String username);
    
    @Query("SELECT * FROM merchantportalusers ORDER BY created_at DESC")
    Flux<MerchantPortalUser> findAllOrderByCreatedAtDesc();
    
    Mono<Long> countByActiveTrue();
}
