import 'package:http/http.dart' as http;
import 'dart:convert';

/// Auth Service - handles authentication API calls
class AuthService {
  /// Login with OIDC PKCE flow
  Future<Map<String, dynamic>?> login(String tenantSlug) async {
    try {
      // In a real implementation, this would:
      // 1. Generate PKCE challenge
      // 2. Redirect to OIDC provider
      // 3. Handle callback and exchange code for tokens

      // For demo purposes, simulate login
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tenantSlug': tenantSlug,
          // PKCE parameters would be included here
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
  }

  /// Refresh token
  Future<Map<String, dynamic>?> refreshToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('http://localhost:8080/api/v1/auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      // Ignore logout errors
    }
  }

  /// Validate token
  Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/auth/validate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get verification code for web login
  Future<String?> getVerificationCode(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/verification-code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['code'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Refresh verification code
  Future<String?> refreshVerificationCode(String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/verification-code/refresh'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['code'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}