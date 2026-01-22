import 'package:flutter/material.dart';
import '../services/pos_service.dart';
import '../models/transaction.dart';
import '../models/terminal.dart';

class PosProvider with ChangeNotifier {
  Terminal? _terminal;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  double _currentAmount = 0.0;

  Terminal? get terminal => _terminal;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get currentAmount => _currentAmount;

  final PosService _posService = PosService();

  void setCurrentAmount(double amount) {
    _currentAmount = amount;
    notifyListeners();
  }

  Future<void> loadTerminal(String terminalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _terminal = await _posService.getTerminal(terminalId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadTransactions(String terminalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _posService.getTerminalTransactions(terminalId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> processPayment(String terminalId, double amount, String paymentMethod) async {
    try {
      final result = await _posService.processPayment(terminalId, amount, paymentMethod);
      if (result['approved'] == true) {
        // Add to transactions list
        final transaction = Transaction(
          id: result['transactionId'],
          amount: amount,
          paymentMethod: paymentMethod,
          status: 'APPROVED',
          timestamp: DateTime.now(),
        );
        _transactions.insert(0, transaction);
        _currentAmount = 0.0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  void clearCurrentAmount() {
    _currentAmount = 0.0;
    notifyListeners();
  }
}