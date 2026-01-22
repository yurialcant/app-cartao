package com.benefits.notificationservice.provider;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Stub baseado na API real do Firebase Cloud Messaging (FCM)
 * Documentação: https://firebase.google.com/docs/cloud-messaging/send-message
 * 
 * Endpoint real: POST https://fcm.googleapis.com/v1/projects/{project_id}/messages:send
 * 
 * Este stub imita a estrutura de resposta da API real do FCM.
 */
@Slf4j
@Component
public class FcmPushProvider {
    
    @Value("${fcm.project-id:benefits-project}")
    private String projectId;
    
    /**
     * Enviar push notification baseado na API real do FCM
     */
    public Map<String, Object> sendPush(String fcmToken, String title, String body, Map<String, String> data) {
        log.info("🔵 [FCM-STUB] Enviando push - Token: {}, Title: {}", fcmToken.substring(0, 20) + "...", title);
        
        // Message name do FCM (formato: projects/{project_id}/messages/{message_id})
        String messageId = UUID.randomUUID().toString();
        String messageName = "projects/" + projectId + "/messages/" + messageId;
        
        Map<String, Object> response = new HashMap<>();
        response.put("name", messageName);
        
        log.info("🔵 [FCM-STUB] Push enviado - MessageName: {}", messageName);
        
        return response;
    }
    
    /**
     * Enviar push para múltiplos dispositivos (baseado na API real do FCM)
     */
    public Map<String, Object> sendMulticast(java.util.List<String> fcmTokens, String title, String body, Map<String, String> data) {
        log.info("🔵 [FCM-STUB] Enviando push multicast - Tokens: {}", fcmTokens.size());
        
        String batchId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("batchId", batchId);
        response.put("successCount", fcmTokens.size());
        response.put("failureCount", 0);
        
        return response;
    }
}
