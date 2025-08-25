/// Configuração de endpoints da API
class ApiEndpoints {
  // ========================================
  // 🌐 CONFIGURAÇÕES DE AMBIENTE
  // ========================================
  
  /// URL base da API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.carteirabeneficios.com.br',
  );
  
  /// Versão da API
  static const String apiVersion = 'v1';
  
  /// URL completa da API
  static String get apiUrl => '$baseUrl/api/$apiVersion';
  
  /// URL do websocket
  static String get websocketUrl => baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
  
  // ========================================
  // 🔐 ENDPOINTS DE AUTENTICAÇÃO
  // ========================================
  
  /// Verificação de CPF
  static const String cpfCheck = '/auth/cpf-check';
  
  /// Login
  static const String login = '/auth/login';
  
  /// Login com biometria
  static const String biometricLogin = '/auth/biometric-login';
  
  /// Logout
  static const String logout = '/auth/logout';
  
  /// Refresh token
  static const String refreshToken = '/auth/refresh-token';
  
  /// Verificação de primeiro acesso
  static const String firstAccessCheck = '/auth/first-access-check';
  
  /// Registro de primeiro acesso
  static const String firstAccessRegister = '/auth/first-access-register';
  
  /// Envio de token SMS
  static const String sendSmsToken = '/auth/send-sms-token';
  
  /// Envio de token Email
  static const String sendEmailToken = '/auth/send-email-token';
  
  /// Verificação de token
  static const String verifyToken = '/auth/verify-token';
  
  /// Recuperação de senha
  static const String forgotPassword = '/auth/forgot-password';
  
  /// Reset de senha
  static const String resetPassword = '/auth/reset-password';
  
  /// Verificação de dispositivo
  static const String deviceVerification = '/auth/device-verification';
  
  /// Autorização de dispositivo
  static const String deviceAuthorization = '/auth/device-authorization';
  
  // ========================================
  // 👤 ENDPOINTS DE USUÁRIO
  // ========================================
  
  /// Perfil do usuário
  static const String userProfile = '/user/profile';
  
  /// Atualização de perfil
  static const String updateProfile = '/user/profile/update';
  
  /// Alteração de senha
  static const String changePassword = '/user/change-password';
  
  /// Configurações do usuário
  static const String userSettings = '/user/settings';
  
  /// Atualização de configurações
  static const String updateSettings = '/user/settings/update';
  
  /// Notificações do usuário
  static const String userNotifications = '/user/notifications';
  
  /// Marcar notificação como lida
  static const String markNotificationRead = '/user/notifications/read';
  
  /// Preferências de notificação
  static const String notificationPreferences = '/user/notifications/preferences';
  
  // ========================================
  // 🔐 ENDPOINTS DE SEGURANÇA
  // ========================================
  
  /// Configuração de biometria
  static const String biometricSetup = '/security/biometric-setup';
  
  /// Habilitação de biometria
  static const String enableBiometric = '/security/biometric/enable';
  
  /// Desabilitação de biometria
  static const String disableBiometric = '/security/biometric/disable';
  
  /// Verificação de biometria
  static const String verifyBiometric = '/security/biometric/verify';
  
  /// Histórico de login
  static const String loginHistory = '/security/login-history';
  
  /// Dispositivos autorizados
  static const String authorizedDevices = '/security/authorized-devices';
  
  /// Revogar dispositivo
  static const String revokeDevice = '/security/revoke-device';
  
  /// Configurações de segurança
  static const String securitySettings = '/security/settings';
  
  /// Atualização de configurações de segurança
  static const String updateSecuritySettings = '/security/settings/update';
  
  // ========================================
  // 💰 ENDPOINTS FINANCEIROS
  // ========================================
  
  /// Saldo da conta
  static const String accountBalance = '/finance/balance';
  
  /// Extrato da conta
  static const String accountStatement = '/finance/statement';
  
  /// Transações
  static const String transactions = '/finance/transactions';
  
  /// Detalhes da transação
  static const String transactionDetails = '/finance/transactions/{id}';
  
  /// Pagamentos
  static const String payments = '/finance/payments';
  
  /// Realizar pagamento
  static const String makePayment = '/finance/payments/create';
  
  /// Transferências
  static const String transfers = '/finance/transfers';
  
  /// Realizar transferência
  static const String makeTransfer = '/finance/transfers/create';
  
  /// Pix
  static const String pix = '/finance/pix';
  
  /// Gerar QR Code Pix
  static const String generatePixQrCode = '/finance/pix/qr-code';
  
  /// Ler QR Code Pix
  static const String readPixQrCode = '/finance/pix/read-qr';
  
  /// Cartões
  static const String cards = '/finance/cards';
  
  /// Detalhes do cartão
  static const String cardDetails = '/finance/cards/{id}';
  
  /// Bloquear cartão
  static const String blockCard = '/finance/cards/{id}/block';
  
  /// Desbloquear cartão
  static const String unblockCard = '/finance/cards/{id}/unblock';
  
  // ========================================
  // 📱 ENDPOINTS DE DISPOSITIVO
  // ========================================
  
  /// Informações do dispositivo
  static const String deviceInfo = '/device/info';
  
  /// Registro de dispositivo
  static const String deviceRegistration = '/device/register';
  
  /// Atualização de dispositivo
  static const String deviceUpdate = '/device/update';
  
  /// Status do dispositivo
  static const String deviceStatus = '/device/status';
  
  /// Configurações do dispositivo
  static const String deviceSettings = '/device/settings';
  
  // ========================================
  // 📋 ENDPOINTS DE COMPLIANCE
  // ========================================
  
  /// Termos de uso
  static const String termsOfUse = '/compliance/terms-of-use';
  
  /// Política de privacidade
  static const String privacyPolicy = '/compliance/privacy-policy';
  
  /// Aceitação de termos
  static const String acceptTerms = '/compliance/accept-terms';
  
  /// Status de aceitação
  static const String termsAcceptanceStatus = '/compliance/terms-status';
  
  /// Políticas de segurança
  static const String securityPolicies = '/compliance/security-policies';
  
  /// Regulamentações
  static const String regulations = '/compliance/regulations';
  
  // ========================================
  // 📊 ENDPOINTS DE RELATÓRIOS
  // ========================================
  
  /// Relatório de transações
  static const String transactionReport = '/reports/transactions';
  
  /// Relatório de pagamentos
  static const String paymentReport = '/reports/payments';
  
  /// Relatório de transferências
  static const String transferReport = '/reports/transfers';
  
  /// Relatório de Pix
  static const String pixReport = '/reports/pix';
  
  /// Relatório de cartões
  static const String cardReport = '/reports/cards';
  
  /// Relatório de segurança
  static const String securityReport = '/reports/security';
  
  // ========================================
  // 🆘 ENDPOINTS DE SUPORTE
  // ========================================
  
  /// FAQ
  static const String faq = '/support/faq';
  
  /// Contato
  static const String contact = '/support/contact';
  
  /// Ticket de suporte
  static const String supportTicket = '/support/ticket';
  
  /// Criar ticket
  static const String createTicket = '/support/ticket/create';
  
  /// Status do ticket
  static const String ticketStatus = '/support/ticket/{id}/status';
  
  /// Chat de suporte
  static const String supportChat = '/support/chat';
  
  /// Base de conhecimento
  static const String knowledgeBase = '/support/knowledge-base';
  
  // ========================================
  // 🔧 ENDPOINTS DE SISTEMA
  // ========================================
  
  /// Health check
  static const String healthCheck = '/system/health';
  
  /// Status do sistema
  static const String systemStatus = '/system/status';
  
  /// Manutenção
  static const String maintenance = '/system/maintenance';
  
  /// Versão da API
  static const String apiVersionInfo = '/system/version';
  
  /// Configurações do sistema
  static const String systemConfig = '/system/config';
  
  /// Logs do sistema
  static const String systemLogs = '/system/logs';
  
  // ========================================
  // 📱 ENDPOINTS DE PUSH NOTIFICATIONS
  // ========================================
  
  /// Registro de token push
  static const String pushTokenRegistration = '/push/register';
  
  /// Atualização de token push
  static const String pushTokenUpdate = '/push/update';
  
  /// Remoção de token push
  static const String pushTokenRemoval = '/push/remove';
  
  /// Preferências de push
  static const String pushPreferences = '/push/preferences';
  
  /// Histórico de push
  static const String pushHistory = '/push/history';
  
  // ========================================
  // 🔍 MÉTODOS AUXILIARES
  // ========================================
  
  /// Constrói URL completa para um endpoint
  static String buildUrl(String endpoint) {
    return '$apiUrl$endpoint';
  }
  
  /// Constrói URL com parâmetros
  static String buildUrlWithParams(String endpoint, Map<String, String> params) {
    final uri = Uri.parse('$apiUrl$endpoint').replace(queryParameters: params);
    return uri.toString();
  }
  
  /// Constrói URL com path parameters
  static String buildUrlWithPathParams(String endpoint, Map<String, String> pathParams) {
    String url = endpoint;
    pathParams.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return '$apiUrl$url';
  }
  
  /// Constrói URL para websocket
  static String buildWebsocketUrl(String endpoint) {
    return '$websocketUrl$endpoint';
  }
}
