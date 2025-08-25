import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordMethodPage extends StatelessWidget {
  final String? cpf; // CPF do usuário
  
  const ForgotPasswordMethodPage({super.key, this.cpf});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão voltar
            _buildHeader(context),
            
            // Conteúdo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // CPF do usuário
                    if (cpf != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CPF: ${_formatCPF(cpf!)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Subtítulo
                    const Text(
                      'Onde deseja receber o token de recuperação?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Opções de método
                    _buildMethodOption(
                      context,
                      icon: Icons.email_outlined,
                      title: 'E-mail',
                      subtitle: 'Receba o token por e-mail',
                      onTap: () => _selectMethod(context, 'email'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildMethodOption(
                      context,
                      icon: Icons.sms_outlined,
                      title: 'SMS',
                      subtitle: 'Receba o token por SMS',
                      onTap: () => _selectMethod(context, 'sms'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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

  Widget _buildMethodOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            
            // Seta
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF666666),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _selectMethod(BuildContext context, String method) async {
    print('🔍 DEBUG: [ForgotPasswordMethodPage] Método selecionado: $method para CPF: $cpf');
    
    if (cpf == null || cpf!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CPF não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Simula envio do token
      final success = await AuthService.sendForgotPasswordToken(cpf!, method);
      
      if (!context.mounted) return;
      
      // Remove loading
      Navigator.of(context).pop();
      
      if (success) {
        // Token enviado com sucesso - navega para tela de token
        context.go('${RoutePaths.forgotPasswordToken}?method=$method&cpf=$cpf');
      } else {
        // Falha no envio - verifica se é CPF não encontrado
        final isCPFNotFound = !AuthService.isExistingUser(cpf!);
        String errorMessage;
        
        if (isCPFNotFound) {
          errorMessage = 'CPF não encontrado no sistema. Verifique se está correto ou entre em contato com o suporte.';
        } else {
          errorMessage = 'Falha ao enviar token via $method. Tente novamente.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      // Remove loading
      Navigator.of(context).pop();
      
      // Erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar token: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  String _formatCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }
}
