import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Sistema de armazenamento local com cache e persistência
class AppStorage {
  static const String _userKey = 'user_data';
  static const String _authTokenKey = 'auth_token';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _lockoutTimeKey = 'lockout_time';
  static const String _permanentLockKey = 'permanent_lock';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _firstAccessKey = 'first_access';
  static const String _cacheExpiryKey = 'cache_expiry';
  
  static const Duration _cacheDuration = Duration(hours: 1);
  static const Duration _sessionTimeout = Duration(hours: 24);
  
  // ========================================
  // 🔐 ARMAZENAMENTO SEGURO
  // ========================================
  
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Salva dados sensíveis de forma segura
  static Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Recupera dados sensíveis
  static Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Remove dados sensíveis
  static Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  // ========================================
  // 💾 ARMAZENAMENTO LOCAL
  // ========================================
  
  static SharedPreferences? _prefs;
  static bool _isInitializing = false;
  
  /// Inicializa o storage
  static Future<void> init() async {
    if (_isInitializing) {
      // Aguarda se já estiver inicializando
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return;
    }
    
    if (_prefs != null) return;
    
    _isInitializing = true;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      print('🔍 DEBUG: [AppStorage] Inicializado com sucesso');
    } catch (e) {
      print('🔍 DEBUG: [AppStorage] Erro na inicialização: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }
  
  /// Garante que o storage está inicializado
  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
  
  /// Salva dados localmente
  static Future<bool> saveLocal(String key, dynamic value) async {
    await _ensureInitialized();
    
    if (value is String) {
      return await _prefs!.setString(key, value);
    } else if (value is int) {
      return await _prefs!.setInt(key, value);
    } else if (value is bool) {
      return await _prefs!.setBool(key, value);
    } else if (value is double) {
      return await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      return await _prefs!.setStringList(key, value);
    } else {
      // Para objetos complexos, converte para JSON
      return await _prefs!.setString(key, jsonEncode(value));
    }
  }
  
  /// Recupera dados locais
  static T? getLocal<T>(String key) {
    if (_prefs == null) {
      print('🔍 DEBUG: [AppStorage] _prefs é null, retornando null');
      return null;
    }
    
    if (T == String) {
      return _prefs!.getString(key) as T?;
    } else if (T == int) {
      return _prefs!.getInt(key) as T?;
    } else if (T == bool) {
      return _prefs!.getBool(key) as T?;
    } else if (T == double) {
      return _prefs!.getDouble(key) as T?;
    } else if (T == List<String>) {
      return _prefs!.getStringList(key) as T?;
    } else {
      // Para objetos complexos, tenta fazer parse do JSON
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        try {
          return jsonDecode(jsonString) as T?;
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }
  
  /// Remove dados locais
  static Future<bool> removeLocal(String key) async {
    await _ensureInitialized();
    return await _prefs!.remove(key);
  }
  
  /// Limpa todos os dados locais
  static Future<bool> clearLocal() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }
  
  // ========================================
  // 👤 DADOS DO USUÁRIO
  // ========================================
  
  /// Salva dados do usuário
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await saveLocal(_userKey, userData);
    await saveLocal(_cacheExpiryKey, DateTime.now().add(_cacheDuration).toIso8601String());
  }
  
  /// Recupera dados do usuário
  static Map<String, dynamic>? getUser() {
    if (_prefs == null) {
      print('🔍 DEBUG: [AppStorage] _prefs é null, retornando null');
      return null;
    }
    
    final userData = getLocal<Map<String, dynamic>>(_userKey);
    final expiryString = getLocal<String>(_cacheExpiryKey);
    
    print('🔍 DEBUG: [AppStorage] getUser() - userData: $userData, expiry: $expiryString');
    
    if (userData != null && expiryString != null) {
      try {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isBefore(expiry)) {
          print('🔍 DEBUG: [AppStorage] Usuário encontrado e cache válido');
          return userData;
        } else {
          // Cache expirado, remove dados
          print('🔍 DEBUG: [AppStorage] Cache expirado, removendo dados');
          removeLocal(_userKey);
          removeLocal(_cacheExpiryKey);
        }
      } catch (e) {
        // Se erro no parse, remove dados corrompidos
        print('🔍 DEBUG: [AppStorage] Erro no parse da data, removendo dados: $e');
        removeLocal(_userKey);
        removeLocal(_cacheExpiryKey);
      }
    }
    
    print('🔍 DEBUG: [AppStorage] Nenhum usuário encontrado');
    return null;
  }
  
  /// Remove dados do usuário
  static Future<void> clearUser() async {
    await removeLocal(_userKey);
    await removeLocal(_cacheExpiryKey);
  }
  
  // ========================================
  // 🔑 TOKEN DE AUTENTICAÇÃO
  // ========================================
  
  /// Salva token de autenticação
  static Future<void> saveAuthToken(String token) async {
    await saveSecure(_authTokenKey, token);
  }
  
  /// Recupera token de autenticação
  static Future<String?> getAuthToken() async {
    return await getSecure(_authTokenKey);
  }
  
  /// Remove token de autenticação
  static Future<void> clearAuthToken() async {
    await removeSecure(_authTokenKey);
  }
  
  // ========================================
  // 🔒 CONTROLE DE TENTATIVAS DE LOGIN
  // ========================================
  
  /// Incrementa tentativas de login
  static Future<void> incrementLoginAttempts() async {
    final attempts = getLocal<int>(_loginAttemptsKey) ?? 0;
    await saveLocal(_loginAttemptsKey, attempts + 1);
  }
  
  /// Recupera tentativas de login
  static int getLoginAttempts() {
    return getLocal<int>(_loginAttemptsKey) ?? 0;
  }
  
  /// Reseta tentativas de login
  static Future<void> resetLoginAttempts() async {
    await saveLocal(_loginAttemptsKey, 0);
  }
  
  /// Salva tempo de bloqueio
  static Future<void> saveLockoutTime(DateTime lockoutTime) async {
    await saveLocal(_lockoutTimeKey, lockoutTime.toIso8601String());
  }
  
  /// Recupera tempo de bloqueio
  static DateTime? getLockoutTime() {
    final lockoutString = getLocal<String>(_lockoutTimeKey);
    if (lockoutString != null) {
      try {
        return DateTime.parse(lockoutString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// Verifica se a conta está bloqueada
  static bool isAccountLocked() {
    final lockoutTime = getLockoutTime();
    if (lockoutTime != null) {
      final now = DateTime.now();
      final difference = now.difference(lockoutTime);
      return difference.inMinutes < 10;
    }
    return false;
  }
  
  /// Verifica se a conta está bloqueada permanentemente
  static bool isAccountPermanentlyLocked() {
    return getLocal<bool>(_permanentLockKey) ?? false;
  }
  
  /// Bloqueia conta permanentemente
  static Future<void> lockAccountPermanently() async {
    await saveLocal(_permanentLockKey, true);
  }
  
  /// Desbloqueia conta
  static Future<void> unlockAccount() async {
    await removeLocal(_lockoutTimeKey);
    await removeLocal(_permanentLockKey);
    await resetLoginAttempts();
  }
  
  // ========================================
  // 📱 CONFIGURAÇÕES DE BIOMETRIA
  // ========================================
  
  /// Salva preferência de biometria
  static Future<void> setBiometricEnabled(bool enabled) async {
    await saveLocal(_biometricEnabledKey, enabled);
  }
  
  /// Verifica se biometria está habilitada
  static bool isBiometricEnabled() {
    return getLocal<bool>(_biometricEnabledKey) ?? false;
  }
  
  // ========================================
  // 📋 TERMOS DE USO
  // ========================================
  
  /// Salva aceitação dos termos
  static Future<void> setTermsAccepted(bool accepted) async {
    await saveLocal(_termsAcceptedKey, accepted);
  }
  
  /// Verifica se termos foram aceitos
  static bool areTermsAccepted() {
    return getLocal<bool>(_termsAcceptedKey) ?? false;
  }
  
  // ========================================
  // 🧪 MODO TESTE - LIMPA TUDO
  // ========================================
  
  /// Limpa todo o storage (usado para logout e modo teste)
  static Future<void> clearAll() async {
    print('🔍 DEBUG: [AppStorage] Limpando todo o storage');
    
    try {
      // Limpa dados locais
      if (_prefs != null) {
        await _prefs!.clear();
        print('🔍 DEBUG: [AppStorage] Dados locais limpos');
      }
      
      // Limpa dados seguros
      await clearAuthToken();
      await clearUser();
      
      // Limpa variáveis de estado
      _prefs = null;
      
      print('🔍 DEBUG: [AppStorage] Storage limpo com sucesso');
    } catch (e) {
      print('🔍 DEBUG: [AppStorage] Erro ao limpar storage: $e');
      // Mesmo com erro, tenta limpar o que for possível
      _prefs = null;
    }
  }
  
  /// Limpa dados de autenticação (token e usuário)
  static Future<void> clearAuthData() async {
    await clearAuthToken();
    await clearUser();
    print('🔍 DEBUG: [AppStorage] Dados de autenticação limpos');
  }
  
  // ========================================
  // 🆕 PRIMEIRO ACESSO
  // ========================================
  
  /// Salva status de primeiro acesso
  static Future<void> setFirstAccess(bool isFirst) async {
    await saveLocal(_firstAccessKey, isFirst);
  }
  
  /// Verifica se é primeiro acesso
  static bool isFirstAccess() {
    return getLocal<bool>(_firstAccessKey) ?? true;
  }
  
  // ========================================
  // 🧹 LIMPEZA E MANUTENÇÃO
  // ========================================
  
  /// Verifica se há dados em cache
  static bool hasCachedData() {
    return getUser() != null;
  }
  
  /// Força expiração do cache
  static Future<void> expireCache() async {
    await removeLocal(_cacheExpiryKey);
  }
  
  /// Verifica se o storage está inicializado
  static bool get isInitialized => _prefs != null;
}
