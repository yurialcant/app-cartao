# 📋 MODO PLAN

**Objetivo:** Criar planos de ação detalhados, breakdown de tarefas, estimativas

---

## 🎯 **QUANDO USAR**

Use o modo PLAN quando:
- 📋 Precisa criar um plano de implementação
- 📋 Precisa quebrar uma tarefa grande em subtarefas
- 📋 Precisa estimar esforço e dependências
- 📋 Precisa documentar estratégia de abordagem
- 📋 Precisa criar roadmap de execução

---

## 📋 **COMPORTAMENTO ESPERADO**

### **1. Breakdown de Tarefas**
- ✅ Dividir tarefas grandes em subtarefas menores
- ✅ Identificar dependências entre tarefas
- ✅ Definir ordem de execução
- ✅ Estimar esforço por tarefa

### **2. Análise de Dependências**
- ✅ Mapear dependências técnicas
- ✅ Mapear dependências entre agentes
- ✅ Identificar bloqueios potenciais
- ✅ Definir pré-requisitos

### **3. Estratégia de Abordagem**
- ✅ Definir abordagem técnica
- ✅ Identificar riscos e mitigações
- ✅ Propor alternativas
- ✅ Documentar decisões

### **4. Documentação de Plano**
- ✅ Criar arquivo de plano estruturado
- ✅ Incluir critérios de sucesso
- ✅ Incluir critérios de validação
- ✅ Incluir rollback plan se aplicável

---

## 📝 **FORMATO DE PLANO**

### **Estrutura de Plano:**

```markdown
# 📋 PLANO: [Título]

## 🎯 OBJETIVO
- O que será feito
- Por que é necessário
- Critérios de sucesso

## 📊 ANÁLISE INICIAL
- Estado atual
- Problemas a resolver
- Dependências identificadas

## 📋 BREAKDOWN DE TAREFAS

### Fase 1: [Nome]
**Duração estimada:** [X horas/dias]
**Dependências:** [Lista]

#### Tarefa 1.1: [Nome]
- **Descrição:** [O que fazer]
- **Esforço:** [Estimativa]
- **Responsável:** [Papel]
- **Critérios de sucesso:** [Como validar]

#### Tarefa 1.2: [Nome]
...

### Fase 2: [Nome]
...

## 🔗 DEPENDÊNCIAS
- **Técnicas:** [Lista]
- **Entre agentes:** [Lista]
- **Externas:** [Lista]

## ⚠️ RISCOS E MITIGAÇÕES
- **Risco 1:** [Descrição]
  - **Mitigação:** [Como evitar]
  - **Contingência:** [O que fazer se ocorrer]

## ✅ CRITÉRIOS DE VALIDAÇÃO
- [ ] Critério 1
- [ ] Critério 2
- [ ] Critério 3

## 🔄 ROLLBACK PLAN (se aplicável)
- Passos para reverter mudanças
- Como restaurar estado anterior

## 📅 TIMELINE
- **Início:** [Data]
- **Fase 1:** [Data início] - [Data fim]
- **Fase 2:** [Data início] - [Data fim]
- **Conclusão:** [Data estimada]
```

---

## ⚠️ **REGRAS**

1. **NÃO implemente código** em modo PLAN
2. **SEMPRE consulte** outros agentes para dependências
3. **SEMPRE valide** viabilidade técnica antes de planejar
4. **SEMPRE documente** riscos e alternativas
5. **SEMPRE atualize** `docs/AGENT-COMMUNICATION.md` com plano criado

---

## 🔗 **ARQUIVOS DE REFERÊNCIA**

- `docs/ROADMAP.md` - Roadmap geral do projeto
- `docs/AGENT-COMMUNICATION.md` - Coordenação entre agentes
- `docs/decisions.md` - Decisões técnicas (ADRs)
- `MASTER-BACKLOG.md` - Backlog completo

---

**Última Atualização:** 2026-01-18
