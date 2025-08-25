/// Configuração local para desenvolvimento
/// 
/// Este arquivo pode ser editado localmente para alterar configurações
/// sem precisar usar --dart-define
class LocalConfig {
  // ========================================
  // 🧪 CONFIGURAÇÕES DE TESTE
  // ========================================
  
  /// Modo de teste - limpa storage para facilitar testes de primeiro acesso
  static const bool testMode = true;
  
  /// Modo de teste para "Esqueci minha senha" - simula cenários específicos
  static const bool forgotPasswordTestMode = true;
  
  /// Força sempre o fluxo de login, ignorando dados salvos
  static const bool forceLoginMode = false;
  
  // ========================================
  // 🔒 CONFIGURAÇÕES DE SEGURANÇA
  // ========================================
  
  /// Número máximo de tentativas de login antes do bloqueio temporário
  static const int maxLoginAttempts = 3;
  
  /// Número máximo de tentativas de login antes do bloqueio permanente
  static const int maxLoginAttemptsPermanent = 5;
  
  /// Duração do bloqueio temporário em minutos
  static const int lockoutDurationMinutes = 10;
  
  // ========================================
  // 🌐 CONFIGURAÇÕES DE API
  // ========================================
  
  /// URL base da API
  static const String apiBaseUrl = 'https://api.exemplo.com';
  
  /// Timeout da API em segundos
  static const int apiTimeoutSeconds = 30;
  
  // ========================================
  // 📱 CONFIGURAÇÕES DE BIOMETRIA
  // ========================================
  
  /// Habilita biometria por padrão
  static const bool biometricEnabledByDefault = false;
  
  // ========================================
  // 🔍 CONFIGURAÇÕES DE DEBUG
  // ========================================
  
  /// Habilita logs de debug
  static const bool enableDebugLogs = true;
  
  /// Simula delays de rede (em segundos)
  static const double networkDelaySeconds = 1.0;
}
