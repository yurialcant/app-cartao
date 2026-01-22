package com.benefits.merchantbff.controller;

import com.benefits.merchantbff.dto.MerchantResponse;
import com.benefits.merchantbff.entity.Merchant;
import com.benefits.merchantbff.service.MerchantService;
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
@RequestMapping("/merchants")
@Tag(name = "Merchants", description = "Merchant Management APIs")
public class MerchantController {
    
    private static final Logger log = LoggerFactory.getLogger(MerchantController.class);
    private final MerchantService service;
    
    public MerchantController(MerchantService service) {
        this.service = service;
    }
    
    @GetMapping
    @Operation(summary = "List all Merchants")
    public Flux<MerchantResponse> list() {
        log.info("GET /merchants");
        return service.getAll();
    }
    
    @GetMapping("/active")
    @Operation(summary = "List active Merchants")
    public Flux<MerchantResponse> listActive() {
        log.info("GET /merchants/active");
        return service.getActive();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get Merchant by ID")
    public Mono<ResponseEntity<MerchantResponse>> getById(@PathVariable String id) {
        log.info("GET /merchants/{}", id);
        return service.getById(id)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{name}")
    @Operation(summary = "Get Merchant by name")
    public Mono<ResponseEntity<MerchantResponse>> getByName(@PathVariable String name) {
        log.info("GET /merchants/name/{}", name);
        return service.getByName(name)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    @Operation(summary = "Create new Merchant")
    public Mono<ResponseEntity<MerchantResponse>> create(@RequestBody Merchant item) {
        log.info("POST /merchants");
        return service.create(item)
                .map(created -> ResponseEntity.status(HttpStatus.CREATED).body(created))
                .onErrorResume(e -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update Merchant")
    public Mono<ResponseEntity<MerchantResponse>> update(@PathVariable String id, @RequestBody Merchant update) {
        log.info("PUT /merchants/{}", id);
        return service.update(id, update)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete Merchant")
    public Mono<ResponseEntity<Void>> delete(@PathVariable String id) {
        log.info("DELETE /merchants/{}", id);
        return service.delete(id)
                .then(Mono.just(ResponseEntity.noContent().<Void>build()))
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/count/active")
    @Operation(summary = "Count active Merchants")
    public Mono<ResponseEntity<Long>> countActive() {
        log.info("GET /merchants/count/active");
        return service.countActive()
                .map(ResponseEntity::ok);
    }
}
