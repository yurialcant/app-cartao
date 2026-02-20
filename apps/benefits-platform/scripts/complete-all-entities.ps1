# Script para completar todas as entidades com campos específicos

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🔧 COMPLETANDO ENTIDADES COM CAMPOS ESPECÍFICOS 🔧        ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$entityDir = Join-Path $baseDir "services/benefits-core/src/main/java/com/benefits/core/entity"

# Definir campos específicos para cada entidade
$entityFields = @{
    "User" = @"
    @Column(name = "keycloak_id", unique = true, nullable = false)
    private String keycloakId;
    
    @Column(nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String name;
    
    @Column(length = 14)
    private String cpf;
    
    @Column(length = 20)
    private String phone;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserStatus status = UserStatus.ACTIVE;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum UserStatus {
        ACTIVE, INACTIVE, BLOCKED, PENDING_KYC
    }
"@
    
    "Merchant" = @"
    @Column(name = "keycloak_id", unique = true, nullable = false)
    private String keycloakId;
    
    @Column(nullable = false)
    private String name;
    
    @Column(length = 18, unique = true)
    private String cnpj;
    
    @Column(nullable = false)
    private String email;
    
    @Column(length = 20)
    private String phone;
    
    @Column(length = 10)
    private String mcc; // Merchant Category Code
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MerchantStatus status = MerchantStatus.PENDING;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "kyb_status", nullable = false)
    private KYBStatus kybStatus = KYBStatus.PENDING;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum MerchantStatus {
        PENDING, ACTIVE, INACTIVE, BLOCKED
    }
    
    public enum KYBStatus {
        PENDING, APPROVED, REJECTED
    }
"@
    
    "Device" = @"
    @Column(name = "user_id", nullable = false)
    private String userId;
    
    @Column(name = "device_id", unique = true, nullable = false)
    private String deviceId;
    
    @Column(name = "device_name")
    private String deviceName;
    
    @Column(name = "device_type", length = 50)
    private String deviceType; // ANDROID, IOS
    
    @Column(name = "os_version", length = 50)
    private String osVersion;
    
    @Column(name = "app_version", length = 50)
    private String appVersion;
    
    @Column(name = "is_trusted", nullable = false)
    private Boolean isTrusted = false;
    
    @Column(name = "trusted_at")
    private LocalDateTime trustedAt;
    
    @Column(name = "last_seen_at")
    private LocalDateTime lastSeenAt = LocalDateTime.now();
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
"@
    
    "ChargeIntent" = @"
    @Column(name = "merchant_id", nullable = false)
    private UUID merchantId;
    
    @Column(name = "terminal_id")
    private UUID terminalId;
    
    @Column(name = "operator_id")
    private UUID operatorId;
    
    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;
    
    @Column(nullable = false, length = 3)
    private String currency = "BRL";
    
    @Column(name = "payment_method", length = 50)
    private String paymentMethod; // QR, CARD
    
    @Column(name = "qr_code", columnDefinition = "TEXT")
    private String qrCode;
    
    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChargeIntentStatus status = ChargeIntentStatus.PENDING;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    public enum ChargeIntentStatus {
        PENDING, APPROVED, EXPIRED, CANCELLED
    }
"@
    
    "Ticket" = @"
    @Column(name = "user_id", nullable = false)
    private String userId;
    
    @Column(name = "transaction_id")
    private UUID transactionId;
    
    @Column(nullable = false)
    private String subject;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TicketStatus status = TicketStatus.OPEN;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TicketPriority priority = TicketPriority.MEDIUM;
    
    @Column(name = "assigned_to")
    private String assignedTo;
    
    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    public enum TicketStatus {
        OPEN, IN_PROGRESS, RESOLVED, CLOSED
    }
    
    public enum TicketPriority {
        LOW, MEDIUM, HIGH, URGENT
    }
"@
}

function Complete-Entity {
    param(
        [string]$EntityName,
        [string]$Fields
    )
    
    $entityPath = Join-Path $entityDir "$EntityName.java"
    
    if (-not (Test-Path $entityPath)) {
        Write-Host "  ⚠ $EntityName.java não encontrado" -ForegroundColor Yellow
        return
    }
    
    $content = Get-Content $entityPath -Raw
    
    # Verificar se já tem campos específicos (não apenas createdAt/updatedAt)
    if ($content -match "private String keycloakId|private String email|private BigDecimal amount") {
        Write-Host "  ⚠ $EntityName já tem campos específicos" -ForegroundColor Yellow
        return
    }
    
    # Substituir TODO por campos específicos
    $newContent = $content -replace "    // TODO: Adicionar campos específicos da entidade`n    // Campos básicos comuns", $Fields
    
    Set-Content -Path $entityPath -Value $newContent -Encoding UTF8
    Write-Host "    ✓ $EntityName completado" -ForegroundColor Green
}

Write-Host "`nCompletando entidades com campos específicos..." -ForegroundColor Cyan

foreach ($entityName in $entityFields.Keys) {
    Write-Host "  Completando $entityName..." -ForegroundColor Yellow
    Complete-Entity -EntityName $entityName -Fields $entityFields[$entityName]
}

Write-Host "`n✅ Entidades completadas!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Adicionar imports necessários (BigDecimal, etc.)" -ForegroundColor White
Write-Host "  2. Adicionar relacionamentos JPA (@ManyToOne, etc.)" -ForegroundColor White
Write-Host "  3. Criar repositórios para todas as entidades" -ForegroundColor White
Write-Host ""
