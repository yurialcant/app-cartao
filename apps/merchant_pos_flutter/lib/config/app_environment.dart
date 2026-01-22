/// Configuração centralizada para Merchant POS
/// Suporta Android Emulator, iOS Simulator, Dispositivo Físico e Web
import 'dart:io';

enum Environment {
  development,
  staging,
  production,
}

class AppEnvironment {
  static final AppEnvironment _instance = AppEnvironment._internal();

  late Environment _environment;
  late Map<String, String> _config;

  factory AppEnvironment() {
    return _instance;
  }

  AppEnvironment._internal();

  /// Inicializa a configuração com base no ambiente
  void initialize({
    Environment environment = Environment.development,
    Map<String, String>? customConfig,
  }) {
    _environment = environment;
    _config = _getConfigForEnvironment(environment);
    
    // Override com custom config se fornecido
    if (customConfig != null) {
      _config.addAll(customConfig);
    }
  }

  /// Retorna a configuração para o ambiente especificado
  Map<String, String> _getConfigForEnvironment(Environment env) {
    switch (env) {
      case Environment.development:
        return _developmentConfig();
      case Environment.staging:
        return _stagingConfig();
      case Environment.production:
        return _productionConfig();
    }
  }

  /// Configuração para desenvolvimento (localhost / emulator)
  /// Merchant POS usa a porta 8084 (Merchant BFF)
  Map<String, String> _developmentConfig() {
    return {
      'base_url': _getLocalBaseUrl(),
      'api_timeout': '10',
      'retry_enabled': 'true',
      'debug_enabled': 'true',
      'log_enabled': 'true',
    };
  }

  /// Configuração para staging
  Map<String, String> _stagingConfig() {
    return {
      'base_url': 'https://staging-merchant.benefits.test',
      'api_timeout': '15',
      'retry_enabled': 'true',
      'debug_enabled': 'true',
      'log_enabled': 'true',
    };
  }

  /// Configuração para produção
  Map<String, String> _productionConfig() {
    return {
      'base_url': 'https://merchant.benefits.test',
      'api_timeout': '30',
      'retry_enabled': 'true',
      'debug_enabled': 'false',
      'log_enabled': 'false',
    };
  }

  /// Detecta o IP correto baseado na plataforma
  /// - Android Emulator: 10.0.2.2 (gateway para localhost do host)
  /// - iOS Simulator: localhost
  /// - Dispositivo Físico: precisa do IP real da máquina
  /// - Web: localhost
  /// Merchant POS usa porta 8084
  static String _getLocalBaseUrl() {
    if (Platform.isAndroid) {
      // Android Emulator usa 10.0.2.2 para acessar localhost do host
      return 'http://10.0.2.2:8084';
    } else if (Platform.isIOS) {
      // iOS Simulator e Dispositivo Physical usam localhost
      return 'http://localhost:8084';
    } else {
      // Web e outros
      return 'http://localhost:8084';
    }
  }

  // Getters para as configurações
  Environment get environment => _environment;
  String get baseUrl => _config['base_url'] ?? 'http://localhost:8084';
  int get apiTimeoutSeconds => 
    int.tryParse(_config['api_timeout'] ?? '10') ?? 10;
  bool get retryEnabled => 
    _config['retry_enabled']?.toLowerCase() == 'true';
  bool get debugEnabled => 
    _config['debug_enabled']?.toLowerCase() == 'true';
  bool get logEnabled => 
    _config['log_enabled']?.toLowerCase() == 'true';

  /// Permite sobrescrever a URL base (útil para teste)
  void setBaseUrl(String url) {
    _config['base_url'] = url;
  }

  /// Permite sobrescrever o ambiente
  void setEnvironment(Environment env) {
    _environment = env;
    _config = _getConfigForEnvironment(env);
  }

  /// Retorna informações de debug
  String getDebugInfo() {
    return '''
AppEnvironment Debug Info (Merchant POS):
- Environment: $_environment
- Base URL: $baseUrl
- Timeout: ${apiTimeoutSeconds}s
- Retry Enabled: $retryEnabled
- Debug Enabled: $debugEnabled
- Log Enabled: $logEnabled
- Platform: ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : Platform.isLinux ? 'Linux' : Platform.isWindows ? 'Windows' : 'Unknown'}
- Config Keys: ${_config.keys.toList()}
    ''';
  }
}
