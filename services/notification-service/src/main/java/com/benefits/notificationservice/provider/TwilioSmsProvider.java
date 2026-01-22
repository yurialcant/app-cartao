package com.benefits.notificationservice.provider;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

/**
 * Stub baseado na API real do Twilio SMS
 * Documentação: https://www.twilio.com/docs/sms
 * 
 * Endpoint real: POST /2010-04-01/Accounts/{AccountSid}/Messages.json
 * 
 * Este stub imita a estrutura de resposta da API real do Twilio.
 */
@Slf4j
@Component
public class TwilioSmsProvider {
    
    private final Random random = new Random();
    
    @Value("${twilio.account-sid:AC${random.uuid}}")
    private String accountSid;
    
    @Value("${twilio.from-number:+5511999999999}")
    private String fromNumber;
    
    /**
     * Enviar SMS baseado na API real do Twilio
     */
    public Map<String, Object> sendSms(String to, String message) {
        log.info("🔵 [TWILIO-STUB] Enviando SMS - To: {}, Message: {}", to, message);
        
        // Message SID único do Twilio (formato: SM + 32 caracteres)
        String messageSid = "SM" + UUID.randomUUID().toString().replace("-", "").substring(0, 32);
        
        // Status do Twilio (queued, sent, delivered, failed)
        String[] statuses = {"queued", "sent", "delivered"};
        String status = statuses[random.nextInt(statuses.length)];
        
        Map<String, Object> response = new HashMap<>();
        response.put("sid", messageSid);
        response.put("account_sid", accountSid);
        response.put("from", fromNumber);
        response.put("to", to);
        response.put("body", message);
        response.put("status", status);
        response.put("date_created", LocalDateTime.now().toString());
        response.put("date_sent", status.equals("sent") || status.equals("delivered") 
                ? LocalDateTime.now().toString() : null);
        response.put("date_updated", LocalDateTime.now().toString());
        response.put("direction", "outbound-api");
        response.put("price", "0.00");
        response.put("price_unit", "USD");
        response.put("error_code", null);
        response.put("error_message", null);
        response.put("uri", "/2010-04-01/Accounts/" + accountSid + "/Messages/" + messageSid + ".json");
        
        log.info("🔵 [TWILIO-STUB] SMS enviado - SID: {}, Status: {}", messageSid, status);
        
        return response;
    }
    
    /**
     * Verificar status do SMS (baseado na API real do Twilio)
     */
    public Map<String, Object> getMessageStatus(String messageSid) {
        log.info("🔵 [TWILIO-STUB] Verificando status - MessageSid: {}", messageSid);
        
        String[] statuses = {"queued", "sent", "delivered", "failed"};
        String status = statuses[random.nextInt(statuses.length)];
        
        Map<String, Object> response = new HashMap<>();
        response.put("sid", messageSid);
        response.put("status", status);
        response.put("date_updated", LocalDateTime.now().toString());
        
        if (status.equals("failed")) {
            response.put("error_code", "30008");
            response.put("error_message", "Unknown destination handset");
        }
        
        return response;
    }
}
