import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/terminal_provider.dart';

class PosScreenScreen extends StatefulWidget {
  const PosScreenScreen({Key? key}) : super(key: key);

  @override
  State<PosScreenScreen> createState() => _PosScreenScreenState();
}

class _PosScreenScreenState extends State<PosScreenScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPaymentMethod = 'CARD';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TerminalProvider>().loadRecentTransactions();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _processSale() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: R\$ ${amount.toStringAsFixed(2)}'),
            Text('Method: $_selectedPaymentMethod'),
            const SizedBox(height: 16),
            const Text('Process this transaction?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTransaction(amount);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _completeTransaction(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction of R\$ ${amount.toStringAsFixed(2)} processed!'),
        backgroundColor: Colors.green,
      ),
    );
    _amountController.clear();
    _descriptionController.clear();
    context.read<TerminalProvider>().loadRecentTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Terminal'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Sale Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Sale',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount (R\$)',
                        prefixIcon: const Icon(Icons.money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value ?? 'CARD');
                      },
                      items: ['CARD', 'PIX', 'CASH']
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _processSale,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Process Sale'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<TerminalProvider>(
              builder: (context, terminalProvider, _) {
                if (terminalProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = terminalProvider.recentTransactions ?? [];
                if (transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No recent transactions'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _buildTransactionCard(tx);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(PosTransaction tx) {
    final statusColor = _getStatusColor(tx.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.receipt, color: statusColor),
        ),
        title: Text('R\$ ${tx.amount.toStringAsFixed(2)}'),
        subtitle: Text(
          '${tx.method} • ${DateTime.parse(tx.timestamp).toLocal().toString().split('.')[0]}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Chip(
          label: Text(tx.status),
          backgroundColor: statusColor.withOpacity(0.2),
          labelStyle: TextStyle(color: statusColor),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
