import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../../core/storage/app_storage.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/http_service.dart';
import '../../core/config/env_config.dart';

/// Serviço de autenticação completo
class AuthService {
  // ========================================
  // 🔐 CONFIGURAÇÕES DE SEGURANÇA
  // ========================================
  
  // Configurações de segurança
  static int get _maxLoginAttempts => EnvConfig.maxLoginAttempts;
  static int get _maxLoginAttemptsPermanent => EnvConfig.maxLoginAttemptsPermanent;
  static Duration get _lockoutDuration => EnvConfig.lockoutDuration;
  
  // ========================================
  // 🧪 DADOS MOCKADOS PARA TESTES
  // ========================================
  
  // CPFs para primeiro acesso
  static const List<String> _firstAccessCpfs = [
    '11144477735',
    '22255588846',
  ];
  
  // CPFs para usuários existentes
  static const List<String> _existingCpfs = [
    '94691907009',
    '63254351096',
  ];
  
  // Senhas válidas para teste
  // Regras: 6-8 caracteres, 1 maiúscula, 1 número, 1 especial
  static const Map<String, String> _validPasswords = {
    '94691907009': 'Senha1@',   // 8 caracteres
    '63254351096': 'Test2#',    // 6 caracteres
  };
  
  // Token válido para teste
  static const String _validToken = '1234';
  
  // Usuários mockados
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    '94691907009': {
      'cpf': '94691907009',
      'name': 'João Silva',
      'email': 'joao.silva@email.com',
      'phone': '(11) 99999-9999',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'lastLogin': '2024-01-15T10:30:00.000Z',
      'isActive': true,
      'roles': ['user'],
    },
    '63254351096': {
      'cpf': '63254351096',
      'name': 'Maria Santos',
      'email': 'maria.santos@email.com',
      'phone': '(11) 88888-8888',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'lastLogin': '2024-01-14T15:45:00.000Z',
      'isActive': true,
      'roles': ['user'],
    },
  };
  
  // ========================================
  // 🔍 VERIFICAÇÃO DE CPF
  // ========================================
  
  /// Verifica se o CPF é válido
  static bool isValidCPF(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se tem 11 dígitos
    if (cpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) return false;
    
    // Validação dos dígitos verificadores
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;
    
    if (int.parse(cpf[9]) != digit1) return false;
    
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;
    
    return int.parse(cpf[10]) == digit2;
  }
  
  /// Verifica se o CPF é de primeiro acesso
  static bool isFirstAccessCPF(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    final result = _firstAccessCpfs.contains(cleanCpf);
    print('🔍 DEBUG: [AuthService] isFirstAccessCPF($cpf) = $result');
    print('🔍 DEBUG: [AuthService] CPFs de primeiro acesso: $_firstAccessCpfs');
    return result;
  }
  
  /// Verifica se é primeiro acesso (método principal)
  static Future<bool> isFirstAccess(String cpf) async {
    print('🔍 DEBUG: [AuthService] isFirstAccess($cpf) chamado');
    
    try {
      // Usa HttpService que pode alternar entre mock e API real
      final response = await HttpService.verifyCPF(cpf);
      
      if (response['success'] == true) {
        final status = response['data']['status'];
        final result = status == 'FIRST_ACCESS';
        
        print('🔍 DEBUG: [AuthService] Resposta da API: $response');
        print('🔍 DEBUG: [AuthService] Status: $status');
        print('🔍 DEBUG: [AuthService] isFirstAccess($cpf) = $result');
        
        return result;
      } else {
        print('🔍 DEBUG: [AuthService] Erro na API: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('🔍 DEBUG: [AuthService] Erro ao verificar CPF: $e');
      // Fallback para lógica local
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
      final result = _firstAccessCpfs.contains(cleanCpf);
      print('🔍 DEBUG: [AuthService] Fallback local: $result');
      return result;
    }
  }
  
  /// Verifica se o CPF é de usuário existente
  static bool isExistingUserCPF(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    return _existingCpfs.contains(cleanCpf);
  }
  
  // ========================================
  // 🔐 AUTENTICAÇÃO
  // ========================================
  
  /// Realiza login do usuário
  static Future<AuthResult> login(String cpf, String password) async {
    try {
      // Verifica se a conta está bloqueada
      if (AppStorage.isAccountLocked()) {
        return AuthResult.accountLocked(
          remainingMinutes: _getRemainingLockoutMinutes(),
        );
      }
      
      if (AppStorage.isAccountPermanentlyLocked()) {
        return AuthResult.accountPermanentlyLocked();
      }
      
      // Valida CPF
      if (!isValidCPF(cpf)) {
        return AuthResult.invalidCPF();
      }
      
      // Usa HttpService que pode alternar entre mock e API real
      final response = await HttpService.login(cpf, password);
      
      if (response['success'] == true) {
        // Login bem-sucedido
        final userData = response['data']['user'];
        final token = response['data']['token'];
        
        // Salva dados do usuário
        await AppStorage.saveUser(userData);
        await AppStorage.saveAuthToken(token);
        await AppStorage.resetLoginAttempts();
        
        return AuthResult.success(
          user: User.fromJson(userData),
          token: token,
        );
      } else {
        // Trata erros da API
        final errorCode = response['error']['code'];
        
        switch (errorCode) {
          case 'ACCOUNT_LOCKED':
            final remainingMinutes = response['error']['remainingMinutes'] ?? 10;
            await AppStorage.saveLockoutTime(DateTime.now());
            return AuthResult.accountLocked(remainingMinutes: remainingMinutes);
            
          case 'ACCOUNT_PERMANENTLY_LOCKED':
            await AppStorage.lockAccountPermanently();
            return AuthResult.accountPermanentlyLocked();
            
          case 'INVALID_CREDENTIALS':
            return await _handleInvalidPassword();
            
          default:
            return AuthResult.error(response['error']['message'] ?? 'Erro no login');
        }
      }
    } catch (e) {
      print('🔍 DEBUG: [AuthService] Erro no login: $e');
      // Fallback para lógica local
      return await _fallbackLogin(cpf, password);
    }
  }
  
  /// Fallback para login local quando API falha
  static Future<AuthResult> _fallbackLogin(String cpf, String password) async {
    try {
      // Verifica se é usuário existente
      if (!isExistingUserCPF(cpf)) {
        return AuthResult.userNotFound();
      }
      
      // Verifica senha
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
      final validPassword = _validPasswords[cleanCpf];
      
      if (password != validPassword) {
        return await _handleInvalidPassword();
      }
      
      // Login bem-sucedido
      await _handleSuccessfulLogin(cleanCpf);
      
      return AuthResult.success(
        user: User.fromJson(_mockUsers[cleanCpf]!),
        token: _generateToken(cleanCpf),
      );
    } catch (e) {
      return AuthResult.error('Erro durante o login local: $e');
    }
  }
  
  /// Realiza login com biometria
  static Future<AuthResult> loginWithBiometrics() async {
    try {
      // Verifica se a conta está bloqueada
      if (AppStorage.isAccountLocked()) {
        return AuthResult.accountLocked(
          remainingMinutes: _getRemainingLockoutMinutes(),
        );
      }
      
      if (AppStorage.isAccountPermanentlyLocked()) {
        return AuthResult.accountPermanentlyLocked();
      }
      
      // Verifica se biometria está habilitada
      if (!AppStorage.isBiometricEnabled()) {
        return AuthResult.biometricNotEnabled();
      }
      
      // Autentica com biometria
      final authenticated = await BiometricService.authenticate(
        reason: 'Autentique-se para acessar o aplicativo',
      );
      
      if (!authenticated) {
        return AuthResult.biometricFailed();
      }
      
      // Recupera dados do usuário em cache
      final userData = AppStorage.getUser();
      if (userData == null) {
        return AuthResult.userNotFound();
      }
      
      // Login bem-sucedido
      final user = User.fromJson(userData);
      await _updateLastLogin(user.cpf);
      
      return AuthResult.success(
        user: user,
        token: _generateToken(user.cpf),
      );
    } catch (e) {
      return AuthResult.error('Erro na autenticação biométrica: $e');
    }
  }
  
  /// Registra novo usuário
  static Future<AuthResult> register(String cpf, String password) async {
    try {
      // Verifica se CPF é válido
      if (!isValidCPF(cpf)) {
        return AuthResult.invalidCPF();
      }
      
      // Verifica se é CPF de primeiro acesso
      if (!isFirstAccessCPF(cpf)) {
        return AuthResult.cpfNotEligibleForRegistration();
      }
      
      // Valida senha
      if (!_isValidPassword(password)) {
        return AuthResult.invalidPassword();
      }
      
      // Cria usuário
      final user = User(
        cpf: cpf.replaceAll(RegExp(r'[^\d]'), ''),
        name: 'Usuário ${cpf.substring(0, 3)}',
        email: null,
        phone: null,
        createdAt: DateTime.now(),
        lastLogin: null,
        isActive: true,
        roles: ['user'],
      );
      
      // Salva usuário e token
      await AppStorage.saveUser(user.toJson());
      await AppStorage.saveAuthToken(_generateToken(user.cpf));
      await AppStorage.setFirstAccess(false);
      
      return AuthResult.success(
        user: user,
        token: _generateToken(user.cpf),
      );
    } catch (e) {
      return AuthResult.error('Erro durante o registro: $e');
    }
  }
  
  /// Recupera senha
  static Future<AuthResult> forgotPassword(String cpf) async {
    try {
      // Verifica se CPF é válido
      if (!isValidCPF(cpf)) {
        return AuthResult.invalidCPF();
      }
      
      // Verifica se usuário existe
      if (!isExistingUserCPF(cpf)) {
        return AuthResult.userNotFound();
      }
      
      // Simula envio de email/SMS
      await Future.delayed(const Duration(seconds: 2));
      
      return AuthResult.passwordRecoverySent();
    } catch (e) {
      return AuthResult.error('Erro ao recuperar senha: $e');
    }
  }
  
  /// Altera senha
  static Future<AuthResult> changePassword(String cpf, String oldPassword, String newPassword) async {
    try {
      // Verifica se CPF é válido
      if (!isValidCPF(cpf)) {
        return AuthResult.invalidCPF();
      }
      
      // Verifica se usuário existe
      if (!isExistingUserCPF(cpf)) {
        return AuthResult.userNotFound();
      }
      
      // Verifica senha antiga
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
      final validPassword = _validPasswords[cleanCpf];
      
      if (oldPassword != validPassword) {
        return AuthResult.invalidPassword();
      }
      
      // Valida nova senha
      if (!_isValidPassword(newPassword)) {
        return AuthResult.invalidPassword();
      }
      
      // Simula alteração de senha
      await Future.delayed(const Duration(seconds: 1));
      
      return AuthResult.passwordChanged();
    } catch (e) {
      return AuthResult.error('Erro ao alterar senha: $e');
    }
  }
  
  /// Logout
  static Future<void> logout() async {
    await AppStorage.clearAll();
  }
  
  // ========================================
  // 🔒 CONTROLE DE BLOQUEIO
  // ========================================
  
  /// Desbloqueia conta
  static Future<void> unlockAccount() async {
    await AppStorage.unlockAccount();
  }
  
  /// Verifica status da conta
  static AccountStatus getAccountStatus() {
    if (AppStorage.isAccountPermanentlyLocked()) {
      return AccountStatus.permanentlyLocked;
    }
    
    if (AppStorage.isAccountLocked()) {
      return AccountStatus.temporarilyLocked;
    }
    
    return AccountStatus.active;
  }
  
  // ========================================
  // 📱 BIOMETRIA
  // ========================================
  
  /// Habilita biometria
  static Future<void> enableBiometric() async {
    await BiometricService.enableBiometric();
  }
  
  /// Desabilita biometria
  static Future<void> disableBiometric() async {
    await BiometricService.disableBiometric();
  }
  
  /// Verifica se biometria está disponível
  static Future<bool> isBiometricAvailable() async {
    return await BiometricService.isBiometricAvailable();
  }
  
  /// Verifica se biometria está habilitada
  static bool isBiometricEnabled() {
    return BiometricService.isBiometricEnabled();
  }
  
  // ========================================
  // 📋 TERMOS DE USO
  // ========================================
  
  /// Aceita termos de uso
  static Future<void> acceptTerms() async {
    await AppStorage.setTermsAccepted(true);
  }
  
  /// Verifica se termos foram aceitos
  static bool areTermsAccepted() {
    return AppStorage.areTermsAccepted();
  }
  
  // ========================================
  // 🧪 FUNÇÕES PARA TESTES
  // ========================================
  
  /// Simula falha de login (apenas para testes)
  static Future<AuthResult> simulateLoginFailure() async {
    const testMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);
    
    if (testMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult.error('Simulação de falha de login');
    }
    
    throw Exception('Esta função só deve ser usada em testes');
  }
  
  /// Simula bloqueio de conta (apenas para testes)
  static Future<void> simulateAccountLock() async {
    const testMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);
    
    if (testMode) {
      await AppStorage.saveLockoutTime(DateTime.now());
    }
  }
  
  /// Simula bloqueio permanente (apenas para testes)
  static Future<void> simulatePermanentLock() async {
    const testMode = bool.fromEnvironment('TEST_MODE', defaultValue: false);
    
    if (testMode) {
      await AppStorage.lockAccountPermanently();
    }
  }
  
  /// Simula envio de token para recuperação de senha
  static Future<bool> sendForgotPasswordToken(String cpf, String method) async {
    print('🔍 DEBUG: [AuthService] Enviando token para CPF: $cpf via $method');
    
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 1));
    
    // PRIMEIRO: Verifica se o CPF existe no sistema
    if (!isExistingUser(cpf)) {
      print('🔍 DEBUG: [AuthService] CPF $cpf não encontrado no sistema');
      return false;
    }
    
    // Em modo de teste, simula diferentes cenários
    if (EnvConfig.isForgotPasswordTestMode) {
      print('🔍 DEBUG: [AuthService] Modo de teste ativado para "Esqueci minha senha"');
      
      // Simula falha para CPFs específicos em modo de teste
      if (cpf == '11111111111') {
        print('🔍 DEBUG: [AuthService] Simulando falha para CPF de teste');
        return false;
      }
      
      // Simula sucesso e mostra tokens válidos para cada método
      if (method == 'email') {
        print('🔍 DEBUG: [AuthService] ✅ Token enviado por EMAIL para CPF: $cpf');
        print('🔍 DEBUG: [AuthService] 📧 Tokens válidos para EMAIL: 1234, 5678, 9999');
      } else {
        print('🔍 DEBUG: [AuthService] ✅ Token enviado por SMS para CPF: $cpf');
        print('🔍 DEBUG: [AuthService] 📱 Tokens válidos para SMS: 2222, 3333, 4444');
      }
      
      return true;
    }
    
    // Comportamento normal (sempre sucesso para CPFs existentes)
    return true;
  }
  
  /// Verifica se o usuário existe no sistema
  static bool isExistingUser(String cpf) {
    // Lista de CPFs válidos que existem no sistema
    final existingCPFs = [
      '94691907009', // Usuário com senha: Senha123@
      '63254351096', // Usuário com senha: Test123!
      '12345678901', // Usuário adicional para teste
      '98765432109', // Usuário adicional para teste
    ];
    
    return existingCPFs.contains(cpf);
  }
  
  /// Simula verificação de token para recuperação de senha
  static Future<bool> verifyForgotPasswordToken(String cpf, String method, String token) async {
    print('🔍 DEBUG: [AuthService] Verificando token: $token para CPF: $cpf via $method');
    
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 1));
    
    // Em modo de teste, simula diferentes cenários
    if (EnvConfig.isForgotPasswordTestMode) {
      print('🔍 DEBUG: [AuthService] Modo de teste ativado para verificação de token');
      
      // Tokens válidos diferentes para cada método
      if (method == 'email') {
        // Tokens válidos para email
        final validEmailTokens = ['1234', '5678', '9999'];
        final isValid = validEmailTokens.contains(token);
        print('🔍 DEBUG: [AuthService] Verificação por EMAIL - Token: $token, Válido: $isValid');
        return isValid;
      } else {
        // Tokens válidos para SMS
        final validSmsTokens = ['2222', '3333', '4444'];
        final isValid = validSmsTokens.contains(token);
        print('🔍 DEBUG: [AuthService] Verificação por SMS - Token: $token, Válido: $isValid');
        return isValid;
      }
    }
    
    // Comportamento normal (sempre sucesso para tokens válidos)
    return token.length == 4;
  }
  
  /// Simula alteração de senha após recuperação
  static Future<bool> changePasswordAfterRecovery(String cpf, String method, String token, String newPassword) async {
    print('🔍 DEBUG: [AuthService] Alterando senha para CPF: $cpf via $method');
    print('🔍 DEBUG: [AuthService] Token: $token, Nova senha: $newPassword');
    
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 2));
    
    // Em modo de teste, simula diferentes cenários
    if (EnvConfig.isForgotPasswordTestMode) {
      print('🔍 DEBUG: [AuthService] Modo de teste ativado para alteração de senha');
      
      // Simula falha para senhas específicas em modo de teste
      if (newPassword == 'Test123!') {
        print('🔍 DEBUG: [AuthService] Simulando falha para senha de teste');
        return false;
      }
      
      // Simula sucesso para outras senhas
      print('🔍 DEBUG: [AuthService] Simulando sucesso para alteração de senha');
      return true;
    }
    
    // Comportamento normal (sempre sucesso)
    return true;
  }
  
  // ========================================
  // 🔧 FUNÇÕES PRIVADAS
  // ========================================
  
  /// Trata senha inválida
  static Future<AuthResult> _handleInvalidPassword() async {
    await AppStorage.incrementLoginAttempts();
    final attempts = AppStorage.getLoginAttempts();
    
    if (attempts >= _maxLoginAttemptsPermanent) {
      await AppStorage.lockAccountPermanently();
      return AuthResult.accountPermanentlyLocked();
    } else if (attempts >= _maxLoginAttempts) {
      await AppStorage.saveLockoutTime(DateTime.now());
      return AuthResult.accountLocked(remainingMinutes: 10);
    } else {
      return AuthResult.invalidPassword();
    }
  }
  
  /// Trata login bem-sucedido
  static Future<void> _handleSuccessfulLogin(String cpf) async {
    await AppStorage.resetLoginAttempts();
    await _updateLastLogin(cpf);
    
    // Salva dados do usuário em cache
    final userData = _mockUsers[cpf];
    if (userData != null) {
      await AppStorage.saveUser(userData);
      // Salva token de autenticação
      await AppStorage.saveAuthToken(_generateToken(cpf));
    }
  }
  
  /// Atualiza último login
  static Future<void> _updateLastLogin(String cpf) async {
    // Em um sistema real, isso seria feito no backend
    // Aqui apenas simulamos
  }
  
  /// Gera token de autenticação
  static String _generateToken(String cpf) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$cpf:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Valida senha
  static bool _isValidPassword(String password) {
    // Mínimo 6, máximo 8 caracteres
    if (password.length < 6 || password.length > 8) return false;
    
    // Deve conter pelo menos uma letra maiúscula
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Deve conter pelo menos um número
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Deve conter pelo menos um caractere especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }
  
  /// Calcula minutos restantes de bloqueio
  static int _getRemainingLockoutMinutes() {
    final lockoutTime = AppStorage.getLockoutTime();
    if (lockoutTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lockoutTime);
      final remaining = 10 - difference.inMinutes;
      return remaining > 0 ? remaining : 0;
    }
    return 0;
  }
}

/// Resultado da autenticação
class AuthResult {
  final AuthStatus status;
  final String? message;
  final User? user;
  final String? token;
  final int? remainingMinutes;
  
  const AuthResult._({
    required this.status,
    this.message,
    this.user,
    this.token,
    this.remainingMinutes,
  });
  
  // Construtores de sucesso
  factory AuthResult.success({required User user, required String token}) {
    return AuthResult._(
      status: AuthStatus.success,
      user: user,
      token: token,
    );
  }
  
  factory AuthResult.passwordRecoverySent() {
    return const AuthResult._(
      status: AuthStatus.passwordRecoverySent,
      message: 'Instruções de recuperação enviadas',
    );
  }
  
  factory AuthResult.passwordChanged() {
    return const AuthResult._(
      status: AuthStatus.passwordChanged,
      message: 'Senha alterada com sucesso',
    );
  }
  
  // Construtores de erro
  factory AuthResult.invalidCPF() {
    return const AuthResult._(
      status: AuthStatus.invalidCPF,
      message: 'CPF inválido',
    );
  }
  
  factory AuthResult.invalidPassword() {
    return const AuthResult._(
      status: AuthStatus.invalidPassword,
      message: 'Senha inválida',
    );
  }
  
  factory AuthResult.userNotFound() {
    return const AuthResult._(
      status: AuthStatus.userNotFound,
      message: 'Usuário não encontrado',
    );
  }
  
  factory AuthResult.cpfNotEligibleForRegistration() {
    return const AuthResult._(
      status: AuthStatus.cpfNotEligibleForRegistration,
      message: 'CPF não elegível para registro',
    );
  }
  
  factory AuthResult.accountLocked({required int remainingMinutes}) {
    return AuthResult._(
      status: AuthStatus.accountLocked,
      message: 'Conta bloqueada temporariamente',
      remainingMinutes: remainingMinutes,
    );
  }
  
  factory AuthResult.accountPermanentlyLocked() {
    return const AuthResult._(
      status: AuthStatus.accountPermanentlyLocked,
      message: 'Conta bloqueada permanentemente',
    );
  }
  
  factory AuthResult.biometricNotEnabled() {
    return const AuthResult._(
      status: AuthStatus.biometricNotEnabled,
      message: 'Biometria não habilitada',
    );
  }
  
  factory AuthResult.biometricFailed() {
    return const AuthResult._(
      status: AuthStatus.biometricFailed,
      message: 'Autenticação biométrica falhou',
    );
  }
  
  factory AuthResult.error(String message) {
    return AuthResult._(
      status: AuthStatus.error,
      message: message,
    );
  }
  
  /// Verifica se o resultado é de sucesso
  bool get isSuccess => status == AuthStatus.success;
  
  /// Verifica se o resultado é de erro
  bool get isError => status != AuthStatus.success;
}

/// Status da autenticação
enum AuthStatus {
  success,
  invalidCPF,
  invalidPassword,
  userNotFound,
  cpfNotEligibleForRegistration,
  accountLocked,
  accountPermanentlyLocked,
  biometricNotEnabled,
  biometricFailed,
  passwordRecoverySent,
  passwordChanged,
  error,
}

/// Status da conta
enum AccountStatus {
  active,
  temporarilyLocked,
  permanentlyLocked,
}
