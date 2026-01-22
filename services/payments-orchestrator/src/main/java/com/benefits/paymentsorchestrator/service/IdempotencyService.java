package com.benefits.paymentsorchestrator.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Serviço para garantir idempotência em operações de pagamento
 * Usa chave idempotente para evitar processamento duplicado
 */
@Service
public class IdempotencyService {

    private static final Logger log = LoggerFactory.getLogger(IdempotencyService.class);
    private final Map<String, Map<String, Object>> idempotencyStore = new ConcurrentHashMap<>();

    public boolean isProcessed(String idempotencyKey) {
        boolean exists = idempotencyStore.containsKey(idempotencyKey);
        if (exists) {
            log.info("🔵 [IDEMPOTENCY] Chave já processada: {}", idempotencyKey);
        }
        return exists;
    }

    public Map<String, Object> getResult(String idempotencyKey) {
        return idempotencyStore.get(idempotencyKey);
    }

    public void storeResult(String idempotencyKey, Map<String, Object> result) {
        log.info("🔵 [IDEMPOTENCY] Armazenando resultado para chave: {}", idempotencyKey);
        idempotencyStore.put(idempotencyKey, result);
    }

    public void clear(String idempotencyKey) {
        idempotencyStore.remove(idempotencyKey);
    }
}
