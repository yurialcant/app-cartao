/// Configurações de versão do aplicativo
/// 
/// Este arquivo centraliza todas as informações de versão
/// e é usado para exibir a versão em diferentes partes do app
class AppVersion {
  // ========================================
  // 🏷️ INFORMAÇÕES DE VERSÃO
  // ========================================
  
  /// Versão principal do aplicativo (ex: 0.0.000)
  static const String version = '0.0.002';
  
  /// Número da build (ex: 002)
  static const String buildNumber = 'dev';
  
  /// Nome do aplicativo
  static const String appName = 'Origami DEV';
  
  /// Descrição da versão
  static const String versionDescription = 'VERSÃO DE DESENVOLVIMENTO - NÃO USAR EM PRODUÇÃO';
  
  /// Data de lançamento
  static const String releaseDate = '25/08/2025 19:50';
  
  /// Ambiente de execução
  static const String environment = 'DESENVOLVIMENTO MOCK';
  
  // ========================================
  // 🔍 GETTERS PÚBLICOS
  // ========================================
  
  /// Retorna a versão completa (ex: 0.0.000-001)
  static String get fullVersion => '$version-$buildNumber';
  
  /// Retorna a versão para exibição (ex: v0.0.000)
  static String get displayVersion => 'v$version';
  
  /// Retorna informações completas da versão
  static String get fullInfo => '$appName $displayVersion (Build $buildNumber)';
  
  /// Retorna informações para debug
  static String get debugInfo => '$fullInfo - $environment - $releaseDate';
  
  // ========================================
  // 📱 VERIFICAÇÃO DE VERSÃO
  // ========================================
  
  /// Verifica se é uma versão de desenvolvimento
  static bool get isDevelopment => environment.toLowerCase() == 'development';
  
  /// Verifica se é uma versão de produção
  static bool get isProduction => environment.toLowerCase() == 'production';
  
  /// Verifica se é uma versão de teste
  static bool get isTest => environment.toLowerCase() == 'test';
  
  // ========================================
  // 🔄 HISTÓRICO DE VERSÕES
  // ========================================
  
  /// Histórico de mudanças da versão atual
  static const List<String> changelog = [
    '🚨 VERSÃO DE DESENVOLVIMENTO - NÃO USAR EM PRODUÇÃO',
    '🔧 Sistema de login completo implementado',
    '🔧 Primeiro acesso com validação de CPF',
    '🔧 Recuperação de senha por SMS/Email',
    '🔧 Sistema de mocks para desenvolvimento',
    '🔧 Gerenciamento de sessão e navegação',
    '🔧 Controle de tentativas e bloqueios',
    '🔧 Validação de senha com regras específicas',
    '🔧 Interface responsiva e acessível',
    '🔧 Sistema de configuração flexível',
    '🔧 Documentação completa da API',
    '🔧 Credenciais de teste atualizadas e validadas',
    '🔧 Funcionalidade de backspace nos campos de token',
    '🔧 Validação de CPF com máscara consistente',
    '🔧 Sistema de build automatizado com mocks',
    '🔧 Correção de bugs e melhorias de performance',
    '⚠️ APENAS PARA TESTES E DESENVOLVIMENTO',
  ];
  
  /// Retorna o changelog formatado
  static String get formattedChangelog {
    return changelog.map((item) => '• $item').join('\n');
  }
  
  // ========================================
  // 📊 ESTATÍSTICAS DA VERSÃO
  // ========================================
  
  /// Número total de funcionalidades implementadas
  static int get totalFeatures => changelog.length;
  
  /// Número de funcionalidades de segurança
  static int get securityFeatures => 4; // Login, CPF, Senha, Bloqueio
  
  /// Número de funcionalidades de UX
  static int get uxFeatures => 3; // Interface, Responsividade, Acessibilidade
  
  /// Número de funcionalidades técnicas
  static int get technicalFeatures => 3; // Mocks, Configuração, Documentação
  
  // ========================================
  // 🎯 OBJETIVOS DA VERSÃO
  // ========================================
  
  /// Objetivos principais desta versão
  static const List<String> objectives = [
    '🚨 VERSÃO DE DESENVOLVIMENTO - TESTES APENAS',
    'Sistema de autenticação robusto e seguro',
    'Experiência do usuário fluida e intuitiva',
    'Base sólida para desenvolvimento futuro',
    'Documentação completa para desenvolvedores',
    'Sistema de mocks para desenvolvimento independente',
    '⚠️ NÃO USAR EM PRODUÇÃO - APENAS DESENVOLVIMENTO',
  ];
  
  /// Retorna os objetivos formatados
  static String get formattedObjectives {
    return objectives.map((item) => '🎯 $item').join('\n');
  }
  
  // ========================================
  // 📋 INFORMAÇÕES TÉCNICAS
  // ========================================
  
  /// Tecnologias utilizadas
  static const List<String> technologies = [
    'Flutter 3.27+',
    'Dart 3.0+',
    'GoRouter para navegação',
    'GetIt para injeção de dependência',
    'SharedPreferences para storage local',
    'Flutter Secure Storage para dados sensíveis',
    'HTTP package para APIs',
    'Crypto para hashing',
  ];
  
  /// Retorna as tecnologias formatadas
  static String get formattedTechnologies {
    return technologies.map((item) => '🛠️ $item').join('\n');
  }
  
  // ========================================
  // 🔧 CONFIGURAÇÕES DE BUILD
  // ========================================
  
  /// Configurações específicas para debug
  static const Map<String, String> debugConfig = {
    'TEST_MODE': 'true',
    'USE_MOCKS': 'true',
    'FORGOT_PASSWORD_TEST_MODE': 'true',
    'FORCE_LOGIN_MODE': 'false',
    'API_BASE_URL': 'http://localhost:8080',
    'API_TIMEOUT_SECONDS': '30',
    'NETWORK_DELAY_SECONDS': '1',
    'DEV_MODE': 'true',
    'DEBUG_ENABLED': 'true',
    'MOCK_DATA': 'true',
  };
  
  /// Configurações específicas para release
  static const Map<String, String> releaseConfig = {
    'TEST_MODE': 'false',
    'USE_MOCKS': 'false',
    'FORGOT_PASSWORD_TEST_MODE': 'false',
    'FORCE_LOGIN_MODE': 'false',
    'API_BASE_URL': 'https://api.producao.com',
    'API_TIMEOUT_SECONDS': '30',
    'NETWORK_DELAY_SECONDS': '0',
  };
  
  /// Retorna as configurações atuais baseadas no ambiente
  static Map<String, String> get currentConfig {
    if (isDevelopment) {
      return debugConfig;
    } else {
      return releaseConfig;
    }
  }
  
  // ========================================
  // 📱 EXIBIÇÃO DA VERSÃO
  // ========================================
  
  /// Retorna texto para exibição na tela de splash
  static String get splashText => '$appName\n$displayVersion\n🚨 DEV VERSION';
  
  /// Retorna texto para exibição no dashboard
  static String get dashboardText => 'Versão $version (DEV)';
  
  /// Retorna texto para exibição nas configurações
  static String get settingsText => '$appName $displayVersion (DEV)';
  
  /// Retorna texto para exibição no about
  static String get aboutText => '$fullInfo\n\n$versionDescription\n\n🚨 VERSÃO DE DESENVOLVIMENTO - NÃO USAR EM PRODUÇÃO';
  
  // ========================================
  // 🔍 DEBUG E LOGS
  // ========================================
  
  /// Retorna informações completas para debug
  static String get debugString {
    return '''
=== APP VERSION DEBUG INFO ===
🚨 VERSÃO DE DESENVOLVIMENTO - NÃO USAR EM PRODUÇÃO 🚨
App: $appName
Version: $version
Build: $buildNumber
Full Version: $fullVersion
Environment: $environment
Release Date: $releaseDate
Total Features: $totalFeatures
Security Features: $securityFeatures
UX Features: $uxFeatures
Technical Features: $technicalFeatures
⚠️ APENAS PARA TESTES E DESENVOLVIMENTO ⚠️
================================
''';
  }
  
  /// Imprime informações de debug no console
  static void printDebugInfo() {
    print(debugString);
    print('Changelog:');
    print(formattedChangelog);
    print('\nObjectives:');
    print(formattedObjectives);
    print('\nTechnologies:');
    print(formattedTechnologies);
    print('\nCurrent Config:');
    currentConfig.forEach((key, value) {
      print('$key: $value');
    });
  }
}

