import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Auth Provider - manages authentication state and security
class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  String? _token;
  String? _personId; // Canonical user ID (pid from JWT)
  String? _tenantId;
  List<String> _roles = [];
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;
  bool _privacyMode = false;
  bool _biometricEnabled = false;

  // Getters
  String? get token => _token;
  String? get personId => _personId;
  String? get tenantId => _tenantId;
  List<String> get roles => _roles;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get privacyMode => _privacyMode;
  bool get biometricEnabled => _biometricEnabled;

  // Role helpers
  bool get isPlatformOwner => _roles.contains('PLATFORM_OWNER');
  bool get isTenantOwner => _roles.contains('TENANT_OWNER');
  bool get isEmployerAdmin => _roles.contains('EMPLOYER_ADMIN');
  bool get isEmployerUser => _roles.contains('EMPLOYER_USER');
  bool get isUser => _roles.contains('USER');

  AuthProvider(this._secureStorage, this._localAuth) {
    _initialize();
  }

  /// Initialize provider - load stored auth state
  Future<void> _initialize() async {
    try {
      _token = await _secureStorage.read(key: 'auth_token');
      _personId = await _secureStorage.read(key: 'person_id');
      _tenantId = await _secureStorage.read(key: 'tenant_id');
      _privacyMode = await _secureStorage.read(key: 'privacy_mode') == 'true';
      _biometricEnabled = await _secureStorage.read(key: 'biometric_enabled') == 'true';

      final rolesJson = await _secureStorage.read(key: 'user_roles');
      if (rolesJson != null) {
        _roles = List<String>.from(jsonDecode(rolesJson));
      }

      if (_token != null && _personId != null) {
        // Try silent refresh
        await _silentRefresh();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// OIDC Login with PKCE
  Future<bool> login(String tenantSlug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real implementation, this would:
      // 1. Generate PKCE challenge
      // 2. Open browser for OIDC flow
      // 3. Handle callback and exchange code for tokens

      // For demo purposes, simulate login
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tenantSlug': tenantSlug,
          // PKCE and OIDC parameters would go here
        }),
      );

      if (response.statusCode == 200) {
        final authData = jsonDecode(response.body);

        _token = authData['token'];
        _personId = authData['personId']; // pid from JWT
        _tenantId = authData['tenantId'];
        _roles = List<String>.from(authData['roles'] ?? []);

        // Store securely
        await _secureStorage.write(key: 'auth_token', value: _token);
        await _secureStorage.write(key: 'person_id', value: _personId);
        await _secureStorage.write(key: 'tenant_id', value: _tenantId);
        await _secureStorage.write(key: 'user_roles', value: jsonEncode(_roles));

        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Silent token refresh
  Future<bool> _silentRefresh() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final refreshData = jsonDecode(response.body);
        _token = refreshData['token'];
        await _secureStorage.write(key: 'auth_token', value: _token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint
      if (_token != null) {
        await http.post(
          Uri.parse('http://localhost:8080/api/v1/auth/logout'),
          headers: {'Authorization': 'Bearer $_token'},
        );
      }
    } catch (e) {
      // Ignore logout errors
    }

    // Clear local data
    await _secureStorage.deleteAll();
    _token = null;
    _personId = null;
    _tenantId = null;
    _roles.clear();
    _isAuthenticated = false;
    _error = null;

    notifyListeners();
  }

  /// Toggle privacy mode (hide values)
  Future<void> togglePrivacyMode() async {
    _privacyMode = !_privacyMode;
    await _secureStorage.write(key: 'privacy_mode', value: _privacyMode.toString());
    notifyListeners();
  }

  /// Setup biometric authentication
  Future<bool> setupBiometric() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for app security',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        _biometricEnabled = true;
        await _secureStorage.write(key: 'biometric_enabled', value: 'true');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometric() async {
    if (!_biometricEnabled) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access sensitive features',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if biometrics are available
  Future<bool> canUseBiometric() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/auth/validate'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}