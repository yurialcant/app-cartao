package com.benefits.merchantbff.repository;

import com.benefits.merchantbff.entity.Merchant;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface MerchantRepository extends R2dbcRepository<Merchant, String> {
    
    Flux<Merchant> findByActiveTrue();
    
    Mono<Merchant> findByNameIgnoreCase(String name);
    
    @Query("SELECT * FROM merchants ORDER BY created_at DESC")
    Flux<Merchant> findAllOrderByCreatedAtDesc();
    
    Mono<Long> countByActiveTrue();
}
