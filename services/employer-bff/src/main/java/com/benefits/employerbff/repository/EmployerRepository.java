package com.benefits.employerbff.repository;

import com.benefits.employerbff.entity.Employer;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface EmployerRepository extends R2dbcRepository<Employer, String> {
    
    Flux<Employer> findByActiveTrue();
    
    Mono<Employer> findByNameIgnoreCase(String name);
    
    @Query("SELECT * FROM employers ORDER BY created_at DESC")
    Flux<Employer> findAllOrderByCreatedAtDesc();
    
    Mono<Long> countByActiveTrue();
}
