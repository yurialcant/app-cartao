# 🎭 CENÁRIOS COMPLETOS DE TESTE - FLUTTER LOGIN APP

## 📋 Visão Geral

Este documento descreve todos os cenários de teste disponíveis no sistema, incluindo dados de entrada, fluxos esperados e resultados esperados.

## 🎯 Configurações de Teste

### **Variáveis Ativas por Padrão:**
- ✅ `TEST_MODE = true` - Limpa storage para facilitar testes
- ✅ `USE_MOCKS = true` - Usa sistema de mocks 100%
- ✅ `FORGOT_PASSWORD_TEST_MODE = true` - Modo teste para recuperação
- ✅ `FORCE_LOGIN_MODE = false` - Permite fluxo normal
- ✅ `API_BASE_URL = https://api.exemplo.com` - URL mockada
- ✅ `API_TIMEOUT_SECONDS = 30` - Timeout das requisições
- ✅ `NETWORK_DELAY_SECONDS = 1.0` - Delay simulado de rede

---

## 🔍 CENÁRIO 1: PRIMEIRO ACESSO (NOVO USUÁRIO)

### **📱 Dados de Entrada:**
- **CPFs Válidos:** `11144477735`, `22255588846`
- **Token SMS:** `1234` (qualquer 4 dígitos)
- **Senha:** Deve seguir regras (6-8 chars, 1 maiúscula, 1 número, 1 especial)

### **🔄 Fluxo Completo:**
1. **Welcome Screen** → Digite CPF de primeiro acesso
2. **CPF Check** → Sistema identifica como `FIRST_ACCESS`
3. **Terms of Use** → Aceite os termos obrigatórios
4. **SMS Verification** → Digite token `1234`
5. **Password Registration** → Crie senha válida
6. **Success Message** → Confirmação de registro
7. **Dashboard** → Usuário logado e direcionado

### **✅ Senhas Válidas para Teste:**
- `Test123@` - 8 caracteres, maiúscula, número, especial
- `Senha1!` - 6 caracteres, maiúscula, número, especial
- `Abc123#` - 7 caracteres, maiúscula, número, especial

### **❌ Senhas Inválidas para Teste:**
- `test123@` - Falta maiúscula
- `Test123` - Falta caractere especial
- `Test@` - Muito curta (5 chars)
- `Teste12345@` - Muito longa (10 chars)

### **🎯 Resultado Esperado:**
- Usuário criado com sucesso
- Token de autenticação gerado
- Redirecionamento para dashboard
- Dados salvos no storage local

---

## 🔐 CENÁRIO 2: LOGIN (USUÁRIO EXISTENTE)

### **📱 Dados de Entrada:**
- **CPF:** `94691907009` → **Senha:** `Senha123@`
- **CPF:** `63254351096` → **Senha:** `Test123!`

### **🔄 Fluxo Completo:**
1. **Welcome Screen** → Digite CPF de usuário existente
2. **CPF Check** → Sistema identifica como `EXISTING_USER`
3. **Login Screen** → CPF já preenchido, digite a senha
4. **Dashboard** → Usuário autenticado e direcionado

### **✅ Comportamentos Esperados:**
- CPF é automaticamente passado para tela de login
- CPF mantém sua máscara (formato visual)
- Validação de credenciais em tempo real
- Redirecionamento imediato após login bem-sucedido

### **❌ Cenários de Erro:**
- **Senha incorreta:** Mensagem de erro e incremento de tentativas
- **CPF inválido:** Validação de formato
- **Conta bloqueada:** Mensagem específica de bloqueio

### **🎯 Resultado Esperado:**
- Login bem-sucedido
- Token de autenticação válido
- Dados do usuário carregados
- Redirecionamento para dashboard

---

## 🔑 CENÁRIO 3: RECUPERAÇÃO DE SENHA

### **📱 Dados de Entrada:**
- **CPFs Válidos:** `94691907009`, `63254351096`
- **Método:** SMS ou Email (ambos funcionam igual)
- **Token:** Qualquer 4 dígitos (exceto `0000`)
- **Nova Senha:** Deve seguir regras de validação

### **🔄 Fluxo Completo:**
1. **Login Screen** → Clique em "Esqueci minha senha"
2. **Method Selection** → Escolha SMS ou Email
3. **Token Input** → Digite token de 4 dígitos
4. **New Password** → Crie nova senha válida
5. **Success** → Senha alterada com sucesso
6. **Dashboard** → Usuário direcionado para dashboard

### **✅ Tokens de Teste:**
- **Válidos:** `1234`, `5678`, `9999`, `0001` (qualquer 4 dígitos)
- **Inválidos:** `0000` (simula falha), `123` (muito curto)

### **✅ Novas Senhas Válidas:**
- `Nova123@` - 8 caracteres, maiúscula, número, especial
- `Rec123!` - 7 caracteres, maiúscula, número, especial

### **🎯 Resultado Esperado:**
- Token enviado com sucesso
- Token validado corretamente
- Senha alterada com sucesso
- Redirecionamento para dashboard
- **IMPORTANTE:** Usuário vai para dashboard, NÃO para login

---

## 🔒 CENÁRIO 4: BLOQUEIO DE CONTA

### **📱 Dados de Entrada:**
- **CPF de Teste:** `94691907009`
- **Senha Incorreta:** Qualquer senha diferente de `Senha123@`

### **🔄 Fluxo para Bloqueio Temporário:**
1. **Login Screen** → Digite CPF e senha incorreta
2. **Erro** → Mensagem de credenciais inválidas
3. **Repita** → Digite senha incorreta mais 2 vezes
4. **Account Locked** → Conta bloqueada por 10 minutos
5. **Mensagem** → "Conta bloqueada temporariamente"

### **🔄 Fluxo para Bloqueio Permanente:**
1. **Continue** → Digite senha incorreta mais 2 vezes
2. **Account Permanently Locked** → Conta bloqueada permanentemente
3. **Mensagem** → "Conta bloqueada permanentemente"
4. **Instrução** → "Entre em contato com o suporte"

### **⏰ Regras de Bloqueio:**
- **3 tentativas incorretas** = Bloqueio temporário (10 minutos)
- **5 tentativas incorretas** = Bloqueio permanente
- **Reset automático** após 10 minutos (apenas para bloqueio temporário)

### **🎯 Resultado Esperado:**
- Contador de tentativas incrementado
- Mensagens de erro apropriadas
- Bloqueio progressivo implementado
- Proteção contra ataques de força bruta

---

## 📱 CENÁRIO 5: BIOMETRIA

### **📱 Pré-requisitos:**
- Usuário deve ter feito login com senha primeiro
- Biometria deve estar habilitada no dispositivo

### **🔄 Fluxo Completo:**
1. **Dashboard** → Clique no botão de biometria
2. **Biometric Auth** → Sistema simula autenticação
3. **Result** → Sucesso ou falha baseado na simulação

### **🎲 Simulação de Biometria:**
- **80% de sucesso** para testes realistas
- **20% de falha** para testar cenários de erro
- **Comportamento aleatório** a cada tentativa

### **✅ Cenário de Sucesso:**
- Autenticação biométrica bem-sucedida
- Usuário logado automaticamente
- Redirecionamento para dashboard

### **❌ Cenário de Falha:**
- Mensagem de erro biométrico
- Instruções para usar senha
- Usuário permanece na tela atual

### **🎯 Resultado Esperado:**
- Simulação realista de autenticação biométrica
- Tratamento adequado de sucesso e falha
- Integração com sistema de autenticação

---

## 🧪 CENÁRIO 6: MODOS DE TESTE ESPECIAIS

### **🔧 TEST_MODE = true**
**Comportamento:**
- Limpa todo o storage ao iniciar
- Facilita testes de primeiro acesso
- Reseta contadores de tentativas
- Remove dados de usuários anteriores

**Uso:**
- Para testar fluxo completo de primeiro acesso
- Para resetar estado da aplicação
- Para testes limpos e isolados

### **🔧 FORCE_LOGIN_MODE = true**
**Comportamento:**
- Sempre redireciona para login
- Ignora dados salvos
- Força fluxo de autenticação

**Uso:**
- Para testar fluxo de login
- Para ignorar estado salvo
- Para testes de autenticação

### **🔧 FORGOT_PASSWORD_TEST_MODE = true**
**Comportamento:**
- Simula cenários específicos de recuperação
- Token `0000` sempre falha
- Senha `Test123!` sempre falha

**Uso:**
- Para testar cenários de erro
- Para validar tratamento de falhas
- Para testes de recuperação de senha

---

## 🎯 EXECUÇÃO DOS TESTES

### **🚀 Script Automático (Recomendado):**
```powershell
# Execute o script PowerShell
.\run_full_test_system.ps1
```

### **🔧 Comando Manual:**
```bash
flutter run --debug --dart-define=TEST_MODE=true --dart-define=USE_MOCKS=true --dart-define=FORGOT_PASSWORD_TEST_MODE=true --dart-define=FORCE_LOGIN_MODE=false
```

### **📱 Pré-requisitos:**
- Dispositivo Android conectado ou emulador ativo
- Flutter instalado e configurado
- Dependências do projeto instaladas

---

## 📋 CHECKLIST DE TESTES

### **✅ Testes Obrigatórios:**
- [ ] **Primeiro Acesso:** CPF `11144477735` ou `22255588846`
- [ ] **Login Existente:** CPF `94691907009` com `Senha123@`
- [ ] **Login Existente:** CPF `63254351096` com `Test123!`
- [ ] **Recuperação de Senha:** CPF `94691907009` ou `63254351096`
- [ ] **Bloqueio Temporário:** 3 tentativas incorretas
- [ ] **Bloqueio Permanente:** 5 tentativas incorretas
- [ ] **Biometria:** Após login normal
- [ ] **Logout:** Limpa dados da sessão

### **✅ Testes de Validação:**
- [ ] **CPF Inválido:** Formato incorreto
- [ ] **Senha Inválida:** Não atende regras
- [ ] **Token Inválido:** Formato incorreto
- [ ] **Navegação:** Todas as telas acessíveis
- [ ] **Responsividade:** Diferentes tamanhos de tela

---

## 🎉 RESULTADO ESPERADO

Com todos os cenários testados, você deve conseguir:

1. ✅ **Sistema 100% funcional** sem dependências externas
2. ✅ **Todos os fluxos funcionando** corretamente
3. ✅ **Validações implementadas** e funcionando
4. ✅ **Tratamento de erros** adequado
5. ✅ **Navegação fluida** entre todas as telas
6. ✅ **Logs detalhados** no console para debug
7. ✅ **Mocks realistas** simulando comportamento de API
8. ✅ **Configurações flexíveis** para diferentes cenários

**🎯 O sistema está pronto para desenvolvimento e testes em produção!**

---

## 📚 DOCUMENTAÇÃO ADICIONAL

- **README.md** - Visão geral do projeto
- **API_DOCUMENTATION.md** - Documentação da API mockada
- **CONFIGURATION.md** - Sistema de configuração
- **run_full_test_system.ps1** - Script de execução automática

**💡 Dica:** Execute todos os cenários em sequência para validar o sistema completo!
