// Importa bibliotecas necessárias para o funcionamento do serviço
import 'dart:convert';        // Para codificação/decodificação JSON
import 'dart:math';           // Para geração de números aleatórios
import '../config/env_config.dart';  // Para acessar configurações do ambiente
import 'package:crypto/crypto.dart';  // Para gerar hashes SHA256

/// Serviço de Mock que simula uma API REST real
/// 
/// Este serviço simula os mesmos endpoints que serão implementados
/// no backend real (Spring Boot), permitindo que o dev apenas
/// altere a URL base e tudo funcione
class MockApiService {
  // ========================================
  // 🌐 CONFIGURAÇÃO BASE
  // ========================================
  
  /// URL base da API (será substituída pelo dev)
  /// Esta é a URL que o desenvolvedor alterará quando implementar a API real
  static const String _baseUrl = 'https://api.exemplo.com';
  
  /// Timeout das requisições - obtém da configuração do ambiente
  /// Define quanto tempo esperar antes de considerar uma requisição como falha
  static Duration get _timeout => EnvConfig.apiTimeout;
  
  /// Simula delay de rede para tornar os mocks mais realistas
  /// Aguarda um tempo configurável para simular latência de rede
  static Future<void> _simulateNetworkDelay() async {
    // Obtém o delay configurado em segundos
    final delay = EnvConfig.networkDelaySeconds;
    // Converte para milissegundos e aguarda
    await Future.delayed(Duration(milliseconds: (delay * 1000).round()));
  }
  
  // ========================================
  // 🔍 ENDPOINT: VERIFICAÇÃO DE CPF
  // ========================================
  
  /// Endpoint: POST /api/v1/cpf/verify
  /// Verifica se o CPF é cadastrado e direciona o fluxo
  /// 
  /// Este é o endpoint principal que decide se o usuário vai para:
  /// - Primeiro acesso (registro)
  /// - Login (usuário existente)
  /// - Erro (CPF não elegível)
  static Future<Map<String, dynamic>> verifyCPF(String cpf) async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/cpf/verify - CPF: $cpf');
    
    // Simula delay de rede para tornar mais realista
    await _simulateNetworkDelay();
    
    // Remove caracteres não numéricos (pontos, traços, espaços)
    // Ex: "123.456.789-00" vira "12345678900"
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // Simula resposta da API baseada no CPF informado
    if (_isFirstAccessCPF(cleanCpf)) {
      // CPF elegível para primeiro acesso
      return {
        'success': true,                    // Indica sucesso na operação
        'data': {                          // Dados da resposta
          'cpf': cleanCpf,                 // CPF limpo retornado
          'status': 'FIRST_ACCESS',        // Status indicando primeiro acesso
          'message': 'CPF elegível para primeiro acesso',  // Mensagem amigável
          'requiresRegistration': true,     // Flag indicando que precisa registrar
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    } else if (_isExistingUserCPF(cleanCpf)) {
      // CPF de usuário já cadastrado
      return {
        'success': true,                    // Indica sucesso na operação
        'data': {                          // Dados da resposta
          'cpf': cleanCpf,                 // CPF limpo retornado
          'status': 'EXISTING_USER',       // Status indicando usuário existente
          'message': 'Usuário já cadastrado',  // Mensagem amigável
          'requiresRegistration': false,    // Flag indicando que NÃO precisa registrar
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    } else {
      // CPF não encontrado ou não elegível
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'CPF_NOT_FOUND',         // Código do erro para tratamento
          'message': 'CPF não encontrado no sistema',  // Mensagem para o usuário
          'details': 'Este CPF não está elegível para cadastro ou login',  // Detalhes técnicos
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
  }
  
  // ========================================
  // 🔐 ENDPOINT: AUTENTICAÇÃO
  // ========================================
  
  /// Endpoint: POST /api/v1/auth/login
  /// Realiza login do usuário com validação de credenciais
  /// 
  /// Este endpoint verifica:
  /// - Se a conta está bloqueada
  /// - Se as credenciais estão corretas
  /// - Incrementa tentativas de login em caso de falha
  static Future<Map<String, dynamic>> login(String cpf, String password) async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/auth/login - CPF: $cpf');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // Remove caracteres não numéricos do CPF
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // PRIMEIRO: Verifica se a conta está bloqueada temporariamente
    if (_isAccountLocked(cleanCpf)) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'ACCOUNT_LOCKED',        // Código específico para conta bloqueada
          'message': 'Conta bloqueada temporariamente',  // Mensagem para o usuário
          'details': 'Tente novamente em ${_getRemainingLockoutMinutes(cleanCpf)} minutos',  // Detalhes com tempo restante
          'remainingMinutes': _getRemainingLockoutMinutes(cleanCpf),  // Tempo restante em minutos
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // SEGUNDO: Verifica se a conta está bloqueada permanentemente
    if (_isAccountPermanentlyLocked(cleanCpf)) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'ACCOUNT_PERMANENTLY_LOCKED',  // Código para bloqueio permanente
          'message': 'Conta bloqueada permanentemente',  // Mensagem para o usuário
          'details': 'Entre em contato com o suporte',  // Instruções para o usuário
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // TERCEIRO: Verifica se as credenciais estão corretas
    if (_isValidCredentials(cleanCpf, password)) {
      // Login bem-sucedido - reseta tentativas e atualiza último login
      _resetLoginAttempts(cleanCpf);       // Zera contador de tentativas
      _updateLastLogin(cleanCpf);          // Atualiza timestamp do último login
      
      return {
        'success': true,                    // Indica sucesso na operação
        'data': {                          // Dados da resposta
          'user': _getMockUser(cleanCpf),  // Dados do usuário logado
          'token': _generateToken(cleanCpf),  // Token de autenticação gerado
          'expiresAt': DateTime.now().add(Duration(hours: 24)).toIso8601String(),  // Expiração do token (24h)
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    } else {
      // Credenciais inválidas - incrementa tentativas de login
      _incrementLoginAttempts(cleanCpf);  // Incrementa contador de tentativas
      
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'INVALID_CREDENTIALS',   // Código para credenciais inválidas
          'message': 'CPF ou senha incorretos',  // Mensagem para o usuário
          'details': 'Verifique suas credenciais e tente novamente',  // Instruções para o usuário
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
  }
  
  // ========================================
  // 📝 ENDPOINT: REGISTRO
  // ========================================
  
  /// Endpoint: POST /api/v1/auth/register
  /// Registra novo usuário no sistema
  /// 
  /// Este endpoint verifica:
  /// - Se o CPF é elegível para registro
  /// - Se a senha atende aos requisitos
  /// - Cria o usuário e retorna dados
  static Future<Map<String, dynamic>> register(String cpf, String password) async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/auth/register - CPF: $cpf');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // Remove caracteres não numéricos do CPF
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // PRIMEIRO: Verifica se CPF é elegível para registro
    if (!_isFirstAccessCPF(cleanCpf)) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'CPF_NOT_ELIGIBLE',      // Código para CPF não elegível
          'message': 'CPF não elegível para registro',  // Mensagem para o usuário
          'details': 'Este CPF não está na lista de elegíveis',  // Detalhes técnicos
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // SEGUNDO: Valida se a senha atende aos requisitos
    if (!_isValidPassword(password)) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'INVALID_PASSWORD',      // Código para senha inválida
          'message': 'Senha não atende aos requisitos',  // Mensagem para o usuário
          'details': 'A senha deve ter 6-8 caracteres, uma maiúscula, um número e um caractere especial',  // Requisitos detalhados
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // TERCEIRO: Simula criação do usuário no sistema
    final user = _createMockUser(cleanCpf);  // Cria dados mockados do usuário
    
    return {
      'success': true,                      // Indica sucesso na operação
      'data': {                            // Dados da resposta
        'user': user,                      // Dados do usuário criado
        'token': _generateToken(cleanCpf), // Token de autenticação gerado
        'message': 'Usuário registrado com sucesso',  // Mensagem de confirmação
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
    };
  }
  
  // ========================================
  // 🔑 ENDPOINT: RECUPERAÇÃO DE SENHA
  // ========================================
  
  /// Endpoint: POST /api/v1/auth/forgot-password
  /// Inicia processo de recuperação de senha
  /// 
  /// Este endpoint:
  /// - Verifica se o usuário existe
  /// - Simula envio de token por SMS/Email
  /// - Retorna confirmação do envio
  static Future<Map<String, dynamic>> forgotPassword(String cpf, String method) async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/auth/forgot-password - CPF: $cpf, Método: $method');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // Remove caracteres não numéricos do CPF
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // PRIMEIRO: Verifica se o usuário existe no sistema
    if (!_isExistingUserCPF(cleanCpf)) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'USER_NOT_FOUND',        // Código para usuário não encontrado
          'message': 'Usuário não encontrado',  // Mensagem para o usuário
          'details': 'Este CPF não está cadastrado no sistema',  // Detalhes técnicos
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // SEGUNDO: Simula envio do token de recuperação
    final token = _generateVerificationToken();  // Gera token de 4 dígitos
    
    return {
      'success': true,                      // Indica sucesso na operação
      'data': {                            // Dados da resposta
        'message': 'Token de recuperação enviado com sucesso',  // Confirmação do envio
        'method': method,                   // Método usado (SMS ou Email)
        'cpf': cleanCpf,                   // CPF do usuário
        'tokenExpiresAt': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),  // Expiração do token (10 min)
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
    };
  }
  
  /// Endpoint: POST /api/v1/auth/verify-token
  /// Verifica token de recuperação enviado ao usuário
  /// 
  /// Este endpoint:
  /// - Valida formato do token
  /// - Simula verificação no sistema
  /// - Retorna confirmação da validação
  static Future<Map<String, dynamic>> verifyToken(String cpf, String method, String token) async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/auth/verify-token - CPF: $cpf, Token: $token');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // Remove caracteres não numéricos do CPF
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // PRIMEIRO: Simula verificação do token no sistema
    if (token == '0000') {
      // Token específico para simular falha (apenas para testes)
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'INVALID_TOKEN',         // Código para token inválido
          'message': 'Token inválido',     // Mensagem para o usuário
          'details': 'O token informado não é válido',  // Detalhes técnicos
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // SEGUNDO: Verifica se o token tem o formato correto (4 dígitos)
    if (token.length != 4) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'INVALID_TOKEN_FORMAT',  // Código para formato inválido
          'message': 'Formato de token inválido',  // Mensagem para o usuário
          'details': 'O token deve ter 4 dígitos',  // Requisitos do formato
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // TERCEIRO: Token válido - retorna sucesso
    return {
      'success': true,                      // Indica sucesso na operação
      'data': {                            // Dados da resposta
        'message': 'Token verificado com sucesso',  // Confirmação da validação
        'cpf': cleanCpf,                   // CPF do usuário
        'method': method,                   // Método usado (SMS ou Email)
        'token': token,                     // Token validado
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
    };
  }
  
  /// Endpoint: PUT /api/v1/auth/reset-password
  /// Altera senha após verificação do token de recuperação
  /// 
  /// Este endpoint:
  /// - Valida a nova senha
  /// - Simula alteração no sistema
  /// - Retorna confirmação da alteração
  static Future<Map<String, dynamic>> resetPassword(String cpf, String method, String token, String newPassword) async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] PUT /api/v1/auth/reset-password - CPF: $cpf');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // Remove caracteres não numéricos do CPF
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // PRIMEIRO: Valida se a nova senha atende aos requisitos
    if (!_isValidPassword(newPassword)) {
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'INVALID_PASSWORD',      // Código para senha inválida
          'message': 'Nova senha não atende aos requisitos',  // Mensagem para o usuário
          'details': 'A senha deve ter 6-8 caracteres, uma maiúscula, um número e um caractere especial',  // Requisitos detalhados
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // SEGUNDO: Simula alteração da senha no sistema
    _updatePassword(cleanCpf, newPassword);  // Atualiza senha (simulado)
    
    return {
      'success': true,                      // Indica sucesso na operação
      'data': {                            // Dados da resposta
        'message': 'Senha alterada com sucesso',  // Confirmação da alteração
        'cpf': cleanCpf,                   // CPF do usuário
        'passwordChangedAt': DateTime.now().toIso8601String(),  // Timestamp da alteração
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
    };
  }
  
  // ========================================
  // 📱 ENDPOINT: BIOMETRIA
  // ========================================
  
  /// Endpoint: POST /api/v1/auth/biometric
  /// Login com autenticação biométrica (digital, facial)
  /// 
  /// Este endpoint:
  /// - Simula autenticação biométrica
  /// - Verifica se há usuário em cache
  /// - Retorna dados do usuário autenticado
  static Future<Map<String, dynamic>> biometricLogin() async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/auth/biometric');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // PRIMEIRO: Simula autenticação biométrica (80% de sucesso para testes)
    final authenticated = await _simulateBiometricAuth();
    
    if (!authenticated) {
      // Autenticação biométrica falhou
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'BIOMETRIC_FAILED',      // Código para falha biométrica
          'message': 'Autenticação biométrica falhou',  // Mensagem para o usuário
          'details': 'Tente novamente ou use sua senha',  // Instruções alternativas
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // SEGUNDO: Recupera dados do usuário em cache (simulado)
    final userData = _getCachedUser();
    if (userData == null) {
      // Não há usuário em cache
      return {
        'success': false,                   // Indica falha na operação
        'error': {                          // Detalhes do erro
          'code': 'USER_NOT_FOUND',        // Código para usuário não encontrado
          'message': 'Usuário não encontrado',  // Mensagem para o usuário
          'details': 'Faça login com senha primeiro',  // Instruções para o usuário
        },
        'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
      };
    }
    
    // TERCEIRO: Autenticação biométrica bem-sucedida
    return {
      'success': true,                      // Indica sucesso na operação
      'data': {                            // Dados da resposta
        'user': userData,                   // Dados do usuário autenticado
        'token': _generateToken(userData['cpf']),  // Token de autenticação gerado
        'expiresAt': DateTime.now().add(Duration(hours: 24)).toIso8601String(),  // Expiração do token (24h)
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
    };
  }
  
  // ========================================
  // 🔒 ENDPOINT: LOGOUT
  // ========================================
  
  /// Endpoint: POST /api/v1/auth/logout
  /// Realiza logout do usuário e limpa dados da sessão
  /// 
  /// Este endpoint:
  /// - Limpa dados do usuário em cache
  /// - Invalida tokens de sessão
  /// - Retorna confirmação do logout
  static Future<Map<String, dynamic>> logout() async {
    // Log de debug para acompanhar as chamadas
    print('🔍 DEBUG: [MockApiService] POST /api/v1/auth/logout');
    
    // Simula delay de rede
    await _simulateNetworkDelay();
    
    // Simula logout - limpa dados em cache
    _clearCachedUser();  // Remove usuário do cache (simulado)
    
    return {
      'success': true,                      // Indica sucesso na operação
      'data': {                            // Dados da resposta
        'message': 'Logout realizado com sucesso',  // Confirmação do logout
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp da resposta
    };
  }
  
  // ========================================
  // 🧪 DADOS MOCKADOS
  // ========================================
  
  // Lista de CPFs que são elegíveis para primeiro acesso (registro)
  // Estes CPFs não existem no sistema e podem ser registrados
  static const List<String> _firstAccessCpfs = [
    '11144477735',  // CPF de teste para primeiro acesso
    '22255588846',  // CPF de teste para primeiro acesso
  ];
  
  // Lista de CPFs de usuários já cadastrados no sistema
  // Estes CPFs existem e podem fazer login
  static const List<String> _existingCpfs = [
    '94691907009',  // Usuário João Silva
    '63254351096',  // Usuário Maria Santos
  ];
  
  // Mapa de senhas válidas para cada CPF de usuário existente
  // Em um sistema real, isso seria armazenado de forma segura no backend
  static const Map<String, String> _validPasswords = {
    '94691907009': 'Senha123@',  // Senha do usuário João Silva
    '63254351096': 'Test123!',   // Senha do usuário Maria Santos
  };
  
  // Dados mockados dos usuários existentes no sistema
  // Em um sistema real, isso viria do banco de dados
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    '94691907009': {  // Dados do usuário João Silva
      'cpf': '94691907009',                    // CPF do usuário
      'name': 'João Silva',                    // Nome completo
      'email': 'joao.silva@email.com',         // Email de contato
      'phone': '(11) 99999-9999',             // Telefone de contato
      'createdAt': '2024-01-01T00:00:00.000Z', // Data de criação da conta
      'lastLogin': '2024-01-15T10:30:00.000Z', // Último login realizado
      'isActive': true,                        // Status da conta (ativa)
      'roles': ['user'],                       // Papéis/permissões do usuário
    },
    '63254351096': {  // Dados do usuário Maria Santos
      'cpf': '63254351096',                    // CPF do usuário
      'name': 'Maria Santos',                  // Nome completo
      'email': 'maria.santos@email.com',       // Email de contato
      'phone': '(11) 88888-8888',             // Telefone de contato
      'createdAt': '2024-01-01T00:00:00.000Z', // Data de criação da conta
      'lastLogin': '2024-01-14T15:45:00.000Z', // Último login realizado
      'isActive': true,                        // Status da conta (ativa)
      'roles': ['user'],                       // Papéis/permissões do usuário
    },
  };
  
  // Controle de tentativas de login para implementar bloqueio de conta
  // Em um sistema real, isso seria persistido no banco de dados
  static final Map<String, int> _loginAttempts = {};           // Contador de tentativas por CPF
  static final Map<String, DateTime> _lockoutTimes = {};       // Timestamp do bloqueio por CPF
  static final Map<String, bool> _permanentlyLocked = {};      // Flag de bloqueio permanente por CPF
  
  // ========================================
  // 🔧 FUNÇÕES AUXILIARES
  // ========================================
  
  /// Verifica se o CPF é elegível para primeiro acesso
  /// Retorna true se o CPF está na lista de elegíveis
  static bool _isFirstAccessCPF(String cpf) => _firstAccessCpfs.contains(cpf);
  
  /// Verifica se o CPF é de usuário já cadastrado
  /// Retorna true se o CPF está na lista de existentes
  static bool _isExistingUserCPF(String cpf) => _existingCpfs.contains(cpf);
  
  /// Verifica se as credenciais (CPF + senha) são válidas
  /// Compara a senha informada com a senha armazenada para o CPF
  static bool _isValidCredentials(String cpf, String password) {
    return _validPasswords[cpf] == password;  // Retorna true se a senha confere
  }
  
  /// Valida se a senha atende aos requisitos de segurança
  /// 
  /// Requisitos:
  /// - 6 a 8 caracteres de comprimento
  /// - Pelo menos uma letra maiúscula
  /// - Pelo menos um número
  /// - Pelo menos um caractere especial
  static bool _isValidPassword(String password) {
    // Verifica comprimento (6 a 8 caracteres)
    if (password.length < 6 || password.length > 8) return false;
    
    // Verifica se contém pelo menos uma letra maiúscula
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Verifica se contém pelo menos um número
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Verifica se contém pelo menos um caractere especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;  // Senha atende a todos os requisitos
  }
  
  /// Verifica se a conta está bloqueada temporariamente
  /// Retorna true se a conta foi bloqueada por múltiplas tentativas de login
  static bool _isAccountLocked(String cpf) {
    final lockoutTime = _lockoutTimes[cpf];  // Obtém timestamp do bloqueio
    if (lockoutTime == null) return false;   // Se não há bloqueio, retorna false
    
    final now = DateTime.now();              // Timestamp atual
    final difference = now.difference(lockoutTime);  // Calcula diferença de tempo
    return difference.inMinutes < 10;        // Retorna true se ainda está bloqueada (menos de 10 min)
  }
  
  /// Verifica se a conta está bloqueada permanentemente
  /// Retorna true se a conta foi bloqueada por muitas tentativas de login
  static bool _isAccountPermanentlyLocked(String cpf) {
    return _permanentlyLocked[cpf] ?? false;  // Retorna false se não há bloqueio permanente
  }
  
  /// Calcula quantos minutos restam para desbloquear a conta
  /// Retorna 0 se a conta não está bloqueada ou já foi desbloqueada
  static int _getRemainingLockoutMinutes(String cpf) {
    final lockoutTime = _lockoutTimes[cpf];  // Obtém timestamp do bloqueio
    if (lockoutTime == null) return 0;       // Se não há bloqueio, retorna 0
    
    final now = DateTime.now();              // Timestamp atual
    final difference = now.difference(lockoutTime);  // Calcula diferença de tempo
    final remaining = 10 - difference.inMinutes;    // Calcula minutos restantes (bloqueio dura 10 min)
    return remaining > 0 ? remaining : 0;   // Retorna minutos restantes ou 0 se já expirou
  }
  
  /// Incrementa o contador de tentativas de login para um CPF
  /// Implementa lógica de bloqueio progressivo:
  /// - 3 tentativas = bloqueio temporário (10 min)
  /// - 5 tentativas = bloqueio permanente
  static void _incrementLoginAttempts(String cpf) async {
    _loginAttempts[cpf] = (_loginAttempts[cpf] ?? 0) + 1;  // Incrementa contador
    
    if (_loginAttempts[cpf]! >= 5) {
      // 5 ou mais tentativas = bloqueio permanente
      _permanentlyLocked[cpf] = true;
    } else if (_loginAttempts[cpf]! >= 3) {
      // 3 ou mais tentativas = bloqueio temporário
      _lockoutTimes[cpf] = DateTime.now();
    }
  }
  
  /// Reseta o contador de tentativas de login para um CPF
  /// Chamado quando o login é bem-sucedido
  static void _resetLoginAttempts(String cpf) {
    _loginAttempts[cpf] = 0;           // Zera contador de tentativas
    _lockoutTimes.remove(cpf);          // Remove timestamp de bloqueio
  }
  
  /// Atualiza o timestamp do último login para um CPF
  /// Em um sistema real, isso seria persistido no banco de dados
  static void _updateLastLogin(String cpf) {
    // Simula atualização do último login
    // Em implementação real, salvaria no banco de dados
  }
  
  /// Obtém dados mockados de um usuário por CPF
  /// Retorna dados completos se o usuário existe, ou dados básicos se não existe
  static Map<String, dynamic> _getMockUser(String cpf) {
    // Primeiro tenta obter dados completos do usuário
    final existingUser = _mockUsers[cpf];
    if (existingUser != null) {
      return existingUser;  // Retorna dados completos se existem
    }
    
    // Se não existem dados completos, cria dados básicos
    return {
      'cpf': cpf,                                    // CPF do usuário
      'name': 'Usuário ${cpf.substring(0, 3)}',     // Nome baseado nos primeiros 3 dígitos do CPF
      'email': null,                                 // Email não informado
      'phone': null,                                 // Telefone não informado
      'createdAt': DateTime.now().toIso8601String(), // Data atual como data de criação
      'lastLogin': null,                             // Último login não informado
      'isActive': true,                              // Status ativo por padrão
      'roles': ['user'],                             // Papel de usuário padrão
    };
  }
  
  /// Cria dados mockados para um novo usuário
  /// Usado durante o processo de registro
  static Map<String, dynamic> _createMockUser(String cpf) {
    return {
      'cpf': cpf,                                    // CPF do usuário
      'name': 'Usuário ${cpf.substring(0, 3)}',     // Nome baseado nos primeiros 3 dígitos do CPF
      'email': null,                                 // Email não informado
      'phone': null,                                 // Telefone não informado
      'createdAt': DateTime.now().toIso8601String(), // Data atual como data de criação
      'lastLogin': DateTime.now().toIso8601String(), // Data atual como último login
      'isActive': true,                              // Status ativo por padrão
      'roles': ['user'],                             // Papel de usuário padrão
    };
  }
  
  /// Gera token de autenticação baseado no CPF e timestamp
  /// Em um sistema real, isso seria um JWT assinado pelo backend
  static String _generateToken(String cpf) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();  // Timestamp atual em milissegundos
    final data = '$cpf:$timestamp';                                      // Combina CPF com timestamp
    final bytes = utf8.encode(data);                                     // Converte string para bytes UTF-8
    final digest = sha256.convert(bytes);                               // Gera hash SHA256 dos bytes
    return digest.toString();                                            // Retorna hash como string hexadecimal
  }
  
  /// Gera token de verificação de 4 dígitos
  /// Usado para recuperação de senha e primeiro acesso
  static String _generateVerificationToken() {
    final random = Random();                                           // Cria gerador de números aleatórios
    return List.generate(4, (_) => random.nextInt(10)).join();        // Gera 4 dígitos aleatórios de 0-9
  }
  
  /// Simula atualização de senha no sistema
  /// Em um sistema real, isso seria persistido no banco de dados
  static void _updatePassword(String cpf, String newPassword) {
    // Simula atualização da senha
    // Em implementação real, salvaria hash da senha no banco de dados
  }
  
  /// Simula autenticação biométrica
  /// Retorna true em 80% das vezes para simular sucesso realista
  static Future<bool> _simulateBiometricAuth() async {
    final random = Random();                    // Cria gerador de números aleatórios
    return random.nextDouble() > 0.2;          // Retorna true se número aleatório > 0.2 (80% de chance)
  }
  
  /// Simula recuperação de usuário em cache
  /// Em um sistema real, isso seria um cache Redis ou similar
  static Map<String, dynamic>? _getCachedUser() {
    // Simula usuário em cache
    // Em implementação real, retornaria dados do cache
    return null;  // Por simplicidade, sempre retorna null (sem usuário em cache)
  }
  
  /// Simula limpeza de dados de usuário em cache
  /// Chamado durante logout para limpar sessão
  static void _clearCachedUser() {
    // Simula limpeza do cache
    // Em implementação real, removeria dados do cache Redis ou similar
  }
}
