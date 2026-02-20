import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login_app/core/services/biometric_service.dart';
import 'package:flutter/services.dart';

/// 🧪 TESTES DO SERVIÇO BIOMÉTRICO (MOCKADO)
/// Testa todas as funcionalidades de autenticação biométrica usando mocks
void main() {
  group('🧪 TESTES DO SERVIÇO BIOMÉTRICO (MOCKADO)', () {
    
    setUpAll(() {
      // Configura mocks para os canais de método
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Mock para canCheckBiometrics
      const MethodChannel('plugins.flutter.io/local_auth')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'canCheckBiometrics':
            return true;
          case 'isDeviceSupported':
            return true;
          case 'getAvailableBiometrics':
            return ['fingerprint', 'face'];
          case 'authenticate':
            return true;
          default:
            return null;
        }
      });

      // Mock para AppStorage (biometria habilitada)
      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getString':
            if (methodCall.arguments == 'biometric_enabled') {
              return 'true';
            }
            return null;
          case 'getBool':
            if (methodCall.arguments == 'biometric_enabled') {
              return true;
            }
            return null;
          case 'setBool':
            if (methodCall.arguments['key'] == 'biometric_enabled') {
              return true;
            }
            return null;
          default:
            return null;
        }
      });
      
      // Mock para FlutterSecureStorage
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            if (methodCall.arguments['key'] == 'biometric_enabled') {
              return 'true';
            }
            return null;
          default:
            return null;
        }
      });
    });

    tearDownAll(() {
      // Remove os mocks
      const MethodChannel('plugins.flutter.io/local_auth')
          .setMockMethodCallHandler(null);
      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler(null);
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
          .setMockMethodCallHandler(null);
    });

    group('✅ Autenticação Biométrica', () {
      test('Deve verificar disponibilidade de biometria', () async {
        // Testa verificação de disponibilidade
        final result = await BiometricService.isBiometricAvailable();
        expect(result, isA<bool>());
        print('✅ Biometria disponível: $result');
      });

      test('Deve obter tipos de biometria disponíveis', () async {
        // Testa obtenção de tipos de biometria
        final result = await BiometricService.getAvailableBiometrics();
        expect(result, isA<List>());
        print('✅ Tipos de biometria: ${result.toString()}');
      });

      test('Deve verificar se há biometria cadastrada', () async {
        // Testa verificação de biometria cadastrada
        final result = await BiometricService.hasBiometricEnrolled();
        expect(result, isA<bool>());
        print('✅ Biometria cadastrada: $result');
      });
    });
  });
}
