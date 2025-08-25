import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import 'first_access_token_page.dart';

class FirstAccessMethodScreen extends StatefulWidget {
  const FirstAccessMethodScreen({super.key});

  @override
  State<FirstAccessMethodScreen> createState() => _FirstAccessMethodScreenState();
}

class _FirstAccessMethodScreenState extends State<FirstAccessMethodScreen> {
  bool _loading = false;
  String? _error;
  String? _selectedMethod;

  Future<void> _selectMethod(String method) async {
    if (_loading) return;
    
    setState(() {
      _loading = true;
      _error = null;
      _selectedMethod = method;
    });

    try {
      // Salva o canal escolhido para a próxima etapa usar
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_access_channel', method); // 'sms' | 'email'

      // Simula chamada de envio de token
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      
      setState(() => _loading = false);
      
      // Navega para a tela de token
      context.go(RoutePaths.firstAccessToken);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Erro inesperado. Tente novamente.';
      });
    }
  }

  Widget _buildMethodCard({
    required String method,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    final isSelected = _selectedMethod == method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.blue[50] : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isSelected ? Colors.blue : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão voltar
            _buildHeader(),
            
            // Conteúdo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Primeiro acesso',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtítulo
                    const Text(
                      'Onde deseja receber o token de primeiro acesso?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Opções de método
                    _buildMethodCard(
                      method: 'sms',
                      label: 'SMS',
                      icon: Icons.sms,
                      onTap: () => _selectMethod('sms'),
                      isLoading: _loading,
                    ),
                    
                    _buildMethodCard(
                      method: 'email',
                      label: 'E-mail',
                      icon: Icons.email,
                      onTap: () => _selectMethod('email'),
                      isLoading: _loading,
                    ),
                    
                    // Mensagem de erro
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(_error!),
                    ],
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1A1A1A),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFE53E3E),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
