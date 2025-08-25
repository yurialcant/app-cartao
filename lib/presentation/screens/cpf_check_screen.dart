import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../data/services/auth_service.dart';
import '../../core/storage/app_storage.dart';
import 'first_access_method_page.dart';
import 'login_page.dart';
import 'terms_of_use_page.dart';

class CPFCheckScreen extends StatefulWidget {
  const CPFCheckScreen({super.key});

  @override
  State<CPFCheckScreen> createState() => _CPFCheckScreenState();
}

class _CPFCheckScreenState extends State<CPFCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##');
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isValidCPF = false;

  @override
  void initState() {
    super.initState();
    _cpfController.addListener(_onCPFChanged);
  }

  void _onCPFChanged() {
    final cpf = _cpfController.text;
    setState(() {
      _isValidCPF = cpf.length >= 14 && AuthService.isValidCPF(cpf);
      _errorMessage = null;
    });
  }

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Verificar CPF',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtítulo
                      const Text(
                        'Digite seu CPF para continuar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Campo CPF
                      _buildCPFField(),
                      
                      // Mensagem de erro
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _buildErrorMessage(_errorMessage!),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Informações sobre CPF
                      _buildCPFInfo(),
                      
                      const SizedBox(height: 32),
                      
                      // Botão continuar
                      _buildContinueButton(),
                    ],
                  ),
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

  Widget _buildCPFField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CPF',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _cpfController,
          decoration: InputDecoration(
            hintText: 'Digite seu CPF',
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorMessage != null 
                  ? const Color(0xFFE53E3E) 
                  : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE53E3E),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: _isValidCPF 
              ? const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 24,
                )
              : null,
            errorText: _formKey.currentState?.validate() == false 
              ? _getValidationError() 
              : null,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [_cpfMask],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, digite seu CPF';
            }
            final cleanCPF = value.replaceAll(RegExp(r'[^\d]'), '');
            if (cleanCPF.length < 11) {
              return 'CPF deve ter 11 dígitos';
            }
            if (!AuthService.isValidCPF(cleanCPF)) {
              return 'CPF inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCPFInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Informações:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Se for seu primeiro acesso, você será direcionado para criar uma conta\n'
            '• Se já possui conta, será direcionado para fazer login\n'
            '• Seu CPF é usado apenas para identificação e segurança',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.4,
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isValidCPF && !_isLoading ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isValidCPF 
            ? const Color(0xFF1E40AF) 
            : const Color(0xFFE5E7EB),
          foregroundColor: _isValidCPF 
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
              'Continuar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    print('🔍 DEBUG: [CPFCheckScreen] Botão "Continuar" clicado');
    
    if (!_formKey.currentState!.validate()) {
      print('🔍 DEBUG: [CPFCheckScreen] Validação falhou');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
      print('🔍 DEBUG: [CPFCheckScreen] CPF digitado: $cpf');
      print('🔍 DEBUG: [CPFCheckScreen] CPF limpo: $cpf');
      
      // Verifica se é primeiro acesso
      print('🔍 DEBUG: [CPFCheckScreen] Chamando AuthService.isFirstAccess...');
      final isFirstAccess = await AuthService.isFirstAccess(cpf);
      print('🔍 DEBUG: [CPFCheckScreen] É primeiro acesso? $isFirstAccess');
      
      if (!mounted) {
        print('🔍 DEBUG: [CPFCheckScreen] Widget não está montado, abortando');
        return;
      }

      if (isFirstAccess) {
        // PRIMEIRO ACESSO: Vai para Termos de Uso
        print('🔍 DEBUG: [CPFCheckScreen] Navegando para termos de uso: ${RoutePaths.termsOfUse}');
        try {
          context.go(RoutePaths.termsOfUse);
          print('🔍 DEBUG: [CPFCheckScreen] Navegação para termos executada com sucesso');
        } catch (e) {
          print('🔍 DEBUG: [CPFCheckScreen] ERRO na navegação para termos: $e');
        }
      } else {
        // USUÁRIO EXISTENTE: Vai para Login
        print('🔍 DEBUG: [CPFCheckScreen] Navegando para login: ${RoutePaths.login}');
        try {
          // PASSA O CPF PARA A TELA DE LOGIN COM MÁSCARA
          final cpfWithMask = _cpfController.text; // Já tem a máscara aplicada
          context.go('${RoutePaths.login}?cpf=$cpfWithMask');
          print('🔍 DEBUG: [CPFCheckScreen] Navegação para login executada com sucesso');
        } catch (e) {
          print('🔍 DEBUG: [CPFCheckScreen] ERRO na navegação para login: $e');
        }
      }
    } catch (e) {
      print('🔍 DEBUG: [CPFCheckScreen] ERRO GERAL: $e');
      print('🔍 DEBUG: [CPFCheckScreen] Stack trace: ${StackTrace.current}');
      
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🔍 DEBUG: [CPFCheckScreen] Loading finalizado');
      }
    }
  }

  String? _getValidationError() {
    final formState = _formKey.currentState;
    if (formState == null) return null;

    if (formState.validate()) return null;

    final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length < 11) {
      return 'CPF deve ter 11 dígitos';
    }
    if (!AuthService.isValidCPF(cpf)) {
      return 'CPF inválido';
    }
    return null;
  }

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }
}
