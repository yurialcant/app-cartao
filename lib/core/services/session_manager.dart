import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/app_storage.dart';

/// Gerenciador de sessão para controlar navegação e fluxos
/// 
/// Este serviço mantém o estado da navegação, histórico de telas,
/// dados de contexto e controla os fluxos de navegação
class SessionManager {
  // ========================================
  // 🔐 INSTÂNCIA SINGLETON
  // ========================================
  
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();
  
  // ========================================
  // 📱 ESTADO DA SESSÃO
  // ========================================
  
  /// Histórico de navegação (pilha de telas)
  final List<NavigationStep> _navigationHistory = [];
  
  /// Dados de contexto da sessão atual
  Map<String, dynamic> _sessionData = {};
  
  /// CPF atual sendo processado
  String? _currentCpf;
  
  /// Método atual (email/sms)
  String? _currentMethod;
  
  /// Token atual sendo processado
  String? _currentToken;
  
  /// Fluxo atual (primeiro_acesso, login, recuperacao)
  String? _currentFlow;
  
  /// Indicador se está em modo de teste
  bool _isTestMode = false;
  
  // ========================================
  // 🔍 GETTERS PÚBLICOS
  // ========================================
  
  /// CPF atual sendo processado
  String? get currentCpf => _currentCpf;
  
  /// Método atual (email/sms)
  String? get currentMethod => _currentMethod;
  
  /// Token atual sendo processado
  String? get currentToken => _currentToken;
  
  /// Fluxo atual
  String? get currentFlow => _currentFlow;
  
  /// Histórico de navegação
  List<NavigationStep> get navigationHistory => List.unmodifiable(_navigationHistory);
  
  /// Última tela visitada
  NavigationStep? get lastStep => _navigationHistory.isNotEmpty ? _navigationHistory.last : null;
  
  /// Dados da sessão
  Map<String, dynamic> get sessionData => Map.unmodifiable(_sessionData);
  
  // ========================================
  // 🚀 INICIALIZAÇÃO E CONFIGURAÇÃO
  // ========================================
  
  /// Inicializa o gerenciador de sessão
  Future<void> initialize() async {
    print('🔍 DEBUG: [SessionManager] Inicializando...');
    
    // Carrega dados salvos do storage
    await _loadSessionFromStorage();
    
    // Configura modo de teste
    _isTestMode = await _checkTestMode();
    
    print('🔍 DEBUG: [SessionManager] Inicializado com sucesso');
    print('🔍 DEBUG: [SessionManager] Modo teste: $_isTestMode');
    print('🔍 DEBUG: [SessionManager] CPF atual: $_currentCpf');
    print('🔍 DEBUG: [SessionManager] Fluxo atual: $_currentFlow');
  }
  
  /// Carrega dados da sessão do storage
  Future<void> _loadSessionFromStorage() async {
    try {
      final sessionJson = await AppStorage.getSessionData();
      if (sessionJson != null) {
        final sessionMap = json.decode(sessionJson);
        _currentCpf = sessionMap['currentCpf'];
        _currentMethod = sessionMap['currentMethod'];
        _currentToken = sessionMap['currentToken'];
        _currentFlow = sessionMap['currentFlow'];
        
        // Carrega histórico de navegação
        final historyJson = sessionMap['navigationHistory'];
        if (historyJson != null) {
          _navigationHistory.clear();
          for (final stepJson in historyJson) {
            _navigationHistory.add(NavigationStep.fromJson(stepJson));
          }
        }
        
        print('🔍 DEBUG: [SessionManager] Sessão carregada do storage');
      }
    } catch (e) {
      print('🔍 DEBUG: [SessionManager] Erro ao carregar sessão: $e');
    }
  }
  
  /// Salva dados da sessão no storage
  Future<void> _saveSessionToStorage() async {
    try {
      final sessionMap = {
        'currentCpf': _currentCpf,
        'currentMethod': _currentMethod,
        'currentToken': _currentToken,
        'currentFlow': _currentFlow,
        'navigationHistory': _navigationHistory.map((step) => step.toJson()).toList(),
        'sessionData': _sessionData,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await AppStorage.saveSessionData(json.encode(sessionMap));
      print('🔍 DEBUG: [SessionManager] Sessão salva no storage');
    } catch (e) {
      print('🔍 DEBUG: [SessionManager] Erro ao salvar sessão: $e');
    }
  }
  
  /// Verifica se está em modo de teste
  Future<bool> _checkTestMode() async {
    try {
      final testMode = await AppStorage.getTestMode();
      return testMode ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // ========================================
  // 🧭 CONTROLE DE NAVEGAÇÃO
  // ========================================
  
  /// Adiciona um novo passo na navegação
  void addNavigationStep(String route, String screenName, {Map<String, dynamic>? data}) {
    final step = NavigationStep(
      route: route,
      screenName: screenName,
      timestamp: DateTime.now(),
      data: data ?? {},
    );
    
    _navigationHistory.add(step);
    
    // Limita o histórico a 20 passos para evitar vazamento de memória
    if (_navigationHistory.length > 20) {
      _navigationHistory.removeAt(0);
    }
    
    print('🔍 DEBUG: [SessionManager] Novo passo: $screenName ($route)');
    print('🔍 DEBUG: [SessionManager] Histórico: ${_navigationHistory.length} passos');
    
    // Salva no storage
    _saveSessionToStorage();
  }
  
  /// Remove o último passo da navegação
  NavigationStep? removeLastStep() {
    if (_navigationHistory.isNotEmpty) {
      final removedStep = _navigationHistory.removeLast();
      print('🔍 DEBUG: [SessionManager] Removido passo: ${removedStep.screenName}');
      _saveSessionToStorage();
      return removedStep;
    }
    return null;
  }
  
  /// Obtém o passo anterior
  NavigationStep? getPreviousStep() {
    if (_navigationHistory.length >= 2) {
      return _navigationHistory[_navigationHistory.length - 2];
    }
    return null;
  }
  
  /// Verifica se pode voltar para uma tela específica
  bool canGoBackTo(String route) {
    return _navigationHistory.any((step) => step.route == route);
  }
  
  /// Obtém o caminho de volta para uma tela específica
  List<NavigationStep> getBackPathTo(String route) {
    final targetIndex = _navigationHistory.indexWhere((step) => step.route == route);
    if (targetIndex != -1) {
      return _navigationHistory.sublist(0, targetIndex + 1);
    }
    return [];
  }
  
  // ========================================
  // 🔐 CONTROLE DE FLUXOS
  // ========================================
  
  /// Inicia um novo fluxo
  void startFlow(String flow, {String? cpf, String? method}) {
    _currentFlow = flow;
    _currentCpf = cpf;
    _currentMethod = method;
    
    // Limpa dados específicos do fluxo anterior
    _sessionData.remove('flow_specific_data');
    
    print('🔍 DEBUG: [SessionManager] Iniciando fluxo: $flow');
    print('🔍 DEBUG: [SessionManager] CPF: $_currentCpf');
    print('🔍 DEBUG: [SessionManager] Método: $_currentMethod');
    
    _saveSessionToStorage();
  }
  
  /// Atualiza dados do fluxo atual
  void updateFlowData(String key, dynamic value) {
    if (_currentFlow != null) {
      if (!_sessionData.containsKey('flow_specific_data')) {
        _sessionData['flow_specific_data'] = {};
      }
      _sessionData['flow_specific_data'][key] = value;
      
      print('🔍 DEBUG: [SessionManager] Atualizando dados do fluxo: $key = $value');
      _saveSessionToStorage();
    }
  }
  
  /// Obtém dados do fluxo atual
  dynamic getFlowData(String key) {
    if (_currentFlow != null && _sessionData.containsKey('flow_specific_data')) {
      return _sessionData['flow_specific_data'][key];
    }
    return null;
  }
  
  /// Finaliza o fluxo atual
  void endFlow() {
    print('🔍 DEBUG: [SessionManager] Finalizando fluxo: $_currentFlow');
    
    _currentFlow = null;
    _currentMethod = null;
    _currentToken = null;
    _sessionData.remove('flow_specific_data');
    
    _saveSessionToStorage();
  }
  
  // ========================================
  // 📧 CONTROLE DE MÉTODOS (EMAIL/SMS)
  // ========================================
  
  /// Define o método atual
  void setMethod(String method) {
    _currentMethod = method;
    print('🔍 DEBUG: [SessionManager] Método definido: $method');
    _saveSessionToStorage();
  }
  
  /// Alterna entre métodos
  String toggleMethod() {
    final newMethod = _currentMethod == 'email' ? 'sms' : 'email';
    setMethod(newMethod);
    return newMethod;
  }
  
  /// Verifica se o método atual é válido
  bool isMethodValid(String method) {
    return method == 'email' || method == 'sms';
  }
  
  // ========================================
  // 🔑 CONTROLE DE TOKENS
  // ========================================
  
  /// Define o token atual
  void setToken(String token) {
    _currentToken = token;
    print('🔍 DEBUG: [SessionManager] Token definido: $token');
    _saveSessionToStorage();
  }
  
  /// Verifica se o token é válido para o método atual
  bool isTokenValid(String token) {
    if (_currentMethod == null) return false;
    
    if (_currentMethod == 'email') {
      return ['1234', '5678', '9999'].contains(token);
    } else {
      return ['2222', '3333', '4444'].contains(token);
    }
  }
  
  // ========================================
  // 🧹 LIMPEZA E RESET
  // ========================================
  
  /// Limpa toda a sessão
  Future<void> clearSession() async {
    print('🔍 DEBUG: [SessionManager] Limpando sessão completa');
    
    _navigationHistory.clear();
    _sessionData.clear();
    _currentCpf = null;
    _currentMethod = null;
    _currentToken = null;
    _currentFlow = null;
    
    await AppStorage.clearSessionData();
    print('🔍 DEBUG: [SessionManager] Sessão limpa com sucesso');
  }
  
  /// Limpa apenas dados específicos
  void clearFlowData() {
    _sessionData.remove('flow_specific_data');
    print('🔍 DEBUG: [SessionManager] Dados do fluxo limpos');
    _saveSessionToStorage();
  }
  
  /// Reseta para modo de teste
  Future<void> resetForTest() async {
    print('🔍 DEBUG: [SessionManager] Resetando para modo de teste');
    
    // Mantém apenas dados essenciais
    final essentialData = <String, dynamic>{
      'test_mode': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _sessionData = essentialData;
    _navigationHistory.clear();
    
    await _saveSessionToStorage();
    print('🔍 DEBUG: [SessionManager] Reset para teste concluído');
  }
  
  // ========================================
  // 📊 DEBUG E LOGS
  // ========================================
  
  /// Imprime estado atual da sessão
  void printSessionState() {
    print('🔍 DEBUG: [SessionManager] === ESTADO DA SESSÃO ===');
    print('🔍 DEBUG: [SessionManager] CPF: $_currentCpf');
    print('🔍 DEBUG: [SessionManager] Método: $_currentMethod');
    print('🔍 DEBUG: [SessionManager] Token: $_currentToken');
    print('🔍 DEBUG: [SessionManager] Fluxo: $_currentFlow');
    print('🔍 DEBUG: [SessionManager] Histórico: ${_navigationHistory.length} passos');
    print('🔍 DEBUG: [SessionManager] Dados: ${_sessionData.length} chaves');
    print('🔍 DEBUG: [SessionManager] ================================');
  }
  
  /// Obtém resumo da sessão
  Map<String, dynamic> getSessionSummary() {
    return {
      'currentCpf': _currentCpf,
      'currentMethod': _currentMethod,
      'currentToken': _currentToken,
      'currentFlow': _currentFlow,
      'navigationSteps': _navigationHistory.length,
      'sessionDataKeys': _sessionData.keys.toList(),
      'lastStep': lastStep?.screenName,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Representa um passo na navegação
class NavigationStep {
  final String route;
  final String screenName;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  NavigationStep({
    required this.route,
    required this.screenName,
    required this.timestamp,
    this.data = const {},
  });
  
  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'route': route,
      'screenName': screenName,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }
  
  /// Cria a partir de JSON
  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      route: json['route'] ?? '',
      screenName: json['screenName'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      data: json['data'] ?? {},
    );
  }
  
  @override
  String toString() {
    return 'NavigationStep(route: $route, screen: $screenName, time: $timestamp)';
  }
}
