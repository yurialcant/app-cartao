import 'package:flutter/material.dart';
import '../../core/routing/route_paths.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/attempt_control_service.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordTokenPage extends StatefulWidget {
  final String? method; // email ou sms
  final String? cpf; // CPF do usuário
  
  const ForgotPasswordTokenPage({super.key, this.method, this.cpf});
  
  @override
  State<ForgotPasswordTokenPage> createState() => _ForgotPasswordTokenPageState();
}

class _ForgotPasswordTokenPageState extends State<ForgotPasswordTokenPage> {
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
  int _resendCountdown = 0; // Começa em 0
  
  // Controle de tentativas
  late AttemptControlService _attemptControl;
  AttemptState? _currentAttemptState;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializa controle de tentativas
    _attemptControl = AttemptControlService();
    _loadAttemptState();
    
    // Inicializa a sessão com dados do fluxo
    if (widget.cpf != null) {
      NavigationService().setCurrentMethod(widget.method ?? 'sms');
    }
    
    // Configura listeners para auto-focus
    for (int i = 0; i < 3; i++) {
      _tokenControllers[i].addListener(() {
        if (_tokenControllers[i].text.length == 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
    
    // Escuta mudanças no estado de tentativas
    _attemptControl.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentAttemptState = state;
        });
      }
    });
  }
  
  @override
  void dispose() {
    for (var controller in _tokenControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    
    // Limpa controle de tentativas
    _attemptControl.dispose();
    
    super.dispose();
  }
  
  /// Carrega estado de tentativas
  Future<void> _loadAttemptState() async {
    await _attemptControl.loadState();
    _currentAttemptState = _attemptControl.currentState;
  }
  
  void _startResendCountdown() {
    if (_resendCountdown <= 0) return;
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final method = widget.method ?? 'sms';
    final methodText = method == 'email' ? 'e-mail' : 'SMS';
    
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
                      'Recuperar senha',
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
                    Text(
                      'Enviamos um token de 4 dígitos para seu $methodText',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    
                    // Informações de tentativas
                    if (_currentAttemptState != null) ...[
                      const SizedBox(height: 16),
                      _buildAttemptInfo(method),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Campos de token
                    _buildTokenFields(),
                    
                    // Mensagem de erro
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(_errorMessage!),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Botões de ação
                    _buildActionButtons(method),
                    
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
            onPressed: () {
              // Usa NavigationService para navegar de volta de forma segura
              NavigationService().navigateBack(context);
            },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Token de verificação',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 60,
              child: TextField(
                controller: _tokenControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
            );
          }),
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
  
  Widget _buildAttemptInfo(String method) {
    final isMethodBlocked = _attemptControl.isMethodBlocked(method);
    final remainingTime = _attemptControl.getRemainingTime(method);
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                method == 'email' ? Icons.email_outlined : Icons.sms_outlined,
                color: const Color(0xFF1E40AF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tentativas restantes: ${_attemptControl.getRemainingAttempts(method)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isMethodBlocked ? Icons.lock_outline : Icons.lock_open_outlined,
                color: isMethodBlocked ? Colors.red : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isMethodBlocked
                    ? 'Método $method bloqueado. Aguarde $minutes min e ${seconds}s'
                    : 'Método $method disponível.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isMethodBlocked ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(String method) {
    return Column(
      children: [
        // Botão reenviar token
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _resendCountdown > 0 ? null : _resendToken,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF1E40AF),
              size: 20,
            ),
            label: Text(
              _resendCountdown > 0 
                ? 'Reenviar token (${_resendCountdown}s)'
                : 'Reenviar token',
              style: TextStyle(
                color: _resendCountdown > 0 
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF1E40AF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _resendCountdown > 0 
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFF1E40AF),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Link para alterar método
        TextButton.icon(
          onPressed: () => _changeMethod(),
          icon: Icon(
            method == 'email' ? Icons.sms_outlined : Icons.email_outlined,
            color: const Color(0xFF1E40AF),
            size: 20,
          ),
          label: Text(
            'Enviar por ${method == 'email' ? 'SMS' : 'e-mail'}',
            style: const TextStyle(
              color: Color(0xFF1E40AF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContinueButton() {
    final isTokenComplete = _tokenControllers.every((controller) => 
      controller.text.length == 1
    );
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isTokenComplete && !_isLoading ? _verifyToken : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isTokenComplete 
            ? const Color(0xFF1E40AF) 
            : const Color(0xFFE5E7EB),
          foregroundColor: isTokenComplete 
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
              'Verificar token',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }
  
  void _resendToken() {
    final method = widget.method ?? 'sms';
    
    // Verifica se pode tentar
    if (!_attemptControl.canAttempt(method)) {
      final remainingTime = _attemptControl.getRemainingTime(method);
      final minutes = remainingTime ~/ 60;
      final seconds = remainingTime % 60;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            minutes > 0 
              ? 'Aguarde $minutes min e ${seconds}s para tentar novamente'
              : 'Aguarde ${seconds}s para tentar novamente'
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    print('🔍 DEBUG: [ForgotPasswordTokenPage] Reenviando token por: $method');
    
    // Registra tentativa
    _attemptControl.recordAttempt(method);
    
    // Inicia contador baseado no método
    _resendCountdown = method == 'sms' ? 60 : 60;
    _startResendCountdown();
    
    // Atualiza dados do fluxo na sessão
    NavigationService().setCurrentMethod(method);
    
    // Aqui você implementaria a lógica para reenviar o token
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Token reenviado por $method com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _changeMethod() {
    final currentMethod = widget.method ?? 'sms';
    final newMethod = currentMethod == 'email' ? 'sms' : 'email';
    
    print('🔍 DEBUG: [ForgotPasswordTokenPage] Tentando alterar método de $currentMethod para $newMethod');
    
    // Verifica se o novo método está disponível
    if (!_attemptControl.canAttempt(newMethod)) {
      final remainingTime = _attemptControl.getRemainingTime(newMethod);
      final minutes = remainingTime ~/ 60;
      final seconds = remainingTime % 60;
      
      String message;
      if (_attemptControl.isMethodBlocked(newMethod)) {
        message = minutes > 0 
          ? 'Método $newMethod bloqueado. Aguarde $minutes min e ${seconds}s'
          : 'Método $newMethod bloqueado. Aguarde ${seconds}s';
      } else {
        message = minutes > 0 
          ? 'Aguarde $minutes min e ${seconds}s para usar $newMethod'
          : 'Aguarde ${seconds}s para usar $newMethod';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Se está bloqueado geralmente, não permite alternar
    if (_attemptControl.isGenerallyBlocked) {
      final remainingTime = _attemptControl.getGeneralBlockRemainingTime();
      final minutes = remainingTime ~/ 60;
      final seconds = remainingTime % 60;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Todos os métodos estão bloqueados. Aguarde $minutes min e ${seconds}s'
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('🔍 DEBUG: [ForgotPasswordTokenPage] Alterando método para: $newMethod');
    
    // Atualiza o método na sessão
    NavigationService().setCurrentMethod(newMethod);
    
    // Reseta contador para o novo método
    _resendCountdown = 0;
    
    // Usa NavigationService para substituir a tela
    NavigationService().navigateReplace(
      context, 
      RoutePaths.forgotPasswordToken, 
      queryParams: {
        'method': newMethod,
        'cpf': widget.cpf ?? '',
      }
    );
  }
  
  void _verifyToken() async {
    final token = _tokenControllers.map((c) => c.text).join();
    
    if (token.length != 4) {
      setState(() {
        _errorMessage = 'Digite o token completo';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Usa AuthService para verificar o token
      final success = await AuthService.verifyForgotPasswordToken(
        widget.cpf ?? '', 
        widget.method ?? 'sms', 
        token
      );
      
      if (!mounted) return;
      
      if (success) {
        // Token válido - atualiza na sessão
        NavigationService().setCurrentToken(token);
        
        // Navega para criação de nova senha
        NavigationService().navigateTo(
          context, 
          RoutePaths.forgotPasswordNewPassword, 
          queryParams: {
            'method': widget.method ?? 'sms',
            'token': token,
            'cpf': widget.cpf ?? '',
          }
        );
      } else {
        // Token inválido
        setState(() {
          _errorMessage = 'Token inválido. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar token. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }
}
