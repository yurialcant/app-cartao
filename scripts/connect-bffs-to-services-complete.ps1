# Script para conectar BFFs com serviços especializados via Feign

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔗 CONECTANDO BFFs COM SERVIÇOS ESPECIALIZADOS 🔗        ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot

# User BFF - DeviceController
$deviceControllerPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/controller/DeviceController.java"
if (Test-Path $deviceControllerPath) {
    $content = Get-Content $deviceControllerPath -Raw
    $newContent = $content -replace "@RequiredArgsConstructor", "@RequiredArgsConstructor`n`n    private final com.benefits.userbff.client.DeviceServiceClient deviceServiceClient;"
    $newContent = $newContent -replace "// TODO: Chamar Device Service", "return ResponseEntity.ok(deviceServiceClient.registerDevice(userId, deviceInfo));"
    $newContent = $newContent -replace "return ResponseEntity.ok\(Map.of\(""status"", ""OK"", ""message"", ""Device registrado""\)\);", "return ResponseEntity.ok(deviceServiceClient.getUserDevices(userId));"
    Set-Content -Path $deviceControllerPath -Value $newContent -Encoding UTF8
    Write-Host "  ✓ DeviceController conectado com DeviceService" -ForegroundColor Green
}

# User BFF - SecurityController
$securityControllerPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/controller/SecurityController.java"
if (Test-Path $securityControllerPath) {
    $content = Get-Content $securityControllerPath -Raw
    $newContent = $content -replace "@RequiredArgsConstructor", "@RequiredArgsConstructor`n`n    private final com.benefits.userbff.client.DeviceServiceClient deviceServiceClient;"
    Set-Content -Path $securityControllerPath -Value $newContent -Encoding UTF8
    Write-Host "  ✓ SecurityController conectado" -ForegroundColor Green
}

# User BFF - SupportController
$supportControllerPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/controller/SupportController.java"
if (Test-Path $supportControllerPath) {
    $content = Get-Content $supportControllerPath -Raw
    $newContent = $content -replace "@RequiredArgsConstructor", "@RequiredArgsConstructor`n`n    private final com.benefits.userbff.client.SupportServiceClient supportServiceClient;"
    $newContent = $newContent -replace "// TODO: Chamar Support Service", "return ResponseEntity.ok(supportServiceClient.createTicket(userId, requestBody));"
    Set-Content -Path $supportControllerPath -Value $newContent -Encoding UTF8
    Write-Host "  ✓ SupportController conectado com SupportService" -ForegroundColor Green
}

# User BFF - PaymentController
$paymentControllerPath = Join-Path $baseDir "services/user-bff/src/main/java/com/benefits/userbff/controller/PaymentController.java"
if (Test-Path $paymentControllerPath) {
    $content = Get-Content $paymentControllerPath -Raw
    $newContent = $content -replace "@RequiredArgsConstructor", "@RequiredArgsConstructor`n`n    private final com.benefits.userbff.client.PaymentServiceClient paymentServiceClient;"
    $newContent = $newContent -replace "// TODO: Chamar Payments Orchestrator", "return ResponseEntity.ok(paymentServiceClient.scanQR(requestBody));"
    Set-Content -Path $paymentControllerPath -Value $newContent -Encoding UTF8
    Write-Host "  ✓ PaymentController conectado com PaymentService" -ForegroundColor Green
}

# Admin BFF - MerchantManagementController
$merchantControllerPath = Join-Path $baseDir "services/admin-bff/src/main/java/com/benefits/adminbff/controller/MerchantManagementController.java"
if (Test-Path $merchantControllerPath) {
    $content = Get-Content $merchantControllerPath -Raw
    $newContent = $content -replace "@RequiredArgsConstructor", "@RequiredArgsConstructor`n`n    private final com.benefits.adminbff.client.KybServiceClient kybServiceClient;"
    Set-Content -Path $merchantControllerPath -Value $newContent -Encoding UTF8
    Write-Host "  ✓ MerchantManagementController conectado com KYBService" -ForegroundColor Green
}

Write-Host "`n✅ BFFs conectados com serviços especializados!" -ForegroundColor Green
Write-Host ""
