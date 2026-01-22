import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../providers/auth_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final posProvider = Provider.of<PosProvider>(context, listen: false);

    if (authProvider.user != null) {
      await posProvider.loadTransactions(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<PosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: posProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : posProvider.transactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = posProvider.transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(transaction.getFormattedAmount()),
                          subtitle: Text(
                            '${transaction.paymentMethod.replaceAll('_', ' ')} • ${transaction.timestamp.toString().substring(0, 16)}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.isApproved()
                                  ? Colors.green
                                  : transaction.isPending()
                                      ? Colors.orange
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              transaction.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}