# 🌐 Documentação da API

## 📋 Visão Geral

Esta documentação descreve todos os endpoints que devem ser implementados no backend (Spring Boot) para que o app Flutter funcione corretamente.

## 🔗 Base URL

```
https://api.exemplo.com/api/v1
```

## 📊 Formato das Respostas

### **Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    // Dados específicos do endpoint
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### **Resposta de Erro:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Mensagem de erro para o usuário",
    "details": "Detalhes técnicos do erro"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## 🔍 Endpoints

### **1. Verificação de CPF**

#### **POST /api/v1/cpf/verify**

Verifica se o CPF é cadastrado e direciona o fluxo.

**Request Body:**
```json
{
  "cpf": "94691907009"
}
```

**Resposta de Sucesso (Primeiro Acesso):**
```json
{
  "success": true,
  "data": {
    "cpf": "94691907009",
    "status": "FIRST_ACCESS",
    "message": "CPF elegível para primeiro acesso",
    "requiresRegistration": true
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Sucesso (Usuário Existente):**
```json
{
  "success": true,
  "data": {
    "cpf": "94691907009",
    "status": "EXISTING_USER",
    "message": "Usuário já cadastrado",
    "requiresRegistration": false
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro:**
```json
{
  "success": false,
  "error": {
    "code": "CPF_NOT_FOUND",
    "message": "CPF não encontrado no sistema",
    "details": "Este CPF não está elegível para cadastro ou login"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

### **2. Autenticação**

#### **POST /api/v1/auth/login**

Realiza login do usuário.

**Request Body:**
```json
{
  "cpf": "94691907009",
  "password": "Senha123@"
}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "user": {
      "cpf": "94691907009",
      "name": "João Silva",
      "email": "joao.silva@email.com",
      "phone": "(11) 99999-9999",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "lastLogin": "2024-01-15T10:30:00.000Z",
      "isActive": true,
      "roles": ["user"]
    },
    "token": "abc123def456...",
    "expiresAt": "2024-01-16T10:30:00.000Z"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro (Conta Bloqueada):**
```json
{
  "success": false,
  "error": {
    "code": "ACCOUNT_LOCKED",
    "message": "Conta bloqueada temporariamente",
    "details": "Tente novamente em 8 minutos",
    "remainingMinutes": 8
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro (Credenciais Inválidas):**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "CPF ou senha incorretos",
    "details": "Verifique suas credenciais e tente novamente"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

#### **POST /api/v1/auth/register**

Registra novo usuário.

**Request Body:**
```json
{
  "cpf": "11144477735",
  "password": "Test123@"
}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "user": {
      "cpf": "11144477735",
      "name": "Usuário 111",
      "email": null,
      "phone": null,
      "createdAt": "2024-01-15T10:30:00.000Z",
      "lastLogin": "2024-01-15T10:30:00.000Z",
      "isActive": true,
      "roles": ["user"]
    },
    "token": "abc123def456...",
    "message": "Usuário registrado com sucesso"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro (CPF Não Elegível):**
```json
{
  "success": false,
  "error": {
    "code": "CPF_NOT_ELIGIBLE",
    "message": "CPF não elegível para registro",
    "details": "Este CPF não está na lista de elegíveis"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro (Senha Inválida):**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_PASSWORD",
    "message": "Senha não atende aos requisitos",
    "details": "A senha deve ter 6-8 caracteres, uma maiúscula, um número e um caractere especial"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

### **3. Recuperação de Senha**

#### **POST /api/v1/auth/forgot-password**

Inicia processo de recuperação de senha.

**Request Body:**
```json
{
  "cpf": "94691907009",
  "method": "sms"
}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "message": "Token de recuperação enviado com sucesso",
    "method": "sms",
    "cpf": "94691907009",
    "tokenExpiresAt": "2024-01-15T10:40:00.000Z"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro:**
```json
{
  "success": false,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "Usuário não encontrado",
    "details": "Este CPF não está cadastrado no sistema"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

#### **POST /api/v1/auth/verify-token**

Verifica token de recuperação.

**Request Body:**
```json
{
  "cpf": "94691907009",
  "method": "sms",
  "token": "1234"
}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "message": "Token verificado com sucesso",
    "cpf": "94691907009",
    "method": "sms",
    "token": "1234"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Token inválido",
    "details": "O token informado não é válido"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

#### **PUT /api/v1/auth/reset-password**

Altera senha após recuperação.

**Request Body:**
```json
{
  "cpf": "94691907009",
  "method": "sms",
  "token": "1234",
  "newPassword": "New123@"
}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "message": "Senha alterada com sucesso",
    "cpf": "94691907009",
    "passwordChangedAt": "2024-01-15T10:30:00.000Z"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_PASSWORD",
    "message": "Nova senha não atende aos requisitos",
    "details": "A senha deve ter 6-8 caracteres, uma maiúscula, um número e um caractere especial"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

### **4. Biometria**

#### **POST /api/v1/auth/biometric**

Login com biometria.

**Request Body:**
```json
{}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "user": {
      "cpf": "94691907009",
      "name": "João Silva",
      "email": "joao.silva@email.com",
      "phone": "(11) 99999-9999",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "lastLogin": "2024-01-15T10:30:00.000Z",
      "isActive": true,
      "roles": ["user"]
    },
    "token": "abc123def456...",
    "expiresAt": "2024-01-16T10:30:00.000Z"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Resposta de Erro:**
```json
{
  "success": false,
  "error": {
    "code": "BIOMETRIC_FAILED",
    "message": "Autenticação biométrica falhou",
    "details": "Tente novamente ou use sua senha"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

### **5. Logout**

#### **POST /api/v1/auth/logout**

Realiza logout do usuário.

**Request Body:**
```json
{}
```

**Resposta de Sucesso:**
```json
{
  "success": true,
  "data": {
    "message": "Logout realizado com sucesso"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## 🔒 Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `CPF_NOT_FOUND` | CPF não encontrado no sistema |
| `CPF_NOT_ELIGIBLE` | CPF não elegível para registro |
| `INVALID_CREDENTIALS` | CPF ou senha incorretos |
| `ACCOUNT_LOCKED` | Conta bloqueada temporariamente |
| `ACCOUNT_PERMANENTLY_LOCKED` | Conta bloqueada permanentemente |
| `USER_NOT_FOUND` | Usuário não encontrado |
| `INVALID_PASSWORD` | Senha não atende aos requisitos |
| `INVALID_TOKEN` | Token inválido |
| `INVALID_TOKEN_FORMAT` | Formato de token inválido |
| `BIOMETRIC_FAILED` | Autenticação biométrica falhou |
| `HTTP_ERROR` | Erro na requisição HTTP |
| `NETWORK_ERROR` | Erro de conexão |

---

## 📱 Requisitos de Senha

A senha deve atender aos seguintes critérios:
- **Comprimento:** 6 a 8 caracteres
- **Letra maiúscula:** Pelo menos uma
- **Número:** Pelo menos um
- **Caractere especial:** Pelo menos um (!@#$%^&*(),.?":{}|<>)

---

## ⏱️ Timeouts

- **Timeout padrão:** 30 segundos
- **Token de recuperação:** Expira em 10 minutos
- **Token de autenticação:** Expira em 24 horas

---

## 🔄 Estados do Usuário

| Status | Descrição |
|--------|-----------|
| `FIRST_ACCESS` | CPF elegível para primeiro acesso |
| `EXISTING_USER` | Usuário já cadastrado |
| `ACTIVE` | Usuário ativo |
| `LOCKED` | Usuário bloqueado temporariamente |
| `PERMANENTLY_LOCKED` | Usuário bloqueado permanentemente |

---

## 📋 Headers

### **Headers de Request:**
```
Content-Type: application/json
Accept: application/json
User-Agent: FlutterApp/1.0.0
```

### **Headers de Response:**
```
Content-Type: application/json
Cache-Control: no-cache
```

---

## 🧪 Dados de Teste

### **CPFs para Primeiro Acesso:**
- `111.444.777-35`
- `222.555.888-46`

### **CPFs para Usuário Existente:**
- `946.919.070-09` → Senha: `Senha123@`
- `632.543.510-96` → Senha: `Test123!`

### **Token de Teste:**
- `1234` (válido)
- `0000` (inválido - simula falha)

---

## 🚀 Implementação no Spring Boot

### **Estrutura de Pacotes Recomendada:**
```
com.exemplo.api
├── controller
│   ├── AuthController.java
│   └── CpfController.java
├── service
│   ├── AuthService.java
│   ├── CpfService.java
│   └── UserService.java
├── repository
│   └── UserRepository.java
├── model
│   ├── User.java
│   ├── LoginRequest.java
│   └── ApiResponse.java
└── exception
    └── GlobalExceptionHandler.java
```

### **Exemplo de Controller:**
```java
@RestController
@RequestMapping("/api/v1")
public class CpfController {
    
    @PostMapping("/cpf/verify")
    public ResponseEntity<ApiResponse> verifyCpf(@RequestBody CpfRequest request) {
        // Implementação
    }
}
```

---

## 📝 Notas Importantes

1. **Validação de CPF:** Implementar validação completa de CPF
2. **Segurança:** Usar HTTPS e implementar rate limiting
3. **Logs:** Registrar todas as tentativas de login e operações sensíveis
4. **Cache:** Implementar cache para tokens e dados de usuário
5. **Monitoramento:** Adicionar métricas e alertas
6. **Testes:** Implementar testes unitários e de integração

---

## 🔗 URLs de Exemplo

```
Base: https://api.exemplo.com/api/v1

CPF Verify: https://api.exemplo.com/api/v1/cpf/verify
Login: https://api.exemplo.com/api/v1/auth/login
Register: https://api.exemplo.com/api/v1/auth/register
Forgot Password: https://api.exemplo.com/api/v1/auth/forgot-password
Verify Token: https://api.exemplo.com/api/v1/auth/verify-token
Reset Password: https://api.exemplo.com/api/v1/auth/reset-password
Biometric: https://api.exemplo.com/api/v1/auth/biometric
Logout: https://api.exemplo.com/api/v1/auth/logout
```
