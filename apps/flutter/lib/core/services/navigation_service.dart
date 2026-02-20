import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_paths.dart';
import 'session_manager.dart';

/// Serviço de navegação seguro que integra com o SessionManager
/// 
/// Este serviço controla toda a navegação da aplicação, mantendo
/// histórico e prevenindo erros de navegação
class NavigationService {
  // ========================================
  // 🔐 INSTÂNCIA SINGLETON
  // ========================================
  
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  // ========================================
  // 🎭 DEPENDÊNCIAS
  // ========================================
  
  final SessionManager _sessionManager = SessionManager();
  
  // ========================================
  // 🚀 INICIALIZAÇÃO
  // ========================================
  
  /// Inicializa o serviço de navegação
  Future<void> initialize() async {
    await _sessionManager.initialize();
    print('🔍 DEBUG: [NavigationService] Inicializado com sucesso');
  }
  
  // ========================================
  // 🧭 NAVEGAÇÃO SEGURA
  // ========================================
  
  /// Navega para uma rota de forma segura
  void navigateTo(BuildContext context, String route, {Map<String, String>? queryParams}) {
    try {
      // Adiciona passo na navegação
      _sessionManager.addNavigationStep(route, _getScreenName(route), data: queryParams);
      
      // Constrói a URL com parâmetros
      final url = _buildUrl(route, queryParams);
      
      print('🔍 DEBUG: [NavigationService] Navegando para: $url');
      context.go(url);
      
    } catch (e) {
      print('🔍 DEBUG: [NavigationService] Erro na navegação: $e');
      _handleNavigationError(context, route);
    }
  }
  
  /// Navega para uma rota substituindo a atual
  void navigateReplace(BuildContext context, String route, {Map<String, String>? queryParams}) {
    try {
      // Remove o último passo e adiciona o novo
      _sessionManager.removeLastStep();
      _sessionManager.addNavigationStep(route, _getScreenName(route), data: queryParams);
      
      final url = _buildUrl(route, queryParams);
      
      print('🔍 DEBUG: [NavigationService] Substituindo para: $url');
      context.replace(url);
      
    } catch (e) {
      print('🔍 DEBUG: [NavigationService] Erro na substituição: $e');
      _handleNavigationError(context, route);
    }
  }
  
  /// Navega de volta de forma segura
  void navigateBack(BuildContext context) {
    try {
      // Verifica se pode fazer pop
      if (context.canPop()) {
        // Remove o último passo da sessão
        _sessionManager.removeLastStep();
        
        print('🔍 DEBUG: [NavigationService] Navegando de volta (pop)');
        context.pop();
      } else {
        // Se não pode fazer pop, volta para uma rota segura
        _navigateToSafeRoute(context);
      }
      
    } catch (e) {
      print('🔍 DEBUG: [NavigationService] Erro ao voltar: $e');
      _navigateToSafeRoute(context);
    }
  }
  
  /// Navega de volta para uma rota específica
  void navigateBackTo(BuildContext context, String targetRoute) {
    try {
      if (_sessionManager.canGoBackTo(targetRoute)) {
        // Obtém o caminho de volta
        final backPath = _sessionManager.getBackPathTo(targetRoute);
        
        // Remove passos extras da sessão
        while (_sessionManager.navigationHistory.length > backPath.length) {
          _sessionManager.removeLastStep();
        }
        
        final url = _buildUrl(targetRoute, null);
        print('🔍 DEBUG: [NavigationService] Voltando para: $url');
        context.go(url);
        
      } else {
        // Se não pode voltar, vai para rota segura
        _navigateToSafeRoute(context);
      }
      
    } catch (e) {
      print('🔍 DEBUG: [NavigationService] Erro ao voltar para: $targetRoute - $e');
      _navigateToSafeRoute(context);
    }
  }
  
  /// Navega para uma rota segura (fallback)
  void _navigateToSafeRoute(BuildContext context) {
    print('🔍 DEBUG: [NavigationService] Navegando para rota segura');
    
    // Determina a rota segura baseada no contexto atual
    final safeRoute = _determineSafeRoute();
    
    // Limpa a sessão e vai para a rota segura
    _sessionManager.clearSession();
    context.go(safeRoute);
  }
  
  /// Determina a rota segura baseada no contexto
  String _determineSafeRoute() {
    // Se tem CPF na sessão, vai para verificação
    if (_sessionManager.currentCpf != null) {
      return RoutePaths.cpfCheck;
    }
    
    // Se não tem nada, vai para welcome
    return RoutePaths.welcome;
  }
  
  // ========================================
  // 🔐 CONTROLE DE FLUXOS
  // ========================================
  
  /// Inicia fluxo de primeiro acesso
  void startFirstAccessFlow(BuildContext context, String cpf) {
    print('🔍 DEBUG: [NavigationService] Iniciando fluxo de primeiro acesso para: $cpf');
    
    _sessionManager.startFlow('primeiro_acesso', cpf: cpf);
    
    // Navega para verificação de CPF
    navigateTo(context, RoutePaths.cpfCheck, queryParams: {'cpf': cpf});
  }
  
  /// Inicia fluxo de login
  void startLoginFlow(BuildContext context, String cpf) {
    print('🔍 DEBUG: [NavigationService] Iniciando fluxo de login para: $cpf');
    
    _sessionManager.startFlow('login', cpf: cpf);
    
    // Navega para tela de login
    navigateTo(context, RoutePaths.login, queryParams: {'cpf': cpf});
  }
  
  /// Inicia fluxo de recuperação de senha
  void startRecoveryFlow(BuildContext context, String cpf) {
    print('🔍 DEBUG: [NavigationService] Iniciando fluxo de recuperação para: $cpf');
    
    _sessionManager.startFlow('recuperacao', cpf: cpf);
    
    // Navega para seleção de método
    navigateTo(context, RoutePaths.forgotPasswordMethod, queryParams: {'cpf': cpf});
  }
  
  /// Finaliza fluxo atual
  void endCurrentFlow(BuildContext context) {
    print('🔍 DEBUG: [NavigationService] Finalizando fluxo atual');
    
    _sessionManager.endFlow();
    
    // Vai para dashboard se estiver autenticado, senão para welcome
    // TODO: Implementar verificação de autenticação
    navigateTo(context, RoutePaths.dashboard);
  }
  
  // ========================================
  // 📧 CONTROLE DE MÉTODOS
  // ========================================
  
  /// Define método atual (email/sms)
  void setCurrentMethod(String method) {
    _sessionManager.setMethod(method);
  }
  
  /// Alterna entre métodos
  String toggleMethod() {
    return _sessionManager.toggleMethod();
  }
  
  /// Verifica se método é válido
  bool isMethodValid(String method) {
    return _sessionManager.isMethodValid(method);
  }
  
  // ========================================
  // 🔑 CONTROLE DE TOKENS
  // ========================================
  
  /// Define token atual
  void setCurrentToken(String token) {
    _sessionManager.setToken(token);
  }
  
  /// Verifica se token é válido
  bool isTokenValid(String token) {
    return _sessionManager.isTokenValid(token);
  }
  
  // ========================================
  // 🧹 LIMPEZA E RESET
  // ========================================
  
  /// Limpa toda a sessão
  Future<void> clearSession() async {
    await _sessionManager.clearSession();
  }
  
  /// Reseta para modo de teste
  Future<void> resetForTest() async {
    await _sessionManager.resetForTest();
  }
  
  // ========================================
  // 🛠️ UTILITÁRIOS
  // ========================================
  
  /// Constrói URL com parâmetros
  String _buildUrl(String route, Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return route;
    }
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$route?$queryString';
  }
  
  /// Obtém nome da tela baseado na rota
  String _getScreenName(String route) {
    switch (route) {
      case RoutePaths.welcome:
        return 'Welcome';
      case RoutePaths.cpfCheck:
        return 'CPF Check';
      case RoutePaths.termsOfUse:
        return 'Terms of Use';
      case RoutePaths.firstAccessMethod:
        return 'First Access Method';
      case RoutePaths.firstAccessToken:
        return 'First Access Token';
      case RoutePaths.firstAccessRegister:
        return 'First Access Register';
      case RoutePaths.login:
        return 'Login';
      case RoutePaths.forgotPasswordMethod:
        return 'Forgot Password Method';
      case RoutePaths.forgotPasswordToken:
        return 'Forgot Password Token';
      case RoutePaths.forgotPasswordNewPassword:
        return 'Forgot Password New Password';
      case RoutePaths.dashboard:
        return 'Dashboard';
      default:
        return 'Unknown Screen';
    }
  }
  
  /// Trata erros de navegação
  void _handleNavigationError(BuildContext context, String route) {
    print('🔍 DEBUG: [NavigationService] Tratando erro de navegação para: $route');
    
    // Em caso de erro, vai para rota segura
    _navigateToSafeRoute(context);
  }
  
  // ========================================
  // 📊 DEBUG E LOGS
  // ========================================
  
  /// Imprime estado atual da navegação
  void printNavigationState() {
    _sessionManager.printSessionState();
  }
  
  /// Obtém resumo da navegação
  Map<String, dynamic> getNavigationSummary() {
    return _sessionManager.getSessionSummary();
  }
}
