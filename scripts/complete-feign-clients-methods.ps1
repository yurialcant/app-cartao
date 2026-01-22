# Script para completar métodos nos Feign Clients

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔧 COMPLETANDO MÉTODOS NOS FEIGN CLIENTS 🔧               ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot

# User BFF - DeviceServiceClient
$deviceClientPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/client/DeviceServiceClient.java"
if (Test-Path $deviceClientPath) {
    $deviceClientContent = @"
package com.benefits.userbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@FeignClient(name = "device-service", url = "`${deviceservice.service.url:http://device-service:8098}")
public interface DeviceServiceClient {
    
    @PostMapping("/api/devices/register")
    Map<String, Object> registerDevice(
            @RequestParam String userId,
            @RequestBody Map<String, Object> deviceInfo
    );
    
    @GetMapping("/api/devices")
    Map<String, Object> getUserDevices(@RequestParam String userId);
    
    @PutMapping("/api/devices/{deviceId}/trust")
    Map<String, Object> trustDevice(
            @PathVariable String deviceId,
            @RequestParam String otp
    );
    
    @DeleteMapping("/api/devices/{deviceId}")
    Map<String, Object> revokeDevice(@PathVariable String deviceId);
}
"@
    Set-Content -Path $deviceClientPath -Value $deviceClientContent -Encoding UTF8
    Write-Host "  ✓ DeviceServiceClient completado" -ForegroundColor Green
}

# User BFF - SupportServiceClient
$supportClientPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/client/SupportServiceClient.java"
if (Test-Path $supportClientPath) {
    $supportClientContent = @"
package com.benefits.userbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@FeignClient(name = "support-service", url = "`${supportservice.service.url:http://support-service:8095}")
public interface SupportServiceClient {
    
    @PostMapping("/api/tickets")
    Map<String, Object> createTicket(@RequestBody Map<String, Object> requestBody);
    
    @GetMapping("/api/tickets")
    Map<String, Object> getUserTickets(@RequestParam String userId);
    
    @GetMapping("/api/tickets/{ticketId}")
    Map<String, Object> getTicket(@PathVariable String ticketId);
}
"@
    Set-Content -Path $supportClientPath -Value $supportClientContent -Encoding UTF8
    Write-Host "  ✓ SupportServiceClient completado" -ForegroundColor Green
}

# User BFF - PaymentServiceClient
$paymentClientPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/client/PaymentServiceClient.java"
if (Test-Path $paymentClientPath) {
    $paymentClientContent = @"
package com.benefits.userbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@FeignClient(name = "payments-orchestrator", url = "`${paymentsorchestrator.service.url:http://payments-orchestrator:8092}")
public interface PaymentServiceClient {
    
    @PostMapping("/api/payments/qr/scan")
    Map<String, Object> scanQR(@RequestBody Map<String, Object> requestBody);
    
    @PostMapping("/api/payments/qr/confirm")
    Map<String, Object> confirmQRPayment(@RequestBody Map<String, Object> requestBody);
    
    @PostMapping("/api/payments/card")
    Map<String, Object> processCardPayment(@RequestBody Map<String, Object> requestBody);
    
    @GetMapping("/api/payments/{paymentId}")
    Map<String, Object> getPaymentStatus(@PathVariable String paymentId);
}
"@
    Set-Content -Path $paymentClientPath -Value $paymentClientContent -Encoding UTF8
    Write-Host "  ✓ PaymentServiceClient completado" -ForegroundColor Green
}

# Admin BFF - KybServiceClient
$kybClientPath = Join-Path $baseDir "services/admin-bff/src/main/java/com/benefits/adminbff/client/KybServiceClient.java"
if (Test-Path $kybClientPath) {
    $kybClientContent = @"
package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "kyb-service", url = "`${kybservice.service.url:http://kyb-service:8102}")
public interface KybServiceClient {
    
    @GetMapping("/api/kyb/{merchantId}")
    Map<String, Object> getKYB(@PathVariable String merchantId);
    
    @PutMapping("/api/kyb/{id}/verify")
    Map<String, Object> verifyKYB(
            @PathVariable String id,
            @RequestBody Map<String, Object> requestBody
    );
}
"@
    Set-Content -Path $kybClientPath -Value $kybClientContent -Encoding UTF8
    Write-Host "  ✓ KybServiceClient completado" -ForegroundColor Green
}

Write-Host "`n✅ Feign Clients completados com métodos!" -ForegroundColor Green
Write-Host ""
