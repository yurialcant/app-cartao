# 🚀 **DOCUMENTAÇÃO COMPLETA DA API - TODOS OS BOTÕES E AÇÕES**

## 📋 **VISÃO GERAL**

Esta documentação descreve **TODAS** as rotas da API que serão consumidas pelo Flutter App através de um BFF (Backend for Frontend) Spring Boot rodando em `localhost:8080`.

### **🏗️ Arquitetura**
```
Flutter App → BFF Spring Boot (localhost:8080) → Microserviços
```

### **🔐 Autenticação**
- **JWT Token** no header `Authorization: Bearer {token}`
- **Refresh Token** para renovação automática
- **Session Token** para fluxos temporários (primeiro acesso, recuperação)

---

## 📱 **FLUXOS DE AUTENTICAÇÃO - TELA POR TELA**

### **1. 🔍 TELA: VERIFICAÇÃO DE CPF**

#### **Botão: "Continuar"**
- **Endpoint:** `POST /api/v1/auth/cpf/verify`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response - CPF Existe (Primeiro Acesso):**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "isFirstAccess": true,
    "userStatus": "PENDING_REGISTRATION",
    "message": "CPF encontrado. Usuário deve completar primeiro acesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response - CPF Existe (Usuário Cadastrado):**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "isFirstAccess": false,
    "userStatus": "ACTIVE",
    "hasPassword": true,
    "message": "CPF encontrado. Usuário pode fazer login."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **2. 📋 TELA: TERMOS DE USO**

#### **Botão: "Aceitar e Continuar"**
- **Endpoint:** `POST /api/v1/auth/terms/accept`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "termsAccepted": true,
  "privacyAccepted": true,
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "termsAccepted": true,
    "privacyAccepted": true,
    "acceptedAt": "2025-08-25T15:30:00Z",
    "message": "Termos aceitos com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **3. 📧 TELA: SELEÇÃO DE MÉTODO (PRIMEIRO ACESSO)**

#### **Botão: "Enviar por SMS"**
- **Endpoint:** `POST /api/v1/auth/first-access/send-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "SMS",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "SMS",
    "phone": "11987654321", // Telefone parcial (últimos 4 dígitos)
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Token enviado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Enviar por e-mail"**
- **Endpoint:** `POST /api/v1/auth/first-access/send-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "EMAIL",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "EMAIL",
    "email": "jo***@em***.com", // Email parcial (primeiras e últimas letras)
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Token enviado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **4. 🔑 TELA: INSERÇÃO DE TOKEN (PRIMEIRO ACESSO)**

#### **Botão: "Verificar token"**
- **Endpoint:** `POST /api/v1/auth/first-access/verify-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "SMS",
  "token": "1234",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "tokenValid": true,
    "sessionToken": "jwt-token-temporario",
    "expiresAt": "2025-08-25T15:40:00Z",
    "message": "Token verificado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Reenviar token"**
- **Endpoint:** `POST /api/v1/auth/first-access/resend-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "SMS",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "SMS",
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Token reenviado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Enviar por SMS" / "Enviar por e-mail" (Alternância)**
- **Endpoint:** `POST /api/v1/auth/first-access/change-method`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "currentMethod": "SMS",
  "newMethod": "EMAIL",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "EMAIL",
    "email": "jo***@em***.com", // Email parcial para mostrar na tela
    "phone": "11987654321", // Telefone anterior (para referência)
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Método alterado para e-mail. Token enviado."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **5. 📝 TELA: REGISTRO DE USUÁRIO**

#### **Botão: "Criar conta"**
- **Endpoint:** `POST /api/v1/auth/first-access/register`
- **Token:** `sessionToken` (do passo anterior)
- **Request:**
```json
{
  "cpf": "12345678901",
  "sessionToken": "jwt-token-temporario",
  "userData": {
    "name": "João Silva",
    "email": "joao.silva@email.com",
    "phone": "11987654321",
    "password": "Senha123!",
    "termsAccepted": true,
    "privacyAccepted": true
  },
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user-id",
      "cpf": "12345678901",
      "name": "João Silva",
      "email": "joao.silva@email.com",
      "phone": "11987654321",
      "status": "ACTIVE",
      "createdAt": "2025-08-25T15:30:00Z"
    },
    "authToken": "jwt-auth-token",
    "refreshToken": "jwt-refresh-token",
    "expiresAt": "2025-08-25T16:30:00Z",
    "message": "Usuário registrado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **6. 🔐 TELA: LOGIN**

#### **Botão: "Entrar"**
- **Endpoint:** `POST /api/v1/auth/login`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "password": "Senha123!",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user-id",
      "cpf": "12345678901",
      "name": "João Silva",
      "email": "joao.silva@email.com",
      "phone": "11987654321",
      "status": "ACTIVE",
      "lastLogin": "2025-08-25T15:30:00Z"
    },
    "authToken": "jwt-auth-token",
    "refreshToken": "jwt-refresh-token",
    "expiresAt": "2025-08-25T16:30:00Z",
    "message": "Login realizado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Esqueci minha senha"**
- **Endpoint:** `GET /api/v1/auth/forgot-password/init`
- **Token:** Não requer
- **Request:** Query params: `?cpf=12345678901`
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "userExists": true,
    "recoveryMethods": ["SMS", "EMAIL"],
    "defaultMethod": "SMS",
    "message": "Selecione o método de recuperação."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **7. 📧 TELA: SELEÇÃO DE MÉTODO (RECUPERAÇÃO)**

#### **Botão: "Enviar por SMS"**
- **Endpoint:** `POST /api/v1/auth/password-recovery/send-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "SMS",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "SMS",
    "phone": "11987654321", // Telefone parcial
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Token de recuperação enviado por SMS."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Enviar por e-mail"**
- **Endpoint:** `POST /api/v1/auth/password-recovery/send-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "EMAIL",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "EMAIL",
    "email": "jo***@em***.com", // Email parcial
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Token de recuperação enviado por e-mail."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **8. 🔑 TELA: TOKEN DE RECUPERAÇÃO**

#### **Botão: "Verificar token"**
- **Endpoint:** `POST /api/v1/auth/password-recovery/verify-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "SMS",
  "token": "1234",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "tokenValid": true,
    "recoveryToken": "jwt-recovery-token",
    "expiresAt": "2025-08-25T15:40:00Z",
    "message": "Token verificado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Reenviar token"**
- **Endpoint:** `POST /api/v1/auth/password-recovery/resend-token`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "method": "SMS",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "SMS",
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Token reenviado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Enviar por SMS" / "Enviar por e-mail" (Alternância)**
- **Endpoint:** `POST /api/v1/auth/password-recovery/change-method`
- **Token:** Não requer
- **Request:**
```json
{
  "cpf": "12345678901",
  "currentMethod": "SMS",
  "newMethod": "EMAIL",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "method": "EMAIL",
    "email": "jo***@em***.com", // Email parcial para mostrar na tela
    "phone": "11987654321", // Telefone anterior (para referência)
    "tokenExpiry": "2025-08-25T15:35:00Z",
    "resendAllowedAt": "2025-08-25T15:31:00Z",
    "message": "Método alterado para e-mail. Token enviado."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

### **9. 🔄 TELA: NOVA SENHA**

#### **Botão: "Alterar senha"**
- **Endpoint:** `POST /api/v1/auth/password-recovery/change-password`
- **Token:** `recoveryToken` (do passo anterior)
- **Request:**
```json
{
  "cpf": "12345678901",
  "recoveryToken": "jwt-recovery-token",
  "newPassword": "NovaSenha123!",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "cpf": "12345678901",
    "passwordChanged": true,
    "changedAt": "2025-08-25T15:30:00Z",
    "message": "Senha alterada com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

## 📊 **DASHBOARD - TODOS OS BOTÕES**

### **10. 👤 TELA: PERFIL DO USUÁRIO**

#### **Botão: "Editar perfil"**
- **Endpoint:** `GET /api/v1/user/profile/edit`
- **Token:** `authToken`
- **Request:** Não requer body
- **Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user-id",
      "cpf": "12345678901",
      "name": "João Silva",
      "email": "joao.silva@email.com",
      "phone": "11987654321",
      "status": "ACTIVE",
      "preferences": {
        "biometricEnabled": true,
        "notifications": {
          "email": true,
          "sms": false,
          "push": true
        }
      }
    },
    "editable": true,
    "message": "Dados carregados para edição."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Salvar alterações"**
- **Endpoint:** `PUT /api/v1/user/profile`
- **Token:** `authToken`
- **Request:**
```json
{
  "name": "João Silva Santos",
  "email": "joao.santos@email.com",
  "phone": "11987654321",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-user-id",
      "cpf": "12345678901",
      "name": "João Silva Santos",
      "email": "joao.santos@email.com",
      "phone": "11987654321",
      "updatedAt": "2025-08-25T15:30:00Z"
    },
    "message": "Perfil atualizado com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Alterar senha"**
- **Endpoint:** `PUT /api/v1/user/change-password`
- **Token:** `authToken`
- **Request:**
```json
{
  "currentPassword": "Senha123!",
  "newPassword": "NovaSenha456!",
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "passwordChanged": true,
    "changedAt": "2025-08-25T15:30:00Z",
    "message": "Senha alterada com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Habilitar/Desabilitar Biometria"**
- **Endpoint:** `PUT /api/v1/user/biometric`
- **Token:** `authToken`
- **Request:**
```json
{
  "enabled": true,
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "biometricEnabled": true,
    "updatedAt": "2025-08-25T15:30:00Z",
    "message": "Biometria habilitada com sucesso."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Configurar Notificações"**
- **Endpoint:** `PUT /api/v1/user/notifications`
- **Token:** `authToken`
- **Request:**
```json
{
  "notifications": {
    "email": true,
    "sms": false,
    "push": true
  },
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "notifications": {
      "email": true,
      "sms": false,
      "push": true
    },
    "updatedAt": "2025-08-25T15:30:00Z",
    "message": "Configurações de notificação atualizadas."
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

#### **Botão: "Sair" (Logout)**
- **Endpoint:** `POST /api/v1/auth/logout`
- **Token:** `authToken`
- **Request:**
```json
{
  "requestId": "uuid-v4-para-tracking"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "message": "Logout realizado com sucesso.",
    "loggedOutAt": "2025-08-25T15:30:00Z"
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

---

## 🔄 **FUNCIONALIDADES DE ALTERNÂNCIA SMS/EMAIL**

### **📱 Dados Parciais para Interface**

#### **Telefone Parcial:**
- **Formato:** `11987654321` → `11987654321` (últimos 4 dígitos visíveis)
- **Exemplo:** `11987654321` → `11987654321`
- **Máscara:** `(11) 98765-4321`

#### **Email Parcial:**
- **Formato:** `joao.silva@email.com` → `jo***@em***.com`
- **Regra:** Primeiras 2 letras + `***` + `@` + Primeiras 2 letras do domínio + `***`
- **Exemplo:** `joao.silva@email.com` → `jo***@em***.com`

### **🔄 Endpoints de Alternância**

#### **Primeiro Acesso:**
- **Endpoint:** `POST /api/v1/auth/first-access/change-method`
- **Funcionalidade:** Alterna entre SMS e Email, retorna dados parciais

#### **Recuperação de Senha:**
- **Endpoint:** `POST /api/v1/auth/password-recovery/change-method`
- **Funcionalidade:** Alterna entre SMS e Email, retorna dados parciais

---

## 🚨 **TRATAMENTO DE ERROS - TODOS OS ENDPOINTS**

### **Códigos de Erro Padrão**

#### **4xx - Erros do Cliente**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Mensagem de erro para o usuário",
    "details": "Detalhes técnicos (opcional)",
    "field": "campo_específico" // Para validações
  },
  "timestamp": "2025-08-25T15:30:00Z",
  "requestId": "uuid-v4-para-tracking"
}
```

### **Códigos de Erro Específicos**

| Código | Descrição | HTTP Status | Endpoint |
|--------|-----------|--------------|----------|
| `INVALID_CPF` | CPF inválido | 400 | CPF Verify |
| `CPF_NOT_FOUND` | CPF não encontrado | 404 | CPF Verify |
| `INVALID_TOKEN` | Token inválido/expirado | 401 | Token Verify |
| `METHOD_BLOCKED` | Método bloqueado | 429 | Send Token |
| `TOO_MANY_ATTEMPTS` | Muitas tentativas | 429 | Send Token |
| `INVALID_PASSWORD` | Senha não atende requisitos | 400 | Register/Change Password |
| `UNAUTHORIZED` | Não autorizado | 401 | Todos autenticados |
| `FORBIDDEN` | Acesso negado | 403 | Todos autenticados |

---

## 📋 **REQUISITOS TÉCNICOS**

### **Headers Obrigatórios**
```
Content-Type: application/json
Accept: application/json
User-Agent: FlutterApp/1.0.0
Request-ID: uuid-v4-para-tracking
```

### **Headers de Autenticação**
```
Authorization: Bearer {jwt-token}
```

### **Rate Limiting**
- **Endpoints públicos:** 100 requests/min por IP
- **Endpoints autenticados:** 1000 requests/min por usuário
- **Endpoints de autenticação:** 5 requests/min por IP

---

## 🎯 **RESUMO DE TODOS OS ENDPOINTS**

### **🔐 Autenticação (Sem Token)**
1. `POST /api/v1/auth/cpf/verify` - Verificar CPF
2. `POST /api/v1/auth/terms/accept` - Aceitar termos
3. `POST /api/v1/auth/first-access/send-token` - Enviar token primeiro acesso
4. `POST /api/v1/auth/first-access/verify-token` - Verificar token primeiro acesso
5. `POST /api/v1/auth/first-access/change-method` - Alterar método primeiro acesso
6. `POST /api/v1/auth/first-access/resend-token` - Reenviar token primeiro acesso
7. `POST /api/v1/auth/login` - Login
8. `GET /api/v1/auth/forgot-password/init` - Iniciar recuperação
9. `POST /api/v1/auth/password-recovery/send-token` - Enviar token recuperação
10. `POST /api/v1/auth/password-recovery/verify-token` - Verificar token recuperação
11. `POST /api/v1/auth/password-recovery/change-method` - Alterar método recuperação
12. `POST /api/v1/auth/password-recovery/resend-token` - Reenviar token recuperação

### **🔑 Com Session Token**
13. `POST /api/v1/auth/first-access/register` - Registrar usuário

### **🔑 Com Recovery Token**
14. `POST /api/v1/auth/password-recovery/change-password` - Alterar senha recuperação

### **🔐 Com Auth Token**
15. `GET /api/v1/user/profile/edit` - Carregar perfil para edição
16. `PUT /api/v1/user/profile` - Atualizar perfil
17. `PUT /api/v1/user/change-password` - Alterar senha
18. `PUT /api/v1/user/biometric` - Configurar biometria
19. `PUT /api/v1/user/notifications` - Configurar notificações
20. `POST /api/v1/auth/logout` - Logout
21. `POST /api/v1/auth/refresh` - Refresh token

---

## 📱 **INTEGRAÇÃO COM FLUTTER**

### **Configuração da URL Base**
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const Duration timeout = Duration(seconds: 30);
}
```

### **Exemplo de Uso - Alternância de Método**
```dart
class AuthService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  static Future<Map<String, dynamic>> changeMethod(String cpf, String currentMethod, String newMethod) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/first-access/change-method'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cpf': cpf,
          'currentMethod': currentMethod,
          'newMethod': newMethod,
          'requestId': Uuid().v4(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Retorna dados parciais para interface
      }
      throw Exception('Erro ao alterar método');
    } catch (e) {
      print('Erro ao alterar método: $e');
      rethrow;
    }
  }
}
```

---

## 🎯 **PRÓXIMOS PASSOS**

1. **Implementar BFF Spring Boot** seguindo esta documentação
2. **Configurar todos os endpoints** com validações
3. **Implementar sistema de dados parciais** para SMS/Email
4. **Configurar rate limiting** e autenticação
5. **Testar todos os fluxos** de botões e ações
6. **Integrar com Flutter App**

---

*Documentação gerada em: 25/08/2025*
*Versão: 2.0.0*
*Última atualização: Foco em todos os botões e ações + Alternância SMS/Email*
