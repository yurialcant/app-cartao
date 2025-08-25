/// 🧪 TESTES DA TELA DE REGISTRO DE PRIMEIRO ACESSO
/// Autor: Tiago Tiede
/// Empresa: Origami
/// Versão: 1.0.0
/// 
/// Testes específicos para a tela de registro de senha
/// durante o primeiro acesso do usuário

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_app/presentation/screens/first_access_register_page.dart';
import 'package:flutter_login_app/core/storage/app_storage.dart';
import '../test_config.dart';

void main() {
  group('🧪 TESTES DA TELA DE REGISTRO DE PRIMEIRO ACESSO', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() {
      TestConfig.cleanup();
    });

    group('✅ Renderização da Tela', () {
      testWidgets('Deve renderizar todos os elementos da tela', (WidgetTester tester) async {
        TestConfig.setupScreenSize(tester);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Verifica elementos principais
        expect(find.text('Crie sua senha de acesso'), findsOneWidget);
        expect(find.text('Sua senha deve conter:'), findsOneWidget);
        expect(find.text('6 a 8 caracteres'), findsOneWidget);
        expect(find.text('números'), findsOneWidget);
        expect(find.text('letras maiúsculas e minúsculas'), findsOneWidget);
        expect(find.text('caracteres especiais'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Confirmar senha'), findsOneWidget);
        expect(find.text('Criar Senha'), findsOneWidget);
      });
    });

    group('✅ Validação de Senha', () {
      testWidgets('Deve aceitar senha válida', (WidgetTester tester) async {
        TestConfig.setupScreenSize(tester);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Digita senha válida
        await tester.enterText(find.byType(TextFormField).first, 'Abc123@');
        await TestConfig.waitForAnimations(tester);

        // Verifica se os requisitos estão marcados
        expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
      });
    });

    group('✅ Confirmação de Senha', () {
      testWidgets('Deve rejeitar senhas diferentes', (WidgetTester tester) async {
        TestConfig.setupScreenSize(tester);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Digita senhas diferentes
        await tester.enterText(find.byType(TextFormField).first, 'Abc123@');
        await tester.enterText(find.byType(TextFormField).last, 'Abc123#');
        await TestConfig.waitForAnimations(tester);

        // Verifica se mostra erro
        expect(find.text('As duas senhas não são iguais'), findsOneWidget);
      });

      testWidgets('Deve aceitar senhas iguais', (WidgetTester tester) async {
        TestConfig.setupScreenSize(tester);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Digita senhas iguais
        await tester.enterText(find.byType(TextFormField).first, 'Abc123@');
        await tester.enterText(find.byType(TextFormField).last, 'Abc123@');
        await TestConfig.waitForAnimations(tester);

        // Verifica se não mostra erro
        expect(find.text('As duas senhas não são iguais'), findsNothing);
      });
    });

    group('✅ Validação em Tempo Real', () {
      testWidgets('Deve mostrar checkmarks para requisitos atendidos', (WidgetTester tester) async {
        TestConfig.setupScreenSize(tester);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Digita senha que atende todos os requisitos
        await tester.enterText(find.byType(TextFormField).first, 'Abc123@');
        await TestConfig.waitForAnimations(tester);

        // Verifica se todos os requisitos estão marcados
        expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
        expect(find.byIcon(Icons.cancel), findsNothing);
      });

      testWidgets('Deve atualizar validação ao digitar', (WidgetTester tester) async {
        TestConfig.setupScreenSize(tester);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Inicialmente não deve ter checkmarks
        expect(find.byIcon(Icons.check_circle), findsNothing);

        // Digita parcialmente
        await tester.enterText(find.byType(TextFormField).first, 'Abc');
        await TestConfig.waitForAnimations(tester);

        // Deve ter alguns checkmarks
        expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
      });
    });

    group('✅ Responsividade', () {
      testWidgets('Deve funcionar em diferentes tamanhos de tela', (WidgetTester tester) async {
        // Testa tela pequena
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: const FirstAccessRegisterPage(),
          ),
        );
        await TestConfig.waitForAnimations(tester);

        // Deve renderizar sem erro
        expect(find.text('Crie sua senha de acesso'), findsOneWidget);
        
        // Restaura tamanho padrão
        TestConfig.restoreScreenSize(tester);
      });
    });
  });
}
