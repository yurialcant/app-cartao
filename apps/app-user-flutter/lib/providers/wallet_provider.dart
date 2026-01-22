import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/wallet.dart';
import '../models/statement_entry.dart';

/// Wallet Provider - manages wallet operations and balances
class WalletProvider with ChangeNotifier {
  List<Wallet> _wallets = [];
  bool _isLoading = false;
  String? _error;
  Map<String, List<StatementEntry>> _statementCache = {};

  // Getters
  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user wallets
  Future<bool> loadWallets(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/wallets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _wallets = (json['wallets'] as List?)
            ?.map((e) => Wallet.fromJson(e))
            .toList() ?? [];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to load wallets: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get wallet by ID
  Wallet? getWalletById(String walletId) {
    return _wallets.where((w) => w.id == walletId).firstOrNull;
  }

  /// Get wallet details (with rules and policies)
  Future<WalletDetail?> getWalletDetail(String token, String walletId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/wallets/$walletId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WalletDetail.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Load statement for wallet
  Future<List<StatementEntry>> loadStatement(
    String token,
    String walletId, {
    int page = 1,
    int size = 20,
    String? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final cacheKey = '${walletId}_${page}_${size}_${filter}';

    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        if (filter != null) 'filter': filter,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final uri = Uri.parse('http://localhost:8080/api/v1/statement')
          .replace(queryParameters: {
        ...queryParams,
        'walletId': walletId,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final entries = (json['entries'] as List?)
            ?.map((e) => StatementEntry.fromJson(e))
            .toList() ?? [];

        _statementCache[cacheKey] = entries;
        return entries;
      } else {
        _error = 'Failed to load statement: ${response.statusCode}';
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      return [];
    }
  }

  /// Export statement
  Future<String?> exportStatement(
    String token,
    String walletId, {
    String format = 'CSV',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/statement/export'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'walletId': walletId,
          'format': format,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['jobId']; // Return job ID for tracking
      } else {
        _error = 'Export failed: ${response.statusCode}';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Export error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Check export status
  Future<ExportStatus?> checkExportStatus(String token, String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/exports/$jobId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ExportStatus.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh wallet data
  Future<void> refreshWallets(String token) async {
    await loadWallets(token);
  }
}