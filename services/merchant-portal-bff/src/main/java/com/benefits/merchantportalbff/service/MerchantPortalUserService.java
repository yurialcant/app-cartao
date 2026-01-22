package com.benefits.merchantportalbff.service;

import com.benefits.merchantportalbff.dto.MerchantPortalUserResponse;
import com.benefits.merchantportalbff.entity.MerchantPortalUser;
import com.benefits.merchantportalbff.repository.MerchantPortalUserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;
import java.time.LocalDateTime;

@Service
public class MerchantPortalUserService {
    
    private static final Logger log = LoggerFactory.getLogger(MerchantPortalUserService.class);
    private final MerchantPortalUserRepository repository;
    
    public MerchantPortalUserService(MerchantPortalUserRepository repository) {
        this.repository = repository;
    }
    
    public Flux<MerchantPortalUserResponse> getAll() {
        log.debug("Fetching all MerchantPortalUsers");
        return repository.findAll()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Flux<MerchantPortalUserResponse> getActive() {
        log.debug("Fetching active MerchantPortalUsers");
        return repository.findByActiveTrue()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantPortalUserResponse> getById(String id) {
        log.debug("Fetching MerchantPortalUser with id: {}", id);
        return repository.findById(id)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantPortalUserResponse> getByName(String name) {
        log.debug("Fetching MerchantPortalUser with name: {}", name);
        return repository.findByUsernameIgnoreCase(name)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantPortalUserResponse> create(MerchantPortalUser item) {
        log.info("Creating new MerchantPortalUser: {}", item.getUsername());
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        item.setActive(true);
        
        return repository.save(item)
                .map(this::toResponse)
                .doOnSuccess(saved -> log.info("MerchantPortalUser created: {}", saved.getId()))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantPortalUserResponse> update(String id, MerchantPortalUser update) {
        log.info("Updating MerchantPortalUser: {}", id);
        return repository.findById(id)
                .flatMap(existing -> {
                    if (update.getUsername() != null) existing.setUsername(update.getUsername());
                    if (update.getActive() != null) existing.setActive(update.getActive());
                    existing.setUpdatedAt(LocalDateTime.now());
                    return repository.save(existing);
                })
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<Void> delete(String id) {
        log.info("Deleting MerchantPortalUser: {}", id);
        return repository.deleteById(id)
                .doOnSuccess(v -> log.info("MerchantPortalUser deleted: {}", id))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<Long> countActive() {
        log.debug("Counting active MerchantPortalUsers");
        return repository.countByActiveTrue()
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    private MerchantPortalUserResponse toResponse(MerchantPortalUser item) {
        return MerchantPortalUserResponse.builder()
                .id(item.getId())
                .name(item.getUsername())
                .status(item.getActive() != null && item.getActive() ? "ACTIVE" : "INACTIVE")
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }
}
