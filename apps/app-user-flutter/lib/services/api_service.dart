import 'package:http/http.dart' as http;
import 'dart:convert';

/// API Service - base service for API calls
class ApiService {
  final String baseUrl = 'http://localhost:8080';

  /// GET request
  Future<Map<String, dynamic>?> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('GET $endpoint failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error in GET $endpoint: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>?> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } else {
        throw Exception('POST $endpoint failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error in POST $endpoint: $e');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>?> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } else {
        throw Exception('PUT $endpoint failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error in PUT $endpoint: $e');
    }
  }

  /// DELETE request
  Future<bool> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      throw Exception('Network error in DELETE $endpoint: $e');
    }
  }

  /// Handle API errors consistently
  String handleApiError(dynamic error) {
    if (error is Exception) {
      final message = error.toString();

      // Try to extract meaningful error messages
      if (message.contains('INSUFFICIENT_FUNDS')) {
        return 'Saldo insuficiente para esta operação';
      } else if (message.contains('POLICY_DENIED')) {
        return 'Operação não permitida pela política';
      } else if (message.contains('MODULE_DISABLED')) {
        return 'Este recurso não está disponível';
      } else if (message.contains('INVALID_TOKEN')) {
        return 'Sessão expirada. Faça login novamente';
      } else if (message.contains('FORBIDDEN_SCOPE')) {
        return 'Você não tem permissão para esta operação';
      }

      return 'Erro na operação. Tente novamente';
    }

    return 'Erro desconhecido';
  }
}