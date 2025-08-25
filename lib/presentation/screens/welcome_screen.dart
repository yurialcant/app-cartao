import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/branding/welcome_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Status bar personalizada
                _buildStatusBar(),
                
                // Espaço para centralizar o conteúdo
                const Spacer(),
                
                // Botão Acessar
                _buildAccessButton(context),
                
                // Espaço inferior
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Indicador de sinal
          _buildSignalIndicator(),
          
          const SizedBox(width: 8),
          
          // Nome do app
          const Text(
            'Figma',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Ícone Wi-Fi
          const Icon(
            Icons.wifi,
            color: Colors.white,
            size: 16,
          ),
          
          const Spacer(),
          
          // Hora
          const Text(
            '9:41 AM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Ícones do lado direito
          const Icon(
            Icons.brightness_6,
            color: Colors.white,
            size: 16,
          ),
          
          const SizedBox(width: 8),
          
          const Icon(
            Icons.bluetooth,
            color: Colors.white,
            size: 16,
          ),
          
          const SizedBox(width: 8),
          
          // Bateria
          _buildBatteryIndicator(),
        ],
      ),
    );
  }

  Widget _buildSignalIndicator() {
    return Row(
      children: List.generate(4, (index) => 
        Container(
          width: 3,
          height: 8 - (index * 1.5),
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    return Row(
      children: [
        const Text(
          '100%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 24,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _navigateToCPFCheck(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Acessar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // KISS: Método simples e testável
  void _navigateToCPFCheck(BuildContext context) {
    print('🔍 DEBUG: [WelcomeScreen] Botão "Acessar" clicado');
    
    try {
      // Navegação simples
      context.go(RoutePaths.cpfCheck);
      print('🔍 DEBUG: [WelcomeScreen] Navegação executada com sucesso');
    } catch (e) {
      print('🔍 DEBUG: [WelcomeScreen] ERRO na navegação: $e');
      // Fallback simples
      Navigator.of(context).pushNamed('/cpf-check');
    }
  }
}
