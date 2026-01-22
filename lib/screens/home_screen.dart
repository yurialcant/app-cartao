import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/bootstrap_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/card_provider.dart';
import '../providers/notification_provider.dart';
import '../models/tenant_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    if (authProvider.token != null) {
      await Future.wait([
        walletProvider.loadWallets(authProvider.token!),
        cardProvider.loadCards(authProvider.token!),
        notificationProvider.loadNotifications(authProvider.token!),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bootstrapProvider = Provider.of<BootstrapProvider>(context);
    final tenantConfig = bootstrapProvider.tenantConfig;

    return Scaffold(
      appBar: _buildAppBar(authProvider, bootstrapProvider),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: tenantConfig != null
            ? _buildDynamicHome(tenantConfig)
            : _buildFallbackHome(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AuthProvider authProvider,
    BootstrapProvider bootstrapProvider,
  ) {
    final userProfile = bootstrapProvider.userProfile;
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${userProfile?.displayName ?? 'Usuário'}',
            style: const TextStyle(fontSize: 16),
          ),
          if (userProfile?.employerName != null)
            Text(
              userProfile!.employerName!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      actions: [
        // Notifications
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.go('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Privacy mode toggle
        IconButton(
          icon: Icon(
            authProvider.privacyMode ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => authProvider.togglePrivacyMode(),
        ),
        // Profile menu
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.go('/profile');
                break;
              case 'settings':
                context.go('/settings');
                break;
              case 'support':
                context.go('/support');
                break;
              case 'logout':
                authProvider.logout();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text('Perfil')),
            const PopupMenuItem(value: 'settings', child: Text('Configurações')),
            const PopupMenuItem(value: 'support', child: Text('Ajuda')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'logout', child: Text('Sair')),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicHome(TenantConfig config) {
    final blocks = config.uiComposition.blocks;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Build blocks dynamically
        for (final block in blocks)
          _buildHomeBlock(block),

        const SizedBox(height: 16),

        // "Ver todos" button for quick actions
        Center(
          child: TextButton(
            onPressed: () => _showAllShortcuts(context),
            child: const Text('Ver todos os atalhos'),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeBlock(HomeBlock block) {
    switch (block.type) {
      case 'wallet_summary':
        return _buildWalletSummaryBlock();
      case 'quick_actions':
        return _buildQuickActionsBlock();
      case 'notifications_preview':
        return _buildNotificationsPreviewBlock();
      default:
        return const SizedBox.shrink(); // Ignore unknown blocks
    }
  }

  Widget _buildWalletSummaryBlock() {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallets = walletProvider.wallets;
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seus Saldos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (wallets.isNotEmpty)
              ...wallets.take(2).map((wallet) => ListTile(
                leading: Icon(_getWalletIcon(wallet.iconKey)),
                title: Text(wallet.displayName),
                subtitle: Text(
                  authProvider.privacyMode
                      ? '••••••'
                      : 'R\$ ${wallet.availableAmount.toStringAsFixed(2)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/wallets/${wallet.id}'),
              ))
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum saldo disponível'),
                ),
              ),
            if (wallets.length > 2)
              Center(
                child: TextButton(
                  onPressed: () => context.go('/wallets'),
                  child: const Text('Ver todos os saldos'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsBlock() {
    final bootstrapProvider = Provider.of<BootstrapProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acesso Rápido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickActionItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Carteira',
                  enabled: true,
                  onTap: () => context.go('/wallets'),
                ),
                _buildQuickActionItem(
                  icon: Icons.receipt_long,
                  label: 'Extrato',
                  enabled: true,
                  onTap: () => context.go('/statement'),
                ),
                _buildQuickActionItem(
                  icon: Icons.credit_card,
                  label: 'Cartões',
                  enabled: bootstrapProvider.isCardsEnabled,
                  onTap: () => context.go('/cards'),
                ),
                _buildQuickActionItem(
                  icon: Icons.verified_user,
                  label: 'Código',
                  enabled: bootstrapProvider.isVerificationCodeEnabled,
                  onTap: () => context.go('/verification-code'),
                ),
                _buildQuickActionItem(
                  icon: Icons.business,
                  label: 'Parceiros',
                  enabled: bootstrapProvider.isPartnersEnabled,
                  onTap: () => context.go('/partners'),
                ),
                _buildQuickActionItem(
                  icon: Icons.request_page,
                  label: 'Despesas',
                  enabled: bootstrapProvider.isExpensesEnabled,
                  onTap: () => context.go('/expense'),
                ),
                _buildQuickActionItem(
                  icon: Icons.support,
                  label: 'Ajuda',
                  enabled: true,
                  onTap: () => context.go('/support'),
                ),
                _buildQuickActionItem(
                  icon: Icons.more_horiz,
                  label: 'Mais',
                  enabled: true,
                  onTap: () => _showAllShortcuts(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsPreviewBlock() {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications.take(3);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/notifications'),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (notifications.isNotEmpty)
              ...notifications.map((notification) => ListTile(
                leading: Icon(_getNotificationIcon(notification.type)),
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: notification.isRead
                    ? null
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: () => context.go('/notifications'),
              ))
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma notificação'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackHome() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Carregando...'),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: enabled ? Colors.blue.shade50 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: enabled ? Colors.blue : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0, // Home is always selected
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            context.go('/wallets');
            break;
          case 2:
            context.go('/statement');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Carteira',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Extrato',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _showAllShortcuts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Todos os Atalhos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Add all available shortcuts here
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Carteira'),
              onTap: () {
                Navigator.pop(context);
                context.go('/wallets');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Extrato'),
              onTap: () {
                Navigator.pop(context);
                context.go('/statement');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Cartões'),
              onTap: () {
                Navigator.pop(context);
                context.go('/cards');
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Código de Verificação'),
              onTap: () {
                Navigator.pop(context);
                context.go('/verification-code');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Parceiros'),
              onTap: () {
                Navigator.pop(context);
                context.go('/partners');
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_page),
              title: const Text('Despesas Corporativas'),
              onTap: () {
                Navigator.pop(context);
                context.go('/expense');
              },
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Ajuda e Suporte'),
              onTap: () {
                Navigator.pop(context);
                context.go('/support');
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWalletIcon(String iconKey) {
    switch (iconKey) {
      case 'meal':
        return Icons.restaurant;
      case 'food':
        return Icons.fastfood;
      case 'fuel':
        return Icons.local_gas_station;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.account_balance_wallet;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'PAYMENT':
        return Icons.payment;
      case 'CREDIT':
        return Icons.add_circle;
      case 'EXPENSE':
        return Icons.receipt;
      default:
        return Icons.notifications;
    }
  }
}