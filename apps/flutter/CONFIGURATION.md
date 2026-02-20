# 🔧 Sistema de Configuração

## 📋 Visão Geral

Este projeto implementa um sistema de configuração flexível com **3 níveis de prioridade**:

1. **`--dart-define`** (maior prioridade)
2. **`LocalConfig`** (configuração local editável)
3. **Valores padrão** (fallback)

## 🎯 Como Funciona

### **Prioridade das Configurações:**

```dart
// 1. --dart-define (maior prioridade)
flutter run --dart-define=TEST_MODE=true

// 2. LocalConfig (configuração local)
// lib/core/config/local_config.dart
static const bool testMode = true;

// 3. Valor padrão (fallback)
bool.fromEnvironment('TEST_MODE', defaultValue: false)
```

## 🚀 Formas de Configurar

### **Opção 1: Editar LocalConfig (Recomendado para desenvolvimento)**

Edite o arquivo `lib/core/config/local_config.dart`:

```dart
class LocalConfig {
  /// Modo de teste - limpa storage para facilitar testes de primeiro acesso
  static const bool testMode = true;  // ← Altere aqui
  
  /// Modo de teste para "Esqueci minha senha"
  static const bool forgotPasswordTestMode = true;  // ← Altere aqui
  
  /// Força sempre o fluxo de login
  static const bool forceLoginMode = false;  // ← Altere aqui
}
```

### **Opção 2: Usar --dart-define (Para CI/CD ou sobrescrever)**

```bash
# Configuração básica
flutter run --dart-define=TEST_MODE=true

# Múltiplas configurações
flutter run --dart-define=TEST_MODE=true --dart-define=FORCE_LOGIN_MODE=true

# Configurações de segurança
flutter run --dart-define=MAX_LOGIN_ATTEMPTS=2 --dart-define=MAX_LOGIN_ATTEMPTS_PERMANENT=4

# Configurações de API
flutter run --dart-define=API_BASE_URL=https://api.teste.com --dart-define=API_TIMEOUT_SECONDS=60
```

## 🔧 Configurações Disponíveis

### **🧪 Configurações de Teste**

| Configuração | Descrição | Padrão |
|--------------|-----------|---------|
| `TEST_MODE` | Limpa storage para testes de primeiro acesso | `true` |
| `FORGOT_PASSWORD_TEST_MODE` | Ativa cenários específicos de "Esqueci minha senha" | `true` |
| `FORCE_LOGIN_MODE` | Força sempre o fluxo de login | `false` |

### **🔒 Configurações de Segurança**

| Configuração | Descrição | Padrão |
|--------------|-----------|---------|
| `MAX_LOGIN_ATTEMPTS` | Tentativas antes do bloqueio temporário | `3` |
| `MAX_LOGIN_ATTEMPTS_PERMANENT` | Tentativas antes do bloqueio permanente | `5` |
| `LOCKOUT_DURATION_MINUTES` | Duração do bloqueio temporário | `10` |

### **🌐 Configurações de API**

| Configuração | Descrição | Padrão |
|--------------|-----------|---------|
| `API_BASE_URL` | URL base da API | `https://api.exemplo.com` |
| `API_TIMEOUT_SECONDS` | Timeout da API em segundos | `30` |

### **📱 Configurações de Biometria**

| Configuração | Descrição | Padrão |
|--------------|-----------|---------|
| `BIOMETRIC_ENABLED_BY_DEFAULT` | Habilita biometria por padrão | `false` |

### **🔍 Configurações de Debug**

| Configuração | Descrição | Padrão |
|--------------|-----------|---------|
| `ENABLE_DEBUG_LOGS` | Habilita logs de debug | `true` |
| `NETWORK_DELAY_SECONDS` | Simula delays de rede | `1.0` |

## 📱 Exemplos de Uso

### **🧪 Testar Primeiro Acesso**

```bash
# Usando LocalConfig (já configurado)
flutter run

# Ou usando --dart-define
flutter run --dart-define=TEST_MODE=true
```

### **🔐 Forçar Sempre Login**

```bash
# Editar LocalConfig
static const bool forceLoginMode = true;

# Ou usar --dart-define
flutter run --dart-define=FORCE_LOGIN_MODE=true
```

### **🔑 Testar Recuperação de Senha**

```bash
# Usando LocalConfig (já configurado)
flutter run

# Ou usando --dart-define
flutter run --dart-define=FORGOT_PASSWORD_TEST_MODE=true
```

### **🔒 Testar Bloqueio de Conta**

```bash
# Bloqueio rápido para testes
flutter run --dart-define=MAX_LOGIN_ATTEMPTS=2 --dart-define=MAX_LOGIN_ATTEMPTS_PERMANENT=3
```

### **🌐 Configurar API de Teste**

```bash
# API local para desenvolvimento
flutter run --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_TIMEOUT_SECONDS=60
```

## 📋 Verificar Configuração Atual

Para ver todas as configurações atuais, use:

```dart
print(EnvConfig.currentConfig);
```

**Saída:**
```
🔧 CONFIGURAÇÃO ATUAL:
🧪 TEST_MODE: true
🔑 FORGOT_PASSWORD_TEST_MODE: true
🚫 FORCE_LOGIN_MODE: false
🔒 MAX_LOGIN_ATTEMPTS: 3
🔒 MAX_LOGIN_ATTEMPTS_PERMANENT: 5
⏰ LOCKOUT_DURATION_MINUTES: 10
🌐 API_BASE_URL: https://api.exemplo.com
⏱️ API_TIMEOUT_SECONDS: 30
📱 BIOMETRIC_ENABLED_BY_DEFAULT: false
🔍 ENABLE_DEBUG_LOGS: true
⏱️ NETWORK_DELAY_SECONDS: 1.0
🌍 ENVIRONMENT: DEVELOPMENT
📱 USE_MOCKS: true
```

## 💡 Dicas

1. **Para desenvolvimento:** Use `LocalConfig` - é mais rápido e não precisa de comandos longos
2. **Para CI/CD:** Use `--dart-define` para sobrescrever configurações
3. **Para testes específicos:** Combine `LocalConfig` com `--dart-define` para cenários complexos
4. **Sempre verifique:** Use `EnvConfig.currentConfig` para confirmar as configurações ativas

## 🔄 Fluxo de Configuração

```
1. --dart-define (se fornecido)
   ↓
2. LocalConfig (se não sobrescrito)
   ↓
3. Valor padrão (fallback)
```

## 📁 Estrutura de Arquivos

```
lib/core/config/
├── env_config.dart      # Sistema principal de configuração
├── local_config.dart    # Configurações locais editáveis
└── CONFIGURATION.md     # Esta documentação
```
