import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/notification.dart';

/// Notification Provider - manages user notifications
class NotificationProvider with ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Load user notifications
  Future<bool> loadNotifications(String token, {int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/notifications?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _notifications = (json['notifications'] as List?)
            ?.map((e) => Notification.fromJson(e))
            .toList() ?? [];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to load notifications: ${response.statusCode}';
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

  /// Mark notification as read
  Future<bool> markAsRead(String token, String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/v1/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = _notifications[index].copyWith(isRead: true);
          _notifications[index] = updatedNotification;
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to mark as read: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(String token) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/v1/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update all local notifications
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to mark all as read: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get notifications by type
  List<Notification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<Notification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();

  /// Get recent notifications (last 7 days)
  List<Notification> get recentNotifications {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.createdAt.isAfter(sevenDaysAgo)).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}