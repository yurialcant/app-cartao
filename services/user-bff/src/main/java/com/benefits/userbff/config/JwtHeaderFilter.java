package com.benefits.userbff.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

@Component
public class JwtHeaderFilter implements WebFilter {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String authHeader = exchange.getRequest().getHeaders().getFirst("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

            try {
                Claims claims = Jwts.parserBuilder()
                    .setSigningKey(jwtSecret.getBytes())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

                // Extract tenant_id and person_id (pid) from JWT
                String tenantId = claims.get("tenant_id", String.class);
                String personId = claims.get("pid", String.class); // person_id canonical

                if (tenantId != null && personId != null) {
                    // Add headers for downstream services
                    ServerWebExchange mutatedExchange = exchange.mutate()
                        .request(exchange.getRequest().mutate()
                            .header("X-Tenant-ID", tenantId)
                            .header("X-Person-ID", personId)
                            .build())
                        .build();

                    return chain.filter(mutatedExchange);
                }
            } catch (Exception e) {
                // Invalid token - continue without headers
                // Could return 401 here if strict validation is needed
            }
        }

        return chain.filter(exchange);
    }
}