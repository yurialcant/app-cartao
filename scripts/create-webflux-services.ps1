#!/usr/bin/env powershell
# Create Services, Controllers e DTOs para os 4 BFFs

$bffs = @(
    @{name="employer-bff"; pkg="employerbff"; entity="Employer"; response="EmployerResponse"; endpoint="employers"},
    @{name="merchant-bff"; pkg="merchantbff"; entity="Merchant"; response="MerchantResponse"; endpoint="merchants"},
    @{name="user-bff"; pkg="userbff"; entity="User"; response="UserResponse"; endpoint="users"},
    @{name="merchant-portal-bff"; pkg="merchantportalbff"; entity="MerchantPortalUser"; response="MerchantPortalUserResponse"; endpoint="portal-users"}
)

$basePath = "c:\Users\gesch\Documents\projeto-lucas\services"

# Generate Service code
foreach ($bff in $bffs) {
    $servicePath = "$basePath\$($bff.name)\src\main\java\com\benefits\$($bff.pkg)\service\$($bff.entity)Service.java"
    mkdir -Force (Split-Path $servicePath) -ErrorAction SilentlyContinue | Out-Null
    
    $code = @"
package com.benefits.$($bff.pkg).service;

import com.benefits.$($bff.pkg).dto.$($bff.response);
import com.benefits.$($bff.pkg).entity.$($bff.entity);
import com.benefits.$($bff.pkg).repository.$($bff.entity)Repository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;
import java.time.LocalDateTime;

@Service
public class $($bff.entity)Service {
    
    private static final Logger log = LoggerFactory.getLogger($($bff.entity)Service.class);
    private final $($bff.entity)Repository repository;
    
    public $($bff.entity)Service($($bff.entity)Repository repository) {
        this.repository = repository;
    }
    
    public Flux<$($bff.response)> getAll() {
        log.debug("Fetching all $($bff.entity)s");
        return repository.findAll()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Flux<$($bff.response)> getActive() {
        log.debug("Fetching active $($bff.entity)s");
        return repository.findByActiveTrue()
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<$($bff.response)> getById(String id) {
        log.debug("Fetching $($bff.entity) with id: {}", id);
        return repository.findById(id)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<$($bff.response)> getByName(String name) {
        log.debug("Fetching $($bff.entity) with name: {}", name);
        return repository.findByNameIgnoreCase(name)
                .map(this::toResponse)
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<$($bff.response)> create($($bff.entity) item) {
        log.info("Creating new $($bff.entity): {}", item.getName());
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        item.setActive(true);
        
        return repository.save(item)
                .map(this::toResponse)
                .doOnSuccess(saved -> log.info("$($bff.entity) created: {}", saved.getId()))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<$($bff.response)> update(String id, $($bff.entity) update) {
        log.info("Updating $($bff.entity): {}", id);
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
        log.info("Deleting $($bff.entity): {}", id);
        return repository.deleteById(id)
                .doOnSuccess(v -> log.info("$($bff.entity) deleted: {}", id))
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    public Mono<Long> countActive() {
        log.debug("Counting active $($bff.entity)s");
        return repository.countByActiveTrue()
                .subscribeOn(Schedulers.boundedElastic());
    }
    
    private $($bff.response) toResponse($($bff.entity) item) {
        return $($bff.response).builder()
                .id(item.getId())
                .name(item.getName())
                .status(item.getActive() != null && item.getActive() ? "ACTIVE" : "INACTIVE")
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }
}
"@
    
    $code | Out-File $servicePath -Encoding UTF8 -Force
    Write-Host "✅ $($bff.name): $($bff.entity)Service created"
}

# Generate DTO Response code
foreach ($bff in $bffs) {
    $dtoPath = "$basePath\$($bff.name)\src\main\java\com\benefits\$($bff.pkg)\dto\$($bff.response).java"
    mkdir -Force (Split-Path $dtoPath) -ErrorAction SilentlyContinue | Out-Null
    
    $code = @"
package com.benefits.$($bff.pkg).dto;

import java.time.LocalDateTime;

public class $($bff.response) {
    private String id;
    private String name;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public $($bff.response)() {}
    
    public $($bff.response)(String id, String name, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.name = name;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    public static $($bff.response)Builder builder() {
        return new $($bff.response)Builder();
    }
    
    public static class $($bff.response)Builder {
        private String id;
        private String name;
        private String status;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        
        public $($bff.response)Builder id(String id) { this.id = id; return this; }
        public $($bff.response)Builder name(String name) { this.name = name; return this; }
        public $($bff.response)Builder status(String status) { this.status = status; return this; }
        public $($bff.response)Builder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public $($bff.response)Builder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        
        public $($bff.response) build() {
            return new $($bff.response)(id, name, status, createdAt, updatedAt);
        }
    }
    
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
"@
    
    $code | Out-File $dtoPath -Encoding UTF8 -Force
    Write-Host "✅ $($bff.name): $($bff.response) DTO created"
}

# Generate Controller code
foreach ($bff in $bffs) {
    $controllerPath = "$basePath\$($bff.name)\src\main\java\com\benefits\$($bff.pkg)\controller\$($bff.entity)Controller.java"
    mkdir -Force (Split-Path $controllerPath) -ErrorAction SilentlyContinue | Out-Null
    
    $code = @"
package com.benefits.$($bff.pkg).controller;

import com.benefits.$($bff.pkg).dto.$($bff.response);
import com.benefits.$($bff.pkg).entity.$($bff.entity);
import com.benefits.$($bff.pkg).service.$($bff.entity)Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/$($bff.endpoint)")
@Tag(name = "$($bff.entity)s", description = "$($bff.entity) Management APIs")
public class $($bff.entity)Controller {
    
    private static final Logger log = LoggerFactory.getLogger($($bff.entity)Controller.class);
    private final $($bff.entity)Service service;
    
    public $($bff.entity)Controller($($bff.entity)Service service) {
        this.service = service;
    }
    
    @GetMapping
    @Operation(summary = "List all $($bff.entity)s")
    public Flux<$($bff.response)> list() {
        log.info("GET /$($bff.endpoint)");
        return service.getAll();
    }
    
    @GetMapping("/active")
    @Operation(summary = "List active $($bff.entity)s")
    public Flux<$($bff.response)> listActive() {
        log.info("GET /$($bff.endpoint)/active");
        return service.getActive();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get $($bff.entity) by ID")
    public Mono<ResponseEntity<$($bff.response)>> getById(@PathVariable String id) {
        log.info("GET /$($bff.endpoint)/{}", id);
        return service.getById(id)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{name}")
    @Operation(summary = "Get $($bff.entity) by name")
    public Mono<ResponseEntity<$($bff.response)>> getByName(@PathVariable String name) {
        log.info("GET /$($bff.endpoint)/name/{}", name);
        return service.getByName(name)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    @Operation(summary = "Create new $($bff.entity)")
    public Mono<ResponseEntity<$($bff.response)>> create(@RequestBody $($bff.entity) item) {
        log.info("POST /$($bff.endpoint)");
        return service.create(item)
                .map(created -> ResponseEntity.status(HttpStatus.CREATED).body(created))
                .onErrorResume(e -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update $($bff.entity)")
    public Mono<ResponseEntity<$($bff.response)>> update(@PathVariable String id, @RequestBody $($bff.entity) update) {
        log.info("PUT /$($bff.endpoint)/{}", id);
        return service.update(id, update)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete $($bff.entity)")
    public Mono<ResponseEntity<Void>> delete(@PathVariable String id) {
        log.info("DELETE /$($bff.endpoint)/{}", id);
        return service.delete(id)
                .then(Mono.just(ResponseEntity.noContent().<Void>build()))
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/count/active")
    @Operation(summary = "Count active $($bff.entity)s")
    public Mono<ResponseEntity<Long>> countActive() {
        log.info("GET /$($bff.endpoint)/count/active");
        return service.countActive()
                .map(ResponseEntity::ok);
    }
}
"@
    
    $code | Out-File $controllerPath -Encoding UTF8 -Force
    Write-Host "✅ $($bff.name): $($bff.entity)Controller created"
}

Write-Host "`n✅ ALL Services, DTOs, and Controllers generated for 4 BFFs!"
