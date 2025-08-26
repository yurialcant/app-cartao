import 'dart:async';
import '../storage/app_storage.dart';

/// Serviço para controlar tentativas de envio de tokens
/// 
/// Este serviço gerencia:
/// - Tentativas por método (email/sms)
/// - Tempo de espera entre tentativas
/// - Bloqueio temporário após exceder limites
/// - Alternância entre métodos
class AttemptControlService {
  // ========================================
  // 🔐 INSTÂNCIA SINGLETON
  // ========================================
  
  static final AttemptControlService _instance = AttemptControlService._internal();
  factory AttemptControlService() => _instance;
  AttemptControlService._internal();
  
  // ========================================
  // 📱 CONSTANTES DE CONFIGURAÇÃO
  // ========================================
  
  static const int _maxAttemptsPerMethod = 3;
  static const int _smsCooldownSeconds = 60;
  static const int _emailCooldownSeconds = 60;
  static const int _blockedCooldownMinutes = 10;
  
  // ========================================
  // 🎭 ESTADO DO SERVIÇO
  // ========================================
  
  /// Tentativas por método
  final Map<String, int> _attempts = {
    'sms': 0,
    'email': 0,
  };
  
  /// Timestamps da última tentativa por método
  final Map<String, DateTime?> _lastAttemptTime = {
    'sms': null,
    'email': null,
  };
  
  /// Timestamp do bloqueio geral (após exceder todos os métodos)
  DateTime? _generalBlockTime;
  
  /// Indicador se está bloqueado geralmente
  bool _isGenerallyBlocked = false;
  
  /// Stream controllers para notificar mudanças
  final StreamController<AttemptState> _stateController = StreamController<AttemptState>.broadcast();
  
  // ========================================
  // 🔍 GETTERS PÚBLICOS
  // ========================================
  
  /// Stream de mudanças de estado
  Stream<AttemptState> get stateStream => _stateController.stream;
  
  /// Estado atual das tentativas
  AttemptState get currentState => _getCurrentState();
  
  /// Verifica se pode tentar enviar por um método específico
  bool canAttempt(String method) {
    if (_isGenerallyBlocked) {
      return _isGeneralBlockExpired();
    }
    
    if (_attempts[method]! >= _maxAttemptsPerMethod) {
      return _isMethodBlockExpired(method);
    }
    
    return _isCooldownExpired(method);
  }
  
  /// Verifica se um método está bloqueado
  bool isMethodBlocked(String method) {
    if (_attempts[method]! >= _maxAttemptsPerMethod) {
      return !_isMethodBlockExpired(method);
    }
    return false;
  }
  
  /// Verifica se está bloqueado geralmente
  bool get isGenerallyBlocked => _isGenerallyBlocked && !_isGeneralBlockExpired();
  
  /// Obtém tempo restante para um método específico
  int getRemainingTime(String method) {
    if (_isGenerallyBlocked) {
      return _getGeneralBlockRemainingTime();
    }
    
    if (_attempts[method]! >= _maxAttemptsPerMethod) {
      return _getMethodBlockRemainingTime(method);
    }
    
    return _getCooldownRemainingTime(method);
  }
  
  /// Obtém tempo restante do bloqueio geral
  int getGeneralBlockRemainingTime() {
    return _getGeneralBlockRemainingTime();
  }
  
  /// Obtém tentativas restantes para um método
  int getRemainingAttempts(String method) {
    final used = _attempts[method] ?? 0;
    return _maxAttemptsPerMethod - used;
  }
  
  // ========================================
  // 🚀 MÉTODOS DE CONTROLE
  // ========================================
  
  /// Registra uma tentativa de envio
  void recordAttempt(String method) {
    print('🔍 DEBUG: [AttemptControlService] Registrando tentativa para: $method');
    
    _attempts[method] = (_attempts[method] ?? 0) + 1;
    _lastAttemptTime[method] = DateTime.now();
    
    // Verifica se excedeu o limite para este método
    if (_attempts[method]! >= _maxAttemptsPerMethod) {
      print('🔍 DEBUG: [AttemptControlService] Método $method bloqueado após ${_attempts[method]} tentativas');
    }
    
    // Verifica se deve bloquear geralmente
    _checkGeneralBlock();
    
    // Salva estado
    _saveState();
    
    // Notifica mudanças
    _stateController.add(_getCurrentState());
  }
  
  /// Reseta tentativas para um método específico
  void resetMethod(String method) {
    print('🔍 DEBUG: [AttemptControlService] Resetando tentativas para: $method');
    
    _attempts[method] = 0;
    _lastAttemptTime[method] = null;
    
    _saveState();
    _stateController.add(_getCurrentState());
  }
  
  /// Reseta todas as tentativas
  void resetAll() {
    print('🔍 DEBUG: [AttemptControlService] Resetando todas as tentativas');
    
    _attempts['sms'] = 0;
    _attempts['email'] = 0;
    _lastAttemptTime['sms'] = null;
    _lastAttemptTime['email'] = null;
    _generalBlockTime = null;
    _isGenerallyBlocked = false;
    
    _saveState();
    _stateController.add(_getCurrentState());
  }
  
  /// Força desbloqueio de um método
  void forceUnblock(String method) {
    print('🔍 DEBUG: [AttemptControlService] Forçando desbloqueio de: $method');
    
    _attempts[method] = 0;
    _lastAttemptTime[method] = null;
    
    _saveState();
    _stateController.add(_getCurrentState());
  }
  
  // ========================================
  // 🔒 VERIFICAÇÕES DE BLOQUEIO
  // ========================================
  
  /// Verifica se deve bloquear geralmente
  void _checkGeneralBlock() {
    final smsBlocked = _attempts['sms']! >= _maxAttemptsPerMethod && !_isMethodBlockExpired('sms');
    final emailBlocked = _attempts['email']! >= _maxAttemptsPerMethod && !_isMethodBlockExpired('email');
    
    if (smsBlocked && emailBlocked && !_isGenerallyBlocked) {
      _isGenerallyBlocked = true;
      _generalBlockTime = DateTime.now();
      print('🔍 DEBUG: [AttemptControlService] Bloqueio geral ativado');
    }
  }
  
  /// Verifica se o bloqueio geral expirou
  bool _isGeneralBlockExpired() {
    if (_generalBlockTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_generalBlockTime!);
    
    return difference.inMinutes >= _blockedCooldownMinutes;
  }
  
  /// Verifica se o bloqueio de um método expirou
  bool _isMethodBlockExpired(String method) {
    final lastTime = _lastAttemptTime[method];
    if (lastTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    
    return difference.inMinutes >= _blockedCooldownMinutes;
  }
  
  /// Verifica se o cooldown de um método expirou
  bool _isCooldownExpired(String method) {
    final lastTime = _lastAttemptTime[method];
    if (lastTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    
    final cooldownSeconds = method == 'sms' ? _smsCooldownSeconds : _emailCooldownSeconds;
    
    return difference.inSeconds >= cooldownSeconds;
  }
  
  // ========================================
  // ⏰ CÁLCULOS DE TEMPO
  // ========================================
  
  /// Obtém tempo restante do cooldown
  int _getCooldownRemainingTime(String method) {
    final lastTime = _lastAttemptTime[method];
    if (lastTime == null) return 0;
    
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    
    final cooldownSeconds = method == 'sms' ? _smsCooldownSeconds : _emailCooldownSeconds;
    final remaining = cooldownSeconds - difference.inSeconds;
    
    return remaining > 0 ? remaining : 0;
  }
  
  /// Obtém tempo restante do bloqueio de método
  int _getMethodBlockRemainingTime(String method) {
    final lastTime = _lastAttemptTime[method];
    if (lastTime == null) return 0;
    
    final now = DateTime.now();
    final difference = now.difference(lastTime);
    
    final remainingMinutes = _blockedCooldownMinutes - difference.inMinutes;
    final remainingSeconds = remainingMinutes * 60;
    
    return remainingSeconds > 0 ? remainingSeconds : 0;
  }
  
  /// Obtém tempo restante do bloqueio geral
  int _getGeneralBlockRemainingTime() {
    if (_generalBlockTime == null) return 0;
    
    final now = DateTime.now();
    final difference = now.difference(_generalBlockTime!);
    
    final remainingMinutes = _blockedCooldownMinutes - difference.inMinutes;
    final remainingSeconds = remainingMinutes * 60;
    
    return remainingSeconds > 0 ? remainingSeconds : 0;
  }
  
  // ========================================
  // 💾 PERSISTÊNCIA
  // ========================================
  
  /// Salva estado no storage
  void _saveState() {
    final state = {
      'attempts': _attempts,
      'lastAttemptTime': _lastAttemptTime.map((key, value) => 
        MapEntry(key, value?.toIso8601String())
      ),
      'generalBlockTime': _generalBlockTime?.toIso8601String(),
      'isGenerallyBlocked': _isGenerallyBlocked,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    AppStorage.saveAttemptControlState(state);
  }
  
  /// Carrega estado do storage
  Future<void> loadState() async {
    try {
      final state = AppStorage.getAttemptControlState();
      if (state != null) {
        _attempts['sms'] = state['attempts']['sms'] ?? 0;
        _attempts['email'] = state['attempts']['email'] ?? 0;
        
        _lastAttemptTime['sms'] = state['lastAttemptTime']['sms'] != null 
          ? DateTime.parse(state['lastAttemptTime']['sms']) 
          : null;
        _lastAttemptTime['email'] = state['lastAttemptTime']['email'] != null 
          ? DateTime.parse(state['lastAttemptTime']['email']) 
          : null;
        
        _generalBlockTime = state['generalBlockTime'] != null 
          ? DateTime.parse(state['generalBlockTime']) 
          : null;
        
        _isGenerallyBlocked = state['isGenerallyBlocked'] ?? false;
        
        print('🔍 DEBUG: [AttemptControlService] Estado carregado do storage');
      }
    } catch (e) {
      print('🔍 DEBUG: [AttemptControlService] Erro ao carregar estado: $e');
    }
  }
  
  // ========================================
  // 📊 ESTADO ATUAL
  // ========================================
  
  /// Obtém estado atual
  AttemptState _getCurrentState() {
    return AttemptState(
      smsAttempts: _attempts['sms'] ?? 0,
      emailAttempts: _attempts['email'] ?? 0,
      smsBlocked: isMethodBlocked('sms'),
      emailBlocked: isMethodBlocked('email'),
      generallyBlocked: isGenerallyBlocked,
      smsRemainingTime: getRemainingTime('sms'),
      emailRemainingTime: getRemainingTime('email'),
      generalBlockRemainingTime: getGeneralBlockRemainingTime(),
      canAttemptSms: canAttempt('sms'),
      canAttemptEmail: canAttempt('email'),
    );
  }
  
  // ========================================
  // 🧹 LIMPEZA
  // ========================================
  
  /// Limpa recursos
  void dispose() {
    _stateController.close();
  }
}

/// Estado das tentativas
class AttemptState {
  final int smsAttempts;
  final int emailAttempts;
  final bool smsBlocked;
  final bool emailBlocked;
  final bool generallyBlocked;
  final int smsRemainingTime;
  final int emailRemainingTime;
  final int generalBlockRemainingTime;
  final bool canAttemptSms;
  final bool canAttemptEmail;
  
  AttemptState({
    required this.smsAttempts,
    required this.emailAttempts,
    required this.smsBlocked,
    required this.emailBlocked,
    required this.generallyBlocked,
    required this.smsRemainingTime,
    required this.emailRemainingTime,
    required this.generalBlockRemainingTime,
    required this.canAttemptSms,
    required this.canAttemptEmail,
  });
  
  @override
  String toString() {
    return 'AttemptState(sms: $smsAttempts/$emailAttempts, smsBlocked: $smsBlocked, emailBlocked: $emailBlocked, generallyBlocked: $generallyBlocked)';
  }
}
