/// 🧪 CONFIGURAÇÃO CENTRAL PARA TODOS OS TESTES
/// Autor: Tiago Tiede
/// Empresa: Origami
/// Versão: 1.0.0
/// 
/// Este arquivo centraliza todas as configurações necessárias
/// para executar os testes de forma confiável

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Configuração central para todos os testes
class TestConfig {
  static bool _isInitialized = false;
  
  /// Inicializa o ambiente de teste
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🧪 [TestConfig] Inicializando ambiente de teste...');
    
    // Configura mocks para shared_preferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), (call) async {
      switch (call.method) {
        case 'getAll':
          return <String, Object>{
            'flutter.first_access': 'true',
            'flutter.user_data': '',
            'flutter.auth_token': '',
            'flutter.terms_accepted': 'false',
          };
        case 'setString':
          return true;
        case 'setBool':
          return true;
        case 'setInt':
          return true;
        case 'remove':
          return true;
        case 'clear':
          return true;
        default:
          return null;
      }
    });
    
    // Configura mocks para flutter_secure_storage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (call) async {
      switch (call.method) {
        case 'read':
          return 'mock_secure_value';
        case 'write':
          return null;
        case 'delete':
          return null;
        case 'deleteAll':
          return null;
        default:
          return null;
      }
    });
    
    // Configura mocks para local_auth
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/local_auth'), (call) async {
      switch (call.method) {
        case 'getAvailableBiometrics':
          return ['fingerprint', 'face'];
        case 'isDeviceSupported':
          return true;
        case 'canCheckBiometrics':
          return true;
        case 'authenticate':
          return true;
        default:
          return null;
      }
    });
    
    _isInitialized = true;
    print('🧪 [TestConfig] Ambiente de teste inicializado com sucesso!');
  }
  
  /// Limpa o ambiente de teste
  static void cleanup() {
    print('🧪 [TestConfig] Limpando ambiente de teste...');
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'), null);
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), null);
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/local_auth'), null);
    
    _isInitialized = false;
    print('🧪 [TestConfig] Ambiente de teste limpo!');
  }
  
  /// Configura tamanho de tela padrão para testes
  static void setupScreenSize(WidgetTester tester) {
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
  }
  
  /// Restaura tamanho de tela padrão
  static void restoreScreenSize(WidgetTester tester) {
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  }
  
  /// Aguarda um tempo seguro para animações
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }
  
  /// Verifica se o teste está em modo de debug
  static bool get isDebugMode {
    return const bool.fromEnvironment('dart.vm.product') == false;
  }
  
  /// Imprime informações de debug se estiver em modo debug
  static void debugPrint(String message) {
    if (isDebugMode) {
      print('🧪 [DEBUG] $message');
    }
  }
}
