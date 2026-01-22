package com.benefits.notificationservice.controller;

import com.benefits.notificationservice.service.NotificationService;
import com.benefits.notificationservice.service.SmsInboxService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    
    private final NotificationService notificationService;
    private final SmsInboxService smsInboxService;
    
    @PostMapping("/sms")
    public ResponseEntity<Map<String, Object>> sendSMS(
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            HttpServletRequest request) {
        
        log.info("🔵 [NOTIFICATION-SERVICE] POST /api/notifications/sms - Request-ID: {} - TenantId: {}", requestId, tenantId);
        
        String phone = (String) requestBody.get("phone");
        String message = (String) requestBody.get("message");
        
        Map<String, Object> result = notificationService.sendSMS(phone, message);
        
        // Armazenar SMS no inbox para consulta local
        smsInboxService.storeSms(phone, message, result);
        
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/email")
    public ResponseEntity<Map<String, Object>> sendEmail(
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            HttpServletRequest request) {
        
        log.info("🔵 [NOTIFICATION-SERVICE] POST /api/notifications/email - Request-ID: {} - TenantId: {}", requestId, tenantId);
        
        String email = (String) requestBody.get("email");
        String subject = (String) requestBody.get("subject");
        String body = (String) requestBody.get("body");
        String htmlBody = (String) requestBody.getOrDefault("htmlBody", null);
        
        Map<String, Object> result = notificationService.sendEmail(email, subject, body, htmlBody);
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/push")
    public ResponseEntity<Map<String, Object>> sendPush(
            @RequestBody Map<String, Object> requestBody,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            HttpServletRequest request) {
        
        log.info("🔵 [NOTIFICATION-SERVICE] POST /api/notifications/push - Request-ID: {} - TenantId: {}", requestId, tenantId);
        
        String userId = (String) requestBody.get("userId");
        String fcmToken = (String) requestBody.getOrDefault("fcmToken", null);
        String apnsToken = (String) requestBody.getOrDefault("apnsToken", null);
        String title = (String) requestBody.get("title");
        String body = (String) requestBody.get("body");
        @SuppressWarnings("unchecked")
        Map<String, String> data = (Map<String, String>) requestBody.getOrDefault("data", Map.of());
        
        Map<String, Object> result = notificationService.sendPush(userId, fcmToken, apnsToken, title, body, data);
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/sms/inbox/{phone}")
    public ResponseEntity<List<Map<String, Object>>> getSmsInbox(
            @PathVariable String phone,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            HttpServletRequest request) {
        
        log.info("🔵 [NOTIFICATION-SERVICE] GET /api/notifications/sms/inbox/{} - Request-ID: {}", phone, requestId);
        
        List<Map<String, Object>> smsList = smsInboxService.getSmsByPhone(phone);
        return ResponseEntity.ok(smsList);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserNotifications(
            @PathVariable String userId,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            HttpServletRequest request) {
        
        log.info("🔵 [NOTIFICATION-SERVICE] GET /api/notifications/user/{} - Request-ID: {}", userId, requestId);
        
        Map<String, Object> result = notificationService.getUserNotifications(userId);
        return ResponseEntity.ok(result);
    }
    
    @PutMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(
            @PathVariable String id,
            @RequestHeader(value = "X-Request-Id", required = false) String requestId,
            HttpServletRequest request) {
        
        log.info("🔵 [NOTIFICATION-SERVICE] PUT /api/notifications/{}/read - Request-ID: {}", id, requestId);
        
        // TODO: Implementar marcação como lida no banco de dados
        return ResponseEntity.ok(Map.of(
            "id", id,
            "status", "read",
            "readAt", java.time.LocalDateTime.now().toString()
        ));
    }
}
