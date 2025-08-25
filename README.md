# 🚀 Flutter Login App

Aplicativo Flutter completo com sistema de autenticação, primeiro acesso, recuperação de senha e biometria.

## 🎯 Funcionalidades Principais

- ✅ **Primeiro Acesso**: Registro de novos usuários
- ✅ **Login**: Autenticação com CPF e senha
- ✅ **Recuperação de Senha**: Via SMS ou Email
- ✅ **Biometria**: Login com digital/facial
- ✅ **Bloqueio de Conta**: Proteção contra ataques de força bruta
- ✅ **Sistema de Mocks**: API completa simulada para desenvolvimento

## 🧪 Sistema de Configuração

### **3 Níveis de Prioridade:**

1. **`--dart-define`** (maior prioridade) - Para CI/CD e produção
2. **`LocalConfig`** (prioridade média) - Para desenvolvimento local
3. **Valores padrão** (menor prioridade) - Fallback de segurança

### **Como Usar:**

#### **Opção 1: LocalConfig (Recomendado para Dev)**
Edite `lib/core/config/local_config.dart`:
```dart
class LocalConfig {
  static const bool testMode = true;           // Limpa storage para testes
  static const bool useMocks = true;           // Usa mocks em vez de API real
  static const bool forceLoginMode = false;    // Força fluxo de login
}
```

#### **Opção 2: --dart-define (Para CI/CD)**
```bash
flutter run --dart-define=TEST_MODE=true --dart-define=USE_MOCKS=true
```

### **Configurações Disponíveis:**

| Configuração | Descrição | Padrão |
|--------------|-----------|---------|
| `TEST_MODE` | Limpa storage para facilitar testes | `true` |
| `USE_MOCKS` | Usa mocks em vez de API real | `true` |
| `FORCE_LOGIN_MODE` | Sempre força fluxo de login | `false` |
| `FORGOT_PASSWORD_TEST_MODE` | Modo teste para recuperação | `true` |
| `API_BASE_URL` | URL base da API real | `https://api.exemplo.com` |
| `API_TIMEOUT_SECONDS` | Timeout das requisições | `30` |
| `NETWORK_DELAY_SECONDS` | Delay simulado de rede | `1.0` |

## 🎭 Cenários de Teste Completos

### **🔍 Cenário 1: Primeiro Acesso (Novo Usuário)**
**CPFs de Teste:** `11144477735`, `22255588846`

**Fluxo:**
1. **Welcome Screen** → Digite um CPF de primeiro acesso
2. **CPF Check** → Sistema identifica como primeiro acesso
3. **Terms of Use** → Aceite os termos
4. **SMS Verification** → Digite `1234` como token
5. **Password Registration** → Crie senha (6-8 chars, 1 maiúscula, 1 número, 1 especial)
6. **Success Message** → Confirmação de registro
7. **Dashboard** → Usuário logado e direcionado

**Senha Válida:** `Test123@` ou `Senha1!`

### **🔐 Cenário 2: Login (Usuário Existente)**
**CPFs de Teste:** `94691907009`, `63254351096`

**Credenciais:**
- **CPF:** `94691907009` → **Senha:** `Senha123@`
- **CPF:** `63254351096` → **Senha:** `Test123!`

**Fluxo:**
1. **Welcome Screen** → Digite CPF de usuário existente
2. **CPF Check** → Sistema identifica como usuário existente
3. **Login Screen** → CPF já preenchido, digite a senha
4. **Dashboard** → Usuário autenticado

### **🔑 Cenário 3: Recuperação de Senha**
**CPFs Válidos:** `94691907009`, `63254351096`

**Fluxo:**
1. **Login Screen** → Clique em "Esqueci minha senha"
2. **Method Selection** → Escolha SMS ou Email
3. **Token Input** → Digite qualquer token de 4 dígitos (exceto `0000`)
4. **New Password** → Crie nova senha seguindo as regras
5. **Success** → Senha alterada com sucesso
6. **Dashboard** → Usuário direcionado para dashboard

**Tokens de Teste:**
- ✅ **Válidos:** `1234`, `5678`, `9999` (qualquer 4 dígitos)
- ❌ **Inválidos:** `0000` (simula falha), `123` (muito curto)

### **🔒 Cenário 4: Bloqueio de Conta**
**CPF de Teste:** `94691907009`

**Fluxo para Bloqueio Temporário:**
1. **Login Screen** → Digite CPF e senha incorreta 3 vezes
2. **Account Locked** → Conta bloqueada por 10 minutos
3. **Wait** → Aguarde ou use outro CPF para teste

**Fluxo para Bloqueio Permanente:**
1. **Login Screen** → Digite CPF e senha incorreta 5 vezes
2. **Account Permanently Locked** → Conta bloqueada permanentemente
3. **Contact Support** → Mensagem para contatar suporte

### **📱 Cenário 5: Biometria**
**Requisitos:** Usuário deve ter feito login com senha primeiro

**Fluxo:**
1. **Dashboard** → Clique no botão de biometria
2. **Biometric Auth** → Sistema simula autenticação (80% sucesso)
3. **Result** → Sucesso ou falha baseado na simulação

### **🧪 Cenário 6: Modos de Teste Especiais**

#### **TEST_MODE = true**
- Limpa todo o storage ao iniciar
- Facilita testes de primeiro acesso
- Reseta contadores de tentativas

#### **FORCE_LOGIN_MODE = true**
- Sempre redireciona para login
- Ignora dados salvos
- Útil para testar fluxo de login

#### **FORGOT_PASSWORD_TEST_MODE = true**
- Simula cenários específicos de recuperação
- Token `0000` sempre falha
- Senha `Test123!` sempre falha

## 🚀 Como Executar o Sistema 100% Mockado

### **1. Configuração Local (Recomendado)**
Edite `lib/core/config/local_config.dart`:
```dart
class LocalConfig {
  static const bool testMode = true;           // ✅ Habilita modo teste
  static const bool useMocks = true;           // ✅ Usa mocks
  static const bool forceLoginMode = false;    // ✅ Permite fluxo normal
  static const bool forgotPasswordTestMode = true; // ✅ Modo teste recuperação
}
```

### **2. Executar no Android**
```bash
# Conecte um dispositivo Android ou emulador
flutter devices

# Execute com configurações de teste
flutter run --debug

# Ou para forçar modo de teste específico
flutter run --debug --dart-define=TEST_MODE=true --dart-define=USE_MOCKS=true
```

### **3. Testar Todos os Cenários**

#### **Cenário A: Primeiro Acesso Completo**
1. Use CPF: `11144477735`
2. Siga todo o fluxo até o dashboard
3. Verifique se usuário foi criado

#### **Cenário B: Login Existente**
1. Use CPF: `94691907009` com senha: `Senha123@`
2. Verifique se vai direto para dashboard
3. Teste logout e login novamente

#### **Cenário C: Recuperação de Senha**
1. Use CPF: `63254351096`
2. Clique em "Esqueci minha senha"
3. Escolha método SMS
4. Digite token: `1234`
5. Nova senha: `Nova123@`
6. Verifique se vai para dashboard

#### **Cenário D: Bloqueio de Conta**
1. Use CPF: `94691907009`
2. Digite senha incorreta 3 vezes
3. Verifique bloqueio temporário
4. Continue até 5 tentativas para bloqueio permanente

#### **Cenário E: Biometria**
1. Faça login normal primeiro
2. Ative biometria nas configurações
3. Teste login biométrico

## 🔧 Comandos Úteis

### **Limpar e Rebuild**
```bash
flutter clean
flutter pub get
flutter run --debug
```

### **Verificar Configurações Ativas**
```bash
flutter run --debug --dart-define=DEBUG_CONFIG=true
```

### **Executar Testes**
```bash
flutter test
```

## 📱 Estrutura da Aplicação

```
lib/
├── core/
│   ├── config/           # Configurações e variáveis de ambiente
│   ├── routing/          # Rotas e navegação
│   ├── services/         # Serviços base (HTTP, Biometria)
│   └── storage/          # Armazenamento local
├── data/
│   ├── models/           # Modelos de dados
│   └── services/         # Serviços de dados (Auth, API)
└── presentation/
    ├── screens/          # Telas da aplicação
    └── widgets/          # Widgets reutilizáveis
```

## 🌐 API Mockada

O sistema inclui uma API REST completa mockada com endpoints:

- `POST /api/v1/cpf/verify` - Verificação de CPF
- `POST /api/v1/auth/login` - Autenticação
- `POST /api/v1/auth/register` - Registro
- `POST /api/v1/auth/forgot-password` - Recuperação de senha
- `POST /api/v1/auth/verify-token` - Verificação de token
- `PUT /api/v1/auth/reset-password` - Alteração de senha
- `POST /api/v1/auth/biometric` - Login biométrico
- `POST /api/v1/auth/logout` - Logout

## 📋 Checklist de Testes

- [ ] **Primeiro Acesso:** CPF `11144477735` ou `22255588846`
- [ ] **Login Existente:** CPF `94691907009` com `Senha123@`
- [ ] **Login Existente:** CPF `63254351096` com `Test123!`
- [ ] **Recuperação de Senha:** CPF `94691907009` ou `63254351096`
- [ ] **Bloqueio Temporário:** 3 tentativas incorretas
- [ ] **Bloqueio Permanente:** 5 tentativas incorretas
- [ ] **Biometria:** Após login normal
- [ ] **Logout:** Limpa dados da sessão
- [ ] **Navegação:** Todas as telas acessíveis
- [ ] **Validações:** Senhas, CPFs, tokens

## 🎉 Resultado Esperado

Com todas as configurações corretas, você deve conseguir:
1. ✅ Testar primeiro acesso completo
2. ✅ Fazer login com usuários existentes
3. ✅ Recuperar senhas
4. ✅ Testar bloqueios de conta
5. ✅ Usar biometria
6. ✅ Navegar por todas as telas
7. ✅ Ver logs detalhados no console
8. ✅ Sistema 100% funcional sem dependências externas

**🎯 O sistema está pronto para desenvolvimento e testes!**
