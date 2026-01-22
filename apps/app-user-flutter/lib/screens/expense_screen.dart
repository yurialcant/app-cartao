import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/benefits_provider.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Meals';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Meals',
    'Transportation',
    'Accommodation',
    'Office Supplies',
    'Training',
    'Medical',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final benefitsProvider = Provider.of<BenefitsProvider>(context, listen: false);

    if (authProvider.token != null) {
      await benefitsProvider.loadExpenses(authProvider.token!);
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final benefitsProvider = Provider.of<BenefitsProvider>(context, listen: false);

      final expense = Expense(
        personId: authProvider.user!.id,
        employerId: 'employer-id', // TODO: Get from user context
        amount: double.parse(_amountController.text),
        currency: 'BRL',
        description: _descriptionController.text,
        category: _selectedCategory,
        expenseDate: _selectedDate,
      );

      await benefitsProvider.submitExpense(authProvider.token!, expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense submitted successfully!')),
        );
        _clearForm();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _selectedCategory = 'Meals';
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final benefitsProvider = Provider.of<BenefitsProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expenses'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Expenses'),
              Tab(text: 'Submit New'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Expenses Tab
            benefitsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : benefitsProvider.expenses.isEmpty
                    ? const Center(child: Text('No expenses found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: benefitsProvider.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = benefitsProvider.expenses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(expense.description),
                              subtitle: Text(
                                '${expense.category} • ${expense.getFormattedAmount()}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(expense.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  expense.status,
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

            // Submit New Expense Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Expense Date'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitExpense,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Submit Expense'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'REIMBURSED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}