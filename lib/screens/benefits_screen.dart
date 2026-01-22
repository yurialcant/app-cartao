import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/benefits_provider.dart';
import '../providers/auth_provider.dart';

class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBenefits();
  }

  Future<void> _loadBenefits() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final benefitsProvider = Provider.of<BenefitsProvider>(context, listen: false);

    if (authProvider.token != null) {
      await benefitsProvider.loadBenefits(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final benefitsProvider = Provider.of<BenefitsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Benefits'),
      ),
      body: benefitsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : benefitsProvider.benefits.isEmpty
              ? const Center(
                  child: Text('No benefits available'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: benefitsProvider.benefits.length,
                  itemBuilder: (context, index) {
                    final benefit = benefitsProvider.benefits[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    benefit.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: benefit.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    benefit.isActive ? 'Active' : 'Inactive',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              benefit.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Category: ${benefit.category}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  benefit.getFormattedAmount(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}