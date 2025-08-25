import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_login_app/core/routing/route_guards.dart';
import 'package:flutter_login_app/core/routing/route_paths.dart';
import 'package:flutter_login_app/presentation/screens/welcome_screen.dart';
import 'package:flutter_login_app/presentation/screens/cpf_check_screen.dart';
import 'package:flutter_login_app/presentation/screens/first_access_method_page.dart';
import 'package:flutter_login_app/presentation/screens/first_access_token_page.dart';
import 'package:flutter_login_app/presentation/screens/first_access_register_page.dart';
import 'package:flutter_login_app/presentation/screens/login_page.dart';
import 'package:flutter_login_app/presentation/screens/forgot_password_page.dart';
import 'package:flutter_login_app/presentation/screens/device_token_page.dart';
import 'package:flutter_login_app/presentation/screens/dashboard_page.dart';
import 'package:flutter_login_app/presentation/screens/terms_of_use_page.dart';
import 'package:flutter_login_app/presentation/screens/forgot_password_method_page.dart';
import 'package:flutter_login_app/presentation/screens/forgot_password_token_page.dart';
import 'package:flutter_login_app/presentation/screens/forgot_password_new_password_page.dart';

/// Sistema de roteamento principal com guardas de segurança
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RoutePaths.welcome,
    debugLogDiagnostics: true,
    
    // ========================================
    // 🔒 GUARDAS DE SEGURANÇA
    // ========================================
    
    redirect: RouteGuards.globalRedirect,
    
    // ========================================
    // 🚨 TRATAMENTO DE ERROS
    // ========================================
    
    errorBuilder: (context, state) => _buildErrorPage(context, state),
    
    // ========================================
    // 🛣️ ROTAS PÚBLICAS (sem autenticação)
    // ========================================
    
    routes: [
      // Tela de boas-vindas
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      
      // Verificação de CPF
      GoRoute(
        path: RoutePaths.cpfCheck,
        name: RouteNames.cpfCheck,
        builder: (context, state) => const CPFCheckScreen(),
      ),
      
      // Termos de uso
      GoRoute(
        path: RoutePaths.termsOfUse,
        name: RouteNames.termsOfUse,
        builder: (context, state) => const TermsOfUsePage(),
      ),
      
      // Seleção de método (SMS/Email)
      GoRoute(
        path: RoutePaths.firstAccessMethod,
        name: RouteNames.firstAccessMethod,
        builder: (context, state) => const FirstAccessMethodScreen(),
      ),
      
      // Token de primeiro acesso
      GoRoute(
        path: RoutePaths.firstAccessToken,
        name: RouteNames.firstAccessToken,
        builder: (context, state) => const FirstAccessTokenPage(),
      ),
      
      // Registro de senha
      GoRoute(
        path: RoutePaths.firstAccessRegister,
        name: RouteNames.firstAccessRegister,
        builder: (context, state) => const FirstAccessRegisterPage(),
      ),
      
      // Login
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) {
          // EXTRAI O CPF DOS PARÂMETROS DE QUERY
          final cpf = state.uri.queryParameters['cpf'];
          return LoginScreen(cpf: cpf);
        },
      ),
      
      // Esqueci minha senha
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordMethodPage(),
      ),
      
      // Método de recuperação (SMS/Email)
      GoRoute(
        path: RoutePaths.forgotPasswordMethod,
        name: RouteNames.forgotPasswordMethod,
        builder: (context, state) {
          final cpf = state.uri.queryParameters['cpf'];
          return ForgotPasswordMethodPage(cpf: cpf);
        },
      ),
      
      // Token de recuperação
      GoRoute(
        path: RoutePaths.forgotPasswordToken,
        name: RouteNames.forgotPasswordToken,
        builder: (context, state) {
          final method = state.uri.queryParameters['method'];
          final cpf = state.uri.queryParameters['cpf'];
          return ForgotPasswordTokenPage(method: method, cpf: cpf);
        },
      ),
      
      // Nova senha após recuperação
      GoRoute(
        path: RoutePaths.forgotPasswordNewPassword,
        name: RouteNames.forgotPasswordNewPassword,
        builder: (context, state) {
          final method = state.uri.queryParameters['method'];
          final token = state.uri.queryParameters['token'];
          final cpf = state.uri.queryParameters['cpf'];
          return ForgotPasswordNewPasswordPage(
            method: method,
            token: token,
            cpf: cpf,
          );
        },
      ),
      
      // Token do dispositivo
      GoRoute(
        path: RoutePaths.deviceToken,
        name: RouteNames.deviceToken,
        builder: (context, state) => const DeviceTokenScreen(),
      ),
      
      // Dashboard (rota protegida)
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
        redirect: RouteGuards.requireAuth,
      ),
    ],
  );
  
  /// Getter para o router
  static GoRouter get router => _router;
  
  /// Constrói página de erro
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
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
              'Erro ${state.error?.toString() ?? '404'}',
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
              onPressed: () => context.go(RoutePaths.welcome),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
