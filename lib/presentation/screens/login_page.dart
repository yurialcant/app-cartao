import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import '../../data/services/auth_service.dart';
import '../../core/storage/app_storage.dart';
import 'dashboard_page.dart';

class LoginScreen extends StatefulWidget {
  final String? cpf; // CPF passado da tela anterior
  
  const LoginScreen({super.key, this.cpf});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##');
  
  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;
  int _loginAttempts = 0;
  bool _isAccountLocked = false;
  DateTime? _lockoutTime;

  @override
  void initState() {
    super.initState();
    
    // PREENCHE O CPF AUTOMATICAMENTE SE FOR FORNECIDO
    if (widget.cpf != null) {
      _cpfController.text = widget.cpf!;
    }
    
    // Verifica bloqueio de conta de forma assíncrona
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccountLock();
    });
  }

  void _checkAccountLock() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTime = prefs.getString('account_lockout_time');
    
    if (lockoutTime != null) {
      final lockoutDateTime = DateTime.parse(lockoutTime);
      final now = DateTime.now();
      final difference = now.difference(lockoutDateTime);
      
      if (difference.inMinutes < 10) {
        setState(() {
          _isAccountLocked = true;
          _lockoutTime = lockoutDateTime;
        });
        
        // Desbloqueia após 10 minutos
        Future.delayed(Duration(minutes: 10 - difference.inMinutes), () {
          if (mounted) {
            setState(() {
              _isAccountLocked = false;
              _loginAttempts = 0;
            });
            prefs.remove('account_lockout_time');
          }
        });
      } else {
        prefs.remove('account_lockout_time');
        setState(() {
          _isAccountLocked = false;
          _loginAttempts = 0;
        });
      }
    }
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtítulo
                      const Text(
                        'Digite seu CPF e senha para continuar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Campo CPF
                      _buildCPFField(),
                      
                      const SizedBox(height: 24),
                      
                      // Campo senha
                      _buildPasswordField(),
                      
                      // Mensagem de erro
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorMessage(_errorMessage!),
                      ],
                      
                      // Aviso de conta bloqueada
                      if (_isAccountLocked) ...[
                        const SizedBox(height: 16),
                        _buildAccountLockedWarning(),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Botão esqueci minha senha
                      _buildForgotPasswordButton(),
                      
                      const SizedBox(height: 32),
                      
                      // Botão continuar
                      _buildContinueButton(),
                      
                      const SizedBox(height: 24),
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
          inputFormatters: [_cpfMask],
          keyboardType: TextInputType.number,
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
                color: Color(0xFF3B82F6),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
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
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      ],
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

  Widget _buildAccountLockedWarning() {
    final remainingMinutes = _lockoutTime != null 
      ? 10 - DateTime.now().difference(_lockoutTime!).inMinutes 
      : 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFEAA7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber,
            color: Color(0xFF856404),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conta bloqueada. Aguarde $remainingMinutes minutos para tentar novamente.',
              style: const TextStyle(
                color: Color(0xFF856404),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _forgotPassword,
        icon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF1A1A1A),
          size: 20,
        ),
        label: const Text(
          'Esqueci minha senha',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isButtonEnabled = _cpfController.text.length >= 14 && 
                           _passwordController.text.isNotEmpty && 
                           !_isAccountLocked && 
                           _errorMessage == null;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isButtonEnabled && !_isLoading ? _login : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled 
            ? const Color(0xFF1E40AF) 
            : const Color(0xFFE5E7EB),
          foregroundColor: isButtonEnabled 
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
      final password = _passwordController.text;
      
      print('🔍 DEBUG: [LoginScreen] Tentando login com CPF: $cpf');
      
      // USA O AUTH SERVICE PARA LOGIN
      final result = await AuthService.login(cpf, password);
      
      if (!mounted) return;
      
      if (result.isSuccess) {
        // LOGIN BEM-SUCEDIDO
        print('🔍 DEBUG: [LoginScreen] Login bem-sucedido!');
        _loginAttempts = 0;
        
        // Salva dados do usuário
        if (result.user != null) {
          await AppStorage.saveUser(result.user!.toJson());
        }
        if (result.token != null) {
          await AppStorage.saveAuthToken(result.token!);
        }
        
        // Navega para o dashboard
        context.go(RoutePaths.dashboard);
      } else {
        // LOGIN FALHOU
        print('🔍 DEBUG: [LoginScreen] Login falhou: ${result.message}');
        
        if (result.status == AuthStatus.accountPermanentlyLocked) {
          setState(() {
            _errorMessage = 'Conta bloqueada permanentemente. Entre em contato com o suporte.';
          });
        } else {
          _loginAttempts++;
          if (_loginAttempts >= 3) {
            setState(() {
              _isAccountLocked = true;
              _errorMessage = 'Conta bloqueada por múltiplas tentativas';
            });
          } else {
            setState(() {
              _errorMessage = result.message ?? 'Erro no login';
            });
          }
        }
      }
    } catch (e) {
      print('🔍 DEBUG: [LoginScreen] ERRO no login: $e');
      setState(() {
        _errorMessage = 'Erro ao fazer login. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _lockAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account_lockout_time', DateTime.now().toIso8601String());
  }

  Future<void> _forgotPassword() async {
    final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cpf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite seu CPF primeiro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('🔍 DEBUG: [LoginScreen] Botão "Esqueci minha senha" clicado para CPF: $cpf');
    
    // Navega para o fluxo de recuperação de senha com o CPF
    context.go('${RoutePaths.forgotPasswordMethod}?cpf=$cpf');
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
