package com.benefits.notificationservice.service;

import com.benefits.notificationservice.provider.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {
    
    private final FcmPushProvider fcmProvider;
    private final ApnsPushProvider apnsProvider;
    private final AwsSesEmailProvider awsSesProvider;
    private final SendGridEmailProvider sendGridProvider;
    private final TwilioSmsProvider twilioProvider;
    private final AwsSnsSmsProvider awsSnsProvider;
    
    @Value("${notification.push.provider:fcm}")
    private String pushProvider;
    
    @Value("${notification.email.provider:aws_ses}")
    private String emailProvider;
    
    @Value("${notification.sms.provider:twilio}")
    private String smsProvider;
    
    public Map<String, Object> sendPush(String userId, String fcmToken, String apnsToken, String title, String body, Map<String, String> data) {
        log.info("🔵 [NOTIFICATION-SERVICE] Enviando push - userId: {}, provider: {}", userId, pushProvider);
        
        Map<String, Object> result;
        
        switch (pushProvider.toLowerCase()) {
            case "fcm":
                result = fcmProvider.sendPush(fcmToken != null ? fcmToken : "", title, body, data != null ? data : Map.of());
                break;
            case "apns":
                result = apnsProvider.sendPush(apnsToken != null ? apnsToken : "", title, body, data != null ? Map.of() : Map.of());
                break;
            default:
                log.warn("🔵 [NOTIFICATION-SERVICE] Provider de push desconhecido: {}, usando FCM", pushProvider);
                result = fcmProvider.sendPush(fcmToken != null ? fcmToken : "", title, body, data != null ? data : Map.of());
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("notificationId", java.util.UUID.randomUUID().toString());
        response.put("type", "PUSH");
        response.put("provider", pushProvider);
        response.put("providerResponse", result);
        response.put("status", "SENT");
        response.put("sentAt", java.time.LocalDateTime.now().toString());
        
        return response;
    }
    
    public Map<String, Object> sendEmail(String email, String subject, String body, String htmlBody) {
        log.info("🔵 [NOTIFICATION-SERVICE] Enviando email - email: {}, provider: {}", email, emailProvider);
        
        Map<String, Object> result;
        
        switch (emailProvider.toLowerCase()) {
            case "aws_ses":
                if (htmlBody != null) {
                    result = awsSesProvider.sendEmailWithHtml(email, subject, htmlBody, body);
                } else {
                    result = awsSesProvider.sendEmail(email, subject, body);
                }
                break;
            case "sendgrid":
                result = sendGridProvider.sendEmail(email, subject, body);
                break;
            default:
                log.warn("🔵 [NOTIFICATION-SERVICE] Provider de email desconhecido: {}, usando AWS SES", emailProvider);
                result = awsSesProvider.sendEmail(email, subject, body);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("notificationId", java.util.UUID.randomUUID().toString());
        response.put("type", "EMAIL");
        response.put("provider", emailProvider);
        response.put("providerResponse", result);
        response.put("status", "SENT");
        response.put("sentAt", java.time.LocalDateTime.now().toString());
        
        return response;
    }
    
    public Map<String, Object> sendSMS(String phone, String message) {
        log.info("🔵 [NOTIFICATION-SERVICE] Enviando SMS - phone: {}, provider: {}", phone, smsProvider);
        
        Map<String, Object> result;
        
        switch (smsProvider.toLowerCase()) {
            case "twilio":
                result = twilioProvider.sendSms(phone, message);
                break;
            case "aws_sns":
                result = awsSnsProvider.sendSms(phone, message);
                break;
            default:
                log.warn("🔵 [NOTIFICATION-SERVICE] Provider de SMS desconhecido: {}, usando Twilio", smsProvider);
                result = twilioProvider.sendSms(phone, message);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("notificationId", java.util.UUID.randomUUID().toString());
        response.put("type", "SMS");
        response.put("provider", smsProvider);
        response.put("providerResponse", result);
        response.put("status", "SENT");
        response.put("sentAt", java.time.LocalDateTime.now().toString());
        
        return response;
    }
    
    public Map<String, Object> getUserNotifications(String userId) {
        log.info("🔵 [NOTIFICATION-SERVICE] Buscando notificações - userId: {}", userId);
        
        // TODO: Buscar do banco
        return Map.of(
            "notifications", List.of(),
            "unreadCount", 0
        );
    }
}
