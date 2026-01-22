# Referências Técnicas - Benefits Platform

**Última Atualização:** 2026-01-17

---

## 📚 Repositórios de Referência Estudados

Esta documentação registra todos os repositórios públicos utilizados como **inspiração e estudo** durante o desenvolvimento do Benefits Platform. Nenhum código foi copiado diretamente - apenas padrões e boas práticas foram adaptados ao nosso contexto.

---

### 1. Spring Cloud Samples - Microservices Patterns

**Repositório:** https://github.com/spring-cloud-samples  
**Estudado em:** 2026-01-17  
**Usado para:**
- Padrões de comunicação BFF → Services via Feign
- Circuit breaker com Resilience4j
- Service discovery (planejado para futuro)

**Aplicado em:**
- `bffs/user-bff/client/CoreServiceClient.java`
- Configurações `application.yml` dos BFFs
- ADR-007 (Feign communication)

**Lições Principais:**
- Timeouts conservadores (2s connect, 5s read)
- Circuit breaker por padrão em produção
- Health checks via Actuator

---

### 2. Spring Security OAuth2 Resource Server

**Repositório:** https://github.com/spring-projects/spring-security-samples  
**Estudado em:** 2026-01-17  
**Usado para:**
- JWT validation patterns
- Multi-tenancy via claims extraction
- SecurityConfig reactive (WebFlux)

**Aplicado em:**
- `bffs/user-bff/config/SecurityConfig.java`
- Método `extractTenantIdFromJwt()` em controllers
- ADR-003 (Multi-tenancy via JWT)

**Lições Principais:**
- Claims customizados requerem configuração no Keycloak
- `permitAll()` deve ser usado criteriosamente
- Reactive security usa `ServerHttpSecurity`, não `HttpSecurity`

---

### 3. Flyway Best Practices

**Repositório:** https://github.com/flyway/flyway  
**Estudado em:** 2026-01-17 (planejado)  
**Usado para:**
- Naming conventions para migrations (`V001__Initial_schema.sql`)
- Rollback strategies
- Baseline para databases existentes

**Aplicado em:**
- `services/benefits-core/src/main/resources/db/migration/` (futuro)
- Seeds idempotentes em `infra/postgres/seeds/`

**Lições Principais:**
- Migrations são append-only (nunca editar V001 depois de aplicado)
- Usar `ON CONFLICT DO NOTHING` para idempotência
- Separar schema (Flyway) de data (seeds SQL)

---

### 4. TestContainers - Integration Testing

**Repositório:** https://github.com/testcontainers/testcontainers-java  
**Estudado em:** 2026-01-17 (planejado)  
**Usado para:**
- Testes de integração com Postgres real
- R2DBC repositories testing
- Docker-based test infrastructure

**Aplicado em:**
- `test-db/` module (futuro)
- Integration tests nos serviços (planejado)

**Lições Principais:**
- Containers descartáveis por teste
- Fixtures via SQL scripts
- Compatível com JUnit 5 + Spring Boot Test

---

### 5. OpenAPI Generator - Contract-First Development

**Repositório:** https://github.com/OpenAPITools/openapi-generator  
**Estudado em:** 2026-01-17 (planejado)  
**Usado para:**
- Gerar clientes Feign a partir de contratos
- Gerar DTOs automaticamente
- Sincronizar BFFs com Core Services

**Aplicado em:**
- `docs/api/openapi/` (futuro)
- Maven plugin nos BFFs (planejado)

**Lições Principais:**
- Contracts primeiro, código depois
- Versionamento de APIs via OpenAPI 3.x
- Geração automática reduz erros de integração

---

### 6. Flutter BLoC Pattern

**Repositório:** https://github.com/felangel/bloc  
**Estudado em:** 2026-01-17 (planejado)  
**Usado para:**
- State management nos apps Flutter
- Separation of concerns (UI vs Business Logic)
- Reactive streams

**Aplicado em:**
- `apps/user_app_flutter/lib/bloc/` (futuro)
- `apps/merchant_pos_flutter/lib/bloc/` (futuro)

**Lições Principais:**
- BLoC para features complexas (autenticação, pagamentos)
- Provider para estado simples (tema, locale)
- Testing facilitado por separação clara

---

### 7. Keycloak Admin API Examples

**Repositório:** https://github.com/keycloak/keycloak-quickstarts  
**Estudado em:** 2026-01-17 (planejado)  
**Usado para:**
- Criar usuários programaticamente
- Configurar realms e clients
- Custom claims injection

**Aplicado em:**
- `bffs/user-bff/service/KeycloakAdminService.java` (futuro)
- ADR-003 (tenant_id injection)

**Lições Principais:**
- Admin API requer token de service account
- Usuários podem ter atributos customizados
- Realms por tenant vs realm único com atributos

---

### 8. Spring WebFlux - Reactive Patterns

**Repositório:** https://github.com/spring-projects/spring-framework  
**Estudado em:** 2026-01-17  
**Usado para:**
- Conversões `Flux<T>` → `List<T>`
- Reactive database access (R2DBC)
- Non-blocking controllers

**Aplicado em:**
- `services/tenant-service/service/CatalogService.java`
- ADR-001 (Flux conversions com `.collectList().block()`)

**Lições Principais:**
- `.block()` só em casos específicos (sync necessário)
- Preferir `Mono`/`Flux` em toda a stack
- R2DBC drivers para Postgres

---

### 9. Multi-Tenant SaaS Patterns

**Artigo/Repo:** https://github.com/microsoft/multitenant-saas-guidance  
**Estudado em:** 2026-01-17  
**Usado para:**
- Database per tenant vs Shared database + tenant_id
- Tenant isolation strategies
- Billing and metering

**Aplicado em:**
- ADR-003 (Multi-tenancy via tenant_id)
- Database schema design (todas tabelas têm `tenant_id`)

**Lições Principais:**
- Shared database + row-level isolation é mais barato para MVP
- Database per tenant escala melhor mas aumenta complexidade
- Tenant ID DEVE ser parte de todos os índices compostos

---

### 10. Flutter Launcher Icons

**Repositório:** https://github.com/fluttercommunity/flutter_launcher_icons  
**Estudado em:** 2026-01-17  
**Usado para:**
- Geração automática de ícones para Android/iOS
- Adaptive icons (Android)
- Configuração via `pubspec.yaml`

**Aplicado em:**
- `apps/user_app_flutter/pubspec.yaml`
- `apps/merchant_pos_flutter/pubspec.yaml`
- ADR-005 (Branding strategy)

**Lições Principais:**
- Ícone master 512x512 PNG suficiente
- Adaptive icons requerem foreground + background separados
- Plugin gera automaticamente todos os tamanhos

---

## 🔍 Critérios de Seleção de Referências

**Repositórios são estudados quando:**
1. Problema não trivial (ex: multi-tenancy, reactive patterns)
2. Necessidade de validar decisão arquitetural (ex: Feign vs RestTemplate)
3. Tecnologia nova para o time (ex: R2DBC, WebFlux)

**NÃO clonamos código quando:**
- Já sabemos o padrão (getters/setters manuais)
- Solução é trivial (criar POJO)
- Documentação oficial é suficiente

---

## 📖 Documentação Oficial Consultada

Além de repositórios, a documentação oficial foi extensivamente usada:

- **Spring Boot 3.4.x:** https://docs.spring.io/spring-boot/docs/3.4.x/reference/
- **Spring Security 6.x:** https://docs.spring.io/spring-security/reference/
- **Spring Cloud 2024.x:** https://spring.io/projects/spring-cloud
- **Keycloak 23.x:** https://www.keycloak.org/documentation
- **Flutter 3.x:** https://docs.flutter.dev/
- **PostgreSQL 15:** https://www.postgresql.org/docs/15/
- **Docker Compose:** https://docs.docker.com/compose/

---

## Histórico de Atualizações

| Data | Repositório Adicionado | Usado Em |
|------|------------------------|----------|
| 2026-01-17 | Spring Cloud Samples | BFF communication |
| 2026-01-17 | Spring Security Samples | JWT multi-tenancy |
| 2026-01-17 | Flutter Launcher Icons | App branding |
| 2026-01-17 | Spring WebFlux | Reactive services |
| 2026-01-17 | Multi-Tenant SaaS | Database design |

