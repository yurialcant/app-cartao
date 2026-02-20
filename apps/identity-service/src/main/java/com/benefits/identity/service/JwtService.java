package com.benefits.identity.service;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class JwtService {

    private static final Logger log = LoggerFactory.getLogger(JwtService.class);

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.expiration}")
    private long jwtExpiration;

    @Value("${jwt.refresh-expiration}")
    private long refreshExpiration;

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secretKey.getBytes());
    }

    // Generate JWT token with person_id (pid) claim
    public String generateToken(UUID personId, String email, String tenantId, String roles) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("pid", personId.toString()); // Person ID claim (pid)
        claims.put("email", email);
        claims.put("tenant_id", tenantId);
        claims.put("roles", roles);

        return createToken(claims, personId.toString(), jwtExpiration);
    }

    // Generate refresh token
    public String generateRefreshToken(UUID personId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("pid", personId.toString());

        return createToken(claims, personId.toString(), refreshExpiration);
    }

    private String createToken(Map<String, Object> claims, String subject, long expiration) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // Extract person ID from token
    public UUID extractPersonId(String token) {
        try {
            Claims claims = extractAllClaims(token);
            String pid = claims.get("pid", String.class);
            return pid != null ? UUID.fromString(pid) : null;
        } catch (Exception e) {
            log.error("Error extracting person ID from token", e);
            return null;
        }
    }

    // Extract email from token
    public String extractEmail(String token) {
        try {
            Claims claims = extractAllClaims(token);
            return claims.get("email", String.class);
        } catch (Exception e) {
            log.error("Error extracting email from token", e);
            return null;
        }
    }

    // Extract tenant ID from token
    public String extractTenantId(String token) {
        try {
            Claims claims = extractAllClaims(token);
            return claims.get("tenant_id", String.class);
        } catch (Exception e) {
            log.error("Error extracting tenant ID from token", e);
            return null;
        }
    }

    // Extract roles from token
    public String extractRoles(String token) {
        try {
            Claims claims = extractAllClaims(token);
            return claims.get("roles", String.class);
        } catch (Exception e) {
            log.error("Error extracting roles from token", e);
            return null;
        }
    }

    // Extract expiration date
    public Date extractExpiration(String token) {
        return extractAllClaims(token).getExpiration();
    }

    // Extract all claims
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // Check if token is expired
    public Boolean isTokenExpired(String token) {
        try {
            return extractExpiration(token).before(new Date());
        } catch (Exception e) {
            log.error("Error checking token expiration", e);
            return true;
        }
    }

    // Validate token
    public Boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return !isTokenExpired(token);
        } catch (Exception e) {
            log.error("Token validation failed", e);
            return false;
        }
    }

    // Refresh token
    public String refreshToken(String token) {
        try {
            if (!validateToken(token)) {
                throw new IllegalArgumentException("Invalid token");
            }

            UUID personId = extractPersonId(token);
            String email = extractEmail(token);
            String tenantId = extractTenantId(token);
            String roles = extractRoles(token);

            return generateToken(personId, email, tenantId, roles);
        } catch (Exception e) {
            log.error("Error refreshing token", e);
            throw new RuntimeException("Could not refresh token");
        }
    }
}