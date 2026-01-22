package com.benefits.userbff.service;

import com.benefits.userbff.client.CoreServiceClient;
import com.benefits.userbff.dto.UserResponse;
import com.benefits.userbff.dto.WalletSummaryDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class UserService {
    
    private static final Logger log = LoggerFactory.getLogger(UserService.class);
    private final CoreServiceClient coreServiceClient;
    
    public UserService(CoreServiceClient coreServiceClient) {
        this.coreServiceClient = coreServiceClient;
    }
    
    public Flux<UserResponse> getAll() {
        log.debug("Fetching all Users from benefits-core");
        return coreServiceClient.getAllUsers("default"); // TODO: get tenant from context
    }
    
    public Flux<UserResponse> getActive() {
        log.debug("Fetching active Users from benefits-core");
        return coreServiceClient.getAllUsers("default")
                .filter(user -> "ACTIVE".equals(user.getStatus()));
    }
    
    public Mono<UserResponse> getById(String id) {
        log.debug("Fetching User with id: {} from benefits-core", id);
        return coreServiceClient.getUserById(id, "default");
    }
    
    public Mono<UserResponse> getByUsername(String username) {
        log.debug("Fetching User with username: {} from benefits-core", username);
        return coreServiceClient.getAllUsers("default")
                .filter(user -> username.equals(user.getUsername()))
                .next();
    }
    
    public Mono<WalletSummaryDto> getWalletSummary(String userId) {
        log.debug("Fetching wallet summary for user: {} from benefits-core", userId);
        return coreServiceClient.getWalletSummary(userId, "default");
    }
}
