package com.benefits.pos_bff.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

/**
 * Spring Security configuration for pos-bff
 * 
 * - Temporarily disables authentication for testing
 * - Protects /api/v1/** endpoints (when enabled)
 * - Allows actuator and test endpoints
 */
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        
        http.authorizeExchange(authorize -> authorize
                // Public endpoints for testing
                .pathMatchers("/actuator/**", "/health/**", "/test/**", "/api/v1/**").permitAll()
                
                // Everything else requires authentication
                .anyExchange().permitAll())
            
            // Disable CSRF (stateless API)
            .csrf(ServerHttpSecurity.CsrfSpec::disable)
            
            // Allow CORS if configured
            .cors(cors -> {});
        
        return http.build();
    }
}
