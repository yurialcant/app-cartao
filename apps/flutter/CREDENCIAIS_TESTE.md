# 🔐 CREDENCIAIS DE TESTE - FLUTTER LOGIN APP

## 📱 USUÁRIOS PARA LOGIN (CPFs EXISTENTES)

### 👤 João Silva
- **CPF:** `946.919.070-09` (ou `94691907009`)
- **Senha:** `Senha1@`
- **Email:** `joao.silva@email.com`
- **Telefone:** `(11) 99999-9999`
- **Status:** Usuário ativo normal
- **Cenário:** Login de usuário existente

### 👤 Maria Santos
- **CPF:** `632.543.510-96` (ou `63254351096`)
- **Senha:** `Test2#`
- **Email:** `maria.santos@email.com`
- **Telefone:** `(11) 88888-8888`
- **Status:** Usuária com acesso recente
- **Cenário:** Login de usuária existente

### 👤 Carlos Teste
- **CPF:** `123.456.789-09` (ou `12345678909`)
- **Senha:** `Pass3$`
- **Email:** `carlos.teste@email.com`
- **Telefone:** `(11) 77777-7777`
- **Status:** Usuário para teste de login
- **Cenário:** Login de usuário existente

## 🆕 USUÁRIOS PARA PRIMEIRO ACESSO

### 👤 João Primeiro Acesso
- **CPF:** `111.444.777-35` (ou `11144477735`)
- **Status:** Usuário completamente novo
- **Cenário:** Fluxo completo de primeiro acesso

### 👤 Maria Primeiro Acesso
- **CPF:** `222.555.888-46` (ou `22255588846`)
- **Status:** Usuária com dados básicos
- **Cenário:** Primeiro acesso com validação

### 👤 Pedro Teste
- **CPF:** `333.666.999-57` (ou `33366699957`)
- **Status:** Usuário para teste de validação
- **Cenário:** Teste de validação de CPF

## 🔑 TOKENS DE VALIDAÇÃO

### 📧 Email/SMS
- **Token Válido:** `1234`
- **Token Inválido:** `0000`
- **Token Expirado:** `8888`

### 📱 Dispositivo
- **Token Válido:** `DEVICE123`
- **Token Inválido:** `INVALID`

## 🔒 USUÁRIOS BLOQUEADOS

### 🚫 Usuário Bloqueado Temporariamente
- **CPF:** `987.654.321-00` (ou `98765432100`)
- **Senha:** `Test123!`
- **Status:** Bloqueado por múltiplas tentativas
- **Tempo:** 10 minutos

### 🚫 Usuário Bloqueado Permanentemente
- **CPF:** `555.444.333-22` (ou `55544433322`)
- **Senha:** `Test123!`
- **Status:** Bloqueio permanente por segurança

## 🔐 USUÁRIOS COM BIOMETRIA

### 👆 Ana Biometria
- **CPF:** `111.222.333-44` (ou `11122233344`)
- **Senha:** `Test123!`
- **Biometria:** Impressão digital habilitada
- **Status:** Usuário com biometria ativa

## 📋 REGRAS DE SENHA

### ✅ Requisitos Mínimos
- **Comprimento:** 6 a 8 caracteres
- **Letra Maiúscula:** Pelo menos uma (A-Z)
- **Letra Minúscula:** Pelo menos uma (a-z)
- **Número:** Pelo menos um (0-9)
- **Caractere Especial:** Pelo menos um (!@#$%^&*)

### 🔍 Exemplos de Senhas Válidas
- `Senha1@` (8 caracteres)
- `Test2#` (6 caracteres)
- `Pass3$` (6 caracteres)
- `Abc123@` (7 caracteres)
- `Xyz789#` (7 caracteres)

### ❌ Exemplos de Senhas Inválidas
- `teste123#` (sem maiúscula)
- `TESTE123#` (sem minúscula)
- `Teste123` (sem caractere especial)
- `Test!` (muito curta - 5 caracteres)
- `Teste12345!` (muito longa - 11 caracteres)

## 🧪 CENÁRIOS DE TESTE

### 1️⃣ **Fluxo de Primeiro Acesso**
- **CPF:** `111.444.777-35`
- **Token:** `1234`
- **Nova Senha:** `Test1!`
- **Resultado Esperado:** Dashboard

### 2️⃣ **Login de Usuário Existente**
- **CPF:** `946.919.070-09`
- **Senha:** `Senha1@`
- **Resultado Esperado:** Dashboard

### 3️⃣ **Bloqueio Temporário**
- **CPF:** `946.919.070-09`
- **Senhas Erradas:** `Wrong1!`, `Wrong2!`, `Wrong3!`
- **Resultado Esperado:** Bloqueio temporário (10 min)

### 4️⃣ **Bloqueio Permanente**
- **CPF:** `946.919.070-09`
- **Senhas Erradas:** `Wrong1!`, `Wrong2!`, `Wrong3!`, `Wrong4!`, `Wrong5!`
- **Resultado Esperado:** Bloqueio permanente

### 5️⃣ **Login por Biometria**
- **CPF:** `111.222.333-44`
- **Método:** Impressão digital
- **Resultado Esperado:** Dashboard

### 6️⃣ **Recuperação de Senha**
- **CPF:** `946.919.070-09`
- **Método:** Email
- **Token:** `1234`
- **Nova Senha:** `NewPass1!`
- **Resultado Esperado:** Senha alterada

## ⚠️ IMPORTANTE

- **Formato CPF:** Aceita tanto com máscara (`946.919.070-09`) quanto sem (`94691907009`)
- **Senhas:** Devem seguir exatamente as regras de validação
- **Mocks:** Sistema está configurado para usar dados mockados
- **Ambiente:** Versão de desenvolvimento com todas as funcionalidades ativas

## 🚀 COMO TESTAR

1. **Abra o app** e vá para a tela de login
2. **Use um dos CPFs** listados acima
3. **Digite a senha correspondente** (respeitando as regras)
4. **Verifique o comportamento** conforme o cenário esperado

---
*Última atualização: 25/08/2025*
*Versão: 0.0.002-dev*
