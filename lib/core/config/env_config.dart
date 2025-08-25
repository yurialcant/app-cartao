import 'package:flutter/foundation.dart';
import 'local_config.dart';

/// Configuração de ambiente da aplicação
class EnvConfig {
  // ========================================
  // 🧪 CONFIGURAÇÕES DE TESTE
  // ========================================
  
  /// Modo de teste - limpa storage para facilitar testes de primeiro acesso
  static bool get isTestMode {
    // Prioridade: --dart-define > LocalConfig > default
    return bool.fromEnvironment('TEST_MODE', defaultValue: LocalConfig.testMode);
  }
  
  /// Modo de teste para "Esqueci minha senha" - simula cenários específicos
  static bool get isForgotPasswordTestMode {
    // Prioridade: --dart-define > LocalConfig > default
    return bool.fromEnvironment('FORGOT_PASSWORD_TEST_MODE', defaultValue: LocalConfig.forgotPasswordTestMode);
  }
  
  /// Força sempre o fluxo de login, ignorando dados salvos
  static bool get isForceLoginMode {
    // Prioridade: --dart-define > LocalConfig > default
    return bool.fromEnvironment('FORCE_LOGIN_MODE', defaultValue: LocalConfig.forceLoginMode);
  }
  
  // ========================================
  // 🔒 CONFIGURAÇÕES DE SEGURANÇA
  // ========================================
  
  /// Número máximo de tentativas de login antes do bloqueio temporário
  static int get maxLoginAttempts {
    // Prioridade: --dart-define > LocalConfig > default
    return int.fromEnvironment('MAX_LOGIN_ATTEMPTS', defaultValue: LocalConfig.maxLoginAttempts);
  }
  
  /// Número máximo de tentativas de login antes do bloqueio permanente
  static int get maxLoginAttemptsPermanent {
    // Prioridade: --dart-define > LocalConfig > default
    return int.fromEnvironment('MAX_LOGIN_ATTEMPTS_PERMANENT', defaultValue: LocalConfig.maxLoginAttemptsPermanent);
  }
  
  /// Duração do bloqueio temporário em minutos
  static int get lockoutDurationMinutes {
    // Prioridade: --dart-define > LocalConfig > default
    return int.fromEnvironment('LOCKOUT_DURATION_MINUTES', defaultValue: LocalConfig.lockoutDurationMinutes);
  }
  
  /// Duração do bloqueio temporário como Duration
  static Duration get lockoutDuration {
    return Duration(minutes: lockoutDurationMinutes);
  }
  
  // ========================================
  // 🌐 CONFIGURAÇÕES DE API
  // ========================================
  
  /// URL base da API
  static String get apiBaseUrl {
    // Prioridade: --dart-define > LocalConfig > default
    return String.fromEnvironment('API_BASE_URL', defaultValue: LocalConfig.apiBaseUrl);
  }
  
  /// Timeout da API em segundos
  static int get apiTimeoutSeconds {
    // Prioridade: --dart-define > LocalConfig > default
    return int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: LocalConfig.apiTimeoutSeconds);
  }
  
  /// Timeout da API como Duration
  static Duration get apiTimeout {
    return Duration(seconds: apiTimeoutSeconds);
  }
  
  // ========================================
  // 📱 CONFIGURAÇÕES DE BIOMETRIA
  // ========================================
  
  /// Habilita biometria por padrão
  static bool get biometricEnabledByDefault {
    // Prioridade: --dart-define > LocalConfig > default
    return bool.fromEnvironment('BIOMETRIC_ENABLED_BY_DEFAULT', defaultValue: LocalConfig.biometricEnabledByDefault);
  }
  
  // ========================================
  // 🔍 CONFIGURAÇÕES DE DEBUG
  // ========================================
  
  /// Habilita logs de debug
  static bool get enableDebugLogs {
    // Prioridade: --dart-define > LocalConfig > default
    return bool.fromEnvironment('ENABLE_DEBUG_LOGS', defaultValue: LocalConfig.enableDebugLogs);
  }
  
  /// Delay de rede simulado para tornar mocks mais realistas
  static double get networkDelaySeconds {
    // Prioridade: --dart-define > LocalConfig > default
    return double.tryParse(String.fromEnvironment('NETWORK_DELAY_SECONDS')) ?? LocalConfig.networkDelaySeconds;
  }
  
  // ========================================
  // 🌍 CONFIGURAÇÕES DE AMBIENTE
  // ========================================
  
  /// Verifica se está em modo de desenvolvimento
  static bool get isDevelopment {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'dev';
  }
  
  /// Verifica se está em modo de produção
  static bool get isProduction {
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    return env == 'dev';
  }
  
  /// Verifica se deve usar mocks
  static bool get useMocks {
    const useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: true);
    return useMocks || isDevelopment;
  }
  
  // ========================================
  // 📱 CONFIGURAÇÕES DO APP
  // ========================================
  
  /// Nome da aplicação
  static const String appName = 'Carteira de Benefícios';
  
  /// Versão da aplicação
  static const String appVersion = '1.0.0';
  
  /// Build number da aplicação
  static const String buildNumber = '1';
  
  /// Descrição da aplicação
  static const String appDescription = 'Sistema completo de login e benefícios desenvolvido em Flutter';
  
  // ========================================
  // 🔒 CONFIGURAÇÕES DE SENHA
  // ========================================
  
  /// Comprimento mínimo da senha
  static const int minPasswordLength = 6;
  
  /// Comprimento máximo da senha
  static const int maxPasswordLength = 8;
  
  // ========================================
  // 📊 CONFIGURAÇÕES DE LOG
  // ========================================
  
  /// Nível de log para desenvolvimento
  static const String devLogLevel = 'DEBUG';
  
  /// Nível de log para produção
  static const String prodLogLevel = 'ERROR';
  
  /// Retorna o nível de log baseado no ambiente
  static String get logLevel {
    if (isProduction) {
      return prodLogLevel;
    }
    return devLogLevel;
  }
  
  /// Verifica se deve mostrar logs de debug
  static bool get showDebugLogs {
    return !isProduction;
  }
  
  // ========================================
  // 🧪 CONFIGURAÇÕES DE TESTE
  // ========================================
  
  /// Timeout padrão para testes
  static const Duration testTimeout = Duration(seconds: 30);
  
  /// Verifica se deve usar dados mockados em testes
  static bool get useMockDataInTests {
    return isTestMode || useMocks;
  }
  
  /// CPFs válidos para testes
  static const List<String> testCpfs = [
    '111.444.777-35',  // Primeiro acesso
    '222.555.888-46',  // Primeiro acesso
    '946.919.070-09',  // Usuário existente
    '632.543.510-96',  // Usuário existente
  ];
  
  /// Senhas válidas para testes
  static const Map<String, String> testPasswords = {
    '946.919.070-09': 'Test123!',
    '632.543.510-96': 'Test123!',
  };
  
  /// Token válido para testes
  static const String testToken = '1234';
  
  // ========================================
  // 📋 INFORMAÇÕES DO AMBIENTE
  // ========================================
  
  /// Retorna todas as configurações atuais como string
  static String get currentConfig {
    return '''
🔧 CONFIGURAÇÃO ATUAL:
🧪 TEST_MODE: $isTestMode
🔑 FORGOT_PASSWORD_TEST_MODE: $isForgotPasswordTestMode
🚫 FORCE_LOGIN_MODE: $isForceLoginMode
🔒 MAX_LOGIN_ATTEMPTS: $maxLoginAttempts
🔒 MAX_LOGIN_ATTEMPTS_PERMANENT: $maxLoginAttemptsPermanent
⏰ LOCKOUT_DURATION_MINUTES: $lockoutDurationMinutes
🌐 API_BASE_URL: $apiBaseUrl
⏱️ API_TIMEOUT_SECONDS: $apiTimeoutSeconds
📱 BIOMETRIC_ENABLED_BY_DEFAULT: $biometricEnabledByDefault
🔍 ENABLE_DEBUG_LOGS: $enableDebugLogs
⏱️ NETWORK_DELAY_SECONDS: $networkDelaySeconds
🌍 ENVIRONMENT: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}
📱 USE_MOCKS: $useMocks
''';
  }
}
