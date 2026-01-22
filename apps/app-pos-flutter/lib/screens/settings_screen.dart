import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pos_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final posProvider = Provider.of<PosProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Terminal ID'),
            subtitle: Text(authProvider.user?.id ?? 'Not available'),
            leading: const Icon(Icons.point_of_sale),
          ),
          if (posProvider.terminal != null) ...[
            const Divider(),
            ListTile(
              title: const Text('Terminal Status'),
              subtitle: Text(posProvider.terminal!.status),
              leading: Icon(
                posProvider.terminal!.isActive() ? Icons.check_circle : Icons.error,
                color: posProvider.terminal!.isActive() ? Colors.green : Colors.red,
              ),
            ),
            ListTile(
              title: const Text('Location'),
              subtitle: Text(posProvider.terminal!.locationName),
              leading: const Icon(Icons.location_on),
            ),
            ListTile(
              title: const Text('Capabilities'),
              subtitle: Text(posProvider.terminal!.capabilities.join(', ')),
              leading: const Icon(Icons.settings),
            ),
          ],
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('POS Benefits App v1.0.0'),
            leading: const Icon(Icons.info),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About POS Benefits'),
        content: const Text(
          'Mobile POS application for the Benefits Platform.\n\n'
          'Supports credit cards, debit cards, contactless payments, and QR codes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}