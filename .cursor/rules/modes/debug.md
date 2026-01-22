# 🔍 MODO DEBUG

**Objetivo:** Análise detalhada, rastreamento passo a passo, logs verbosos

---

## 🎯 **QUANDO USAR**

Use o modo DEBUG quando:
- ❓ Precisa investigar um problema complexo
- ❓ Precisa entender o fluxo completo de execução
- ❓ Precisa rastrear dados passo a passo
- ❓ Precisa gerar relatórios detalhados
- ❓ Precisa analisar estado atual do sistema

---

## 📋 **COMPORTAMENTO ESPERADO**

### **1. Análise Detalhada**
- ✅ Ler TODOS os arquivos relevantes antes de responder
- ✅ Analisar logs, erros, stack traces completamente
- ✅ Rastrear dependências e fluxos de dados
- ✅ Verificar estado de todos os componentes relacionados

### **2. Logs Verbosos**
- ✅ Explicar cada passo do raciocínio
- ✅ Mostrar o que foi lido/analisado
- ✅ Documentar descobertas intermediárias
- ✅ Exibir comandos executados e resultados

### **3. Rastreamento Passo a Passo**
- ✅ Quebrar problemas complexos em etapas menores
- ✅ Validar cada etapa antes de prosseguir
- ✅ Documentar decisões tomadas em cada etapa
- ✅ Mostrar evidências de cada conclusão

### **4. Relatórios Detalhados**
- ✅ Criar relatórios completos com:
  - Estado atual do sistema
  - Problemas identificados
  - Análise de causa raiz
  - Soluções propostas
  - Próximos passos

---

## 📝 **FORMATO DE SAÍDA**

### **Estrutura de Relatório DEBUG:**

```markdown
# 🔍 DEBUG REPORT: [Título]

## 📊 ESTADO ATUAL
- Componentes analisados
- Estado de cada componente
- Dependências mapeadas

## 🔍 ANÁLISE DETALHADA
### Passo 1: [Descrição]
- O que foi verificado
- O que foi encontrado
- Conclusão

### Passo 2: [Descrição]
...

## 🐛 PROBLEMAS IDENTIFICADOS
- Problema 1: [Descrição]
  - Causa raiz
  - Impacto
  - Evidências

## 💡 SOLUÇÕES PROPOSTAS
- Solução 1: [Descrição]
  - Passos
  - Riscos
  - Alternativas

## 🎯 PRÓXIMOS PASSOS
1. [Ação]
2. [Ação]
```

---

## ⚠️ **REGRAS**

1. **NÃO implemente código** em modo DEBUG
2. **NÃO faça mudanças** sem documentar análise completa
3. **SEMPRE documente** descobertas em relatórios
4. **SEMPRE valide** hipóteses antes de concluir
5. **SEMPRE mostre evidências** de cada conclusão

---

## 🔗 **ARQUIVOS DE REFERÊNCIA**

- `docs/STATUS.md` - Estado atual do projeto
- `docs/AGENT-COMMUNICATION.md` - Comunicação entre agentes
- `docs/issues.md` - Problemas conhecidos
- `logs/` - Logs históricos

---

**Última Atualização:** 2026-01-18
