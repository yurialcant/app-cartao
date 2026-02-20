# C4 Architecture - Benefits Platform

## Level 1: System Context

```
┌─────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SYSTEMS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  Keycloak      │  │ LocalStack   │  │ Email Service   │   │
│  │ (Identity)     │  │ (AWS Mock)   │  │ (SMTP)          │   │
│  └────────────────┘  └──────────────┘  └─────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                                △
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │  User App    │ │ Admin Portal │ │ Employer     │
        │  (React/     │ │ (React/Vue)  │ │ Portal       │
        │  Flutter)    │ │              │ │ (React)      │
        └──────────────┘ └──────────────┘ └──────────────┘
                │               │               │
                │               │               │
                └───────────────┼───────────────┘
                                │
                                ▼
        ┌─────────────────────────────────────────────────────┐
        │                                                     │
        │        BENEFITS PLATFORM (Microservices)           │
        │                                                     │
        │  Multi-tenant white-label benefits management      │
        │                                                     │
        └─────────────────────────────────────────────────────┘
```

---

## Level 2: Container Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                         LOAD BALANCER (ALB)                            │
│                            localhost:8080                              │
└────────┬────────────────────────────────────┬───────────────────────────┘
         │                                    │
         ▼                                    ▼
    ┌──────────────┐          ┌─────────────────────────────┐
    │ API Gateway  │          │ Keycloak                    │
    │ (Nginx/Kong) │          │ (Identity Provider)         │
    │ :8080        │          │ :8080/auth                  │
    └──────┬───────┘          └─────────────────────────────┘
           │
    ┌──────┴────────────────────┬───────────────────┬────────────────┐
    │                           │                   │                │
    ▼                           ▼                   ▼                ▼
┌──────────────┐    ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐
│ user-bff     │    │ admin-bff        │  │ employer-bff     │  │ pos-bff      │
│ :8081        │    │ :8084            │  │ :8082            │  │ :8085        │
│ Aggregates   │    │ Aggregates       │  │ Aggregates       │  │ Aggregates   │
│ calls to all │    │ admin data       │  │ employer data    │  │ POS txns     │
└──────┬───────┘    └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘
       │                     │                     │                   │
       ├─────────────────────┼─────────────────────┼───────────────────┤
       │                     │                     │                   │
       ▼                     ▼                     ▼                   ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                      CORE SERVICES                                  │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐           │
  │  │tenant-service│ │benefits-core │ │payments-         │           │
  │  │:8090         │ │:8091         │ │orchestrator      │           │
  │  │(SSOT Catalog)│ │(Wallet/      │ │:8092 (Txns)     │           │
  │  │              │ │Ledger)       │ │                 │           │
  │  └──────────────┘ └──────────────┘ └──────────────────┘           │
  │                                                                     │
  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐           │
  │  │merchant-svc  │ │support-svc   │ │audit-service     │           │
  │  │:8093         │ │:8094         │ │:8095 (Timeline)  │           │
  │  │(Merchant/POS)│ │(Expenses/    │ │                 │           │
  │  │              │ │Receipts)     │ │                 │           │
  │  └──────────────┘ └──────────────┘ └──────────────────┘           │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘
       │                     │                     │
       └─────────────────────┼─────────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
         ┌────────────┐  ┌────────────┐  ┌────────────┐
         │PostgreSQL  │  │Redis       │  │LocalStack  │
         │:5432       │  │:6379       │  │:4566       │
         │(Primary DB)│  │(Cache)     │  │(S3, SQS)   │
         └────────────┘  └────────────┘  └────────────┘
                │            │            │
                └────────────┼────────────┘
                             │
                             ▼
         ┌─────────────────────────────┐
         │  EventBridge / Message Bus  │
         │  (Async Events)             │
         └─────────────────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
         ┌────────────┐ ┌────────────┐ ┌────────────┐
         │Notification│ │Settlement  │ │Privacy     │
         │Service     │ │Service     │ │Service     │
         │:8096       │ │:8097       │ │:8098       │
         └────────────┘ └────────────┘ └────────────┘

         ┌─────────────────────────────┐
         │  OBSERVABILITY STACK        │
         ├─────────────────────────────┤
         │ Prometheus :9090            │
         │ Grafana    :3000            │
         │ Loki       :3100            │
         │ Tempo      :4317            │
         │ Jaeger     :16686           │
         └─────────────────────────────┘
```

---

## Level 3: Component Diagram (Benefits Core Example)

```
┌──────────────────────────────────────────────────────────┐
│               BENEFITS-CORE SERVICE                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │           PRESENTATION / HTTP LAYER               │ │
│  ├────────────────────────────────────────────────────┤ │
│  │ Controllers (REST endpoints)                      │ │
│  │ • WalletController                                │ │
│  │ • LedgerController                                │ │
│  │ • BalanceController                               │ │
│  └────────────────────────────────────────────────────┘ │
│           │                                              │
│           ▼                                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │          APPLICATION / BUSINESS LOGIC             │ │
│  ├────────────────────────────────────────────────────┤ │
│  │ Services                                          │ │
│  │ • WalletService (CRUD + balance)                  │ │
│  │ • LedgerService (immutable transactions)          │ │
│  │ • BalanceService (aggregated view)                │ │
│  │ • CreditBatchService (bulk operations)            │ │
│  └────────────────────────────────────────────────────┘ │
│           │                                              │
│           ▼                                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │           DATA / PERSISTENCE LAYER                │ │
│  ├────────────────────────────────────────────────────┤ │
│  │ Repositories                                      │ │
│  │ • WalletRepository                                │ │
│  │ • LedgerRepository                                │ │
│  │ • BalanceRepository                               │ │
│  │                                                   │ │
│  │ Database Access                                  │ │
│  │ • PostgreSQL (primary)                            │ │
│  │ • Redis (cache)                                   │ │
│  └────────────────────────────────────────────────────┘ │
│           │                                              │
│           ▼                                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │      EVENT / EXTERNAL INTEGRATION LAYER           │ │
│  ├────────────────────────────────────────────────────┤ │
│  │ Event Publisher                                   │ │
│  │ • wallet.credited                                 │ │
│  │ • wallet.debited                                  │ │
│  │ • wallet.adjusted                                 │ │
│  │                                                   │ │
│  │ Outbox Relay                                      │ │
│  │ • Publish to EventBridge/SNS                      │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
      ┌─────────┐    ┌─────────┐    ┌────────────┐
      │PostgreSQL   │Redis    │    │EventBridge │
      └─────────┘    └─────────┘    └────────────┘
```

---

## Data Flow Example: Payment Authorization

```
User App
   │
   ▼ (POST /wallets/authorize)
user-bff
   │
   ▼ (calls POST /commands/authorize)
payments-orchestrator
   │
   ├──▶ Validates payment
   │
   ├──▶ calls POST /commands/reserve
   │
   ▼
benefits-core
   │
   ├──▶ Reserves balance
   │
   ├──▶ INSERT into outbox (wallet.reserved)
   │
   ▼ (same transaction)
EventBridge
   │
   ├──▶ audit-service (logs timeline)
   │
   ├──▶ settlement-service (marks for settlement)
   │
   ▼ (async)
user-bff
   │
   ▼ (polling or WebSocket)
User App (shows updated balance)
```

---

## Technology Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Language** | Java | 21+ | Backend services |
| **Framework** | Spring Boot | 3.5+ | REST APIs |
| **Database** | PostgreSQL | 16+ | Primary storage |
| **Cache** | Redis | 7+ | Sessions, tokens |
| **Message Bus** | EventBridge/SQS | - | Async events |
| **Storage** | S3 / LocalStack | - | Files (receipts, exports) |
| **Identity** | Keycloak | 26+ | OIDC/SAML auth |
| **Observability** | OTel + Prometheus + Loki | - | Logs, traces, metrics |
| **Frontend** | React / Vue / Flutter | Latest | Web and mobile apps |

