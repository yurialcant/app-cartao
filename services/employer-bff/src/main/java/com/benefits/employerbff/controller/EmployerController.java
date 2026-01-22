package com.benefits.employerbff.controller;

import com.benefits.employerbff.dto.EmployerResponse;
import com.benefits.employerbff.entity.Employer;
import com.benefits.employerbff.service.EmployerService;
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
@RequestMapping("/employers")
@Tag(name = "Employers", description = "Employer Management APIs")
public class EmployerController {
    
    private static final Logger log = LoggerFactory.getLogger(EmployerController.class);
    private final EmployerService service;
    
    public EmployerController(EmployerService service) {
        this.service = service;
    }
    
    @GetMapping
    @Operation(summary = "List all Employers")
    public Flux<EmployerResponse> list() {
        log.info("GET /employers");
        return service.getAll();
    }
    
    @GetMapping("/active")
    @Operation(summary = "List active Employers")
    public Flux<EmployerResponse> listActive() {
        log.info("GET /employers/active");
        return service.getActive();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get Employer by ID")
    public Mono<ResponseEntity<EmployerResponse>> getById(@PathVariable String id) {
        log.info("GET /employers/{}", id);
        return service.getById(id)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{name}")
    @Operation(summary = "Get Employer by name")
    public Mono<ResponseEntity<EmployerResponse>> getByName(@PathVariable String name) {
        log.info("GET /employers/name/{}", name);
        return service.getByName(name)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    @Operation(summary = "Create new Employer")
    public Mono<ResponseEntity<EmployerResponse>> create(@RequestBody Employer item) {
        log.info("POST /employers");
        return service.create(item)
                .map(created -> ResponseEntity.status(HttpStatus.CREATED).body(created))
                .onErrorResume(e -> Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()));
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update Employer")
    public Mono<ResponseEntity<EmployerResponse>> update(@PathVariable String id, @RequestBody Employer update) {
        log.info("PUT /employers/{}", id);
        return service.update(id, update)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete Employer")
    public Mono<ResponseEntity<Void>> delete(@PathVariable String id) {
        log.info("DELETE /employers/{}", id);
        return service.delete(id)
                .then(Mono.just(ResponseEntity.noContent().<Void>build()))
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/count/active")
    @Operation(summary = "Count active Employers")
    public Mono<ResponseEntity<Long>> countActive() {
        log.info("GET /employers/count/active");
        return service.countActive()
                .map(ResponseEntity::ok);
    }
}
