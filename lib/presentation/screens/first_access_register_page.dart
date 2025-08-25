import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../core/storage/app_storage.dart';
import 'dashboard_page.dart';

class FirstAccessRegisterPage extends StatefulWidget {
  const FirstAccessRegisterPage({super.key});

  @override
  State<FirstAccessRegisterPage> createState() => _FirstAccessRegisterPageState();
}

class _FirstAccessRegisterPageState extends State<FirstAccessRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  // Validação de senha
  bool _hasMinLength = false;
  bool _hasNumbers = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasSpecialChars = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePasswordsMatch);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    
    setState(() {
      _hasMinLength = password.length >= 6 && password.length <= 8;
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    
    _validatePasswordsMatch();
  }

  void _validatePasswordsMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text && 
                       _confirmPasswordController.text.isNotEmpty;
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasNumbers && _hasUppercase && 
                               _hasSpecialChars;

  bool get _canContinue => _isPasswordValid && _passwordsMatch;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Crie sua senha de acesso',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Requisitos de senha
                      _buildPasswordRequirements(),
                      
                      const SizedBox(height: 32),
                      
                      // Campo de senha
                      _buildPasswordField(),
                      
                      const SizedBox(height: 24),
                      
                      // Campo de confirmação
                      _buildConfirmPasswordField(),
                      
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

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sua senha deve conter:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildRequirementItem('6 a 8 caracteres', _hasMinLength),
        _buildRequirementItem('números', _hasNumbers),
        _buildRequirementItem('letras maiúsculas', _hasUppercase),
        _buildRequirementItem('caracteres especiais', _hasSpecialChars),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Senha',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            hintText: 'Digite sua senha',
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordController.text.isNotEmpty && !_isPasswordValid
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
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, digite sua senha';
            }
            if (!_isPasswordValid) {
              return 'Senha fora dos padrões requisitados';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmar senha',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Confirme sua senha',
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _confirmPasswordController.text.isNotEmpty && !_passwordsMatch
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
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, confirme sua senha';
            }
            if (!_passwordsMatch) {
              return 'As duas senhas não são iguais';
            }
            return null;
          },
        ),
        
        // Mensagem de erro para senhas diferentes
        if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFE53E3E),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'As duas senhas não são iguais',
                style: const TextStyle(
                  color: Color(0xFFE53E3E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canContinue && !_isLoading ? _createPassword : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canContinue 
            ? const Color(0xFF1E40AF) 
            : const Color(0xFFE5E7EB),
          foregroundColor: _canContinue 
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
              'Criar Senha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }

  Future<void> _createPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simula criação da senha
      await Future.delayed(const Duration(seconds: 1));
      
      // Salva a senha (em produção, seria criptografada)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_password', _passwordController.text);
      
      // Salva dados de autenticação para permitir acesso ao dashboard
      await prefs.setString('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', jsonEncode({
        'cpf': '11144477735', // CPF do primeiro acesso
        'name': 'Usuário Primeiro Acesso',
        'email': 'primeiro.acesso@email.com',
        'isFirstAccess': false,
      }));
      
      // IMPORTANTE: Salva também no AppStorage para as guardas de rota funcionarem
      final userData = {
        'cpf': '11144477735',
        'name': 'Usuário Primeiro Acesso',
        'email': 'primeiro.acesso@email.com',
        'isFirstAccess': false,
      };
      
      await AppStorage.saveUser(userData);
      await AppStorage.saveAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await AppStorage.setFirstAccess(false);
      
      print('🔍 DEBUG: [FirstAccessRegisterPage] Dados salvos com sucesso');
      print('🔍 DEBUG: [FirstAccessRegisterPage] User: ${AppStorage.getUser()}');
      print('🔍 DEBUG: [FirstAccessRegisterPage] Token: ${await AppStorage.getAuthToken()}');
      
      // Aguarda um pouco para garantir que os dados foram salvos
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Mostra modal de sucesso
      _showSuccessModal();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar senha: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Senha cadastrada com sucesso!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'Sua senha de acesso ao aplicativo foi definida com sucesso.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async {
                  print('🔍 DEBUG: Botão "Entendido" clicado');
                  
                  // IMPORTANTE: Navega ANTES de fechar o dialog
                  try {
                    final user = AppStorage.getUser();
                    final token = await AppStorage.getAuthToken();
                    print('🔍 DEBUG: [Navigation] User antes da navegação: $user');
                    print('🔍 DEBUG: [Navigation] Token antes da navegação: $token');
                    
                    if (user != null && token != null) {
                      // Fecha o dialog primeiro
                      Navigator.of(context).pop();
                      // Aguarda um pouco e navega
                      await Future.delayed(const Duration(milliseconds: 100));
                      context.go(RoutePaths.dashboard);
                      print('🔍 DEBUG: Navegação executada com sucesso');
                    } else {
                      print('🔍 DEBUG: [Navigation] Dados não encontrados, tentando salvar novamente...');
                      await AppStorage.saveUser({
                        'cpf': '11144477735', 
                        'name': 'Usuário Primeiro Acesso', 
                        'email': 'primeiro.acesso@email.com', 
                        'isFirstAccess': false,
                      });
                      await AppStorage.saveAuthToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
                      
                      // Fecha o dialog primeiro
                      Navigator.of(context).pop();
                      // Aguarda um pouco e navega
                      await Future.delayed(const Duration(milliseconds: 100));
                      context.go(RoutePaths.dashboard);
                      print('🔍 DEBUG: Navegação executada após novo salvamento');
                    }
                  } catch (e) {
                    print('🔍 DEBUG: ERRO na navegação: $e');
                    // Fecha o dialog mesmo com erro
                    Navigator.of(context).pop();
                  
                    try {
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                      print('🔍 DEBUG: Fallback Navigator executado com sucesso');
                    } catch (navigatorError) {
                      print('🔍 DEBUG: ERRO no Navigator também: $navigatorError');
                      context.go('/');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
