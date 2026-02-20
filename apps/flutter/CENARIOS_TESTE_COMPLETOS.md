# 🧪 **CENÁRIOS DE TESTE COMPLETOS**

## 🎯 **FLUXOS DISPONÍVEIS PARA TESTE:**

### **1. FLUXO DE PRIMEIRO ACESSO (CADASTRO)**

#### **CPFs para Primeiro Acesso:**
- **`111.444.777-35`** → Fluxo completo de cadastro
- **`222.555.888-46`** → Fluxo completo de cadastro

#### **Sequência do Fluxo:**
1. **Welcome Screen** → Botão "Acessar"
2. **CPF Check** → Digite o CPF → Botão "Continuar"
3. **Termos de Uso** → Aceite os termos → Botão "Aceitar e Continuar"
4. **Método de Verificação** → Selecione "SMS" → Botão "Enviar Token"
5. **Token de Verificação** → Digite `1234` → Botão "Verificar"
6. **Registro de Senha** → Digite senha → Botão "Criar Senha"
7. **Dashboard** → Tela principal do app

---

### **2. FLUXO DE LOGIN (USUÁRIO EXISTENTE)**

#### **CPFs para Login:**
- **`946.919.070-09`** → Senha: `Senha123@`
- **`632.543.510-96`** → Senha: `Test123!`

#### **Sequência do Fluxo:**
1. **Welcome Screen** → Botão "Acessar"
2. **CPF Check** → Digite o CPF → Botão "Continuar"
3. **Login Screen** → CPF já preenchido → Digite a senha → Botão "Entrar"
4. **Dashboard** → Tela principal do app

---

### **3. FLUXO "ESQUECI MINHA SENHA"**

#### **CPFs para Recuperação:**
- **`946.919.070-09`** → Usuário existente
- **`632.543.510-96`** → Usuário existente

#### **Sequência do Fluxo:**
1. **Welcome Screen** → Botão "Acessar"
2. **CPF Check** → Digite o CPF → Botão "Continuar"
3. **Login Screen** → Clique em "Esqueci minha senha"
4. **Método de Recuperação** → Selecione "SMS" → Botão "Enviar Token"
5. **Token de Recuperação** → Digite `1234` → Botão "Verificar"
6. **Nova Senha** → Digite nova senha → Botão "Alterar Senha"
7. **Login Screen** → Faça login com nova senha

---

## 🚨 **CENÁRIOS DE ERRO PARA TESTE:**

### **CPFs Inválidos:**
- **`000.000.000-00`** → CPF inválido (dígitos iguais)
- **`111.111.111-11`** → CPF inválido (dígitos iguais)
- **`999.999.999-99`** → CPF não existe no sistema

### **Senhas Incorretas:**
- **CPF:** `946.919.070-09` → **Senha incorreta:** `SenhaErrada123`
- **CPF:** `632.543.510-96` → **Senha incorreta:** `TesteErrado456`

### **Tokens Incorretos:**
- **Token incorreto:** `0000` → Falha na verificação
- **Token incorreto:** `9999` → Falha na verificação

---

## 🔧 **CONFIGURAÇÕES DE TESTE:**

### **Modos Ativos:**
- ✅ **TEST_MODE:** `true` (limpa storage para primeiro acesso)
- ✅ **FORGOT_PASSWORD_TEST_MODE:** `true` (cenários específicos de recuperação)
- ❌ **FORCE_LOGIN_MODE:** `false` (permite fluxo normal)

### **Comportamentos Especiais:**
- **CPF `11111111111`** → Falha no envio de token (recuperação)
- **Token `0000`** → Falha na verificação (recuperação)
- **Senha `Test123!`** → Falha na alteração (recuperação)

---

## 📱 **COMO EXECUTAR OS TESTES:**

### **1. Teste de Primeiro Acesso:**
```bash
# Use CPF: 111.444.777-35 ou 222.555.888-46
# Siga o fluxo completo de cadastro
```

### **2. Teste de Login:**
```bash
# Use CPF: 946.919.070-09 com senha: Senha123@
# Ou CPF: 632.543.510-96 com senha: Test123!
```

### **3. Teste de Recuperação:**
```bash
# Use qualquer CPF existente
# Clique em "Esqueci minha senha"
# Siga o fluxo de recuperação
```

---

## 🎲 **SORTEIO DE CENÁRIOS:**

### **Opções para Teste:**
1. **Primeiro Acesso** → CPF `111.444.777-35`
2. **Primeiro Acesso** → CPF `222.555.888-46`
3. **Login** → CPF `946.919.070-09` + `Senha123@`
4. **Login** → CPF `632.543.510-96` + `Test123!`
5. **Recuperação** → CPF `946.919.070-09`
6. **Recuperação** → CPF `632.543.510-96`

### **Escolha um cenário e teste o fluxo completo!**

---

## 📝 **NOTAS IMPORTANTES:**

- ✅ **CPF Check** direciona automaticamente para o fluxo correto
- ✅ **CPF preenchido** na tela de login para usuários existentes
- ✅ **Máscara preservada** entre as telas
- ✅ **Storage limpo** automaticamente para testes de primeiro acesso
- ✅ **Fluxos completos** implementados e funcionais
