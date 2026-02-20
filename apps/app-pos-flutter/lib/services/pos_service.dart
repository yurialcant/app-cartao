import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/terminal.dart';

class PosService {
  static const String baseUrl = 'http://10.0.2.2:8086'; // Android emulator localhost

  Future<Terminal> getTerminal(String terminalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/terminals/$terminalId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Terminal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load terminal');
    }
  }

  Future<List<Transaction>> getTerminalTransactions(String terminalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/terminals/$terminalId/transactions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<Map<String, dynamic>> processPayment(String terminalId, double amount, String paymentMethod) async {
    final response = await http.post(
      Uri.parse('$baseUrl/terminals/$terminalId/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'paymentMethod': paymentMethod,
        'terminalId': terminalId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment processing failed');
    }
  }

  Future<void> recordTerminalPing(String terminalId) async {
    await http.post(
      Uri.parse('$baseUrl/terminals/$terminalId/ping'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Map<String, dynamic>> getTerminalStats(String terminalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/terminals/$terminalId/stats'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load terminal stats');
    }
  }
}