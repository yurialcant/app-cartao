import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado do dashboard simplificado
class DashboardState {
  final bool isLoading;
  final double? balance;
  final List<Map<String, dynamic>> recentTransactions;
  final int notificationCount;
  final String? error;
  final bool isBalanceVisible;

  const DashboardState({
    this.isLoading = false,
    this.balance,
    this.recentTransactions = const [],
    this.notificationCount = 0,
    this.error,
    this.isBalanceVisible = true,
  });

  DashboardState copyWith({
    bool? isLoading,
    double? balance,
    List<Map<String, dynamic>>? recentTransactions,
    int? notificationCount,
    String? error,
    bool? isBalanceVisible,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      balance: balance ?? this.balance,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      notificationCount: notificationCount ?? this.notificationCount,
      error: error ?? this.error,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }
}

/// Provider do dashboard simplificado
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState()) {
    _loadDashboard();
  }

  /// Carrega os dados do dashboard (mockados)
  Future<void> _loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simula delay de rede
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Dados mockados
      const mockBalance = 1250.75;
      final mockTransactions = [
        {
          'id': '1',
          'title': 'Transferência recebida',
          'amount': 500.00,
          'type': 'credit',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'id': '2',
          'title': 'Pagamento PIX',
          'amount': -150.25,
          'type': 'debit',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '3',
          'title': 'Depósito',
          'amount': 1000.00,
          'type': 'credit',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
      ];
      const mockNotifications = 3;

      state = state.copyWith(
        isLoading: false,
        balance: mockBalance,
        recentTransactions: mockTransactions,
        notificationCount: mockNotifications,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dashboard: $e',
      );
    }
  }

  /// Alterna visibilidade do saldo
  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceVisible: !state.isBalanceVisible);
  }

  /// Recarrega os dados
  Future<void> refresh() async {
    await _loadDashboard();
  }

  /// Adiciona saldo
  Future<void> addBalance(double amount) async {
    try {
      final currentBalance = state.balance ?? 0.0;
      final newBalance = currentBalance + amount;
      state = state.copyWith(balance: newBalance);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao adicionar saldo: $e');
    }
  }
}

/// Provider principal do dashboard
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
