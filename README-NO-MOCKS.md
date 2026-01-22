# 🚀 Benefits Platform - Modos de Execução (Com/Sem Mocks)

Este documento explica como executar o sistema Benefits em diferentes configurações, maximizando o uso de serviços reais e minimizando mocks.

## 📊 Visão Geral dos Modos

| Modo | Business Logic | Auth | AWS Services | External APIs | Mocks Usados |
|------|----------------|------|-------------|---------------|-------------|
| **Mínimo** | ✅ 100% | ❌ Desabilitada | ❌ Não usado | ❌ Não usado | 0% |
| **Desenvolvimento** | ✅ 100% | ✅ Keycloak Local | ✅ LocalStack | 🔄 Smart Stubs | 10% |
| **Completo** | ✅ 100% | ✅ Keycloak Local | ✅ LocalStack | ✅ APIs Reais | 0% |

---

## 🎯 MODO MÍNIMO (Sem Mocks - Business Logic Only)

### O que funciona:
- ✅ **benefits-core**: F05, F06, F07 100% funcionais
- ✅ **tenant-service**: Catálogo e multi-tenancy
- ✅ **Database**: Postgres + Redis reais
- ✅ **Business Logic**: Persistência, validações, ledger
- ✅ **API Endpoints**: REST completos sem auth

### O que NÃO funciona:
- ❌ **Autenticação**: Security desabilitada
- ❌ **BFFs**: Dependem de auth
- ❌ **External APIs**: SMS, email, KYC
- ❌ **AWS Services**: S3, SQS, EventBridge

### Como executar:

```bash
# 1. Infraestrutura mínima
docker-compose up -d postgres redis

# 2. Seeds (dados reais)
# (seeds aplicados automaticamente)

# 3. Serviços core
.\scripts\start-minimal-no-mocks.ps1

# 4. Testar end-to-end
.\scripts\test-minimal-end2end.ps1
```

### Endpoints disponíveis:
```bash
# Benefits Core (porta 8091)
POST /internal/batches/credits    # F05 - Credit Batch
POST /internal/authorize         # F06 - POS Authorize
POST /internal/refunds           # F07 - Refund
GET  /internal/batches/credits   # List batches

# Tenant Service (porta 8092)
GET  /actuator/health           # Health check
```

---

## 🛠️ MODO DESENVOLVIMENTO (Auth Local + AWS Local)

### O que funciona:
- ✅ **Tudo do modo mínimo**
- ✅ **Keycloak**: Autenticação JWT real
- ✅ **LocalStack**: AWS services simulados
- ✅ **BFFs**: Funcionais com auth real
- ✅ **Event-Driven**: Outbox + EventBridge locais

### O que ainda usa mocks:
- 🔄 **External APIs**: Smart stubs (fallback para real)
- 🔄 **Notifications**: SNS local (não envia reais)

### Como executar:

```bash
# 1. Infraestrutura completa
docker-compose up -d

# 2. Configurar Keycloak
.\scripts\setup-keycloak-integration.ps1

# 3. Configurar LocalStack
.\scripts\setup-localstack-complete.ps1

# 4. Iniciar tudo
.\scripts\start-everything.ps1

# 5. Testar completo
.\scripts\test-manual-apis.ps1
```

### Recursos disponíveis:
- 🔐 **Keycloak**: http://localhost:8080 (admin/admin)
- ☁️ **LocalStack**: http://localhost:4566
- 📊 **Grafana**: http://localhost:3000 (admin/admin)
- 📈 **Prometheus**: http://localhost:9090

---

## 🌟 MODO COMPLETO (Produção-Like)

### O que funciona:
- ✅ **Tudo do modo desenvolvimento**
- ✅ **External APIs reais** (se configuradas)
- ✅ **Notifications reais** (se credenciais)
- ✅ **Observabilidade completa**

### Pré-requisitos:
- Credenciais AWS reais (ou LocalStack)
- APIs externas configuradas (SMS, email, KYC)
- Certificados SSL (opcional)

### Como executar:

```bash
# Mesmo processo do desenvolvimento, mas com:
# - Credenciais reais para external services
# - APIs externas habilitadas
# - spring.profiles.active=production
```

---

## 🧪 Testes por Modo

### Mínimo (Sem Mocks):
```bash
.\scripts\test-minimal-end2end.ps1
# ✅ Business logic 100%
# ✅ Database persistence
# ✅ API contracts
```

### Desenvolvimento:
```bash
.\scripts\smoke.ps1
.\scripts\integration-test.ps1
# ✅ Auth flows
# ✅ BFF integration
# ✅ Event-driven
```

### Completo:
```bash
.\scripts\e2e-test.py
.\scripts\load-test.ps1
# ✅ Full user journeys
# ✅ Performance validation
# ✅ External integrations
```

---

## ⚙️ Configurações por Modo

### application.yml (Global):
```yaml
spring:
  profiles:
    active: local  # Base profile

  # Modo mínimo: adicionar no-external,no-auth
  # Modo desenvolvimento: adicionar keycloak,localstack
  # Modo completo: adicionar production
```

### Services específicos:

**benefits-core**:
- `minimal`: `no-external,no-auth`
- `development`: `keycloak,localstack`
- `full`: `production`

**user-bff**:
- `minimal`: `no-auth`
- `development`: `keycloak`
- `full`: `production`

---

## 🔧 Scripts de Configuração

### Setup Inicial:
```bash
.\scripts\setup-keycloak-integration.ps1    # Auth real
.\scripts\setup-localstack-complete.ps1     # AWS local
```

### Inicialização:
```bash
.\scripts\start-minimal-no-mocks.ps1        # Mínimo
.\scripts\start-everything.ps1              # Completo
```

### Testes:
```bash
.\scripts\test-minimal-end2end.ps1          # Mínimo
.\scripts\test-manual-apis.ps1              # Completo
```

---

## 📈 Benefícios dos Modos

### Mínimo (Recomendado para desenvolvimento puro):
- 🚀 **Inicialização rápida** (30s)
- 🎯 **Foco na business logic**
- 🔒 **Sem complexidade de auth**
- 🧪 **Testes determinísticos**

### Desenvolvimento (Recomendado para integração):
- 🔐 **Auth real** (desenvolvimento seguro)
- ☁️ **AWS local** (testes realistas)
- 🌐 **BFFs funcionais** (UI completa)
- 📊 **Observabilidade** (debugging)

### Completo (Pré-produção):
- 🏭 **Production-like**
- 🔄 **APIs reais** (validação completa)
- 📈 **Performance real**
- 🚀 **Deploy ready**

---

## 🎯 Recomendações

### Para Desenvolvimento Inicial:
```bash
# Use sempre o modo mínimo primeiro
.\scripts\start-minimal-no-mocks.ps1
```

### Para Desenvolvimento Completo:
```bash
# Use modo desenvolvimento após validar business logic
.\scripts\start-everything.ps1
```

### Para Testes de Produção:
```bash
# Use modo completo com credenciais reais
# Validar integração completa antes do deploy
```

**💡 Dica**: Comece sempre pelo modo mínimo para validar a business logic, depois adicione camadas de complexidade gradualmente.