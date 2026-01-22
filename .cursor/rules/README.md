# 📋 SISTEMA DE PROMPTS ORGANIZADOS

**Estrutura de prompts por papel e modo de operação**

---

## 🎯 **COMO USAR**

### **1. Seleção por Papel**
Cada agente deve usar o prompt específico do seu papel e se identificar com NOME ÚNICO:

| Prompt | Nome Único | Papel |
|--------|-----------|-------|
| `dev-backend.md` | `BackendDev` | Desenvolvedor Backend (Spring Boot, BFFs) |
| `dev-frontend.md` | `FrontendDev` | Desenvolvedor Frontend (Flutter, Angular) |
| `qa.md` | `QATester` | QA (Testes, validação) |
| `devops.md` | `DevOpsEng` | DevOps (Docker, CI/CD, infraestrutura) |
| `dba.md` | `DatabaseAdmin` | DBA (Migrations, schema, performance) |
| `architect.md` | `Architect` | Arquiteto (ADRs, padrões, decisões) |
| `scrum-master.md` | `ScrumMaster` | Scrum Master (Coordenação, bloqueios) |
| `po.md` | `ProductOwner` | Product Owner (Priorização, backlog) |
| `tech-lead.md` | `TechLead` | Tech Lead / Gerente (Visão geral, estratégia) |

**⚠️ OBRIGATÓRIO:** Sempre use seu NOME ÚNICO ao atualizar `docs/AGENT-COMMUNICATION.md`

### **2. Modos de Operação**
Cada prompt suporta diferentes modos de trabalho:

#### **🔍 DEBUG Mode**
- Análise detalhada de problemas
- Logs verbosos
- Rastreamento passo a passo
- Relatórios detalhados

#### **📋 PLAN Mode**
- Criação de planos de ação
- Breakdown de tarefas
- Estimativas e dependências
- Documentação de estratégias

#### **❓ ASK Mode**
- Respostas a perguntas específicas
- Consultas técnicas
- Explicações detalhadas
- Orientação sem implementação

#### **🤖 AGENT Mode**
- Execução autônoma de tarefas
- Implementação direta
- Atualização de arquivos
- Comunicação via AGENT-COMMUNICATION.md

---

## 📁 **ESTRUTURA DE ARQUIVOS**

```
.cursor/rules/
├── README.md (este arquivo)
├── dev-backend.md
├── dev-frontend.md
├── qa.md
├── devops.md
├── dba.md
├── architect.md
├── scrum-master.md
├── po.md
└── modes/
    ├── debug.md
    ├── plan.md
    ├── ask.md
    └── agent.md
```

---

## 🔄 **PROTOCOLO DE USO**

### **Ao Iniciar Trabalho:**
1. Declare seu papel (ex: "Sou Dev Backend")
2. Declare o modo (ex: "Modo AGENT")
3. Leia o prompt específico do seu papel
4. Leia o modo de operação se necessário
5. Atualize `docs/AGENT-COMMUNICATION.md` com:
   - Papel ativo
   - Modo de operação
   - Tarefa iniciada

### **Durante o Trabalho:**
- Siga as instruções do prompt do seu papel
- Respeite o modo de operação escolhido
- Atualize `docs/AGENT-COMMUNICATION.md` com progresso

### **Ao Terminar:**
- Atualize `docs/AGENT-COMMUNICATION.md` com:
   - Tarefa concluída
   - Resultados
   - Próximos passos

---

## 📊 **MATRIZ DE USO (OTIMIZADA)**

| Papel | DEBUG | PLAN | ASK | AGENT |
|-------|-------|------|-----|-------|
| **👨‍💻 Dev Backend** | ✅ **PRINCIPAL** | ✅ | ✅ | ✅ |
| **👨‍💻 Dev Frontend** | ✅ **PRINCIPAL** | ✅ | ✅ | ✅ |
| **🧪 QA** | ✅ | ✅ **PRINCIPAL** | ✅ **PRINCIPAL** | ✅ |
| **☁️ DevOps** | ✅ | ✅ | ✅ | ✅ **PRINCIPAL** |
| **🗄️ DBA** | ✅ | ✅ | ✅ | ✅ **PRINCIPAL** |
| **🏗️ Arquiteto** | ✅ | ✅ **PRINCIPAL** | ✅ **PRINCIPAL** | ⚠️ |
| **🔄 Scrum Master** | ✅ | ✅ **PRINCIPAL** | ✅ **PRINCIPAL** | ⚠️ |
| **📊 PO** | ✅ | ✅ **PRINCIPAL** | ✅ **PRINCIPAL** | ⚠️ |

**Legenda:**
- ✅ **PRINCIPAL** = Modo mais usado por esse papel (foco principal)
- ✅ = Modo suportado e disponível
- ⚠️ = Modo limitado (não implementa código, apenas documentação)

### **🎯 DISTRIBUIÇÃO OTIMIZADA:**

- **DEBUG:** Foco em **Dev Backend** e **Dev Frontend** (investigação de bugs)
- **PLAN:** Foco em **PO**, **QA**, **Arquiteto**, **Scrum Master** (planejamento)
- **ASK:** Foco em **PO**, **QA**, **Arquiteto**, **Scrum Master**, **Devs** (orientação)
- **AGENT:** Foco em **Dev Backend**, **Dev Frontend**, **QA**, **DevOps**, **DBA** (execução)

---

## 🎯 **EXEMPLOS DE USO**

### **Exemplo 1: Dev Backend em Modo AGENT**
```
Papel: Dev Backend
Modo: AGENT
Tarefa: Implementar endpoint POST /internal/batches/credits
```
→ Lê `dev-backend.md` + `modes/agent.md`
→ Implementa código diretamente
→ Atualiza `docs/AGENT-COMMUNICATION.md`

### **Exemplo 2: QA em Modo PLAN**
```
Papel: QA
Modo: PLAN
Tarefa: Criar plano de testes para F05
```
→ Lê `qa.md` + `modes/plan.md`
→ Cria plano detalhado
→ Documenta em `docs/PLANO-TESTES-F05.md`

### **Exemplo 3: Arquiteto em Modo ASK**
```
Papel: Arquiteto
Modo: ASK
Pergunta: Qual padrão usar para eventos assíncronos?
```
→ Lê `architect.md` + `modes/ask.md`
→ Responde com base em ADRs
→ Não implementa código

---

## ⚠️ **REGRAS IMPORTANTES**

1. **Nunca trabalhe fora do seu papel** sem consultar outros agentes
2. **Sempre atualize** `docs/AGENT-COMMUNICATION.md` ao iniciar/terminar
3. **Respeite o modo** escolhido (não implemente em modo ASK, por exemplo)
4. **Consulte prompts específicos** antes de começar qualquer trabalho
5. **Mantenha especialização** - não tente fazer tudo

---

**Última Atualização:** 2026-01-18  
**Versão:** 1.0
