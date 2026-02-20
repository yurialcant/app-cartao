package com.benefits.merchantbff.service;

import com.benefits.merchantbff.dto.MerchantResponse;
import com.benefits.merchantbff.entity.Merchant;
import com.benefits.merchantbff.repository.MerchantRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;
import java.time.LocalDateTime;

@Service
public class MerchantService {
    
    private static final Logger log = LoggerFactory.getLogger(MerchantService.class);
    private final MerchantRepository repository;
    
    public MerchantService(MerchantRepository repository) {
        this.repository = repository;
    }
    
    public Flux<MerchantResponse> getAll() {
        log.debug("Fetching all Merchants");
        return repository.findAll()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Flux<MerchantResponse> getActive() {
        log.debug("Fetching active Merchants");
        return repository.findByActiveTrue()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantResponse> getById(String id) {
        log.debug("Fetching Merchant with id: {}", id);
        return repository.findById(id)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantResponse> getByName(String name) {
        log.debug("Fetching Merchant with name: {}", name);
        return repository.findByNameIgnoreCase(name)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantResponse> create(Merchant item) {
        log.info("Creating new Merchant: {}", item.getName());
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        item.setActive(true);
        
        return repository.save(item)
                .map(this::toResponse)
                .doOnSuccess(saved -> log.info("Merchant created: {}", saved.getId()))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<MerchantResponse> update(String id, Merchant update) {
        log.info("Updating Merchant: {}", id);
        return repository.findById(id)
                .flatMap(existing -> {
                    if (update.getName() != null) existing.setName(update.getName());
                    if (update.getActive() != null) existing.setActive(update.getActive());
                    existing.setUpdatedAt(LocalDateTime.now());
                    return repository.save(existing);
                })
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<Void> delete(String id) {
        log.info("Deleting Merchant: {}", id);
        return repository.deleteById(id)
                .doOnSuccess(v -> log.info("Merchant deleted: {}", id))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<Long> countActive() {
        log.debug("Counting active Merchants");
        return repository.countByActiveTrue()
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    private MerchantResponse toResponse(Merchant item) {
        return MerchantResponse.builder()
                .id(item.getId())
                .name(item.getName())
                .status(item.getActive() != null && item.getActive() ? "ACTIVE" : "INACTIVE")
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }
}
