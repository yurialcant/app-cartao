import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_login_app/core/routing/route_paths.dart';
import 'package:flutter_login_app/core/storage/app_storage.dart';

/// Serviço de navegação centralizado
class NavigationService {
  // ========================================
  // 🏠 NAVEGAÇÃO PÚBLICA
  // ========================================
  
  /// Navega para a tela de boas-vindas
  static void goToWelcome(BuildContext context) {
    context.go(RoutePaths.welcome);
  }
  
  /// Navega para verificação de CPF
  static void goToCpfCheck(BuildContext context) {
    context.go(RoutePaths.cpfCheck);
  }
  
  /// Navega para termos de uso
  static void goToTermsOfUse(BuildContext context) {
    context.go(RoutePaths.termsOfUse);
  }
  
  /// Navega para seleção de método
  static void goToFirstAccessMethod(BuildContext context) {
    context.go(RoutePaths.firstAccessMethod);
  }
  
  /// Navega para token de primeiro acesso
  static void goToFirstAccessToken(BuildContext context) {
    context.go(RoutePaths.firstAccessToken);
  }
  
  /// Navega para registro de senha
  static void goToFirstAccessRegister(BuildContext context) {
    context.go(RoutePaths.firstAccessRegister);
  }
  
  /// Navega para login
  static void goToLogin(BuildContext context) {
    context.go(RoutePaths.login);
  }
  
  /// Navega para recuperação de senha
  static void goToForgotPassword(BuildContext context) {
    context.go(RoutePaths.forgotPassword);
  }
  
  /// Navega para token do dispositivo
  static void goToDeviceToken(BuildContext context) {
    context.go(RoutePaths.deviceToken);
  }
  
  // ========================================
  // 🔐 NAVEGAÇÃO PROTEGIDA
  // ========================================
  
  /// Navega para o dashboard
  static void goToDashboard(BuildContext context) {
    context.go(RoutePaths.dashboard);
  }
  
  /// Navega para perfil do usuário
  static void goToProfile(BuildContext context) {
    context.go(RoutePaths.profile);
  }
  
  /// Navega para configurações
  static void goToSettings(BuildContext context) {
    context.go(RoutePaths.settings);
  }
  
  /// Navega para transações
  static void goToTransactions(BuildContext context) {
    context.go(RoutePaths.transactions);
  }
  
  /// Navega para pagamentos
  static void goToPayments(BuildContext context) {
    context.go(RoutePaths.payments);
  }
  
  /// Navega para transferências
  static void goToTransfers(BuildContext context) {
    context.go(RoutePaths.transfers);
  }
  
  /// Navega para Pix
  static void goToPix(BuildContext context) {
    context.go(RoutePaths.pix);
  }
  
  /// Navega para cartões
  static void goToCards(BuildContext context) {
    context.go(RoutePaths.cards);
  }
  
  /// Navega para investimentos
  static void goToInvestments(BuildContext context) {
    context.go(RoutePaths.investments);
  }
  
  /// Navega para seguros
  static void goToInsurance(BuildContext context) {
    context.go(RoutePaths.insurance);
  }
  
  /// Navega para suporte
  static void goToSupport(BuildContext context) {
    context.go(RoutePaths.support);
  }
  
  /// Navega para sobre o app
  static void goToAbout(BuildContext context) {
    context.go(RoutePaths.about);
  }
  
  /// Navega para política de privacidade
  static void goToPrivacyPolicy(BuildContext context) {
    context.go(RoutePaths.privacyPolicy);
  }
  
  /// Navega para termos completos
  static void goToFullTerms(BuildContext context) {
    context.go(RoutePaths.fullTerms);
  }
  
  /// Navega para FAQ
  static void goToFaq(BuildContext context) {
    context.go(RoutePaths.faq);
  }
  
  /// Navega para contato
  static void goToContact(BuildContext context) {
    context.go(RoutePaths.contact);
  }
  
  /// Navega para notificações
  static void goToNotifications(BuildContext context) {
    context.go(RoutePaths.notifications);
  }
  
  /// Navega para biometria
  static void goToBiometrics(BuildContext context) {
    context.go(RoutePaths.biometrics);
  }
  
  /// Navega para segurança
  static void goToSecurity(BuildContext context) {
    context.go(RoutePaths.security);
  }
  
  /// Navega para backup
  static void goToBackup(BuildContext context) {
    context.go(RoutePaths.backup);
  }
  
  /// Navega para restauração
  static void goToRestore(BuildContext context) {
    context.go(RoutePaths.restore);
  }
  
  // ========================================
  // 🔄 NAVEGAÇÃO COM PARÂMETROS
  // ========================================
  
  /// Navega para uma rota com parâmetros
  static void goToWithParams(BuildContext context, String route, Map<String, dynamic> params) {
    context.go(route, extra: params);
  }
  
  /// Navega para uma rota com query parameters
  static void goToWithQuery(BuildContext context, String route, Map<String, String> queryParams) {
    final uri = Uri(path: route, queryParameters: queryParams);
    context.go(uri.toString());
  }
  
  // ========================================
  // 🚪 NAVEGAÇÃO DE SAÍDA
  // ========================================
  
  /// Faz logout e navega para login
  static Future<void> logout(BuildContext context) async {
    // Limpa dados de autenticação
    await AppStorage.clearAuthData();
    
    // Navega para login
    if (context.mounted) {
      context.go(RoutePaths.login);
    }
  }
  
  /// Volta para a tela anterior
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
  
  /// Volta para uma rota específica
  static void goBackTo(BuildContext context, String route) {
    context.go(route);
  }
  
  // ========================================
  // 🔒 NAVEGAÇÃO CONDICIONAL
  // ========================================
  
  /// Navega baseado no status de autenticação
  static void navigateBasedOnAuth(BuildContext context) {
    final isAuthenticated = AppStorage.getAuthToken() != null;
    
    if (isAuthenticated) {
      goToDashboard(context);
    } else {
      goToWelcome(context);
    }
  }
  
  /// Navega baseado no status de primeiro acesso
  static void navigateBasedOnFirstAccess(BuildContext context, String cpf) async {
    final isFirstAccess = await AppStorage.isFirstAccess(cpf);
    
    if (isFirstAccess) {
      goToTermsOfUse(context);
    } else {
      goToLogin(context);
    }
  }
  
  /// Navega baseado no status de termos
  static void navigateBasedOnTerms(BuildContext context) {
    final termsAccepted = AppStorage.areTermsAccepted();
    
    if (termsAccepted) {
      goToFirstAccessMethod(context);
    } else {
      goToTermsOfUse(context);
    }
  }
  
  // ========================================
  // 📱 NAVEGAÇÃO ESPECÍFICA DE PLATAFORMA
  // ========================================
  
  /// Navega para configurações de biometria (se disponível)
  static void goToBiometricSettings(BuildContext context) {
    // Aqui você pode implementar lógica específica da plataforma
    goToBiometrics(context);
  }
  
  /// Navega para configurações do sistema
  static void goToSystemSettings(BuildContext context) {
    // Aqui você pode implementar navegação para configurações do sistema
    goToSettings(context);
  }
}
