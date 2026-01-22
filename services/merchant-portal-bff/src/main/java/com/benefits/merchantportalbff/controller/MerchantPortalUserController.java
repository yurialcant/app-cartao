package com.benefits.merchantportalbff.controller;

import com.benefits.merchantportalbff.dto.MerchantPortalUserResponse;
import com.benefits.merchantportalbff.entity.MerchantPortalUser;
import com.benefits.merchantportalbff.service.MerchantPortalUserService;
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
@RequestMapping("/portal-users")
@Tag(name = "MerchantPortalUsers", description = "MerchantPortalUser Management APIs")
public class MerchantPortalUserController {
    
    private static final Logger log = LoggerFactory.getLogger(MerchantPortalUserController.class);
    private final MerchantPortalUserService service;
    
    public MerchantPortalUserController(MerchantPortalUserService service) {
        this.service = service;
    }
    
    @GetMapping
    @Operation(summary = "List all MerchantPortalUsers")
    public Flux<MerchantPortalUserResponse> list() {
        log.info("GET /portal-users");
        return service.getAll();
    }
    
    @GetMapping("/active")
    @Operation(summary = "List active MerchantPortalUsers")
    public Flux<MerchantPortalUserResponse> listActive() {
        log.info("GET /portal-users/active");
        return service.getActive();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get MerchantPortalUser by ID")
    public Mono<ResponseEntity<MerchantPortalUserResponse>> getById(@PathVariable String id) {
        log.info("GET /portal-users/{}", id);
        return service.getById(id)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{name}")
    @Operation(summary = "Get MerchantPortalUser by name")
    public Mono<ResponseEntity<MerchantPortalUserResponse>> getByName(@PathVariable String name) {
        log.info("GET /portal-users/name/{}", name);
        return service.getByName(name)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    @Operation(summary = "Create new MerchantPortalUser")
    public Mono<ResponseEntity<MerchantPortalUserResponse>> create(@RequestBody MerchantPortalUser item) {
        log.info("POST /portal-users");
        return service.create(item)
                .map(created -> ResponseEntity.status(HttpStatus.CREATED).body(created))
                .onErrorResume(e -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update MerchantPortalUser")
    public Mono<ResponseEntity<MerchantPortalUserResponse>> update(@PathVariable String id, @RequestBody MerchantPortalUser update) {
        log.info("PUT /portal-users/{}", id);
        return service.update(id, update)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete MerchantPortalUser")
    public Mono<ResponseEntity<Void>> delete(@PathVariable String id) {
        log.info("DELETE /portal-users/{}", id);
        return service.delete(id)
                .then(Mono.just(ResponseEntity.noContent().<Void>build()))
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/count/active")
    @Operation(summary = "Count active MerchantPortalUsers")
    public Mono<ResponseEntity<Long>> countActive() {
        log.info("GET /portal-users/count/active");
        return service.countActive()
                .map(ResponseEntity::ok);
    }
}
