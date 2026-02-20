import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/card.dart';

/// Card Provider - manages card operations
class CardProvider with ChangeNotifier {
  List<Card> _cards = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user cards
  Future<bool> loadCards(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/cards'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _cards = (json['cards'] as List?)
            ?.map((e) => Card.fromJson(e))
            .toList() ?? [];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to load cards: ${response.statusCode}';
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

  /// Create virtual card
  Future<Card?> createVirtualCard(String token, String walletId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/cards/virtual'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'walletId': walletId,
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final newCard = Card.fromJson(json);

        // Add to local list
        _cards.add(newCard);
        notifyListeners();

        return newCard;
      } else {
        _error = 'Failed to create card: ${response.statusCode}';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Freeze/unfreeze card
  Future<bool> toggleCardFreeze(String token, String cardId, bool freeze) async {
    try {
      final endpoint = freeze ? 'freeze' : 'unfreeze';
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/v1/cards/$cardId/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update local card
        final index = _cards.indexWhere((c) => c.id == cardId);
        if (index != -1) {
          final updatedCard = _cards[index].copyWith(
            status: freeze ? 'FROZEN' : 'ACTIVE',
          );
          _cards[index] = updatedCard;
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to ${endpoint} card: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel card
  Future<bool> cancelCard(String token, String cardId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/v1/cards/$cardId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local list
        _cards.removeWhere((c) => c.id == cardId);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to cancel card: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get physical cards
  List<Card> get physicalCards => _cards.where((c) => c.type == 'PHYSICAL').toList();

  /// Get virtual cards
  List<Card> get virtualCards => _cards.where((c) => c.type == 'VIRTUAL').toList();

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}