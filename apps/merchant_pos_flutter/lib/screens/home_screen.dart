import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant POS')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildActionCard(
            context,
            'Cobrar QR',
            Icons.qr_code,
            Colors.blue,
            () => Navigator.pushNamed(context, '/qr-charge'),
          ),
          _buildActionCard(
            context,
            'Cobrar Cartão',
            Icons.credit_card,
            Colors.green,
            () => Navigator.pushNamed(context, '/card-charge'),
          ),
          _buildActionCard(
            context,
            'Fechar Caixa',
            Icons.calculate,
            Colors.orange,
            () => Navigator.pushNamed(context, '/shift'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}
