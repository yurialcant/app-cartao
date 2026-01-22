package com.benefits.notificationservice.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Serviço para armazenar SMS em memória (stub local)
 * Permite que o app consulte SMS recebidos durante desenvolvimento/testes
 */
@Slf4j
@Service
public class SmsInboxService {
    
    // Armazenamento em memória: phone -> List<SMS>
    private final Map<String, List<SmsMessage>> smsInbox = new ConcurrentHashMap<>();
    
    /**
     * Armazenar SMS no inbox
     */
    public void storeSms(String phone, String message, Map<String, Object> providerResponse) {
        log.info("🔵 [SMS-INBOX] Armazenando SMS - Phone: {}, Message: {}", phone, message);
        
        SmsMessage sms = new SmsMessage(
            UUID.randomUUID().toString(),
            phone,
            message,
            LocalDateTime.now(),
            providerResponse
        );
        
        smsInbox.computeIfAbsent(phone, k -> new ArrayList<>()).add(sms);
        
        log.info("🔵 [SMS-INBOX] SMS armazenado - Total para {}: {}", phone, smsInbox.get(phone).size());
    }
    
    /**
     * Buscar SMS por telefone
     */
    public List<Map<String, Object>> getSmsByPhone(String phone) {
        log.info("🔵 [SMS-INBOX] Buscando SMS - Phone: {}", phone);
        
        List<SmsMessage> smsList = smsInbox.getOrDefault(phone, Collections.emptyList());
        
        return smsList.stream()
                .sorted(Comparator.comparing(SmsMessage::getTimestamp).reversed())
                .map(sms -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", sms.getId());
                    map.put("phone", sms.getPhone());
                    map.put("message", sms.getMessage());
                    map.put("timestamp", sms.getTimestamp().toString());
                    map.put("providerResponse", sms.getProviderResponse());
                    return map;
                })
                .collect(Collectors.toList());
    }
    
    /**
     * Limpar inbox (útil para testes)
     */
    public void clearInbox() {
        log.info("🔵 [SMS-INBOX] Limpando inbox");
        smsInbox.clear();
    }
    
    /**
     * Classe interna para representar SMS
     */
    public static class SmsMessage {
        private final String id;
        private final String phone;
        private final String message;
        private final LocalDateTime timestamp;
        private final Map<String, Object> providerResponse;
        
        public SmsMessage(String id, String phone, String message, LocalDateTime timestamp, Map<String, Object> providerResponse) {
            this.id = id;
            this.phone = phone;
            this.message = message;
            this.timestamp = timestamp;
            this.providerResponse = providerResponse;
        }
        
        public String getId() { return id; }
        public String getPhone() { return phone; }
        public String getMessage() { return message; }
        public LocalDateTime getTimestamp() { return timestamp; }
        public Map<String, Object> getProviderResponse() { return providerResponse; }
    }
}
