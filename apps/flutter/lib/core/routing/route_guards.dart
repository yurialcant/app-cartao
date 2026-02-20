import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_login_app/core/routing/route_paths.dart';
import 'package:flutter_login_app/core/storage/app_storage.dart';
import 'package:flutter_login_app/core/config/env_config.dart';

/// Sistema de guardas de segurança para rotas
class RouteGuards {
  // ========================================
  // 🔒 REDIRECIONAMENTO GLOBAL
  // ========================================
  
  /// Redirecionamento global para todas as rotas
  static String? globalRedirect(BuildContext context, GoRouterState state) {
    print('🔍 DEBUG: [RouteGuards] globalRedirect chamado para: ${state.uri.path}');
    print('🔍 DEBUG: [RouteGuards] FORCE_LOGIN_MODE: ${EnvConfig.isForceLoginMode}');
    print('🔍 DEBUG: [RouteGuards] TEST_MODE: ${EnvConfig.isTestMode}');
    
    // FORCE_LOGIN_MODE: Sempre força o fluxo de login (PRIORIDADE MÁXIMA)
    if (EnvConfig.isForceLoginMode) {
      print('🔍 DEBUG: [RouteGuards] FORCE_LOGIN_MODE ativado - sempre redirecionando para login');
      
      // Se não estiver na tela de login, redireciona
      if (state.uri.path != RoutePaths.login) {
        print('🔍 DEBUG: [RouteGuards] Redirecionando para login (FORCE_LOGIN_MODE)');
        return RoutePaths.login;
      }
      return null; // Permite acesso à tela de login
    }
    
    // TEST_MODE: Limpa storage para facilitar testes de primeiro acesso
    if (EnvConfig.isTestMode) {
      print('🔍 DEBUG: [RouteGuards] TEST_MODE ativado');
      
      // Só limpa se estiver em rotas de primeiro acesso ou welcome
      if (_isFirstAccessRoute(state.uri.path) || state.uri.path == RoutePaths.welcome) {
        print('🔍 DEBUG: [RouteGuards] Limpando storage para teste de primeiro acesso');
        AppStorage.clearAll();
      }
    }
    
    // Verifica se o usuário está autenticado
    final isAuthenticated = _isUserAuthenticated();
    print('🔍 DEBUG: [RouteGuards] isAuthenticated: $isAuthenticated');
    
    // Se não estiver autenticado e não for rota pública, redireciona para login
    if (!isAuthenticated && !_isPublicRoute(state.uri.path)) {
      print('🔍 DEBUG: [RouteGuards] Usuário não autenticado, redirecionando para login');
      return RoutePaths.login;
    }
    
    // Se estiver autenticado e tentar acessar rota pública (como welcome), redireciona para dashboard
    if (isAuthenticated && _isPublicRoute(state.uri.path)) {
      print('🔍 DEBUG: [RouteGuards] Usuário autenticado tentando acessar welcome, redirecionando para dashboard');
      return RoutePaths.dashboard;
    }
    
    // Acesso permitido
    print('🔍 DEBUG: [RouteGuards] Acesso permitido para: ${state.uri.path}');
    return null;
  }
  
  // ========================================
  // 🔐 GUARDA DE AUTENTICAÇÃO
  // ========================================
  
  /// Requer autenticação para acessar a rota
  static String? requireAuth(BuildContext context, GoRouterState state) {
    if (!_isUserAuthenticated()) {
      return RoutePaths.login;
    }
    return null;
  }
  
  // ========================================
  // 🚫 GUARDA DE BLOQUEIO
  // ========================================
  
  /// Verifica se a conta está bloqueada
  static String? requireAccountNotLocked(BuildContext context, GoRouterState state) {
    if (AppStorage.isAccountLocked()) {
      return RoutePaths.login;
    }
    return null;
  }
  
  /// Verifica se a conta não está permanentemente bloqueada
  static String? requireAccountNotPermanentlyLocked(BuildContext context, GoRouterState state) {
    if (AppStorage.isAccountPermanentlyLocked()) {
      return RoutePaths.login;
    }
    return null;
  }
  
  // ========================================
  // 📋 GUARDA DE TERMOS
  // ========================================
  
  /// Verifica se os termos foram aceitos
  static String? requireTermsAccepted(BuildContext context, GoRouterState state) {
    if (!AppStorage.areTermsAccepted()) {
      return RoutePaths.termsOfUse;
    }
    return null;
  }
  
  // ========================================
  // 🔍 MÉTODOS AUXILIARES
  // ========================================
  
  /// Verifica se o usuário está autenticado
  static bool _isUserAuthenticated() {
    print('🔍 DEBUG: [RouteGuards] _isUserAuthenticated() chamado');
    
    // Em FORCE_LOGIN_MODE, usuário nunca está autenticado
    if (EnvConfig.isForceLoginMode) {
      print('🔍 DEBUG: [RouteGuards] FORCE_LOGIN_MODE ativado - usuário nunca autenticado');
      return false;
    }
    
    // Verifica se há dados em cache primeiro
    final user = AppStorage.getUser();
    
    print('🔍 DEBUG: [RouteGuards] User: $user');
    
    if (user == null) {
      print('🔍 DEBUG: [RouteGuards] Usuário NÃO autenticado (user null)');
      return false;
    }
    
    print('🔍 DEBUG: [RouteGuards] Usuário AUTENTICADO');
    return true;
  }
  
  /// Verifica se é uma rota pública
  static bool _isPublicRoute(String path) {
    // Em FORCE_LOGIN_MODE, apenas login é considerado rota pública
    if (EnvConfig.isForceLoginMode) {
      return [RoutePaths.login].contains(path);
    }
    
    // Rotas públicas normais
    return [
      RoutePaths.splash,  // Adiciona a tela de splash como rota pública
      RoutePaths.welcome,
      RoutePaths.cpfCheck,
      RoutePaths.termsOfUse,
      RoutePaths.firstAccessMethod,
      RoutePaths.firstAccessToken,
      RoutePaths.firstAccessRegister,
      RoutePaths.login,
      RoutePaths.forgotPassword,
      RoutePaths.forgotPasswordMethod,
      RoutePaths.forgotPasswordToken,
      RoutePaths.forgotPasswordNewPassword,
      RoutePaths.deviceToken,
    ].contains(path);
  }
  
  /// Verifica se é uma rota de primeiro acesso
  static bool _isFirstAccessRoute(String path) {
    // Em FORCE_LOGIN_MODE, não há rotas de primeiro acesso
    if (EnvConfig.isForceLoginMode) {
      return false;
    }
    
    return [
      RoutePaths.firstAccessMethod,
      RoutePaths.firstAccessToken,
      RoutePaths.firstAccessRegister,
    ].contains(path);
  }
  
  /// Verifica se está em modo de manutenção
  static bool _isMaintenanceMode() {
    // Aqui você pode implementar lógica para verificar
    // se o app está em modo de manutenção
    return false;
  }
}
