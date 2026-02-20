#!/usr/bin/env pwsh
# FASE B MVP Flow Validation Script

Write-Host ""
Write-Host "============================================================================"
Write-Host "  FASE B - MVP Flow Execution Validation"
Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "============================================================================"
Write-Host ""

# Check infrastructure
Write-Host "[1] INFRASTRUCTURE STATUS"
Write-Host "---"

# PostgreSQL
Write-Host "PostgreSQL (5432)..." -NoNewline
$pg = docker exec benefits-postgres pg_isready -U benefits -d benefits 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " OK (healthy)" -ForegroundColor Green
} else {
    Write-Host " FAILED" -ForegroundColor Red
}

# Redis
Write-Host "Redis (6379)..." -NoNewline
$redis = docker exec benefits-redis redis-cli ping 2>&1
if ($redis -eq "PONG") {
    Write-Host " OK (PONG)" -ForegroundColor Green
} else {
    Write-Host " FAILED" -ForegroundColor Red
}

# Keycloak
Write-Host "Keycloak (8081)..." -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/health" -TimeoutSec 3 -ErrorAction SilentlyContinue 2>&1
    if ($response.StatusCode -eq 200) {
        Write-Host " OK (running)" -ForegroundColor Green
    } else {
        Write-Host " STARTING (initializing)" -ForegroundColor Yellow
    }
} catch {
    Write-Host " STARTING (initializing)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[2] MVP FLOWS DOCUMENTATION"
Write-Host "---"

Write-Host ""
Write-Host "F03 - Login + Bootstrap"
Write-Host "  Status: PENDING (requires Keycloak + user-bff:8080)"
Write-Host "  Actors: End User, Keycloak, user-bff"
Write-Host "  Flow: OIDC login -> JWT extraction -> tenant_id isolation -> home_json rendering"
Write-Host "  Docs: docs/04-fluxos/F03-login-bootstrap.md"
Write-Host ""

Write-Host "F05 - Credit Batch"
Write-Host "  Status: PENDING (requires benefits-core:8091 + employer-bff:8083)"
Write-Host "  Actors: Employer Admin, employer-bff, benefits-core"
Write-Host "  Flow: Batch POST -> ACID transaction -> outbox event -> async relay"
Write-Host "  Docs: docs/04-fluxos/F05-credit-batch.md"
Write-Host ""

Write-Host "F06 - Wallet + Statement"
Write-Host "  Status: PENDING (requires benefits-core:8091 + user-bff:8080)"
Write-Host "  Actors: End User, user-bff, benefits-core"
Write-Host "  Flow: GET /wallets -> balance snapshot + GET /statement -> ledger entries"
Write-Host "  Docs: docs/04-fluxos/F06-wallet-statement.md"
Write-Host ""

Write-Host "F07 - POS Authorize"
Write-Host "  Status: PENDING (requires payments-orchestrator:8092 + pos-bff:8084)"
Write-Host "  Actors: POS Operator, pos-bff, payments-orchestrator, benefits-core"
Write-Host "  Flow: 3-Phase (RESERVE -> PROVIDER_APPROVAL -> CONFIRM) -> ledger DEBIT"
Write-Host "  Docs: docs/04-fluxos/F07-pos-authorize.md"
Write-Host ""

Write-Host "============================================================================"
Write-Host "  NEXT STEPS TO RUN FLOWS"
Write-Host "============================================================================"
Write-Host ""

Write-Host "1. Wait for Keycloak startup (30-60 seconds)"
Write-Host "   Command: docker logs -f benefits-keycloak"
Write-Host ""

Write-Host "2. Start benefits-core service"
Write-Host "   Command: cd services/benefits-core && mvn spring-boot:run"
Write-Host ""

Write-Host "3. Start BFF services (in separate terminals)"
Write-Host "   user-bff:   cd bffs/user-bff && mvn spring-boot:run"
Write-Host "   employer-bff: cd bffs/employer-bff && mvn spring-boot:run"
Write-Host "   pos-bff:    cd bffs/pos-bff && mvn spring-boot:run"
Write-Host ""

Write-Host "4. Run E2E test suite"
Write-Host "   Command: python e2e-test.py"
Write-Host ""

Write-Host "5. Validate individual flows"
Write-Host "   F03: Login to http://localhost:4200 (Angular admin portal)"
Write-Host "   F05: POST http://localhost:8083/api/v1/credits/batch"
Write-Host "   F06: GET http://localhost:8080/api/v1/wallets"
Write-Host "   F07: POST http://localhost:8084/api/v1/pos/payments/authorize"
Write-Host ""

Write-Host "============================================================================"
Write-Host "  CONFIGURATION"
Write-Host "============================================================================"
Write-Host ""

Write-Host "Keycloak:"
Write-Host "  URL: http://localhost:8081"
Write-Host "  Admin: admin/admin"
Write-Host "  Realm: benefits"
Write-Host ""

Write-Host "PostgreSQL:"
Write-Host "  Host: localhost:5432"
Write-Host "  User: benefits / benefits123"
Write-Host "  Database: benefits"
Write-Host ""

Write-Host "Redis:"
Write-Host "  Host: localhost:6379"
Write-Host ""

Write-Host "Service Ports:"
Write-Host "  user-bff: 8080"
Write-Host "  employer-bff: 8083"
Write-Host "  pos-bff: 8084"
Write-Host "  benefits-core: 8091"
Write-Host "  payments-orchestrator: 8092"
Write-Host ""

Write-Host "Angular Portals:"
Write-Host "  Admin Portal: http://localhost:4200"
Write-Host "  Employer Portal: http://localhost:4201"
Write-Host "  Merchant Portal: http://localhost:4202"
Write-Host ""

Write-Host "============================================================================"
Write-Host ""
