import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../core/storage/app_storage.dart';
import 'first_access_method_page.dart';

class TermsOfUsePage extends StatefulWidget {
  const TermsOfUsePage({super.key});

  @override
  State<TermsOfUsePage> createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  bool _hasAcceptedTerms = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Termos de Uso',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtítulo
                    const Text(
                      'Leia atentamente os termos antes de continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Termos de uso
                    _buildTermsContent(),
                    
                    const SizedBox(height: 32),
                    
                    // Checkbox de aceitação
                    _buildAcceptanceCheckbox(),
                    
                    const SizedBox(height: 32),
                    
                    // Botão continuar
                    _buildContinueButton(),
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

  Widget _buildTermsContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Aceitação dos Termos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ao utilizar este aplicativo, você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não poderá acessar o aplicativo.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            '2. Uso do Aplicativo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'O aplicativo é fornecido para uso pessoal e não comercial. Você concorda em não usar o aplicativo para qualquer propósito ilegal ou não autorizado.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            '3. Privacidade e Segurança',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sua privacidade é importante para nós. Nossa Política de Privacidade explica como coletamos, usamos e protegemos suas informações pessoais.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            '4. Responsabilidades do Usuário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você é responsável por manter a confidencialidade de suas credenciais de acesso e por todas as atividades que ocorrem em sua conta.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            '5. Modificações dos Termos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reservamo-nos o direito de modificar estes termos a qualquer momento. As modificações entrarão em vigor imediatamente após sua publicação.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _hasAcceptedTerms,
          onChanged: (value) {
            setState(() {
              _hasAcceptedTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFF1E40AF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _hasAcceptedTerms = !_hasAcceptedTerms;
              });
            },
            child: const Text(
              'Li e aceito os Termos de Uso e a Política de Privacidade',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _hasAcceptedTerms && !_isLoading ? _acceptTerms : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasAcceptedTerms 
            ? const Color(0xFF1E40AF) 
            : const Color(0xFFE5E7EB),
          foregroundColor: _hasAcceptedTerms 
            ? Colors.white 
            : const Color(0xFF9CA3AF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Aceitar e Continuar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }

  Future<void> _acceptTerms() async {
    print('🔍 DEBUG: [TermsOfUsePage] Botão "Aceitar e Continuar" clicado');
    print('🔍 DEBUG: [TermsOfUsePage] Termos aceitos? $_hasAcceptedTerms');
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 DEBUG: [TermsOfUsePage] Salvando aceitação dos termos...');
      // Salva aceitação dos termos
      await AppStorage.setTermsAccepted(true);
      print('🔍 DEBUG: [TermsOfUsePage] Termos salvos com sucesso');
      
      print('🔍 DEBUG: [TermsOfUsePage] Simulando delay...');
      // Simula delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (!mounted) {
        print('🔍 DEBUG: [TermsOfUsePage] Widget não está montado, abortando');
        return;
      }
      
      // Navega para próxima tela (Método de primeiro acesso)
      print('🔍 DEBUG: [TermsOfUsePage] Navegando para: ${RoutePaths.firstAccessMethod}');
      try {
        context.go(RoutePaths.firstAccessMethod);
        print('🔍 DEBUG: [TermsOfUsePage] Navegação executada com sucesso');
      } catch (e) {
        print('🔍 DEBUG: [TermsOfUsePage] ERRO na navegação: $e');
      }
    } catch (e) {
      print('🔍 DEBUG: [TermsOfUsePage] ERRO GERAL: $e');
      print('🔍 DEBUG: [TermsOfUsePage] Stack trace: ${StackTrace.current}');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao aceitar termos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🔍 DEBUG: [TermsOfUsePage] Loading finalizado');
      }
    }
  }
}
