// Importa bibliotecas necessárias para o funcionamento do serviço HTTP
import 'dart:convert';        // Para codificação/decodificação JSON
import 'package:http/http.dart' as http;  // Para fazer requisições HTTP
import '../config/env_config.dart';  // Para acessar configurações do ambiente
import 'mock_api_service.dart';  // Para usar mocks quando necessário

/// Serviço HTTP que pode alternar entre API real e mocks
/// 
/// Para usar a API real, o dev apenas altera a URL base
/// Para usar mocks, mantém a configuração atual
/// 
/// Este serviço implementa o padrão "Adapter" que permite
/// alternar facilmente entre diferentes fontes de dados
class HttpService {
  // ========================================
  // 🌐 CONFIGURAÇÃO
  // ========================================
  
  /// URL base da API (será alterada pelo dev)
  /// Esta é a URL que o desenvolvedor alterará quando implementar a API real
  /// Exemplo: 'https://api.minhaempresa.com' ou 'http://localhost:8080'
  static String get _baseUrl => EnvConfig.apiBaseUrl;
  
  /// Timeout das requisições - obtém da configuração do ambiente
  /// Define quanto tempo esperar antes de considerar uma requisição como falha
  /// Em produção, geralmente é 30 segundos, em desenvolvimento pode ser menor
  static Duration get _timeout => EnvConfig.apiTimeout;
  
  /// Headers padrão para todas as requisições HTTP
  /// Define o tipo de conteúdo, aceitação e identificação do cliente
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',    // Indica que enviamos dados JSON
    'Accept': 'application/json',          // Indica que aceitamos respostas JSON
    'User-Agent': 'FlutterApp/1.0.0',     // Identifica o aplicativo cliente
  };
  
  // ========================================
  // 🔧 CONFIGURAÇÃO DE MOCK
  // ========================================
  
  /// Verifica se deve usar mocks ou API real
  /// Esta configuração vem do ambiente e pode ser alterada facilmente
  /// 
  /// - true = usa mocks (desenvolvimento/testes)
  /// - false = usa API real (produção)
  static bool get _useMocks => EnvConfig.useMocks;
  
  // ========================================
  // 🔍 ENDPOINT: VERIFICAÇÃO DE CPF
  // ========================================
  
  /// POST /api/v1/cpf/verify
  /// Verifica se o CPF é cadastrado e direciona o fluxo
  /// 
  /// Este endpoint é o primeiro ponto de contato da aplicação
  /// Ele decide se o usuário vai para registro ou login
  static Future<Map<String, dynamic>> verifyCPF(String cpf) async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.verifyCPF(cpf);
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/api/v1/cpf/verify');
      
      // Faz a requisição POST para a API real
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão (Content-Type, Accept, etc.)
        body: jsonEncode({'cpf': cpf}),  // Corpo da requisição em JSON
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro (timeout, rede, etc.), retorna erro
      return _handleError('Erro ao verificar CPF: $e');
    }
  }
  
  // ========================================
  // 🔐 ENDPOINT: AUTENTICAÇÃO
  // ========================================
  
  /// POST /api/v1/auth/login
  /// Realiza login do usuário com validação de credenciais
  /// 
  /// Este endpoint autentica o usuário e retorna dados da sessão
  static Future<Map<String, dynamic>> login(String cpf, String password) async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.login(cpf, password);
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/auth/login-cpf');
      
      // Faz a requisição POST para a API real
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({      // Corpo da requisição em JSON
          'cpf': cpf,          // CPF do usuário
          'password': password, // Senha do usuário
        }),
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro ao fazer login: $e');
    }
  }
  
  /// POST /api/v1/auth/register
  /// Registra novo usuário no sistema
  /// 
  /// Este endpoint cria uma nova conta de usuário
  static Future<Map<String, dynamic>> register(String cpf, String password) async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.register(cpf, password);
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/auth/register');
      
      // Faz a requisição POST para a API real
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({      // Corpo da requisição em JSON
          'name': 'Usuário',   // Nome padrão
          'email': cpf,        // Email do usuário (usando CPF como email para compatibilidade)
          'cpf': cpf,          // CPF do usuário
          'password': password, // Senha do usuário
        }),
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro ao registrar usuário: $e');
    }
  }
  
  // ========================================
  // 🔑 ENDPOINT: RECUPERAÇÃO DE SENHA
  // ========================================
  
  /// POST /api/v1/auth/forgot-password
  /// Inicia processo de recuperação de senha
  /// 
  /// Este endpoint envia token de recuperação por SMS ou Email
  static Future<Map<String, dynamic>> forgotPassword(String cpf, String method) async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.forgotPassword(cpf, method);
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/api/v1/auth/forgot-password');
      
      // Faz a requisição POST para a API real
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({      // Corpo da requisição em JSON
          'cpf': cpf,          // CPF do usuário
          'method': method,     // Método de envio (SMS ou Email)
        }),
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro ao solicitar recuperação de senha: $e');
    }
  }
  
  /// POST /api/v1/auth/verify-token
  /// Verifica token de recuperação enviado ao usuário
  /// 
  /// Este endpoint valida o token recebido por SMS ou Email
  static Future<Map<String, dynamic>> verifyToken(String cpf, String method, String token) async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.verifyToken(cpf, method, token);
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/api/v1/auth/verify-token');
      
      // Faz a requisição POST para a API real
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({      // Corpo da requisição em JSON
          'cpf': cpf,          // CPF do usuário
          'method': method,     // Método usado (SMS ou Email)
          'token': token,       // Token de verificação
        }),
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro ao verificar token: $e');
    }
  }
  
  /// PUT /api/v1/auth/reset-password
  /// Altera senha após verificação do token de recuperação
  /// 
  /// Este endpoint define uma nova senha após validação do token
  static Future<Map<String, dynamic>> resetPassword(String cpf, String method, String token, String newPassword) async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.resetPassword(cpf, method, token, newPassword);
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/api/v1/auth/reset-password');
      
      // Faz a requisição PUT para a API real (PUT é usado para atualizações)
      final response = await http.put(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({      // Corpo da requisição em JSON
          'cpf': cpf,          // CPF do usuário
          'method': method,     // Método usado (SMS ou Email)
          'token': token,       // Token de verificação
          'newPassword': newPassword,  // Nova senha escolhida pelo usuário
        }),
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro ao alterar senha: $e');
    }
  }
  
  // ========================================
  // 📱 ENDPOINT: BIOMETRIA
  // ========================================
  
  /// POST /api/v1/auth/biometric
  /// Login com autenticação biométrica (digital, facial)
  /// 
  /// Este endpoint autentica o usuário usando biometria
  static Future<Map<String, dynamic>> biometricLogin() async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.biometricLogin();
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/api/v1/auth/biometric');
      
      // Faz a requisição POST para a API real
      // Biometria não precisa de dados no corpo, apenas autenticação do dispositivo
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({}),   // Corpo vazio (a autenticação é feita pelo dispositivo)
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro no login biométrico: $e');
    }
  }
  
  // ========================================
  // 🔒 ENDPOINT: LOGOUT
  // ========================================
  
  /// POST /api/v1/auth/logout
  /// Realiza logout do usuário e limpa dados da sessão
  /// 
  /// Este endpoint encerra a sessão do usuário
  static Future<Map<String, dynamic>> logout() async {
    // PRIMEIRO: Verifica se deve usar mocks
    if (_useMocks) {
      // Se mocks estão habilitados, usa o serviço de mock
      return await MockApiService.logout();
    }
    
    // SEGUNDO: Se não usa mocks, faz requisição HTTP real
    try {
      // Constrói a URL completa do endpoint
      final url = Uri.parse('$_baseUrl/api/v1/auth/logout');
      
      // Faz a requisição POST para a API real
      // Logout não precisa de dados no corpo, apenas invalida a sessão
      final response = await http.post(
        url,                    // URL do endpoint
        headers: _defaultHeaders,  // Headers padrão
        body: jsonEncode({}),   // Corpo vazio
      ).timeout(_timeout);      // Aplica timeout configurado
      
      // Processa a resposta da API real
      return _handleResponse(response);
    } catch (e) {
      // Se ocorrer qualquer erro, retorna erro
      return _handleError('Erro ao fazer logout: $e');
    }
  }
  
  // ========================================
  // 🔧 FUNÇÕES AUXILIARES
  // ========================================
  
  /// Trata resposta HTTP da API real
  /// 
  /// Esta função:
  /// - Decodifica o JSON da resposta
  /// - Verifica o status code HTTP
  /// - Retorna dados ou erro baseado no status
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      // Tenta decodificar o corpo da resposta como JSON
      final body = jsonDecode(response.body);
      
      // Verifica se o status code indica sucesso (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Status de sucesso - retorna os dados da resposta
        return body;
      } else {
        // Status de erro - cria resposta de erro padronizada
        return {
          'success': false,     // Indica falha na operação
          'error': {            // Detalhes do erro
            'code': 'HTTP_ERROR',  // Código específico para erro HTTP
            'message': 'Erro na requisição',  // Mensagem para o usuário
            'details': 'Status: ${response.statusCode} - ${response.reasonPhrase}',  // Detalhes técnicos
            'response': body,   // Resposta original da API (pode conter detalhes do erro)
          },
          'timestamp': DateTime.now().toIso8601String(),  // Timestamp do erro
        };
      }
    } catch (e) {
      // Se não conseguir decodificar JSON, retorna erro de parsing
      return _handleError('Erro ao processar resposta: $e');
    }
  }
  
  /// Trata erros de rede e outros erros não-HTTP
  /// 
  /// Esta função cria uma resposta de erro padronizada para:
  /// - Erros de timeout
  /// - Erros de conexão
  /// - Erros de parsing
  /// - Outros erros não relacionados ao HTTP
  static Map<String, dynamic> _handleError(String message) {
    return {
      'success': false,     // Indica falha na operação
      'error': {            // Detalhes do erro
        'code': 'NETWORK_ERROR',  // Código específico para erro de rede
        'message': 'Erro de conexão',  // Mensagem para o usuário
        'details': message, // Detalhes técnicos do erro
      },
      'timestamp': DateTime.now().toIso8601String(),  // Timestamp do erro
    };
  }
  
  // ========================================
  // 📋 INFORMAÇÕES DO SERVIÇO
  // ========================================
  
  /// Retorna informações do serviço atual
  /// 
  /// Útil para debug e verificação de configuração
  /// Mostra URL base, timeout, se está usando mocks, etc.
  static String get serviceInfo {
    return '''
🌐 SERVIÇO HTTP ATUAL:
📡 URL Base: $_baseUrl
⏱️ Timeout: ${_timeout.inSeconds}s
🧪 Usando Mocks: $_useMocks
📱 User Agent: ${_defaultHeaders['User-Agent']}
''';
  }
  
  /// Retorna todos os endpoints disponíveis
  /// 
  /// Útil para documentação e verificação de rotas
  /// Mostra todos os endpoints que o serviço pode chamar
  static String get availableEndpoints {
    return '''
🔗 ENDPOINTS DISPONÍVEIS:

🔍 VERIFICAÇÃO DE CPF:
POST $_baseUrl/api/v1/cpf/verify

🔐 AUTENTICAÇÃO:
POST $_baseUrl/api/v1/auth/login
POST $_baseUrl/api/v1/auth/register

🔑 RECUPERAÇÃO DE SENHA:
POST $_baseUrl/api/v1/auth/forgot-password
POST $_baseUrl/api/v1/auth/verify-token
PUT $_baseUrl/api/v1/auth/reset-password

📱 BIOMETRIA:
POST $_baseUrl/api/v1/auth/biometric

🔒 LOGOUT:
POST $_baseUrl/api/v1/auth/logout
''';
  }
}
