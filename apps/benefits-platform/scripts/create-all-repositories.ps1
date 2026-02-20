# Script para criar repositórios JPA para todas as entidades

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📦 CRIANDO REPOSITÓRIOS JPA PARA TODAS AS ENTIDADES 📦    ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$coreServiceDir = Join-Path $baseDir "services/benefits-core/src/main/java/com/benefits/core"
$repositoryDir = Join-Path $coreServiceDir "repository"

if (-not (Test-Path $repositoryDir)) {
    New-Item -ItemType Directory -Path $repositoryDir -Force | Out-Null
}

# Entidades que precisam de repositórios
$entities = @(
    "User",
    "Merchant",
    "Terminal",
    "Operator",
    "ChargeIntent",
    "Payment",
    "Refund",
    "Dispute",
    "Ticket",
    "Device",
    "AuditLog",
    "Settlement",
    "Reconciliation",
    "TopupBatch",
    "KYC",
    "KYB"
)

$repositoryTemplate = @"
package com.benefits.core.repository;

import com.benefits.core.entity.{ENTITY};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;
import java.util.Optional;
{QUERIES}

@Repository
public interface {ENTITY}Repository extends JpaRepository<{ENTITY}, UUID> {
{QUERY_METHODS}
}
"@

foreach ($entity in $entities) {
    $repositoryName = "${entity}Repository"
    $repositoryPath = Join-Path $repositoryDir "$repositoryName.java"
    
    if (Test-Path $repositoryPath) {
        Write-Host "  ⚠ $repositoryName já existe" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  Criando $repositoryName..." -ForegroundColor Yellow
    
    # Queries específicas por entidade
    $queries = ""
    $queryMethods = ""
    
    switch ($entity) {
        "User" {
            $queries = "import java.util.List;`nimport org.springframework.data.jpa.repository.Query;`nimport org.springframework.data.repository.query.Param;"
            $queryMethods = @"
    Optional<{ENTITY}> findByKeycloakId(String keycloakId);
    Optional<{ENTITY}> findByEmail(String email);
    List<{ENTITY}> findByStatus({ENTITY}.{ENTITY}Status status);
"@
        }
        "Merchant" {
            $queries = "import java.util.List;`nimport org.springframework.data.jpa.repository.Query;`nimport org.springframework.data.repository.query.Param;"
            $queryMethods = @"
    Optional<{ENTITY}> findByKeycloakId(String keycloakId);
    Optional<{ENTITY}> findByCnpj(String cnpj);
    List<{ENTITY}> findByStatus({ENTITY}.MerchantStatus status);
    List<{ENTITY}> findByKybStatus({ENTITY}.KYBStatus kybStatus);
"@
        }
        "Device" {
            $queries = "import java.util.List;"
            $queryMethods = @"
    List<{ENTITY}> findByUserId(String userId);
    Optional<{ENTITY}> findByDeviceId(String deviceId);
    List<{ENTITY}> findByUserIdAndIsTrusted(String userId, Boolean isTrusted);
"@
        }
        "ChargeIntent" {
            $queries = "import java.util.List;`nimport java.time.LocalDateTime;"
            $queryMethods = @"
    List<{ENTITY}> findByMerchantId(UUID merchantId);
    List<{ENTITY}> findByStatus({ENTITY}.ChargeIntentStatus status);
    List<{ENTITY}> findByExpiresAtBefore(LocalDateTime expiresAt);
"@
        }
        "Ticket" {
            $queries = "import java.util.List;"
            $queryMethods = @"
    List<{ENTITY}> findByUserId(String userId);
    List<{ENTITY}> findByStatus({ENTITY}.TicketStatus status);
    List<{ENTITY}> findByAssignedTo(String assignedTo);
    Optional<{ENTITY}> findByTransactionId(UUID transactionId);
"@
        }
        "Payment" {
            $queries = "import java.util.List;"
            $queryMethods = @"
    List<{ENTITY}> findByUserId(String userId);
    List<{ENTITY}> findByMerchantId(UUID merchantId);
    Optional<{ENTITY}> findByAcquirerTxnId(String acquirerTxnId);
"@
        }
        "Refund" {
            $queries = "import java.util.List;"
            $queryMethods = @"
    List<{ENTITY}> findByPaymentId(UUID paymentId);
    List<{ENTITY}> findByStatus({ENTITY}.RefundStatus status);
"@
        }
        "Dispute" {
            $queries = "import java.util.List;"
            $queryMethods = @"
    List<{ENTITY}> findByUserId(String userId);
    List<{ENTITY}> findByMerchantId(UUID merchantId);
    List<{ENTITY}> findByStatus({ENTITY}.DisputeStatus status);
"@
        }
        "AuditLog" {
            $queries = "import java.util.List;`nimport org.springframework.data.domain.Page;`nimport org.springframework.data.domain.Pageable;"
            $queryMethods = @"
    Page<{ENTITY}> findByUserId(String userId, Pageable pageable);
    Page<{ENTITY}> findByResourceTypeAndResourceId(String resourceType, String resourceId, Pageable pageable);
    List<{ENTITY}> findByRequestId(String requestId);
"@
        }
        "Settlement" {
            $queries = "import java.util.List;"
            $queryMethods = @"
    List<{ENTITY}> findByMerchantId(UUID merchantId);
    List<{ENTITY}> findByStatus({ENTITY}.SettlementStatus status);
"@
        }
        "KYC" {
            $queries = "import java.util.Optional;"
            $queryMethods = @"
    Optional<{ENTITY}> findByUserId(String userId);
    List<{ENTITY}> findByStatus({ENTITY}.KYCStatus status);
"@
        }
        "KYB" {
            $queries = "import java.util.Optional;"
            $queryMethods = @"
    Optional<{ENTITY}> findByMerchantId(UUID merchantId);
    List<{ENTITY}> findByStatus({ENTITY}.KYBStatus status);
"@
        }
        default {
            $queries = ""
            $queryMethods = ""
        }
    }
    
    $content = $repositoryTemplate -replace "\{ENTITY\}", $entity
    $content = $content -replace "\{QUERIES\}", $queries
    $content = $content -replace "\{QUERY_METHODS\}", $queryMethods
    
    Set-Content -Path $repositoryPath -Value $content -Encoding UTF8
    Write-Host "    ✓ $repositoryName criado" -ForegroundColor Green
}

Write-Host "`n✅ Repositórios criados com sucesso!" -ForegroundColor Green
Write-Host ""
