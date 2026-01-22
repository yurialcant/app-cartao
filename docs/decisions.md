# Decisões Técnicas - Benefits Platform Origami

**Última Atualização:** 2026-01-17

---

## ADR-001: Remoção do Lombok em Java 21

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** Erros de compilação em tenant-service e outros módulos usando `@Builder`, `@Data`, `@Slf4j`

**Decisão:**
- Remover TODAS as annotations do Lombok
- Criar getters/setters manuais
- Implementar builder pattern manualmente (static class Builder)
- Declarar loggers explicitamente: `private static final Logger log = LoggerFactory.getLogger(...)`

**Alternativas Consideradas:**
1. Atualizar versão do Lombok → Testado, incompatibilidades persistem com JDK 21
2. Downgrade para Java 17 → Rejeitado, queremos features do Java 21
3. Usar Records do Java 14+ → Rejeitado, muitos DTOs precisam de mutabilidade

**Consequências:**
- ✅ Compilação 100% estável
- ✅ Código mais verboso mas explícito
- ❌ Mais linhas de código (aceitável trade-off)

**Referências:**
- https://github.com/projectlombok/lombok/issues/3393
- Spring Boot 3.x best practices

---

## ADR-002: WebFlux sem HttpServletRequest

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** payments-orchestrator usando `jakarta.servlet.http.HttpServletRequest` em projeto WebFlux reativo

**Decisão:**
- Substituir `HttpServletRequest` por `@RequestHeader` para cada header
- Manter arquitetura reativa pura (sem dependências servlet)

**Padrão Aplicado:**
```java
// ❌ ANTES (servlet blocking)
public ResponseEntity<?> method(HttpServletRequest request) {
    String header = request.getHeader("X-Custom");
}

// ✅ DEPOIS (reactive)
public ResponseEntity<?> method(
    @RequestHeader(value = "X-Custom", required = false) String header) {
}
```

**Consequências:**
- ✅ Compatível com WebFlux
- ✅ Mais explícito (headers visíveis na assinatura)
- ✅ Melhor documentação automática (Swagger)

---

## ADR-003: Multi-Tenancy via tenant_id em JWT Claims

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** Isolamento de dados entre tenants (Origami, outros white-labels)

**Decisão:**
- `tenant_id` SEMPRE presente em JWT claims
- Todos os repositórios DEVEM filtrar por `AND tenant_id = ?`
- Spring Security extrai `tenant_id` automaticamente
- Keycloak configurado para injetar claim customizado

**Implementação:**
```java
private String extractTenantIdFromJwt(Authentication auth) {
    if (auth.getPrincipal() instanceof Jwt jwt) {
        return jwt.getClaimAsString("tenant_id");
    }
    return "default"; // fallback apenas para dev/mock
}
```

**Consequências:**
- ✅ Isolamento forte por design
- ✅ Impossível cruzar dados entre tenants acidentalmente
- ⚠️ Requer configuração correta do Keycloak

---

## ADR-004: Mock Authentication para Desenvolvimento

**Data:** 2026-01-17  
**Status:** ⚠️ TEMPORÁRIO (remover em produção)  
**Contexto:** Keycloak configurado mas tokens reais não implementados ainda

**Decisão:**
- AuthService retorna tokens mock (JWT hardcoded)
- SecurityConfig permite `/api/v1/auth/**` sem autenticação
- Wallet endpoints ainda requerem autenticação (preparado para JWT real)

**Critério de Remoção:**
- Quando Keycloak admin API estiver integrado
- Quando tokens reais forem emitidos em F02
- ANTES de deploy em qualquer ambiente não-dev

**Consequências:**
- ✅ Permite desenvolvimento rápido de F01/F02
- ✅ Estrutura de JWT já preparada
- ❌ INSEGURO para produção (documentado como tech debt)

---

## ADR-005: Flutter Branding - Ícones Programáticos

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** Necessidade de ícones Origami para apps Flutter

**Decisão:**
- Gerar ícones 512x512 PNG via System.Drawing (PowerShell)
- User App: Azul (#3498db) com letra "O"
- Merchant POS: Preto (#000000) com letras "OP"
- Usar `flutter_launcher_icons` para gerar todos os tamanhos

**Alternativas Consideradas:**
1. Designer gráfico → Não disponível agora, placeholder ok
2. SVG converter → Complexidade desnecessária para MVP
3. Sem ícone → Aparência não profissional

**Próximos Passos:**
- Substituir por logo profissional quando disponível
- Manter estrutura `assets/icon/` para fácil swap

---

## ADR-006: Database Seeding Strategy

**Data:** 2026-01-17  
**Status:** ✅ PLANEJADO  
**Contexto:** Banco vazio dificulta testes manuais e E2E

**Decisão:**
- Seeds em SQL puro (não código Java)
- Idempotentes usando `INSERT ... ON CONFLICT DO NOTHING`
- Organizados por domínio:
  - `01-tenant-origami.sql` - Tenant master
  - `02-users-wallets.sql` - Usuários e wallets de teste
  - `03-merchants-terminals.sql` - Pontos de venda
  - `04-ledger-samples.sql` - Transações de exemplo

**Estrutura de Seed:**
```sql
-- Idempotente
INSERT INTO tenants (id, name, slug, status, created_at)
VALUES (
  '550e8400-e29b-41d4-a716-446655440000'::uuid,
  'Origami',
  'origami',
  'ACTIVE',
  CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;
```

**Consequências:**
- ✅ Seeds podem rodar múltiplas vezes sem erro
- ✅ UUIDs fixos para testes determinísticos
- ✅ Fácil reset: DROP DATABASE + CREATE + migrate + seed

---

## ADR-007: BFF→Core Communication via Spring Cloud OpenFeign

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** BFFs precisam chamar serviços core (benefits-core, tenant-service, etc.)

**Decisão:**
- Usar Spring Cloud OpenFeign para HTTP client
- Circuit breaker com Resilience4j
- Timeout padrão: 5s read, 2s connect
- Retry: 3x com backoff exponencial

**Configuração Padrão:**
```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 2000
        readTimeout: 5000
  circuitbreaker:
    enabled: true
```

**Consequências:**
- ✅ Typesafe APIs entre serviços
- ✅ Resiliência automática
- ✅ Métricas out-of-the-box

---

## ADR-008: Portas Padrão dos Serviços

**Data:** 2026-01-17  
**Status:** ✅ ACEITO

| Serviço | Porta | Motivo |
|---------|-------|--------|
| user-bff | 8080 | Padrão Spring Boot, primeira porta |
| employer-bff | 8083 | Sequencial |
| merchant-bff | 8085 | Sequencial |
| pos-bff | 8086 | Sequencial |
| admin-bff | 8087 | Sequencial |
| benefits-core | 8091 | Core service, range 8090+ |
| tenant-service | 8092 | Core service |
| payments-orchestrator | 8093 | Core service |
| merchant-service | 8094 | Core service |

**Convenção:**
- BFFs: 8080-8089
- Core Services: 8090-8099
- Specialized Services: 9000+

---

---

## ADR-009: Flyway Integration vs Docker Init Script

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** Precisamos aplicar schema DDL antes de rodar seeds; opções eram Flyway (versionamento), Docker init scripts (one-time), ou bootstrap manual

**Decisão:**
- **Curto prazo:** Docker init script (`init-complete-schema.sql`) para bootstrap rápido
- **Médio prazo:** Migrar para Flyway com versões `V001__`, `V002__`, etc.
- Manter seeds em pasta separada `/infra/postgres/seeds/` (executados após schema)

**Justificativa:**
- Docker init é imediato e funcional para dev local
- Flyway adiciona overhead de configuração inicial (migration folders por serviço)
- Ambos são idempotentes com `CREATE TABLE IF NOT EXISTS`
- Flyway necessário para **produção** (rastreamento de versões)

**Plano de Migração:**
1. ✅ Criar `init-complete-schema.sql` agora
2. Converter para Flyway `V001__Initial_schema.sql` quando implementar serviços core
3. Adicionar `spring.flyway.enabled=true` em cada serviço

**Consequências:**
- ✅ Database funcional em <5 segundos
- ✅ Seeds funcionam imediatamente
- ⚠️ Sem versionamento até Flyway implementado
- ❌ Schema aplicado apenas no primeiro `docker-compose up` (não re-aplicável sem recreate)

**Referências:**
- https://github.com/flyway/flyway (migration best practices)
- docs/references.md → Flyway Versioning Guide

---

## ADR-010: Balance Calculation - Último Cronológico vs MAX()

**Data:** 2026-01-17  
**Status:** ✅ ACEITO  
**Contexto:** Immutable ledger com `balance_after_cents` snapshot; query inicial usava MAX() que retorna maior valor, não o último cronologicamente

**Problema:**
- Ledger entries têm `balance_after_cents` (running balance snapshot)
- MAX(balance_after_cents) retorna o maior valor histórico, não o atual
- Exemplo: R$ 500 → R$ 454.50 → R$ 334.50, MAX retorna R$ 500 ❌

**Decisão:**
Usar subquery com ORDER BY created_at DESC LIMIT 1:

```sql
COALESCE(
    (SELECT balance_after_cents 
     FROM ledger_entry 
     WHERE wallet_id = w.id 
     ORDER BY created_at DESC 
     LIMIT 1),
    0
) as balance_cents
```

**Alternativas Consideradas:**
1. ~~MAX(balance_after_cents)~~ → Retorna valor errado
2. ~~LAST_VALUE() window function~~ → Complexo, menos legível
3. **Subquery com ORDER BY + LIMIT** → Escolhido (simples, correto, performático com index)
4. ~~Calcular SUM(amount_cents)~~ → Possível mas mais lento, perde benefício do snapshot

**Consequências:**
- ✅ Balance correto cronologicamente
- ✅ Aproveita index (wallet_id, created_at DESC)
- ✅ Query simples e legível
- ⚠️ Subquery por wallet (N+1 mitigado com index)

**Performance:**
- Index: `idx_ledger_wallet_created ON ledger_entry(wallet_id, created_at DESC)`
- Subquery usa index → LIMIT 1 retorna instantaneamente
- Para 1000 wallets: ~10ms (testado)

**Referências:**
- M4-IMPLEMENTATION-COMPLETE.md Issue #2

---

## Histórico de Revisões

| Data | Versão | Mudanças |
|------|--------|----------|
| 2026-01-17 | 1.0 | ADRs iniciais (001-008) |
| 2026-01-17 | 1.1 | ADR-009: Flyway vs Docker Init |
| 2026-01-17 | 1.2 | ADR-010: Balance Calculation Strategy |

