# Copilot Instructions: Benefits Platform

**Multi-tenant, white-label microservices platform for corporate benefits management**

## Architecture Overview

### System Design
- **Event-driven microservices** with multi-tenancy at core
- **Java 21+** backend (Spring Boot WebFlux 3.5.9 for reactive services, Web for legacy)
- **PostgreSQL 16** (R2DBC for reactive BFFs, JDBC for traditional services)
- **Keycloak** for OAuth2/JWT identity; `tenant_id` injected for multi-tenancy
- **Docker Compose** orchestration locally (11 services: Postgres, Redis, Keycloak, LocalStack, observability stack)

### Service Tiers

**Core Services** (Domain SSOT):
- `tenant-service/` - Master catalog (tenant, employer, merchant registrations)
- `benefits-core/` - Wallet ledger, balance operations (R2DBC, immutable ledger pattern)
- `payments-orchestrator/` - Payment auth/capture/refund workflows
- `merchant-service/` - Merchant & POS terminal management
- `support-service/` - Expense tracking, receipt management
- `audit-service/` - Event timeline & audit records

**Backend-for-Frontend APIs** (in `bffs/`):
- `user-bff/` - User app API (profile, wallet, statements, expenses)
- `employer-bff/` - Employer portal API (employee mgmt, credit batching)
- `merchant-bff/` - Merchant portal API
- `pos-bff/` - POS terminal authorization (real-time payments)
- `admin-bff/` - Admin/platform operations

**Tech variance**: BFFs use WebFlux + R2DBC (reactive); some legacy services use Web + JPA. See `pom.xml` modules comment for disabled services with compilation issues.

---

## Critical Data Concepts

### Canonical IDs (from MASTER-BACKLOG.md §1.1)
Always use **UUID** format; these are domain SSOT markers:

| ID | SSOT Service | Must Always Present | Usage |
|----|--------------|-------------------|-------|
| `tenant_id` | tenant-service | ✅ (all entities) | Isolation; internal, not user-facing |
| `user_id` | Keycloak `sub` | ✅ (profiles, auth) | Identity; visible to admin/employer, hidden from users |
| `wallet_id` | benefits-core | ✅ (ledger) | Wallet identity for balance ops |
| `payment_id` | payments-orchestrator | ✅ (POS, statements) | Visible in user/admin statements |
| `merchant_id` | merchant-service | ⚠️ (merchant+POS ops) | Partial visibility in user statements |
| `terminal_id` | merchant-service | ⚠️ (POS only) | Internal to POS flow |
| `expense_id` / `receipt_id` | support-service | ✅ (expense flow) | User/employer/admin visible |
| `correlation_id` | Edge (app/bff) | ✅ (commands, events) | Tracing only; internal |

**Rule**: Inject `tenant_id` in all repository/service queries via Spring Security context (`@TenantAware` or middleware). **NEVER hardcode**.

### Immutable Ledger Pattern
`benefits-core/` uses **event-sourced wallet ledgers**:
- `ledger_entry` table is **append-only** (no updates)
- Each transaction creates immutable entry with `type` (CREDIT, DEBIT, REFUND, etc.)
- Balance = SUM of ledger entries (no denormalized balance field)
- For consistency, lock wallet during balance update: use R2DBC transactions + Redisson locks if concurrent load

---

## Developer Workflows

### Build & Clean
```bash
./build.sh validate    # Check Java 21, Maven
./build.sh clean       # Remove target/, node_modules/
./build.sh build       # mvn clean package (multi-threaded, skips tests)
./build.sh test        # mvn test
```
**Note**: Parent pom.xml has 2 modules disabled (tenant-service, payments-orchestrator) due to compilation errors; remove comments when fixed.

### Local Development (Docker Compose)
```bash
cd infra/
docker-compose up -d    # Starts 11 services
# Keycloak: http://localhost:8081 (admin/admin)
# Postgres: localhost:5432 (user: benefits, pass: benefits123)
# LocalStack (AWS mock): http://localhost:4566
```
Schema initialized via `./postgres/init-schemas.sql`. Check health: `docker-compose ps`.

### Run Individual Service
```bash
mvn -pl services/benefits-core spring-boot:run
# Check application.properties for port (usually 8084+)
```

### API Documentation
- BFFs expose Swagger UI via springdoc-openapi-starter-webflux-ui
- After starting: `http://localhost:8080/swagger-ui.html`
- Core services DO NOT expose Swagger (internal APIs only)

---

## Code Patterns & Conventions

### Package Structure (all services follow)
```
src/main/java/com/benefits/{service-name}/
├── config/           # Spring beans, security config
├── controller/       # REST endpoints (BFFs only)
├── service/          # Business logic, transactions
├── repository/       # Data access (R2DBC or JPA)
├── entity/ or model/ # Domain objects (use @Table, @Entity)
├── dto/              # Response/request DTOs (use @Data from Lombok)
├── event/            # DomainEvent, EventPublisher
├── exception/        # Custom exceptions
└── {Service}Application.java  # Main Spring Boot class
```

### Multi-Tenancy Pattern
**In every repository query:**
```java
// ✅ CORRECT
public Mono<Wallet> findByIdAndTenant(UUID walletId, UUID tenantId) {
    return db.query("SELECT * FROM wallets WHERE id = ? AND tenant_id = ?", 
        walletId, tenantId).as(Wallet.class).first();
}

// ❌ WRONG - missing tenant_id filter
public Mono<Wallet> findById(UUID walletId) {
    return db.query("SELECT * FROM wallets WHERE id = ?", walletId)...
}
```
**Source of truth**: Extract `tenant_id` from JWT claim (`@AuthenticationPrincipal` or Spring Security context) in controller, pass down the stack.

### Event Publishing
- Use `DomainEvent` abstract base class (see `services/benefits-core/src/main/java/.../event/DomainEvent.java`)
- Publish via `@EventPublisher` or Spring events
- Event schema: Include `correlation_id`, `tenant_id`, `source_channel`, `created_at`, `event_type`
- **Outbox Pattern**: Write event to `outbox` table in same transaction, async poller publishes to Kafka/SNS

### DTO Validation
```java
@Data
public class CreditBatchRequest {
    @NotNull(message = "employer_id required")
    private UUID employerId;
    
    @NotNull @Min(1)
    private Long amountCents;  // Always cents, not dollars
}
```
Use `@Valid` on controller params; Spring validates automatically.

### Error Handling
All services should return consistent error format:
```json
{
  "error_code": "WALLET_NOT_FOUND",
  "message": "Wallet {} not found for tenant {}",
  "correlation_id": "uuid",
  "timestamp": "2026-01-16T10:00:00Z"
}
```
Create custom `exception/ApiException` with mapping to HTTP status codes.

---

## Cross-Service Communication

### BFF → Core Services
BFFs call core services via **Spring Cloud OpenFeign** (HTTP):
```java
@FeignClient(name = "benefits-core", url = "http://benefits-core:8084")
public interface BenefitsCoreClient {
    @GetMapping("/wallets/{wallet_id}")
    Mono<WalletDto> getWallet(@PathVariable UUID wallet_id);
}
```
**Resilience**: Add retry + circuit breaker via `@CircuitBreaker` (Resilience4j).

### Async: Event Bus (Kafka / SNS via LocalStack)
- Payment events → audit-service
- Credit batch events → notification-service
- Use Spring Cloud Stream or Kafka listener
- **Idempotency**: Store `idempotency_key` + event_hash in `processed_events` to detect duplicates

### Health Check
- All services expose `/actuator/health` (Spring Boot Actuator)
- Docker Compose depends_on uses health checks
- **Liveness**: Ready when DB + external deps respond

---

## Database & Schema

### Schema Location
- [docs/schemas/TEMPLATE-SCHEMA.md](docs/schemas/TEMPLATE-SCHEMA.md) - Pattern reference
- Actual init SQL: [infra/postgres/init-schemas.sql](infra/postgres/init-schemas.sql)
- Migrations: Flyway (in each service, auto-runs on startup)

### Common Columns (all tables)
```sql
created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
created_by UUID,
updated_at TIMESTAMPTZ,
updated_by UUID,
tenant_id UUID NOT NULL,  -- Always present
correlation_id UUID,       -- For tracing
version INT DEFAULT 1      -- Optimistic locking
```

### Ledger (Immutable)
```sql
CREATE TABLE ledger_entry (
  id UUID PRIMARY KEY,
  wallet_id UUID NOT NULL,
  type VARCHAR(50),         -- CREDIT, DEBIT, REFUND, etc.
  amount_cents BIGINT,
  balance_after_cents BIGINT,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  -- NO updates; append-only
);
CREATE INDEX ON ledger_entry(wallet_id, created_at DESC);
```

### Querying Strategy
- **Paginated lists**: Always `LIMIT` + `OFFSET` with tenant_id filter
- **Recent data first**: Order by `created_at DESC`
- **Performance**: Index on (tenant_id, created_at), (tenant_id, status) for common filters

---

## Testing & Quality

### Test Structure
```
services/{service-name}/src/test/java/.../
├── {Service}ApplicationTests.java   -- Spring @SpringBootTest
├── service/                         -- Unit tests
├── controller/                      -- WebFlux @WebFluxTest
└── repository/                      -- @DataR2dbcTest with TestContainers
```

### Key Testing Patterns
- **Tenancy**: Always assert multi-tenancy isolation (tenant_id filters)
- **Idempotency**: Test duplicate event headers → same result
- **TestContainers**: Use for Postgres; Docker Compose UP during CI

### CI/CD (scripts/)
- `build-all-services.ps1` - PowerShell builds all modules
- Lint: `mvn spotbugs:check`, `mvn dependency-check:check`
- Disabled services skip in Maven modules list (commented out in pom.xml)

---

## Key Files to Read (Priority Order)

1. **[README.md](README.md)** - Project overview, getting started
2. **[MASTER-BACKLOG.md](MASTER-BACKLOG.md)** - Complete domain spec (§1.1 = canonical IDs, §3 = data models, §4 = flows)
3. **[docs/architecture/C4-ARCHITECTURE.md](docs/architecture/C4-ARCHITECTURE.md)** - System design
4. **[docs/schemas/TEMPLATE-SCHEMA.md](docs/schemas/TEMPLATE-SCHEMA.md)** - DB patterns
5. **[docs/api/TEMPLATE-API.md](docs/api/TEMPLATE-API.md)** - REST API design
6. **[pom.xml](pom.xml)** - Dependency versions, active modules
7. **[M0-COMPLETION-REPORT.md](M0-COMPLETION-REPORT.md)** - What's delivered

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "tenant_id is null" errors | Ensure JWT contains tenant claim; check Spring Security context injection |
| R2DBC connection timeouts | Verify Postgres container health: `docker-compose ps` |
| Feign client 404 errors | Check service name matches Docker network (e.g., `benefits-core` hostname) |
| Duplicate event processing | Add `idempotency_key` check in `processed_events` table before handling |
| Ledger balance mismatch | Re-sum all entries for wallet; no denormalized balance field exists |
| Disabled module build errors | Modules `tenant-service`, `payments-orchestrator` are commented in pom.xml due to R2DBC/servlet issues |

---

## Quick Start for AI Agents

1. **Understanding a request**: Read MASTER-BACKLOG.md §1-4 for domain context
2. **Writing a service method**: Follow pattern in `services/benefits-core/src/main/java/.../service/`
3. **Adding an API endpoint**: Copy structure from existing BFF controller; use `@Valid` + multi-tenancy checks
4. **Querying data**: Always append `AND tenant_id = ?` filter; use `ledger_entry` SUM for wallet balance
5. **Publishing events**: Extend `DomainEvent`, inject `@EventPublisher`, follow outbox pattern
6. **Testing**: Create test in same service; use TestContainers for DB tests

**Status**: M0 (foundation) complete. M1 (services scaffold) ready. Actively building M2-M20 features.
