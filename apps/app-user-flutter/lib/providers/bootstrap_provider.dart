import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/tenant_config.dart';
import '../models/user_profile.dart';

/// Bootstrap Provider - manages tenant config and user bootstrap
class BootstrapProvider with ChangeNotifier {
  TenantConfig? _tenantConfig;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  TenantConfig? get tenantConfig => _tenantConfig;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Branding helpers
  String get appName => _tenantConfig?.branding.appName ?? 'Benefits App';
  String get primaryColor => _tenantConfig?.branding.primaryColor ?? '#1976d2';
  bool get isCardsEnabled => _tenantConfig?.modules.cards ?? true;
  bool get isPartnersEnabled => _tenantConfig?.modules.partners ?? true;
  bool get isExpensesEnabled => _tenantConfig?.modules.expenses ?? true;

  /// Load complete bootstrap data
  Future<bool> loadBootstrap(String token, String tenantSlug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load tenant config and user profile in parallel
      final results = await Future.wait([
        _loadTenantConfig(tenantSlug),
        _loadUserProfile(token),
      ]);

      _tenantConfig = results[0] as TenantConfig?;
      _userProfile = results[1] as UserProfile?;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load tenant configuration (public endpoint - no auth required)
  Future<TenantConfig?> _loadTenantConfig(String tenantSlug) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/public/tenants/$tenantSlug/config'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return TenantConfig.fromJson(json);
      } else {
        // Fallback to default config
        return TenantConfig.defaultConfig();
      }
    } catch (e) {
      debugPrint('Failed to load tenant config: $e');
      return TenantConfig.defaultConfig();
    }
  }

  /// Load user profile and preferences
  Future<UserProfile?> _loadUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserProfile.fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      return null;
    }
  }

  /// Check if user has access to a specific module
  bool hasModuleAccess(String moduleName) {
    if (_tenantConfig == null) return false;

    switch (moduleName) {
      case 'cards':
        return _tenantConfig!.modules.cards;
      case 'partners':
        return _tenantConfig!.modules.partners;
      case 'expenses':
        return _tenantConfig!.modules.expenses;
      case 'corporate':
        return _tenantConfig!.modules.corporateRequests;
      default:
        return true;
    }
  }

  /// Get wallet definition by type
  WalletDefinition? getWalletDefinition(String walletType) {
    return _tenantConfig?.walletDefinitions
        .where((wd) => wd.walletType == walletType)
        .firstOrNull;
  }

  /// Check if user can access a feature based on policies
  bool canAccessFeature(String feature, {String? walletType}) {
    if (_tenantConfig == null) return false;

    // Check policies
    for (final policy in _tenantConfig!.policies) {
      if (policy.policyType == 'REQUIREMENT') {
        // Check if user meets requirements
        // This would be more complex in real implementation
        continue;
      }
    }

    return true; // Default allow
  }

  /// Clear all data (logout)
  void clear() {
    _tenantConfig = null;
    _userProfile = null;
    _error = null;
    notifyListeners();
  }
}