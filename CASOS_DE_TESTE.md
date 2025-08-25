# 🧪 CASOS DE TESTE - Carteira de Benefícios Flutter App

## 📋 **INFORMAÇÕES DO PROJETO**
- **Nome:** Carteira de Benefícios
- **Tecnologia:** Flutter/Dart
- **Versão:** 1.0.0
- **Data:** Janeiro 2025
- **Status:** ✅ COMPLETO

---

## 🔐 **PARTE 1: WelcomeScreen com Imagem de Fundo**

### **Cenário de Teste 1.1: Carregamento da Tela**
- **Objetivo:** Verificar se a tela carrega corretamente
- **Passos:**
  1. Abrir o aplicativo
  2. Aguardar carregamento da tela de boas-vindas
- **Resultado Esperado:**
  - ✅ Imagem de fundo `welcome_bg.jpg` exibida
  - ✅ Botão "Acessar" visível e centralizado
  - ✅ Status bar personalizada (Figma, 9:41 AM, Wi-Fi, Bluetooth, 100%)

### **Cenário de Teste 1.2: Navegação para CPF Check**
- **Objetivo:** Verificar navegação ao clicar no botão "Acessar"
- **Passos:**
  1. Na tela de boas-vindas, clicar no botão "Acessar"
- **Resultado Esperado:**
  - ✅ Transição suave para tela de CPF Check
  - ✅ Botão voltar funcional

---

## 🔍 **PARTE 2: CPF Check com Validação**

### **Cenário de Teste 2.1: Validação de CPF Válido**
- **Objetivo:** Verificar se CPFs válidos são aceitos
- **CPFs de Teste:**
  - `111.444.777-35` (Primeiro acesso)
  - `222.555.888-46` (Primeiro acesso)
  - `444.777.111-68` (Usuário existente)
  - `555.888.222-79` (Usuário existente)
- **Passos:**
  1. Na tela de CPF Check, digitar um CPF válido
  2. Clicar em "Continuar"
- **Resultado Esperado:**
  - ✅ Máscara aplicada automaticamente (###.###.###-##)
  - ✅ Validação em tempo real
  - ✅ Botão "Continuar" habilitado
  - ✅ Navegação para próxima tela

### **Cenário de Teste 2.2: Validação de CPF Inválido**
- **Objetivo:** Verificar se CPFs inválidos são rejeitados
- **CPFs de Teste:**
  - `111.111.111-11` (todos iguais)
  - `000.000.000-00` (todos zeros)
  - `123.456.789-09` (inválido)
  - `987.654.321-00` (inválido)
- **Passos:**
  1. Na tela de CPF Check, digitar um CPF inválido
  2. Clicar em "Continuar"
- **Resultado Esperado:**
  - ✅ Mensagem de erro exibida
  - ✅ Botão "Continuar" desabilitado
  - ✅ Navegação bloqueada

### **Cenário de Teste 2.3: Formatação Automática**
- **Objetivo:** Verificar se a máscara é aplicada corretamente
- **Passos:**
  1. Digitar números sem formatação (ex: 11144477735)
- **Resultado Esperado:**
  - ✅ Máscara aplicada automaticamente
  - ✅ Formato final: 111.444.777-35

---

## 📱 **PARTE 3: Seleção de Método (SMS/Email)**

### **Cenário de Teste 3.1: Primeiro Acesso - Seleção SMS**
- **Objetivo:** Verificar fluxo de primeiro acesso via SMS
- **Passos:**
  1. Usar CPF de primeiro acesso: `111.444.777-35`
  2. Na tela de seleção, escolher "SMS"
- **Resultado Esperado:**
  - ✅ Tela "Primeiro acesso" exibida
  - ✅ Opções SMS e Email visíveis
  - ✅ Seleção SMS funcional
  - ✅ Navegação para envio de token

### **Cenário de Teste 3.2: Primeiro Acesso - Seleção Email**
- **Objetivo:** Verificar fluxo de primeiro acesso via Email
- **Passos:**
  1. Usar CPF de primeiro acesso: `222.555.888-46`
  2. Na tela de seleção, escolher "Email"
- **Resultado Esperado:**
  - ✅ Seleção Email funcional
  - ✅ Navegação para envio de token

---

## 🔑 **PARTE 4: Autenticação por Token**

### **Cenário de Teste 4.1: Token Válido**
- **Objetivo:** Verificar se tokens válidos são aceitos
- **Tokens de Teste:**
  - `2222` (válido)
  - `1234` (válido)
- **Passos:**
  1. Na tela de token, digitar um token válido
  2. Aguardar validação
- **Resultado Esperado:**
  - ✅ 4 campos de entrada funcionais
  - ✅ Validação automática
  - ✅ Navegação para criação de senha

### **Cenário de Teste 4.2: Token Inválido**
- **Objetivo:** Verificar se tokens inválidos são rejeitados
- **Tokens de Teste:**
  - `1111` (inválido)
  - `0000` (expirado)
- **Passos:**
  1. Na tela de token, digitar um token inválido
  2. Aguardar validação
- **Resultado Esperado:**
  - ✅ Mensagem de erro exibida
  - ✅ Navegação bloqueada

### **Cenário de Teste 4.3: Reenvio de Token**
- **Objetivo:** Verificar funcionalidade de reenvio
- **Passos:**
  1. Na tela de token, clicar em "Reenviar"
- **Resultado Esperado:**
  - ✅ Countdown de 60 segundos iniciado
  - ✅ Botão desabilitado durante countdown
  - ✅ Novo token enviado

---

## 🔒 **PARTE 5: Criação de Senha**

### **Cenário de Teste 5.1: Senha Válida**
- **Objetivo:** Verificar se senhas válidas são aceitas
- **Senhas de Teste:**
  - `Test123!` (6-8 chars, números, maiúsculas/minúsculas, especiais)
  - `Abc123!` (válida)
- **Passos:**
  1. Na tela de criação de senha, digitar uma senha válida
  2. Confirmar a senha
  3. Clicar em "Criar senha"
- **Resultado Esperado:**
  - ✅ Validação em tempo real
  - ✅ Todos os requisitos atendidos
  - ✅ Modal de sucesso exibido
  - ✅ Navegação para dashboard

### **Cenário de Teste 5.2: Senha Inválida**
- **Objetivo:** Verificar se senhas inválidas são rejeitadas
- **Senhas de Teste:**
  - `teste123` (sem maiúsculas)
  - `TESTE123!` (sem minúsculas)
  - `Teste123` (sem caracteres especiais)
  - `Teste!` (muito curta)
  - `Teste123456!` (muito longa)
- **Passos:**
  1. Na tela de criação de senha, digitar uma senha inválida
- **Resultado Esperado:**
  - ✅ Mensagens de erro específicas
  - ✅ Botão "Criar senha" desabilitado
  - ✅ Navegação bloqueada

### **Cenário de Teste 5.3: Confirmação de Senha**
- **Objetivo:** Verificar se a confirmação de senha funciona
- **Passos:**
  1. Digitar senha válida
  2. Digitar confirmação diferente
- **Resultado Esperado:**
  - ✅ Mensagem de erro na confirmação
  - ✅ Botão "Criar senha" desabilitado

---

## 🏠 **PARTE 6: Dashboard Completo**

### **Cenário de Teste 6.1: Carregamento do Dashboard**
- **Objetivo:** Verificar se o dashboard carrega corretamente
- **Passos:**
  1. Acessar o dashboard após login/registro
- **Resultado Esperado:**
  - ✅ Saldo e informações da conta exibidos
  - ✅ Transações recentes visíveis
  - ✅ Serviços (Pix, Transferir, QR Code, Cartão) funcionais
  - ✅ Navegação inferior com 4 abas

### **Cenário de Teste 6.2: Navegação entre Abas**
- **Objetivo:** Verificar navegação entre as abas do dashboard
- **Passos:**
  1. Clicar em cada aba: Início, Serviços, Transações, Perfil
- **Resultado Esperado:**
  - ✅ Transição suave entre abas
  - ✅ Conteúdo específico de cada aba
  - ✅ Ícones e labels corretos

### **Cenário de Teste 6.3: Serviços Rápidos**
- **Objetivo:** Verificar funcionalidade dos botões de serviço
- **Passos:**
  1. Clicar em cada serviço: Pix, Transferir, QR Code, Cartão
- **Resultado Esperado:**
  - ✅ Modal/dialog específico para cada serviço
  - ✅ Mensagem informativa sobre funcionalidade futura

---

## 🔐 **PARTE 7: Sistema de Autenticação**

### **Cenário de Teste 7.1: Login Válido**
- **Objetivo:** Verificar se login com credenciais válidas funciona
- **Credenciais:**
  - **CPF:** Qualquer CPF válido
  - **Senha:** `Test123!`
- **Passos:**
  1. Na tela de login, digitar CPF válido
  2. Digitar senha válida
  3. Clicar em "Entrar"
- **Resultado Esperado:**
  - ✅ Validação bem-sucedida
  - ✅ Navegação para dashboard
  - ✅ Todas as telas anteriores removidas

### **Cenário de Teste 7.2: Login Inválido**
- **Objetivo:** Verificar se login com credenciais inválidas é rejeitado
- **Passos:**
  1. Na tela de login, digitar credenciais inválidas
  2. Clicar em "Entrar"
- **Resultado Esperado:**
  - ✅ Mensagem de erro exibida
  - ✅ Contador de tentativas incrementado
  - ✅ Navegação bloqueada

### **Cenário de Teste 7.3: Bloqueio de Conta**
- **Objetivo:** Verificar sistema de bloqueio após múltiplas tentativas
- **Passos:**
  1. Fazer 3 tentativas de login inválidas
- **Resultado Esperado:**
  - ✅ Conta bloqueada por 10 minutos
  - ✅ Mensagem de bloqueio exibida
  - ✅ Login bloqueado temporariamente

### **Cenário de Teste 7.4: Recuperação de Senha**
- **Objetivo:** Verificar funcionalidade de recuperação de senha
- **Passos:**
  1. Na tela de login, clicar em "Esqueci minha senha"
- **Resultado Esperado:**
  - ✅ Snackbar informativo exibido
  - ✅ Funcionalidade marcada para implementação futura

---

## 📱 **PARTE 8: Biometria**

### **Cenário de Teste 8.1: Verificação de Disponibilidade**
- **Objetivo:** Verificar se a biometria está disponível no dispositivo
- **Passos:**
  1. Acessar o dashboard
  2. Verificar se o botão de biometria está visível
- **Resultado Esperado:**
  - ✅ Botão de biometria visível se disponível
  - ✅ Ícone de fingerprint ou face conforme dispositivo
  - ✅ Botão oculto se biometria não disponível

### **Cenário de Teste 8.2: Autenticação Biométrica**
- **Objetivo:** Verificar funcionalidade de autenticação biométrica
- **Passos:**
  1. Clicar no botão de biometria
  2. Seguir instruções do sistema
- **Resultado Esperado:**
  - ✅ Prompt de autenticação biométrica exibido
  - ✅ Sucesso ou falha comunicada via Snackbar
  - ✅ Tratamento de erros adequado

---

## 🎭 **PARTE 9: Sistema de Mocks**

### **Cenário de Teste 9.1: Dados Mockados**
- **Objetivo:** Verificar se todos os dados mockados estão funcionando
- **Passos:**
  1. Testar todos os fluxos com dados mockados
- **Resultado Esperado:**
  - ✅ CPFs de teste funcionando
  - ✅ Tokens de teste funcionando
  - ✅ Senhas de teste funcionando
  - ✅ Fluxos completos funcionando

---

## 🎨 **PARTE 10: Segurança e Responsividade**

### **Cenário de Teste 10.1: Responsividade**
- **Objetivo:** Verificar se o app é responsivo em diferentes tamanhos
- **Passos:**
  1. Testar em diferentes resoluções de tela
  2. Testar orientação portrait e landscape
- **Resultado Esperado:**
  - ✅ Layout adaptável a diferentes tamanhos
  - ✅ Elementos visíveis e funcionais
  - ✅ Navegação funcional em todas as orientações

### **Cenário de Teste 10.2: Segurança**
- **Objetivo:** Verificar implementação de segurança
- **Passos:**
  1. Verificar validações de entrada
  2. Verificar sistema de bloqueio
- **Resultado Esperado:**
  - ✅ Validações de CPF funcionando
  - ✅ Validações de senha funcionando
  - ✅ Sistema de bloqueio funcionando
  - ✅ Navegação segura implementada

---

## 📊 **MATRIZ DE TESTES**

| Funcionalidade | Teste Manual | Teste Automatizado | Status |
|----------------|---------------|-------------------|---------|
| WelcomeScreen | ✅ | ⚠️ | Completo |
| CPF Check | ✅ | ✅ | Completo |
| Seleção Método | ✅ | ✅ | Completo |
| Token | ✅ | ✅ | Completo |
| Criação Senha | ✅ | ✅ | Completo |
| Dashboard | ✅ | ⚠️ | Completo |
| Login | ✅ | ✅ | Completo |
| Biometria | ✅ | ⚠️ | Completo |
| Mocks | ✅ | ✅ | Completo |
| Responsividade | ✅ | ⚠️ | Completo |

**Legenda:**
- ✅ **Completo:** Funcionalidade implementada e testada
- ⚠️ **Parcial:** Funcionalidade implementada, testes em desenvolvimento
- ❌ **Pendente:** Funcionalidade não implementada

---

## 🚀 **INSTRUÇÕES PARA EXECUÇÃO**

### **1. Preparação do Ambiente**
```bash
# Clone o repositório
git clone <url-do-repositorio>
cd flutter_login_app

# Instale as dependências
flutter pub get
```

### **2. Execução dos Testes**
```bash
# Testes unitários
flutter test test/unit/

# Testes de widget
flutter test test/widget/

# Testes de integração
flutter test test/integration/
```

### **3. Build e Deploy**
```bash
# Build de debug
flutter build apk --debug

# Build de release
flutter build apk --release
```

---

## 📝 **NOTAS IMPORTANTES**

1. **CPFs de Teste:** Todos os CPFs fornecidos são válidos matematicamente
2. **Tokens:** Use apenas os tokens especificados para teste
3. **Senhas:** Respeite os requisitos de complexidade
4. **Biometria:** Funcionalidade depende do hardware do dispositivo
5. **Mocks:** Sistema completo para desenvolvimento e teste

---

## 🔗 **LINKS ÚTEIS**

- **Repositório:** [GitHub](https://github.com/seu-usuario/flutter_login_app)
- **Documentação Flutter:** [flutter.dev](https://flutter.dev)
- **Testes Flutter:** [Testing Guide](https://docs.flutter.dev/testing)

---

**Documento gerado automaticamente em:** Janeiro 2025  
**Versão:** 1.0.0  
**Status:** ✅ COMPLETO
