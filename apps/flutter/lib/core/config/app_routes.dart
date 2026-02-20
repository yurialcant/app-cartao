import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../../presentation/screens/cpf_check_screen.dart';
import '../../presentation/screens/first_access_method_page.dart';
import '../../presentation/screens/first_access_token_page.dart';
import '../../presentation/screens/first_access_register_page.dart';
import '../../presentation/screens/login_page.dart';
import '../../presentation/screens/forgot_password_page.dart';
import '../../presentation/screens/device_token_page.dart';
import '../../presentation/screens/dashboard_page.dart';
import '../../presentation/screens/terms_of_use_page.dart';

/// Configuração das rotas do aplicativo
class AppRoutes {
  // ========================================
  // 🚀 ROTAS PRINCIPAIS
  // ========================================
  
  static const String welcome = '/';
  static const String cpfCheck = '/cpf-check';
  static const String firstAccessMethod = '/first-access-method';
  static const String firstAccessToken = '/first-access-token';
  static const String firstAccessRegister = '/first-access-register';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String deviceToken = '/device-token';
  static const String dashboard = '/dashboard';
  static const String termsOfUse = '/terms-of-use';
  
  // ========================================
  // 🧭 CONFIGURAÇÃO DO GO_ROUTER
  // ========================================
  
  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    debugLogDiagnostics: true,
    routes: [
      // Tela de boas-vindas
      GoRoute(
        path: welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      
      // Verificação de CPF
      GoRoute(
        path: cpfCheck,
        name: 'cpfCheck',
        builder: (context, state) => const CPFCheckScreen(),
      ),
      
      // Seleção de método (SMS/Email)
      GoRoute(
        path: firstAccessMethod,
        name: 'firstAccessMethod',
        builder: (context, state) => const FirstAccessMethodScreen(),
      ),
      
      // Token de primeiro acesso
      GoRoute(
        path: firstAccessToken,
        name: 'firstAccessToken',
        builder: (context, state) => const FirstAccessTokenPage(),
      ),
      
      // Registro de senha
      GoRoute(
        path: firstAccessRegister,
        name: 'firstAccessRegister',
        builder: (context, state) => const FirstAccessRegisterPage(),
      ),
      
      // Login
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Esqueci minha senha
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Token do dispositivo
      GoRoute(
        path: deviceToken,
        name: 'deviceToken',
        builder: (context, state) => const DeviceTokenScreen(),
      ),

      // Termos de uso
      GoRoute(
        path: termsOfUse,
        name: 'termsOfUse',
        builder: (context, state) => const TermsOfUsePage(),
      ),
      
      // Dashboard principal
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
    
    // ========================================
    // 🔒 REDIRECIONAMENTOS E GUARDS
    // ========================================
    
    redirect: (context, state) {
      // Aqui você pode implementar lógica de autenticação
      // Por exemplo, verificar se o usuário está logado
      // e redirecionar para login se necessário
      
      // Por enquanto, permite acesso a todas as rotas
      return null;
    },
    
    // ========================================
    // ⚠️ TRATAMENTO DE ERROS
    // ========================================
    
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Página não encontrada'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro 404',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'A página "${state.uri.path}" não foi encontrada.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(welcome),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      );
    },
  );
  
  // ========================================
  // 🧭 MÉTODOS DE NAVEGAÇÃO
  // ========================================
  
  /// Navega para uma rota específica
  static void goTo(BuildContext context, String route) {
    context.go(route);
  }
  
  /// Navega para uma rota específica com parâmetros
  static void goToWithParams(BuildContext context, String route, Map<String, String> params) {
    context.go(route, extra: params);
  }
  
  /// Navega para uma rota específica e remove todas as anteriores
  static void goToAndClear(BuildContext context, String route) {
    context.go(route);
  }
  
  /// Navega para uma rota específica e remove até uma rota específica
  static void goToAndRemoveUntil(BuildContext context, String route, String untilRoute) {
    context.go(route);
  }
  
  /// Volta para a tela anterior
  static void goBack(BuildContext context) {
    context.pop();
  }
  
  /// Verifica se pode voltar
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }
}
