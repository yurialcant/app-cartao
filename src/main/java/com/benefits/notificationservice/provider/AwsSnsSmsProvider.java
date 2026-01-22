package com.benefits.notificationservice.provider;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Stub baseado na API real do AWS SNS SMS
 * Documentação: https://docs.aws.amazon.com/sns/latest/dg/sms_publish-to-phone.html
 * 
 * Este stub imita a estrutura de resposta da API real do AWS SNS.
 */
@Slf4j
@Component
public class AwsSnsSmsProvider {
    
    /**
     * Enviar SMS baseado na API real do AWS SNS
     */
    public Map<String, Object> sendSms(String phoneNumber, String message) {
        log.info("🔵 [AWS-SNS-STUB] Enviando SMS - PhoneNumber: {}, Message: {}", phoneNumber, message);
        
        // Message ID único do AWS SNS
        String messageId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("MessageId", messageId);
        response.put("ResponseMetadata", Map.of(
            "RequestId", UUID.randomUUID().toString(),
            "HTTPStatusCode", 200
        ));
        
        log.info("🔵 [AWS-SNS-STUB] SMS enviado - MessageId: {}", messageId);
        
        return response;
    }
    
    /**
     * Publicar em tópico SNS (baseado na API real do AWS SNS)
     */
    public Map<String, Object> publishToTopic(String topicArn, String message, Map<String, String> attributes) {
        log.info("🔵 [AWS-SNS-STUB] Publicando em tópico - TopicArn: {}", topicArn);
        
        String messageId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("MessageId", messageId);
        response.put("SequenceNumber", String.valueOf(System.currentTimeMillis()));
        response.put("ResponseMetadata", Map.of(
            "RequestId", UUID.randomUUID().toString(),
            "HTTPStatusCode", 200
        ));
        
        return response;
    }
}
