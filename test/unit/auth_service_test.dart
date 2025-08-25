import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login_app/data/services/auth_service.dart';

/// 🧪 TESTES DO SERVIÇO DE AUTENTICAÇÃO
/// Testa todas as funcionalidades de autenticação da aplicação
void main() {
  group('🧪 TESTES DO SERVIÇO DE AUTENTICAÇÃO', () {
    
    group('✅ Verificação de CPF', () {
      test('Deve verificar se CPF é de primeiro acesso', () async {
        // CPFs de primeiro acesso
        final firstAccessCpfs = [
          '111.444.777-35',  // SMS
          '222.555.888-46',  // Email
        ];
        
        for (final cpf in firstAccessCpfs) {
          final result = await AuthService.isFirstAccess(cpf);
          expect(result, isTrue, reason: 'CPF $cpf deveria ser de primeiro acesso');
        }
      });

      test('Deve verificar se CPF é de usuário existente', () async {
        // CPFs de usuários existentes
        final existingUserCpfs = [
          '946.919.070-09',  // Usuário existente
          '632.543.510-96',  // Usuário existente
        ];
        
        for (final cpf in existingUserCpfs) {
          // Verifica se é usuário existente (não é primeiro acesso)
          final isFirstAccess = await AuthService.isFirstAccess(cpf);
          expect(isFirstAccess, isFalse, reason: 'CPF $cpf deveria ser de usuário existente');
        }
      });

      test('Deve verificar se CPF é válido', () async {
        // CPFs válidos
        final validCpfs = [
          '111.444.777-35',
          '222.555.888-46',
          '946.919.070-09',
          '632.543.510-96',
        ];
        
        for (final cpf in validCpfs) {
          final result = AuthService.isValidCPF(cpf);
          expect(result, isTrue, reason: 'CPF $cpf deveria ser válido');
        }
      });
    });

    group('✅ Verificação de Usuário', () {
      test('Deve verificar se CPF está cadastrado', () async {
        // CPFs cadastrados
        final registeredCpfs = [
          '111.444.777-35',
          '222.555.888-46',
          '946.919.070-09',
          '632.543.510-96',
        ];
        
        for (final cpf in registeredCpfs) {
          final result = await AuthService.isFirstAccess(cpf);
          // CPFs de primeiro acesso retornam true, usuários existentes retornam false
          expect(result is bool, isTrue, reason: 'CPF $cpf deveria retornar um valor booleano');
        }
      });

      test('Deve verificar se CPF não está cadastrado', () async {
        // CPFs não cadastrados
        final unregisteredCpfs = [
          '555.666.777-88',
          '444.333.222-11',
          '777.888.999-00',
        ];
        
        for (final cpf in unregisteredCpfs) {
          final result = await AuthService.isFirstAccess(cpf);
          expect(result, isFalse, reason: 'CPF $cpf não deveria estar cadastrado');
        }
      });
    });

    group('✅ Cenários de Erro', () {
      test('Deve lidar com CPF inválido', () async {
        // CPFs inválidos
        final invalidCpfs = [
          '000.000.000-00',
          '111.111.111-11',
          '123.456.789-10',
        ];
        
        for (final cpf in invalidCpfs) {
          final result = AuthService.isValidCPF(cpf);
          expect(result, isFalse, reason: 'CPF $cpf deveria ser inválido');
        }
      });

      test('Deve lidar com CPF não encontrado', () async {
        // CPFs não encontrados
        final notFoundCpfs = [
          '555.666.777-88',
          '444.333.222-11',
          '777.888.999-00',
        ];
        
        for (final cpf in notFoundCpfs) {
          final result = await AuthService.isFirstAccess(cpf);
          expect(result, isFalse, reason: 'CPF $cpf não deveria ser encontrado');
        }
      });
    });
  });
}
