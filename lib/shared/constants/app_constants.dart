/// Constantes globais do aplicativo
class AppConstants {
  // ========================================
  // 📱 CONFIGURAÇÕES DO APP
  // ========================================
  
  /// Nome do aplicativo
  static const String appName = 'Carteira de Benefícios';
  
  /// Versão do aplicativo
  static const String appVersion = '1.0.0';
  
  /// Build number
  static const String buildNumber = '1';
  
  // ========================================
  // 🎨 CORES
  // ========================================
  
  /// Cor primária
  static const int primaryColor = 0xFF1E40AF;
  
  /// Cor primária clara
  static const int primaryColorLight = 0xFF3B82F6;
  
  /// Cor primária escura
  static const int primaryColorDark = 0xFF1E3A8A;
  
  /// Cor de sucesso
  static const int successColor = 0xFF10B981;
  
  /// Cor de erro
  static const int errorColor = 0xFFE53E3E;
  
  /// Cor de aviso
  static const int warningColor = 0xFFF59E0B;
  
  /// Cor de informação
  static const int infoColor = 0xFF3B82F6;
  
  // ========================================
  // 📏 DIMENSÕES
  // ========================================
  
  /// Padding padrão
  static const double defaultPadding = 16.0;
  
  /// Padding grande
  static const double largePadding = 24.0;
  
  /// Padding pequeno
  static const double smallPadding = 8.0;
  
  /// Border radius padrão
  static const double defaultBorderRadius = 12.0;
  
  /// Border radius grande
  static const double largeBorderRadius = 16.0;
  
  /// Border radius pequeno
  static const double smallBorderRadius = 8.0;
  
  // ========================================
  // ⏱️ DURAÇÕES
  // ========================================
  
  /// Duração de animação padrão
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  /// Duração de animação rápida
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  
  /// Duração de animação lenta
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // ========================================
  // 🔐 CONFIGURAÇÕES DE SEGURANÇA
  // ========================================
  
  /// Número máximo de tentativas de login
  static const int maxLoginAttempts = 3;
  
  /// Tempo de bloqueio da conta (em minutos)
  static const int accountLockoutMinutes = 10;
  
  /// Duração da sessão (em horas)
  static const int sessionDurationHours = 24;
  
  // ========================================
  // 📱 CONFIGURAÇÕES DE PLATAFORMA
  // ========================================
  
  /// Altura mínima da tela para considerar como tablet
  static const double tabletBreakpoint = 600.0;
  
  /// Altura mínima da tela para considerar como desktop
  static const double desktopBreakpoint = 900.0;
  
  // ========================================
  // 🌐 CONFIGURAÇÕES DE IDIOMA
  // ========================================
  
  /// Idioma padrão
  static const String defaultLanguage = 'pt';
  
  /// País padrão
  static const String defaultCountry = 'BR';
  
  /// Locale padrão
  static const String defaultLocale = 'pt_BR';
  
  // ========================================
  // 📊 CONFIGURAÇÕES DE CACHE
  // ========================================
  
  /// Duração do cache (em horas)
  static const int cacheDurationHours = 1;
  
  /// Tamanho máximo do cache (em MB)
  static const int maxCacheSizeMB = 100;
  
  // ========================================
  // 🔧 CONFIGURAÇÕES DE DEBUG
  // ========================================
  
  /// Modo de debug
  static const bool isDebugMode = true;
  
  /// Log de navegação
  static const bool enableNavigationLogging = true;
  
  /// Log de performance
  static const bool enablePerformanceLogging = false;
}
