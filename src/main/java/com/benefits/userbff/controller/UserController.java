package com.benefits.userbff.controller;

import com.benefits.userbff.dto.UserResponse;
import com.benefits.userbff.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/users")
@Tag(name = "Users", description = "User Management APIs")
public class UserController {
    
    private static final Logger log = LoggerFactory.getLogger(UserController.class);
    private final UserService service;
    
    public UserController(UserService service) {
        this.service = service;
    }
    
    @GetMapping
    @Operation(summary = "List all Users")
    public Flux<UserResponse> list() {
        log.info("GET /users");
        return service.getAll();
    }
    
    @GetMapping("/active")
    @Operation(summary = "List active Users")
    public Flux<UserResponse> listActive() {
        log.info("GET /users/active");
        return service.getActive();
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get User by ID")
    public Mono<ResponseEntity<UserResponse>> getById(@PathVariable String id) {
        log.info("GET /users/{}", id);
        return service.getById(id)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{name}")
    @Operation(summary = "Get User by name")
    public Mono<ResponseEntity<UserResponse>> getByName(@PathVariable String name) {
        log.info("GET /users/name/{}", name);
        return service.getByUsername(name)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
}
