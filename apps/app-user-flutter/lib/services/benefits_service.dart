import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/benefit.dart';
import '../models/wallet.dart';
import '../models/expense.dart';

class BenefitsService {
  static const String baseUrl = 'http://10.0.2.2:8086'; // Android emulator localhost

  Future<List<Benefit>> getBenefits(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/benefits'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Benefit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load benefits');
    }
  }

  Future<Wallet> getWallet(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load wallet');
    }
  }

  Future<List<Expense>> getExpenses(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Expense> submitExpense(String token, Expense expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode == 201) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit expense');
    }
  }

  Future<Wallet> getWalletBalance(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/balance'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load wallet balance');
    }
  }
}