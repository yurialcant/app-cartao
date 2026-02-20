import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../storage/app_storage.dart';

/// Serviço de autenticação biométrica
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  // ========================================
  // 🔍 VERIFICAÇÃO DE DISPONIBILIDADE
  // ========================================
  
  /// Verifica se a biometria está disponível no dispositivo
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  /// Verifica se há biometria cadastrada
  static Future<bool> hasBiometricEnrolled() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtém tipos de biometria disponíveis
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  // ========================================
  // 🔐 AUTENTICAÇÃO BIOMÉTRICA
  // ========================================
  
  /// Autentica usando biometria
  static Future<bool> authenticate({
    String reason = 'Autentique-se para acessar o aplicativo',
    String cancelText = 'Cancelar',
    String biometricHint = 'Toque no sensor',
    bool stickyAuth = true,
  }) async {
    try {
      // Verifica se biometria está disponível
      if (!await isBiometricAvailable()) {
        throw BiometricException('Biometria não disponível');
      }
      
      // Verifica se há biometria cadastrada
      if (!await hasBiometricEnrolled()) {
        throw BiometricException('Nenhuma biometria cadastrada');
      }
      
      // Verifica se biometria está habilitada pelo usuário
      if (!AppStorage.isBiometricEnabled()) {
        throw BiometricException('Biometria desabilitada pelo usuário');
      }
      
      // Configura opções de autenticação
      final authOptions = AuthenticationOptions(
        stickyAuth: stickyAuth,
        biometricOnly: true,
        useErrorDialogs: true,
      );
      
      // Executa autenticação
      final success = await _localAuth.authenticate(
        localizedReason: reason,
        options: authOptions,
      );
      
      return success;
    } catch (e) {
      if (e is BiometricException) {
        rethrow;
      }
      throw BiometricException('Erro na autenticação biométrica: $e');
    }
  }
  
  /// Autentica com fallback para PIN/senha
  static Future<bool> authenticateWithFallback({
    String reason = 'Autentique-se para acessar o aplicativo',
    String cancelText = 'Cancelar',
    String biometricHint = 'Toque no sensor',
    bool stickyAuth = true,
  }) async {
    try {
      // Verifica se biometria está disponível
      if (!await isBiometricAvailable()) {
        throw BiometricException('Biometria não disponível');
      }
      
      // Verifica se há biometria cadastrada
      if (!await hasBiometricEnrolled()) {
        throw BiometricException('Nenhuma biometria cadastrada');
      }
      
      // Configura opções de autenticação com fallback
      final authOptions = AuthenticationOptions(
        stickyAuth: stickyAuth,
        biometricOnly: false, // Permite fallback
        useErrorDialogs: true,
      );
      
      // Executa autenticação
      final success = await _localAuth.authenticate(
        localizedReason: reason,
        options: authOptions,
      );
      
      return success;
    } catch (e) {
      if (e is BiometricException) {
        rethrow;
      }
      throw BiometricException('Erro na autenticação biométrica: $e');
    }
  }
  
  // ========================================
  // ⚙️ CONFIGURAÇÕES
  // ========================================
  
  /// Habilita biometria para o usuário
  static Future<void> enableBiometric() async {
    await AppStorage.setBiometricEnabled(true);
  }
  
  /// Desabilita biometria para o usuário
  static Future<void> disableBiometric() async {
    await AppStorage.setBiometricEnabled(false);
  }
  
  /// Verifica se biometria está habilitada
  static bool isBiometricEnabled() {
    return AppStorage.isBiometricEnabled();
  }
  
  // ========================================
  // 🔒 SEGURANÇA
  // ========================================
  
  /// Verifica se o dispositivo está seguro
  static Future<bool> isDeviceSecure() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
  
  /// Força logout (limpa dados biométricos)
  static Future<void> forceLogout() async {
    await AppStorage.clearAll();
  }
  
  // ========================================
  // 📱 CONFIGURAÇÕES ESPECÍFICAS DE PLATAFORMA
  // ========================================
  
  /// Configura opções específicas do Android
  static void configureAndroid() {
    // Configurações específicas do Android podem ser adicionadas aqui
    // quando necessário para versões futuras do local_auth
  }
  
  /// Configura opções específicas do iOS
  static void configureIOS() {
    // Configurações específicas do iOS podem ser adicionadas aqui
    // quando necessário para versões futuras do local_auth
  }
  
  // ========================================
  // 🧪 FUNÇÕES PARA TESTES
  // ========================================
  
  /// Simula falha de biometria (apenas para testes)
  static Future<bool> simulateBiometricFailure() async {
    // Esta função só deve ser usada em ambiente de teste
    const testMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);
    
    if (testMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return false; // Simula falha
    }
    
    // Em produção, sempre tenta autenticação real
    return await authenticate();
  }
  
  /// Simula sucesso de biometria (apenas para testes)
  static Future<bool> simulateBiometricSuccess() async {
    // Esta função só deve ser usada em ambiente de teste
    const testMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);
    
    if (testMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true; // Simula sucesso
    }
    
    // Em produção, sempre tenta autenticação real
    return await authenticate();
  }
}

/// Exceção específica para erros de biometria
class BiometricException implements Exception {
  final String message;
  
  BiometricException(this.message);
  
  @override
  String toString() => 'BiometricException: $message';
}
