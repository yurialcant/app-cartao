# Benefits Platform - Monorepo de Referências

Este repositório contém **apenas referências** (submodules) para todos os componentes da plataforma Benefits. Cada serviço, BFF e aplicação tem seu próprio repositório individual no GitHub.

## 🏗️ Arquitetura da Plataforma

### 📁 Estrutura de Submodules

```
benefits-platform/ (este repositório - apenas referências)
├── services/                    # Serviços backend
│   ├── benefits-core           # Serviço central de benefícios
│   ├── tenant-service          # Gestão de tenants
│   ├── identity-service        # Autenticação e identidade
│   ├── payments-orchestrator   # Orquestração de pagamentos
│   ├── merchant-service        # Gestão de merchants
│   ├── support-service         # Sistema de suporte
│   ├── notification-service    # Notificações
│   ├── reconciliation-service  # Reconciliação
│   ├── risk-service           # Avaliação de risco
│   ├── settlement-service     # Liquidação
│   ├── privacy-service        # Privacidade (LGPD)
│   ├── webhook-receiver       # Receptor de webhooks
│   ├── webhook-service        # Serviço de webhooks
│   ├── payments-service       # Processamento de pagamentos
│   ├── billing-service        # Faturamento
│   ├── device-service         # Gestão de dispositivos
│   ├── employer-service       # Gestão de empregadores
│   ├── kyb-service           # Know Your Business
│   ├── kyc-service           # Know Your Customer
│   ├── ops-relay             # Relay operacional
│   └── acquirer-adapter      # Adaptador de adquirentes
├── bffs/                      # Backend-for-Frontend
│   ├── admin-bff             # BFF para admin
│   ├── employer-bff          # BFF para empregadores
│   ├── merchant-bff          # BFF para merchants
│   ├── platform-bff          # BFF da plataforma
│   ├── pos-bff              # BFF para POS
│   ├── support-bff          # BFF para suporte
│   ├── tenant-bff           # BFF para tenants
│   └── user-bff             # BFF para usuários
└── apps/                     # Aplicações frontend
    ├── app-pos-flutter      # App POS (Flutter)
    └── app-user-flutter     # App usuário (Flutter)
```

## 🚀 Como Usar

### Clonando com Submodules

```bash
# Clone o repositório principal
git clone git@github.com:ttiede/benefits-platform.git
cd benefits-platform

# Clone todos os submodules
git submodule update --init --recursive
```

### Atualizando Submodules

```bash
# Atualizar todos os submodules para a versão mais recente
git submodule update --remote

# Ou atualizar um submodule específico
cd services/benefits-core
git pull origin main
cd ../..
git add services/benefits-core
git commit -m "Update benefits-core submodule"
```

### Trabalhando com um Componente Específico

```bash
# Para trabalhar no benefits-core, por exemplo:
cd services/benefits-core

# Faça suas mudanças normalmente
# git add, git commit, git push

# Volte para o repositório principal
cd ../..

# Atualize a referência
git add services/benefits-core
git commit -m "Update benefits-core reference"
git push origin main
```

## 📊 Status dos Componentes

| Componente | Status | Repositório |
|------------|--------|-------------|
| benefits-core | ✅ Completo | [benefits-core](https://github.com/ttiede/benefits-core) |
| tenant-service | ✅ Completo | [tenant-service](https://github.com/ttiede/tenant-service) |
| identity-service | ✅ Completo | [identity-service](https://github.com/ttiede/identity-service) |
| payments-orchestrator | ✅ Completo | [payments-orchestrator](https://github.com/ttiede/payments-orchestrator) |
| merchant-service | ✅ Completo | [merchant-service](https://github.com/ttiede/merchant-service) |
| support-service | ✅ Completo | [support-service](https://github.com/ttiede/support-service) |
| notification-service | ✅ Completo | [notification-service](https://github.com/ttiede/notification-service) |
| reconciliation-service | ✅ Completo | [reconciliation-service](https://github.com/ttiede/reconciliation-service) |
| risk-service | ✅ Completo | [risk-service](https://github.com/ttiede/risk-service) |
| settlement-service | ✅ Completo | [settlement-service](https://github.com/ttiede/settlement-service) |
| privacy-service | ✅ Completo | [privacy-service](https://github.com/ttiede/privacy-service) |
| webhook-receiver | ✅ Completo | [webhook-receiver](https://github.com/ttiede/webhook-receiver) |
| webhook-service | ✅ Completo | [webhook-service](https://github.com/ttiede/webhook-service) |
| payments-service | ✅ Completo | [payments-service](https://github.com/ttiede/payments-service) |
| billing-service | ✅ Completo | [billing-service](https://github.com/ttiede/billing-service) |
| device-service | ✅ Completo | [device-service](https://github.com/ttiede/device-service) |
| employer-service | ✅ Completo | [employer-service](https://github.com/ttiede/employer-service) |
| kyb-service | ✅ Completo | [kyb-service](https://github.com/ttiede/kyb-service) |
| kyc-service | ✅ Completo | [kyc-service](https://github.com/ttiede/kyc-service) |
| ops-relay | ✅ Completo | [ops-relay](https://github.com/ttiede/ops-relay) |
| acquirer-adapter | ✅ Completo | [acquirer-adapter](https://github.com/ttiede/acquirer-adapter) |
| admin-bff | ✅ Completo | [admin-bff](https://github.com/ttiede/admin-bff) |
| employer-bff | ✅ Completo | [employer-bff](https://github.com/ttiede/employer-bff) |
| merchant-bff | ✅ Completo | [merchant-bff](https://github.com/ttiede/merchant-bff) |
| platform-bff | ✅ Completo | [platform-bff](https://github.com/ttiede/platform-bff) |
| pos-bff | ✅ Completo | [pos-bff](https://github.com/ttiede/pos-bff) |
| support-bff | ✅ Completo | [support-bff](https://github.com/ttiede/support-bff) |
| tenant-bff | ✅ Completo | [tenant-bff](https://github.com/ttiede/tenant-bff) |
| user-bff | ✅ Completo | [user-bff](https://github.com/ttiede/user-bff) |
| app-pos-flutter | ✅ Completo | [app-pos-flutter](https://github.com/ttiede/app-pos-flutter) |
| app-user-flutter | ✅ Completo | [app-user-flutter](https://github.com/ttiede/app-user-flutter) |

**Total: 32 componentes organizados em repositórios individuais**

## 🛠️ Tecnologias

- **Backend**: Java 21, Spring Boot 3.5.9
- **Frontend**: Flutter (mobile), Angular (web portals)
- **Banco**: PostgreSQL 16
- **Mensageria**: Event-driven architecture
- **Infra**: Docker, Kubernetes
- **CI/CD**: GitHub Actions

## 📋 Desenvolvimento

### Pré-requisitos

- Java 21
- Docker & Docker Compose
- Git
- SSH configurado para GitHub

### Configuração Inicial

```bash
# Clone com submodules
git clone --recurse-submodules git@github.com:ttiede/benefits-platform.git

# Ou clone e depois inicialize submodules
git clone git@github.com:ttiede/benefits-platform.git
cd benefits-platform
git submodule update --init --recursive
```

### Executando Serviços

Cada componente tem seu próprio README com instruções específicas. Geralmente:

```bash
cd services/benefits-core
./mvnw spring-boot:run
```

## 🤝 Contribuição

1. **Para mudanças em um componente específico**:
   - Vá para o repositório individual
   - Crie uma branch
   - Faça suas mudanças
   - Abra PR no repositório específico

2. **Para mudanças na estrutura geral**:
   - Modifique este repositório
   - Atualize as referências dos submodules conforme necessário

## 📞 Suporte

Para questões sobre desenvolvimento, consulte os READMEs individuais de cada componente ou abra uma issue neste repositório.

---

**🎉 Benefits Platform - Transformando benefícios em experiências digitais!**

---

## 📋 Quick Overview

- **Type**: Microservices architecture
- **Language**: Java 21+ (backend), React/Vue/Flutter (frontend)
- **Database**: PostgreSQL 16
- **Architecture**: Event-driven, multi-tenant, white-label
- **Status**: M0 Foundation Complete

---

## 🎯 What This Platform Does

Enables companies to:
- **Distribute benefits** (food, mobility, health vouchers) to employees
- **Track spending** with statement views and analytics
- **Manage merchants** and POS terminals
- **Process reimbursements** (expense management)
- **Control policies** (spending limits, MCC restrictions)
- **Maintain compliance** (LGPD, audit trails, data privacy)

---

## 🏗️ Project Structure

```
projeto-lucas/
├── MASTER-BACKLOG.md               # Complete specification
├── docs/
│   ├── architecture/               # C4, ERD, flows
│   ├── api/                        # API specifications
│   ├── schemas/                    # Database schemas
│   ├── flows/                      # Data flow diagrams
│   └── runbooks/                   # Operations guides
│
├── infra/
│   ├── docker/                     # Docker configs
│   ├── kubernetes/                 # K8s manifests
│   ├── terraform/                  # IaC for AWS
│   └── scripts/                    # Setup scripts
│
├── libs/
│   └── common/                     # Shared libraries
│
├── services/
│   ├── tenant-service/             # SSOT catalog
│   ├── benefits-core/              # Wallet/ledger
│   ├── payments-orchestrator/      # Payment flows
│   ├── merchant-service/           # Merchant/POS
│   ├── support-service/            # Expenses/receipts
│   └── audit-service/              # Event timeline
│
├── bffs/
│   ├── user-bff/                   # User app API
│   ├── employer-bff/               # Employer portal API
│   ├── merchant-bff/               # Merchant portal API
│   └── admin-bff/                  # Admin portal API
│
├── apps/
│   ├── user-app/                   # Mobile/web app
│   ├── employer-portal/            # Employer UI
│   ├── merchant-portal/            # Merchant UI
│   ├── admin-portal/               # Admin UI
│   └── platform-portal/            # Platform owner UI
│
├── tests/
│   ├── unit/                       # Unit tests
│   ├── integration/                # Integration tests
│   ├── e2e/                        # End-to-end tests
│   └── performance/                # Load tests
│
└── pom.xml                         # Maven parent POM
```

---

## 🚀 Getting Started

### Prerequisites

- Java 21+
- Maven 3.9+
- Docker Desktop
- Git

### Quick Start

1. **Clone and setup**
```bash
cd projeto-lucas
./build.sh validate    # Check environment
```

2. **Read the documentation**
```bash
cat MASTER-BACKLOG.md                    # Complete spec
cat docs/architecture/C4-ARCHITECTURE.md # System design
```

3. **Build the project**
```bash
./build.sh build       # Compile all modules
./build.sh test        # Run tests
```

4. **Start local infrastructure** (M1)
```bash
cd infra
docker-compose up -d   # PostgreSQL, Redis, Keycloak, LocalStack
./scripts/smoke-test   # Verify setup
```

---

## 📚 Documentation

### Essential Reading (In Order)

1. **MASTER-BACKLOG.md**
   - Canonical fields and IDs
   - Complete data models
   - Data lineage by flow
   - 20-milestone roadmap

2. **docs/architecture/C4-ARCHITECTURE.md**
   - System context diagram
   - Container architecture
   - Component diagram
   - Technology stack

3. **docs/api/TEMPLATE-API.md**
   - API design guidelines
   - Error handling
   - Request/response formats

4. **docs/schemas/TEMPLATE-SCHEMA.md**
   - Database patterns
   - Index recommendations
   - Monitoring queries

### How to Use This Documentation

- **Planning sprints**: Use MASTER-BACKLOG.md milestones M0-M20
- **Designing APIs**: Follow TEMPLATE-API.md patterns
- **Creating tables**: Use TEMPLATE-SCHEMA.md structure
- **Understanding system**: Read C4-ARCHITECTURE.md first
- **Onboarding**: Start with README.md, then MASTER-BACKLOG.md

---

## 🔑 Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **UUIDs for IDs** | Distributed, unguessable, standard |
| **PostgreSQL 16** | JSONB, window functions, reliability |
| **Event-driven** | Loose coupling, audit trail, replay capability |
| **Outbox pattern** | Transactional consistency, exactly-once |
| **Multi-tenant** | One codebase, many isolated customers |
| **White-label** | Each tenant has own branding/rules |

---

## 🎯 Milestones Overview

| Milestone | Focus | Duration |
|-----------|-------|----------|
| **M0** | Foundation (docs, conventions, build) | 1-2 days |
| **M1** | Local infrastructure (Keycloak, PG, LocalStack) | 2-3 days |
| **M2** | Cross-cutting libraries (errors, tenant, observability) | 1-2 days |
| **M3** | tenant-service (SSOT catalog) | 2-3 days |
| **M4** | user-bff + User App MVP | 2-3 days |
| **M5** | benefits-core (wallet/ledger) | 2-3 days |
| **M6-M12** | Additional BFFs, portals, core services | 2-3 days each |
| **M13-M15** | Advanced features (recon, settlement, privacy) | 2-3 days each |
| **M16-M18** | Observability, testing, performance | 2-3 days each |
| **M19** | AWS deployment (IaC, CI/CD) | 2-3 days |
| **M20** | Product completion (billing, docs, demo) | 1-2 days |

---

## 📦 Build Commands

```bash
# Clean, compile, test
./build.sh clean       # Remove build artifacts
./build.sh build       # Compile with Maven
./build.sh test        # Run unit + integration tests
./build.sh lint        # Check code quality

# Docker and validation
./build.sh docker-build    # Build service images
./build.sh validate        # Check environment

# Help
./build.sh help        # Show all commands
```

---

## 🧪 Testing

### Test Strategy

- **Unit Tests**: 80%+ coverage per service
- **Integration Tests**: Real DB (Testcontainers)
- **Contract Tests**: Pact matrix between BFFs and services
- **E2E Tests**: Playwright (web), Flutter (mobile)
- **Performance Tests**: k6 load scenarios

### Running Tests

```bash
./build.sh test                    # Run all Maven tests
cd tests/e2e && npm test          # E2E tests
cd tests/performance && k6 run    # Load tests
```

---

## 🔐 Security

- **Authentication**: OIDC/SAML via Keycloak
- **Authorization**: Role-based (platform_owner, admin_ops, employer_admin, etc.)
- **Secrets**: AWS Secrets Manager (prod), .env (dev)
- **Encryption**: TLS in transit, encrypted at rest
- **Tenant Isolation**: Strict multi-tenant filtering on all queries
- **Audit Trail**: Every material action logged with `correlation_id`

---

## 📊 Observability

### Logs

```bash
# View logs from a service
docker-compose logs -f [service-name]

# Search logs in Loki
# URL: http://localhost:3100
```

### Metrics

```
Prometheus: http://localhost:9090
Grafana: http://localhost:3000 (admin/admin)
```

### Traces

```
Jaeger: http://localhost:16686
Tempo: gRPC on localhost:4317
```

---

## 🤝 Contributing

### Code Standards

- **Java**: Follow Spring conventions, use meaningful names
- **APIs**: RESTful, follow TEMPLATE-API.md
- **Database**: Follow TEMPLATE-SCHEMA.md
- **Commits**: Descriptive messages, small atomic commits
- **PRs**: Link to MASTER-BACKLOG.md tasks

### Before Committing

```bash
./build.sh lint        # Check code quality
./build.sh test        # Run tests
git diff              # Review changes
```

---

## 🐛 Troubleshooting

### Common Issues

**"Connection refused" on PostgreSQL**
```bash
docker-compose logs postgres
docker-compose restart postgres
```

**"401 Unauthorized"**
- Check Keycloak is running: http://localhost:8080
- Verify token with: `curl http://localhost:8080/auth/realms/benefits`

**"502 Bad Gateway"**
- Check service logs: `docker-compose logs [service-name]`
- Verify service is listening on expected port

**Tests failing locally**
```bash
./build.sh clean       # Clean build
./build.sh test        # Run tests again
```

---

## 📞 Support

- **Documentation**: See `docs/` folder
- **Architecture Questions**: Read `docs/architecture/C4-ARCHITECTURE.md`
- **API Design**: See `docs/api/TEMPLATE-API.md`
- **Database**: See `docs/schemas/TEMPLATE-SCHEMA.md`
- **Troubleshooting**: Check runbooks in `docs/runbooks/`

---

## 📝 License

[To be defined]

---

## 🎉 Status

- **M0**: ✅ Complete (Foundation, docs, conventions)
- **M1**: ⏳ Ready to start (Local infrastructure)
- **M2-M20**: 📋 Planned (Features)

**Next**: Start M1 infrastructure setup!

---

**Last Updated**: 2026-01-16  
**Version**: 1.0 (M0 Foundation)

