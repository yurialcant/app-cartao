import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TerminalProvider with ChangeNotifier {
  final ApiService api;
  bool _loading = false;
  String? _error;
  List<PosTransaction> _recent = [];

  TerminalProvider({required this.api});

  bool get loading => _loading;
  String? get error => _error;
  List<PosTransaction> get recent => _recent;

  Future<void> loadRecentTransactions(String terminalId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await api.getRecentTransactions(terminalId);
      _recent = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
