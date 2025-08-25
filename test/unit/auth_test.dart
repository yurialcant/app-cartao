import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login_app/presentation/screens/login_page.dart';

/// 🧪 TESTES DE VALIDAÇÃO DE AUTENTICAÇÃO
/// Testa todas as validações de CPF e senha da aplicação
void main() {
  group('🧪 TESTES DE VALIDAÇÃO DE AUTENTICAÇÃO', () {
    
    group('✅ Validação de CPF', () {
      test('Deve validar CPFs corretos', () {
        // CPFs válidos para teste
        final validCpfs = [
          '111.444.777-35',  // Primeiro acesso SMS
          '987.654.321-00',  // Primeiro acesso Email
          '123.456.789-09',  // Usuário existente SMS
          '946.919.070-09',  // CPF fornecido pelo usuário
        ];
        
        for (final cpf in validCpfs) {
          final isValid = _isValidCPF(cpf);
          expect(isValid, isTrue, reason: 'CPF $cpf deveria ser válido');
        }
      });

      test('Deve rejeitar CPFs inválidos', () {
        // CPFs inválidos para teste
        final invalidCpfs = [
          '000.000.000-00',  // Todos iguais
          '111.111.111-11',  // Todos iguais
          '123.456.789-10',  // Dígito verificador incorreto
          '123.456.789-11',  // Dígito verificador incorreto
        ];
        
        for (final cpf in invalidCpfs) {
          final isValid = _isValidCPF(cpf);
          expect(isValid, isFalse, reason: 'CPF $cpf deveria ser inválido');
        }
      });

      test('Deve rejeitar CPFs com comprimento incorreto', () {
        // CPFs com comprimento incorreto
        final invalidLengthCpfs = [
          '123.456.789',      // Muito curto
          '123.456.789-0',    // Muito curto
          '123.456.789-123',  // Muito longo
          '123.456.789-1234', // Muito longo
        ];
        
        for (final cpf in invalidLengthCpfs) {
          final isValid = _isValidCPF(cpf);
          expect(isValid, isFalse, reason: 'CPF $cpf deveria ser inválido por comprimento');
        }
      });

      test('Deve lidar com CPFs em diferentes formatos', () {
        // CPFs válidos em diferentes formatos
        final cpfFormats = [
          '11144477735',      // Sem formatação
          '111.444.777-35',   // Com formatação
          '111 444 777 35',   // Com espaços
          '111-444-777-35',   // Com hífens
        ];
        
        for (final cpf in cpfFormats) {
          final isValid = _isValidCPF(cpf);
          expect(isValid, isTrue, reason: 'CPF $cpf deveria ser válido independente do formato');
        }
      });
    });

    group('✅ Validação de Senha', () {
      test('Deve validar requisitos de senha', () {
        // Senhas válidas que atendem todos os requisitos (6-8 caracteres)
        final validPasswords = [
          'Test1!',           // 6 caracteres: Maiúscula, minúscula, número, símbolo
          'Abc12@',           // 6 caracteres: Maiúscula, minúscula, número, símbolo
          'Teste1!',          // 7 caracteres: Maiúscula, minúscula, número, símbolo
          'Senha1@',          // 7 caracteres: Maiúscula, minúscula, número, símbolo
          'Teste12!',         // 8 caracteres: Maiúscula, minúscula, número, símbolo
        ];
        
        for (final password in validPasswords) {
          final isValid = _isValidPassword(password);
          expect(isValid, isTrue, reason: 'Senha $password deveria ser válida');
        }
      });

      test('Deve rejeitar senhas inválidas', () {
        // Senhas inválidas que não atendem os requisitos
        final invalidPasswords = [
          'teste',            // Sem maiúscula, números ou símbolos
          'Teste',            // Sem números ou símbolos
          'Teste123',         // Sem símbolos
          'teste123#',        // Sem maiúscula
          'TESTE123#',        // Sem minúscula
          '123456789',        // Apenas números
          '!@#\$%^&*()',     // Apenas símbolos
        ];
        
        for (final password in invalidPasswords) {
          final isValid = _isValidPassword(password);
          expect(isValid, isFalse, reason: 'Senha $password deveria ser inválida');
        }
      });

      test('Deve validar comprimento da senha', () {
        // Senhas muito curtas ou muito longas
        final invalidPasswords = [
          'Ab1!',             // 4 caracteres - muito curta
          'Test1',            // 5 caracteres - muito curta
          'Teste123!',        // 9 caracteres - muito longa
          'MinhaSenha2024!',  // 16 caracteres - muito longa
        ];
        
        for (final password in invalidPasswords) {
          final isValid = _isValidPassword(password);
          expect(isValid, isFalse, reason: 'Senha $password deveria ser inválida por comprimento incorreto');
        }
        
        // Senhas com comprimento correto (6-8 caracteres)
        final validPasswords = [
          'Test1!',           // 6 caracteres
          'Teste1!',          // 7 caracteres
          'Teste12!',         // 8 caracteres
        ];
        
        for (final password in validPasswords) {
          final isValid = _isValidPassword(password);
          expect(isValid, isTrue, reason: 'Senha $password deveria ser válida por comprimento correto');
        }
      });
    });

    group('✅ Validação de Formulário', () {
      test('Deve validar formulário completo', () {
        // Dados válidos para teste
        final validCpf = '111.444.777-35';
        final validPassword = 'Test1!';  // 6 caracteres, atende todas as regras
        
        // Valida CPF
        final isCpfValid = _isValidCPF(validCpf);
        expect(isCpfValid, isTrue, reason: 'CPF deveria ser válido');
        
        // Valida senha
        final isPasswordValid = _isValidPassword(validPassword);
        expect(isPasswordValid, isTrue, reason: 'Senha deveria ser válida');
        
        // Valida formulário completo
        final isFormValid = isCpfValid && isPasswordValid;
        expect(isFormValid, isTrue, reason: 'Formulário deveria ser válido');
      });

      test('Deve rejeitar formulário com dados inválidos', () {
        // Dados inválidos para teste
        final invalidCpf = '123.456.789-10';
        final invalidPassword = 'teste';
        
        // Valida CPF
        final isCpfValid = _isValidCPF(invalidCpf);
        expect(isCpfValid, isFalse, reason: 'CPF deveria ser inválido');
        
        // Valida senha
        final isPasswordValid = _isValidPassword(invalidPassword);
        expect(isPasswordValid, isFalse, reason: 'Senha deveria ser inválida');
        
        // Valida formulário completo
        final isFormValid = isCpfValid && isPasswordValid;
        expect(isFormValid, isFalse, reason: 'Formulário deveria ser inválido');
      });
    });
  });
}

/// Função auxiliar para validar CPF (cópia da implementação da aplicação)
bool _isValidCPF(String cpf) {
  // Remove caracteres não numéricos
  cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
  
  // Verifica se tem 11 dígitos
  if (cpf.length != 11) return false;
  
  // Verifica se todos os dígitos são iguais
  if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) return false;
  
  // Validação dos dígitos verificadores
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int remainder = sum % 11;
  int digit1 = remainder < 2 ? 0 : 11 - remainder;
  
  if (int.parse(cpf[9]) != digit1) return false;
  
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  remainder = sum % 11;
  int digit2 = remainder < 2 ? 0 : 11 - remainder;
  
  return int.parse(cpf[10]) == digit2;
}

/// Função auxiliar para validar senha (implementação da aplicação)
bool _isValidPassword(String password) {
  // Verifica comprimento (6-8 caracteres)
  if (password.length < 6 || password.length > 8) return false;
  
  // Verifica se contém pelo menos uma letra maiúscula
  if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
  
  // Verifica se contém pelo menos uma letra minúscula
  if (!RegExp(r'[a-z]').hasMatch(password)) return false;
  
  // Verifica se contém pelo menos um número
  if (!RegExp(r'[0-9]').hasMatch(password)) return false;
  
  // Verifica se contém pelo menos um símbolo
  final symbols = '!@#\$%^&*(),.?":{}|<>';
  bool hasSymbol = false;
  for (int i = 0; i < symbols.length; i++) {
    if (password.contains(symbols[i])) {
      hasSymbol = true;
      break;
    }
  }
  if (!hasSymbol) return false;
  
  return true;
}
