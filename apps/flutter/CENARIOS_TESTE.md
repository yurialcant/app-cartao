# 🧪 CENÁRIOS DE TESTE - FLUXO DE PRIMEIRO CADASTRO

## 📱 **FLUXO COMPLETO IMPLEMENTADO**

O aplicativo agora possui um fluxo completo e mockado do primeiro cadastro com todos os cenários possíveis implementados.

---

## 🔑 **CPFs PARA TESTE**

### ✅ **Primeiro Acesso (Sucesso)**
- **`123.456.789-09`** → Primeiro acesso via SMS
- **`987.654.321-00`** → Primeiro acesso via Email
- **`111.222.333-44`** → Primeiro acesso com erro no envio do token

### ❌ **CPFs com Erro**
- **`555.666.777-88`** → CPF inválido (erro de validação)
- **`999.888.777-66`** → CPF não cadastrado (erro de empresa)

### 🔐 **CPFs com Conta Existente**
- **`946.919.070-09`** → Já tem conta (vai para tela de login)
- **`632.543.510-96`** → Já tem conta (vai para tela de login)

---

## 🔐 **TOKENS PARA TESTE**

### ✅ **Tokens Válidos**
- **`2222`** → Token válido para primeiro acesso
- **`1234`** → Token válido para primeiro acesso

### ❌ **Tokens Inválidos**
- **`1111`** → Token inválido (erro)
- **`0000`** → Token expirado
- **`9999`** → Token inexistente

---

## 🔒 **SENHAS PARA TESTE**

### ✅ **Senhas Válidas**
- **`Teste123!`** → Senha válida (6-8 chars, números, maiúsculas/minúsculas, especiais)
- **`Abc123!`** → Senha válida
- **`Senha1@`** → Senha válida

### ❌ **Senhas Inválidas**

#### **Sem Maiúsculas**
- **`teste123!`** → Falta letra maiúscula

#### **Sem Minúsculas**
- **`TESTE123!`** → Falta letra minúscula

#### **Sem Números**
- **`TesteABC!`** → Falta número

#### **Sem Caracteres Especiais**
- **`Teste123`** → Falta caractere especial

#### **Muito Curta**
- **`Teste!`** → Menos de 6 caracteres

#### **Muito Longa**
- **`Teste123456!`** → Mais de 8 caracteres

---

## 🎯 **CENÁRIOS COMPLETOS DE TESTE**

### **1. FLUXO SUCESSO - SMS**
1. Digite CPF: `123.456.789-09`
2. Clique em "Continuar"
3. Selecione "SMS"
4. Digite token: `2222`
5. Crie senha: `Teste123!`
6. Confirme senha: `Teste123!`
7. Clique em "Continuar"
8. ✅ **Resultado**: Modal de sucesso e redirecionamento para dashboard

### **2. FLUXO SUCESSO - EMAIL**
1. Digite CPF: `987.654.321-00`
2. Clique em "Continuar"
3. Selecione "E-mail"
4. Digite token: `1234`
5. Crie senha: `Abc123!`
6. Confirme senha: `Abc123!`
7. Clique em "Continuar"
8. ✅ **Resultado**: Modal de sucesso e redirecionamento para dashboard

### **3. ERRO NO ENVIO DO TOKEN**
1. Digite CPF: `111.222.333-44`
2. Clique em "Continuar"
3. Selecione qualquer método
4. ❌ **Resultado**: Erro "Erro no envio do token. Tente novamente."

### **4. CPF INVÁLIDO**
1. Digite CPF: `555.666.777-88`
2. Clique em "Continuar"
3. ❌ **Resultado**: Erro "CPF não cadastrado, fale com sua empresa."

### **5. CPF NÃO CADASTRADO**
1. Digite CPF: `999.888.777-66`
2. Clique em "Continuar"
3. ❌ **Resultado**: Erro "CPF não cadastrado, fale com sua empresa."

### **6. CPF COM CONTA EXISTENTE**
1. Digite CPF: `946.919.070-09`
2. Clique em "Continuar"
3. ✅ **Resultado**: Redirecionamento para tela de login

### **7. TOKEN INVÁLIDO**
1. Siga fluxo de sucesso até tela de token
2. Digite token: `1111`
3. Clique em "Continuar"
4. ❌ **Resultado**: Erro "Token inválido."

### **8. TOKEN EXPIRADO**
1. Siga fluxo de sucesso até tela de token
2. Digite token: `0000`
3. Clique em "Continuar"
4. ❌ **Resultado**: Erro "Token expirado. Solicite um novo."

### **9. SENHA SEM MAIÚSCULAS**
1. Siga fluxo até criação de senha
2. Digite senha: `teste123!`
3. ❌ **Resultado**: Requisito "letras maiúsculas e minúsculas" fica vermelho

### **10. SENHA SEM MINÚSCULAS**
1. Siga fluxo até criação de senha
2. Digite senha: `TESTE123!`
3. ❌ **Resultado**: Requisito "letras maiúsculas e minúsculas" fica vermelho

### **11. SENHA SEM NÚMEROS**
1. Siga fluxo até criação de senha
2. Digite senha: `TesteABC!`
3. ❌ **Resultado**: Requisito "números" fica vermelho

### **12. SENHA SEM CARACTERES ESPECIAIS**
1. Siga fluxo até criação de senha
2. Digite senha: `Teste123`
3. ❌ **Resultado**: Requisito "caracteres especiais" fica vermelho

### **13. SENHA MUITO CURTA**
1. Siga fluxo até criação de senha
2. Digite senha: `Teste!`
3. ❌ **Resultado**: Requisito "6 a 8 caracteres" fica vermelho

### **14. SENHA MUITO LONGA**
1. Siga fluxo até criação de senha
2. Digite senha: `Teste123456!`
3. ❌ **Resultado**: Requisito "6 a 8 caracteres" fica vermelho

### **15. SENHAS NÃO COINCIDEM**
1. Siga fluxo até criação de senha
2. Digite senha: `Teste123!`
3. Digite confirmação: `Teste123`
4. ❌ **Resultado**: Erro "As duas senhas não são iguais"

---

## 🔄 **FUNCIONALIDADES ADICIONAIS**

### **Reenvio de Token**
- Botão fica desabilitado por 60 segundos após envio
- Contador regressivo visível
- Limpa campos após reenvio bem-sucedido

### **Validação em Tempo Real**
- Indicadores visuais para cada requisito de senha
- Bordas coloridas nos campos (verde = válido, vermelho = inválido)
- Botão "Continuar" só fica ativo quando todos os requisitos são atendidos

### **Tratamento de Erros**
- Mensagens de erro específicas para cada cenário
- Containers de erro com ícones e cores apropriadas
- Fallbacks para erros inesperados

---

## 🎨 **CARACTERÍSTICAS VISUAIS**

- **Design consistente** com mockups fornecidos
- **Feedback visual** em tempo real
- **Estados de loading** com spinners
- **Cores semânticas** (verde = sucesso, vermelho = erro)
- **Ícones informativos** para melhor UX
- **Responsividade** para diferentes tamanhos de tela

---

## 🚀 **COMO TESTAR**

1. **Execute o app** com `flutter run`
2. **Use os CPFs listados** para testar diferentes cenários
3. **Teste todos os tokens** para validar fluxos de erro
4. **Experimente diferentes senhas** para ver validação em tempo real
5. **Teste reenvio de token** e contadores
6. **Verifique tratamento de erros** em cada etapa

---

## 📝 **NOTAS IMPORTANTES**

- Todos os delays são simulados (800ms) para simular rede real
- Os mocks são determinísticos (mesmo input = mesmo resultado)
- O sistema salva preferências (SMS/Email) para uso futuro
- Validações são feitas tanto no frontend quanto no mock do serviço
- Tratamento de erros robusto em todas as etapas
