package com.benefits.employerbff.service;

import com.benefits.employerbff.dto.EmployerResponse;
import com.benefits.employerbff.entity.Employer;
import com.benefits.employerbff.repository.EmployerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;
import java.time.LocalDateTime;

@Service
public class EmployerService {
    
    private static final Logger log = LoggerFactory.getLogger(EmployerService.class);
    private final EmployerRepository repository;
    
    public EmployerService(EmployerRepository repository) {
        this.repository = repository;
    }
    
    public Flux<EmployerResponse> getAll() {
        log.debug("Fetching all Employers");
        return repository.findAll()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Flux<EmployerResponse> getActive() {
        log.debug("Fetching active Employers");
        return repository.findByActiveTrue()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<EmployerResponse> getById(String id) {
        log.debug("Fetching Employer with id: {}", id);
        return repository.findById(id)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<EmployerResponse> getByName(String name) {
        log.debug("Fetching Employer with name: {}", name);
        return repository.findByNameIgnoreCase(name)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<EmployerResponse> create(Employer item) {
        log.info("Creating new Employer: {}", item.getName());
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        item.setActive(true);
        
        return repository.save(item)
                .map(this::toResponse)
                .doOnSuccess(saved -> log.info("Employer created: {}", saved.getId()))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<EmployerResponse> update(String id, Employer update) {
        log.info("Updating Employer: {}", id);
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
        log.info("Deleting Employer: {}", id);
        return repository.deleteById(id)
                .doOnSuccess(v -> log.info("Employer deleted: {}", id))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<Long> countActive() {
        log.debug("Counting active Employers");
        return repository.countByActiveTrue()
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    private EmployerResponse toResponse(Employer item) {
        return EmployerResponse.builder()
                .id(item.getId())
                .name(item.getName())
                .status(item.getActive() != null && item.getActive() ? "ACTIVE" : "INACTIVE")
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }
}
