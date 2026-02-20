import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordNewPasswordPage extends StatefulWidget {
  final String? method; // email ou sms
  final String? token; // token de verificação
  final String? cpf; // CPF do usuário
  
  const ForgotPasswordNewPasswordPage({
    super.key, 
    this.method,
    this.token,
    this.cpf,
  });
  
  @override
  State<ForgotPasswordNewPasswordPage> createState() => _ForgotPasswordNewPasswordPageState();
}

class _ForgotPasswordNewPasswordPageState extends State<ForgotPasswordNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;
  
  // Validações de senha
  bool _hasMinLength = false;
  bool _hasNumbers = false;
  bool _hasUpperLower = false;
  bool _hasSpecialChars = false;
  
  @override
  void initState() {
    super.initState();
    
    // Listener para validação em tempo real
    _passwordController.addListener(_validatePassword);
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _validatePassword() {
    final password = _passwordController.text;
    
    setState(() {
      _hasMinLength = password.length >= 6 && password.length <= 8;
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasUpperLower = password.contains(RegExp(r'[A-Z]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Nova senha',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // CPF do usuário
                      if (widget.cpf != null) ...[
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
                                'CPF: ${_formatCPF(widget.cpf!)}',
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
                        'Crie uma nova senha para sua conta',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Requisitos da senha
                      _buildPasswordRequirements(),
                      
                      const SizedBox(height: 24),
                      
                      // Campo nova senha
                      _buildPasswordField(),
                      
                      const SizedBox(height: 24),
                      
                      // Campo confirmar senha
                      _buildConfirmPasswordField(),
                      
                      // Mensagem de erro
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorMessage(_errorMessage!),
                      ],
                      
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildRequirement('6 a 8 caracteres', _hasMinLength),
        _buildRequirement('números', _hasNumbers),
        _buildRequirement('letras maiúsculas', _hasUpperLower),
        _buildRequirement('caracteres especiais', _hasSpecialChars),
      ],
    );
  }
  
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isMet ? Colors.green : Colors.red,
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
          'Nova senha',
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
            hintText: 'Digite sua nova senha',
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
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
                color: Color(0xFF1E40AF),
                width: 2,
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
              return 'Por favor, digite sua nova senha';
            }
            if (value.length < 6 || value.length > 8) {
              return 'A senha deve ter entre 6 e 8 caracteres';
            }
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'A senha deve conter números';
            }
            if (!value.contains(RegExp(r'[a-z]')) || 
                !value.contains(RegExp(r'[A-Z]'))) {
              return 'A senha deve conter letras maiúsculas e minúsculas';
            }
            if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
              return 'A senha deve conter caracteres especiais';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
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
          'Confirmar nova senha',
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
            hintText: 'Confirme sua nova senha',
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
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
                color: Color(0xFF1E40AF),
                width: 2,
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
              return 'Por favor, confirme sua nova senha';
            }
            if (value != _passwordController.text) {
              return 'As senhas não coincidem';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      ],
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
    final isPasswordValid = _hasMinLength && _hasNumbers && 
                            _hasUpperLower && _hasSpecialChars;
    final isConfirmPasswordValid = _confirmPasswordController.text.isNotEmpty;
    final isFormValid = isPasswordValid && isConfirmPasswordValid;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormValid && !_isLoading ? _changePassword : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid 
            ? const Color(0xFF1E40AF) 
            : const Color(0xFFE5E7EB),
          foregroundColor: isFormValid 
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
              'Alterar senha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }
  
  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final newPassword = _passwordController.text;
      final method = widget.method ?? 'sms';
      final token = widget.token ?? '';
      final cpf = widget.cpf ?? '';
      
      print('🔍 DEBUG: [ForgotPasswordNewPasswordPage] Alterando senha...');
      print('🔍 DEBUG: [ForgotPasswordNewPasswordPage] CPF: $cpf');
      print('🔍 DEBUG: [ForgotPasswordNewPasswordPage] Método: $method');
      print('🔍 DEBUG: [ForgotPasswordNewPasswordPage] Token: $token');
      
      // Usa AuthService para alterar a senha
      final success = await AuthService.changePasswordAfterRecovery(
        cpf, 
        method, 
        token, 
        newPassword
      );
      
      if (!mounted) return;
      
      if (success) {
        // Senha alterada com sucesso - mostra dialog de sucesso
        _showSuccessDialog();
      } else {
        // Falha na alteração
        setState(() {
          _errorMessage = 'Falha ao alterar senha. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao alterar senha. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Senha alterada com sucesso!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Sua senha foi alterada com sucesso. Agora você pode fazer login com a nova senha.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navega para o dashboard após alterar a senha
                  context.go(RoutePaths.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  elevation: 0,
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

  String _formatCPF(String cpf) {
    if (cpf.length != 11) {
      return cpf;
    }
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }
}
