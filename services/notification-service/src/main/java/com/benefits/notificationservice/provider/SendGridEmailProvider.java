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
 * Stub baseado na API real do SendGrid
 * Documentação: https://docs.sendgrid.com/api-reference/mail-send/mail-send
 * 
 * Endpoint real: POST /v3/mail/send
 * 
 * Este stub imita a estrutura de resposta da API real do SendGrid.
 */
@Slf4j
@Component
public class SendGridEmailProvider {
    
    @Value("${sendgrid.from-email:noreply@benefits.test}")
    private String fromEmail;
    
    @Value("${sendgrid.from-name:Benefits}")
    private String fromName;
    
    /**
     * Enviar email baseado na API real do SendGrid
     */
    public Map<String, Object> sendEmail(String to, String subject, String body) {
        log.info("🔵 [SENDGRID-STUB] Enviando email - To: {}, Subject: {}", to, subject);
        
        // Message ID do SendGrid (formato específico)
        String messageId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("message_id", messageId);
        response.put("headers", Map.of(
            "X-Message-Id", messageId
        ));
        
        log.info("🔵 [SENDGRID-STUB] Email enviado - MessageId: {}", messageId);
        
        return response;
    }
    
    /**
     * Enviar email com template (baseado na API real do SendGrid)
     */
    public Map<String, Object> sendEmailWithTemplate(String to, String templateId, Map<String, Object> templateData) {
        log.info("🔵 [SENDGRID-STUB] Enviando email com template - To: {}, TemplateId: {}", to, templateId);
        
        String messageId = UUID.randomUUID().toString();
        
        Map<String, Object> response = new HashMap<>();
        response.put("message_id", messageId);
        response.put("template_id", templateId);
        
        return response;
    }
}
