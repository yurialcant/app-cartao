import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_paths.dart';
import 'first_access_register_page.dart';

class FirstAccessTokenPage extends StatefulWidget {
  const FirstAccessTokenPage({super.key});

  @override
  State<FirstAccessTokenPage> createState() => _FirstAccessTokenPageState();
}

class _FirstAccessTokenPageState extends State<FirstAccessTokenPage> {
  final List<TextEditingController> _tokenControllers = List.generate(
    4, 
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4, 
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    
    // Adiciona listeners para navegação automática entre campos
    for (int i = 0; i < 4; i++) {
      _tokenControllers[i].addListener(() {
        if (_tokenControllers[i].text.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _canResend = true;
          }
        });
        if (_resendCountdown > 0) {
          _startResendCountdown();
        }
      }
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Autenticar dispositivo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Instrução
                    const Text(
                      'Enviamos um Token de 4 dígitos para o número: (11) ****-**40',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Campos de token
                    _buildTokenFields(),
                    
                    // Mensagem de erro
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(_errorMessage!),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Botões de reenvio
                    _buildResendButtons(),
                    
                    const Spacer(),
                    
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

  Widget _buildTokenFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          height: 60,
          child: TextField(
            controller: _tokenControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        );
      }),
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

  Widget _buildResendButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _canResend && !_isLoading ? _resendToken : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canResend ? const Color(0xFF1E40AF) : const Color(0xFFE5E7EB),
              foregroundColor: _canResend ? Colors.white : const Color(0xFF9CA3AF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _canResend ? 'Reenviar Token' : 'Reenviar Token (${_resendCountdown}s)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: _isLoading ? null : _sendByEmail,
          child: const Text(
            'Enviar por e-mail',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final token = _getToken();
    final isButtonEnabled = token.length == 4 && _errorMessage == null;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isButtonEnabled && !_isLoading ? _verifyToken : null,
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

  String _getToken() {
    return _tokenControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyToken() async {
    final token = _getToken();
    
    if (token.length != 4) {
      setState(() {
        _errorMessage = 'Token deve ter 4 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simula verificação do token
      await Future.delayed(const Duration(seconds: 1));
      
      // Token válido para teste: "1234"
      if (token == "1234") {
        if (!mounted) return;
        
        // Navega para criação de senha
        context.go(RoutePaths.firstAccessRegister);
      } else {
        setState(() {
          _errorMessage = 'Token inválido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar token. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simula reenvio do token
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      // Reseta o countdown
      setState(() {
        _resendCountdown = 60;
        _canResend = false;
      });
      
      _startResendCountdown();
      
      // Limpa os campos
      for (final controller in _tokenControllers) {
        controller.clear();
      }
      
      // Foca no primeiro campo
      _focusNodes[0].requestFocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token reenviado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao reenviar token. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendByEmail() async {
    // Simula envio por email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token enviado por e-mail!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _tokenControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
