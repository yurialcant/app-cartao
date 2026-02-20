# Script para criar todas as entidades necessárias no Core Service

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🏗️  CRIANDO TODAS AS ENTIDADES DO CORE SERVICE 🏗️         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$coreServiceDir = Join-Path $baseDir "services/benefits-core/src/main/java/com/benefits/core"

# Entidades a criar
$entities = @(
    @{Name="User"; Table="users"; Fields=@("id UUID PRIMARY KEY", "keycloakId VARCHAR(255) UNIQUE", "email VARCHAR(255)", "name VARCHAR(255)", "cpf VARCHAR(14)", "phone VARCHAR(20)", "status VARCHAR(50)", "createdAt TIMESTAMP", "updatedAt TIMESTAMP")},
    @{Name="Merchant"; Table="merchants"; Fields=@("id UUID PRIMARY KEY", "keycloakId VARCHAR(255) UNIQUE", "name VARCHAR(255)", "cnpj VARCHAR(18)", "email VARCHAR(255)", "phone VARCHAR(20)", "mcc VARCHAR(10)", "status VARCHAR(50)", "kybStatus VARCHAR(50)", "createdAt TIMESTAMP", "updatedAt TIMESTAMP")},
    @{Name="Terminal"; Table="terminals"; Fields=@("id UUID PRIMARY KEY", "merchantId UUID REFERENCES merchants(id)", "terminalId VARCHAR(100) UNIQUE", "name VARCHAR(255)", "location VARCHAR(255)", "status VARCHAR(50)", "boundAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="Operator"; Table="operators"; Fields=@("id UUID PRIMARY KEY", "merchantId UUID REFERENCES merchants(id)", "terminalId UUID REFERENCES terminals(id)", "keycloakId VARCHAR(255)", "name VARCHAR(255)", "pinHash VARCHAR(255)", "role VARCHAR(50)", "status VARCHAR(50)", "createdAt TIMESTAMP")},
    @{Name="ChargeIntent"; Table="charge_intents"; Fields=@("id UUID PRIMARY KEY", "merchantId UUID REFERENCES merchants(id)", "terminalId UUID REFERENCES terminals(id)", "operatorId UUID REFERENCES operators(id)", "amount DECIMAL(19,2)", "currency VARCHAR(3)", "paymentMethod VARCHAR(50)", "qrCode TEXT", "expiresAt TIMESTAMP", "status VARCHAR(50)", "createdAt TIMESTAMP")},
    @{Name="Payment"; Table="payments"; Fields=@("id UUID PRIMARY KEY", "chargeIntentId UUID REFERENCES charge_intents(id)", "transactionId UUID REFERENCES transactions(id)", "userId VARCHAR(255)", "merchantId UUID REFERENCES merchants(id)", "amount DECIMAL(19,2)", "currency VARCHAR(3)", "paymentMethod VARCHAR(50)", "status VARCHAR(50)", "acquirerTxnId VARCHAR(255)", "authCode VARCHAR(50)", "processedAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="Refund"; Table="refunds"; Fields=@("id UUID PRIMARY KEY", "paymentId UUID REFERENCES payments(id)", "transactionId UUID REFERENCES transactions(id)", "amount DECIMAL(19,2)", "reason VARCHAR(255)", "status VARCHAR(50)", "acquirerRefundId VARCHAR(255)", "processedAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="Dispute"; Table="disputes"; Fields=@("id UUID PRIMARY KEY", "transactionId UUID REFERENCES transactions(id)", "userId VARCHAR(255)", "merchantId UUID REFERENCES merchants(id)", "amount DECIMAL(19,2)", "reason VARCHAR(255)", "status VARCHAR(50)", "acquirerDisputeId VARCHAR(255)", "evidence TEXT", "resolvedAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="Ticket"; Table="tickets"; Fields=@("id UUID PRIMARY KEY", "userId VARCHAR(255)", "transactionId UUID REFERENCES transactions(id)", "subject VARCHAR(255)", "description TEXT", "status VARCHAR(50)", "priority VARCHAR(50)", "assignedTo VARCHAR(255)", "resolvedAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="Device"; Table="devices"; Fields=@("id UUID PRIMARY KEY", "userId VARCHAR(255)", "deviceId VARCHAR(255) UNIQUE", "deviceName VARCHAR(255)", "deviceType VARCHAR(50)", "osVersion VARCHAR(50)", "appVersion VARCHAR(50)", "isTrusted BOOLEAN", "trustedAt TIMESTAMP", "lastSeenAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="AuditLog"; Table="audit_logs"; Fields=@("id UUID PRIMARY KEY", "userId VARCHAR(255)", "action VARCHAR(100)", "resourceType VARCHAR(50)", "resourceId VARCHAR(255)", "details TEXT", "ipAddress VARCHAR(45)", "userAgent TEXT", "requestId VARCHAR(255)", "createdAt TIMESTAMP")},
    @{Name="Settlement"; Table="settlements"; Fields=@("id UUID PRIMARY KEY", "merchantId UUID REFERENCES merchants(id)", "periodStart DATE", "periodEnd DATE", "totalAmount DECIMAL(19,2)", "fees DECIMAL(19,2)", "netAmount DECIMAL(19,2)", "status VARCHAR(50)", "payoutDate DATE", "batchId VARCHAR(255)", "createdAt TIMESTAMP")},
    @{Name="Reconciliation"; Table="reconciliations"; Fields=@("id UUID PRIMARY KEY", "merchantId UUID REFERENCES merchants(id)", "acquirer VARCHAR(50)", "periodStart DATE", "periodEnd DATE", "expectedAmount DECIMAL(19,2)", "actualAmount DECIMAL(19,2)", "difference DECIMAL(19,2)", "status VARCHAR(50)", "fileUrl VARCHAR(500)", "processedAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="TopupBatch"; Table="topup_batches"; Fields=@("id UUID PRIMARY KEY", "employerId VARCHAR(255)", "batchNumber VARCHAR(100) UNIQUE", "totalAmount DECIMAL(19,2)", "totalUsers INTEGER", "status VARCHAR(50)", "approvedBy VARCHAR(255)", "approvedAt TIMESTAMP", "executedAt TIMESTAMP", "createdAt TIMESTAMP")},
    @{Name="KYC"; Table="kyc"; Fields=@("id UUID PRIMARY KEY", "userId VARCHAR(255)", "status VARCHAR(50)", "documentType VARCHAR(50)", "documentNumber VARCHAR(100)", "documentUrl VARCHAR(500)", "selfieUrl VARCHAR(500)", "verifiedAt TIMESTAMP", "rejectedReason TEXT", "createdAt TIMESTAMP")},
    @{Name="KYB"; Table="kyb"; Fields=@("id UUID PRIMARY KEY", "merchantId UUID REFERENCES merchants(id)", "status VARCHAR(50)", "documentType VARCHAR(50)", "documentNumber VARCHAR(100)", "documentUrl VARCHAR(500)", "verifiedAt TIMESTAMP", "rejectedReason TEXT", "createdAt TIMESTAMP")}
)

$entityDir = Join-Path $coreServiceDir "entity"
if (-not (Test-Path $entityDir)) {
    New-Item -ItemType Directory -Path $entityDir -Force | Out-Null
}

Write-Host "`n[1/2] Criando entidades Java..." -ForegroundColor Cyan

foreach ($entity in $entities) {
    $entityName = $entity.Name
    $tableName = $entity.Table
    Write-Host "  Criando $entityName..." -ForegroundColor Yellow
    
    # Criar entidade Java básica
    $entityContent = @"
package com.benefits.core.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "$tableName")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class $entityName {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    // TODO: Adicionar campos específicos da entidade
    // Campos básicos comuns
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime updatedAt;
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
"@
    
    $entityPath = Join-Path $entityDir "$entityName.java"
    if (-not (Test-Path $entityPath)) {
        Set-Content -Path $entityPath -Value $entityContent -Encoding UTF8
        Write-Host "    ✓ $entityName.java criado" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ $entityName.java já existe" -ForegroundColor Yellow
    }
}

Write-Host "`n[2/2] Criando script SQL para tabelas..." -ForegroundColor Cyan

# Criar script SQL
$sqlDir = Join-Path $baseDir "infra/sql"
if (-not (Test-Path $sqlDir)) {
    New-Item -ItemType Directory -Path $sqlDir -Force | Out-Null
}

$sqlContent = "-- Script SQL para criar todas as tabelas do Core Service`n`n"
$sqlContent += "-- Extensões necessárias`n"
$sqlContent += "CREATE EXTENSION IF NOT EXISTS uuid-ossp;`n`n"

foreach ($entity in $entities) {
    $tableName = $entity.Table
    $fields = $entity.Fields -join ",\n    "
    
    $sqlContent += "-- Tabela: $tableName`n"
    $sqlContent += "CREATE TABLE IF NOT EXISTS $tableName (`n"
    $sqlContent += "    $fields`n"
    $sqlContent += ");`n`n"
    
    # Criar índices básicos
    $sqlContent += "-- Índices para $tableName`n"
    if ($tableName -eq "users") {
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_users_keycloak_id ON $tableName(keycloakId);`n"
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_users_email ON $tableName(email);`n"
    }
    if ($tableName -eq "merchants") {
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_merchants_keycloak_id ON $tableName(keycloakId);`n"
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_merchants_cnpj ON $tableName(cnpj);`n"
    }
    if ($tableName -eq "devices") {
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_devices_user_id ON $tableName(userId);`n"
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_devices_device_id ON $tableName(deviceId);`n"
    }
    if ($tableName -eq "audit_logs") {
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON $tableName(userId);`n"
        $sqlContent += "CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON $tableName(createdAt DESC);`n"
    }
    $sqlContent += "`n"
}

$sqlPath = Join-Path $sqlDir "create-all-tables.sql"
Set-Content -Path $sqlPath -Value $sqlContent -Encoding UTF8

Write-Host "    ✓ Script SQL criado: infra/sql/create-all-tables.sql" -ForegroundColor Green

Write-Host "`n✅ Todas as entidades criadas com sucesso!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Implementar campos específicos em cada entidade" -ForegroundColor White
Write-Host "  2. Criar repositórios para cada entidade" -ForegroundColor White
Write-Host "  3. Executar script SQL no banco de dados" -ForegroundColor White
Write-Host ""
