# 🤖 MODO AGENT

**Objetivo:** Execução autônoma de tarefas, implementação direta, atualização de arquivos

---

## 🎯 **QUANDO USAR**

Use o modo AGENT quando:
- 🤖 Precisa implementar código diretamente
- 🤖 Precisa fazer mudanças em arquivos
- 🤖 Precisa executar comandos
- 🤖 Precisa atualizar documentação
- 🤖 Precisa completar tarefas end-to-end

---

## 📋 **COMPORTAMENTO ESPERADO**

### **1. Execução Autônoma**
- ✅ Implementar código sem pedir confirmação para cada passo
- ✅ Fazer mudanças necessárias em múltiplos arquivos
- ✅ Executar comandos quando necessário
- ✅ Atualizar documentação relacionada

### **2. Comunicação Ativa**
- ✅ Atualizar `docs/AGENT-COMMUNICATION.md` ao iniciar trabalho
- ✅ Atualizar `docs/AGENT-COMMUNICATION.md` com progresso
- ✅ Atualizar `docs/AGENT-COMMUNICATION.md` ao concluir
- ✅ Documentar mudanças feitas

### **3. Validação e Testes**
- ✅ Validar código após implementação
- ✅ Executar testes quando aplicável
- ✅ Verificar compilação/build
- ✅ Confirmar que mudanças funcionam

### **4. Documentação**
- ✅ Atualizar arquivos de documentação relacionados
- ✅ Adicionar comentários no código quando necessário
- ✅ Atualizar status em `docs/STATUS.md` se aplicável
- ✅ Criar/atualizar logs em `logs/` se necessário

---

## 📝 **PROTOCOLO DE EXECUÇÃO**

### **Antes de Começar:**
1. ✅ Ler prompt específico do seu papel
2. ✅ Ler `docs/AGENT-COMMUNICATION.md` para contexto
3. ✅ Verificar dependências e bloqueios
4. ✅ Atualizar `docs/AGENT-COMMUNICATION.md` com:
   - Papel ativo
   - Modo: AGENT
   - Tarefa iniciada
   - Timestamp

### **Durante Execução:**
1. ✅ Implementar código seguindo padrões do projeto
2. ✅ Seguir convenções do seu papel
3. ✅ Validar cada mudança importante
4. ✅ Atualizar `docs/AGENT-COMMUNICATION.md` com progresso

### **Após Concluir:**
1. ✅ Validar que tudo funciona
2. ✅ Executar testes se aplicável
3. ✅ Atualizar `docs/AGENT-COMMUNICATION.md` com:
   - Tarefa concluída
   - Resultados
   - Próximos passos
4. ✅ Atualizar `docs/STATUS.md` se necessário

---

## ⚠️ **REGRAS IMPORTANTES**

1. **SEMPRE atualize** `docs/AGENT-COMMUNICATION.md` antes e depois
2. **NÃO trabalhe** em áreas fora do seu papel sem consultar
3. **SEMPRE valide** mudanças antes de considerar concluído
4. **SEMPRE siga** padrões e convenções do projeto
5. **SEMPRE documente** mudanças significativas

---

## 🔗 **ARQUIVOS DE REFERÊNCIA**

- `docs/AGENT-COMMUNICATION.md` - **OBRIGATÓRIO** atualizar
- `docs/STATUS.md` - Status do projeto
- `.github/copilot-instructions.md` - Padrões gerais
- Prompt específico do seu papel - Padrões específicos

---

## 📊 **EXEMPLO DE ATUALIZAÇÃO EM AGENT-COMMUNICATION.md**

```markdown
#### **2026-01-18 HH:MM - [Seu Papel]**
- ✅ **FEITO:** [O que foi implementado]
- ✅ **FEITO:** [Validações realizadas]
- 🔄 **FAZENDO:** [O que está em progresso]
- 📍 **LOCAL:** [Arquivos/pastas modificados]
- 🔗 **PRÓXIMO:** [Próximo passo]
```

---

**Última Atualização:** 2026-01-18
