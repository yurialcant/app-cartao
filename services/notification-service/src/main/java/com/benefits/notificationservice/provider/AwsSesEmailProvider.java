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
 * Stub baseado na API real do AWS SES (Simple Email Service)
 * Documentação: https://docs.aws.amazon.com/ses/latest/APIReference/Welcome.html
 * 
 * Endpoint real: POST /v2/email/outbound-emails
 * 
 * Este stub imita a estrutura de resposta da API real do AWS SES.
 */
@Slf4j
@Component
public class AwsSesEmailProvider {
    
    @Value("${aws.ses.from-email:noreply@benefits.test}")
    private String fromEmail;
    
    /**
     * Enviar email baseado na API real do AWS SES v2
     */
    public Map<String, Object> sendEmail(String to, String subject, String body) {
        log.info("🔵 [AWS-SES-STUB] Enviando email - To: {}, Subject: {}", to, subject);
        
        // Message ID único do AWS SES
        String messageId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("MessageId", messageId);
        response.put("ResponseMetadata", Map.of(
            "RequestId", UUID.randomUUID().toString(),
            "HTTPStatusCode", 200
        ));
        
        log.info("🔵 [AWS-SES-STUB] Email enviado - MessageId: {}", messageId);
        
        return response;
    }
    
    /**
     * Enviar email com HTML (baseado na API real do AWS SES)
     */
    public Map<String, Object> sendEmailWithHtml(String to, String subject, String htmlBody, String textBody) {
        log.info("🔵 [AWS-SES-STUB] Enviando email HTML - To: {}, Subject: {}", to, subject);
        
        String messageId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("MessageId", messageId);
        response.put("ResponseMetadata", Map.of(
            "RequestId", UUID.randomUUID().toString(),
            "HTTPStatusCode", 200
        ));
        
        return response;
    }
    
    /**
     * Verificar status do email (baseado na API real do AWS SES)
     */
    public Map<String, Object> getSendStatistics() {
        log.info("🔵 [AWS-SES-STUB] Obtendo estatísticas de envio");
        
        Map<String, Object> response = new HashMap<>();
        response.put("SendDataPoints", List.of(
            Map.of(
                "Timestamp", LocalDateTime.now().toString(),
                "DeliveryAttempts", 100,
                "Bounces", 2,
                "Complaints", 0,
                "Rejects", 1
            )
        ));
        
        return response;
    }
}
