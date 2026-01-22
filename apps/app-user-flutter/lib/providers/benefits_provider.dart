import 'package:flutter/material.dart';
import '../services/benefits_service.dart';
import '../models/benefit.dart';
import '../models/wallet.dart';
import '../models/expense.dart';

class BenefitsProvider with ChangeNotifier {
  List<Benefit> _benefits = [];
  Wallet? _wallet;
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Benefit> get benefits => _benefits;
  Wallet? get wallet => _wallet;
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  final BenefitsService _benefitsService = BenefitsService();

  Future<void> loadBenefits(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _benefits = await _benefitsService.getBenefits(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadWallet(String token) async {
    try {
      _wallet = await _benefitsService.getWallet(token);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadExpenses(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _benefitsService.getExpenses(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitExpense(String token, Expense expense) async {
    try {
      final newExpense = await _benefitsService.submitExpense(token, expense);
      _expenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshData(String token) async {
    await Future.wait([
      loadBenefits(token),
      loadWallet(token),
      loadExpenses(token),
    ]);
  }
}