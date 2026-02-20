package com.benefits.common.idempotency;

import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Duration;

/**
 * Idempotency helper using Redis
 * Prevents duplicate operations within a time window
 */
@Service
public class IdempotencyService {
    
    private final ReactiveRedisTemplate<String, String> redisTemplate;
    
    public IdempotencyService(ReactiveRedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }
    
    /**
     * Check if operation with given idempotency key already processed
     * @param tenantId tenant scope
     * @param idempotencyKey unique operation key
     * @param ttlSeconds time-to-live for the cache entry
     * @return Mono<String> cached response if exists, empty Mono if not
     */
    public Mono<String> getIdempotentResponse(String tenantId, String idempotencyKey, int ttlSeconds) {
        String key = buildKey(tenantId, idempotencyKey);
        return redisTemplate.opsForValue().get(key);
    }
    
    /**
     * Store idempotent response
     * @param tenantId tenant scope
     * @param idempotencyKey unique operation key
     * @param response response to cache
     * @param ttlSeconds time-to-live
     */
    public Mono<Void> storeIdempotentResponse(String tenantId, String idempotencyKey, String response, int ttlSeconds) {
        String key = buildKey(tenantId, idempotencyKey);
        return redisTemplate.opsForValue()
            .set(key, response, Duration.ofSeconds(ttlSeconds))
            .then();
    }
    
    /**
     * Clear idempotent response (optional - for cleanup)
     */
    public Mono<Void> clearIdempotentResponse(String tenantId, String idempotencyKey) {
        String key = buildKey(tenantId, idempotencyKey);
        return redisTemplate.delete(key).then();
    }
    
    private String buildKey(String tenantId, String idempotencyKey) {
        return "idempotency:" + tenantId + ":" + idempotencyKey;
    }
}
