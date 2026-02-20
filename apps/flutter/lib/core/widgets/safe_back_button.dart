import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_paths.dart';

/// Botão voltar seguro que não quebra a aplicação
/// 
/// Este widget verifica se pode fazer pop antes de tentar,
/// e se não puder, navega para uma rota específica
class SafeBackButton extends StatelessWidget {
  /// Rota de fallback caso não possa fazer pop
  final String fallbackRoute;
  
  /// Parâmetros para a rota de fallback
  final Map<String, String>? fallbackParams;
  
  /// Ícone personalizado
  final IconData? icon;
  
  /// Cor do ícone
  final Color? iconColor;
  
  /// Tamanho do ícone
  final double? iconSize;
  
  const SafeBackButton({
    super.key,
    required this.fallbackRoute,
    this.fallbackParams,
    this.icon,
    this.iconColor,
    this.iconSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _handleBackNavigation(context),
      icon: Icon(
        icon ?? Icons.arrow_back_ios,
        color: iconColor ?? const Color(0xFF1A1A1A),
        size: iconSize ?? 24,
      ),
    );
  }
  
  void _handleBackNavigation(BuildContext context) {
    // Verifica se pode fazer pop
    if (context.canPop()) {
      context.pop();
    } else {
      // Se não pode fazer pop, navega para a rota de fallback
      if (fallbackParams != null) {
        final queryString = fallbackParams!.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        context.go('$fallbackRoute?$queryString');
      } else {
        context.go(fallbackRoute);
      }
    }
  }
}

/// Botão voltar específico para telas de primeiro acesso
class FirstAccessBackButton extends StatelessWidget {
  const FirstAccessBackButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SafeBackButton(
      fallbackRoute: RoutePaths.welcome,
      icon: Icons.arrow_back_ios,
      iconColor: const Color(0xFF1A1A1A),
    );
  }
}

/// Botão voltar específico para telas de recuperação de senha
class ForgotPasswordBackButton extends StatelessWidget {
  final String? cpf;
  
  const ForgotPasswordBackButton({super.key, this.cpf});
  
  @override
  Widget build(BuildContext context) {
    return SafeBackButton(
      fallbackRoute: RoutePaths.login,
      icon: Icons.arrow_back_ios,
      iconColor: const Color(0xFF1A1A1A),
    );
  }
}

/// Botão voltar específico para telas de login
class LoginBackButton extends StatelessWidget {
  const LoginBackButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SafeBackButton(
      fallbackRoute: RoutePaths.welcome,
      icon: Icons.arrow_back_ios,
      iconColor: const Color(0xFF1A1A1A),
    );
  }
}
