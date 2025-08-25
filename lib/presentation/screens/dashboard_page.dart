import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/app_storage.dart';
import '../../core/routing/route_paths.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (isAvailable && isDeviceSupported) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        
        setState(() {
          _isBiometricAvailable = availableBiometrics.isNotEmpty;
          _availableBiometrics = availableBiometrics;
        });
      }
    } on PlatformException catch (e) {
      print('Erro ao verificar biometria: $e');
    }
  }
  
  /// Obtém o nome do usuário logado
  String _getUserName() {
    try {
      final user = AppStorage.getUser();
      if (user != null && user['name'] != null) {
        final fullName = user['name'] as String;
        // Retorna apenas o primeiro nome
        return fullName.split(' ').first;
      }
    } catch (e) {
      print('Erro ao obter nome do usuário: $e');
    }
    return 'Usuário';
  }
  
  /// Obtém as iniciais do usuário para o avatar
  String _getUserInitials() {
    try {
      final user = AppStorage.getUser();
      if (user != null && user['name'] != null) {
        final fullName = user['name'] as String;
        final names = fullName.split(' ');
        if (names.length >= 2) {
          return '${names[0][0]}${names[1][0]}'.toUpperCase();
        } else if (names.length == 1) {
          return names[0][0].toUpperCase();
        }
      }
    } catch (e) {
      print('Erro ao obter iniciais do usuário: $e');
    }
    return 'U';
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirme sua identidade para acessar o app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Biometria autenticada com sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticação biométrica realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Usuário cancelou ou falhou na autenticação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticação biométrica cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na autenticação: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Faz logout do usuário
  void _logout() async {
    print('🔍 DEBUG: [DashboardPage] Logout solicitado');
    
    // Limpa todo o storage
    await AppStorage.clearAll();
    
    print('🔍 DEBUG: [DashboardPage] Storage limpo, navegando para login');
    
    // Navega para a tela de login (não welcome)
    if (context.mounted) {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildServicesTab(),
          _buildTransactionsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Card de saldo
            _buildBalanceCard(),
            
            const SizedBox(height: 24),
            
            // Ações rápidas
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // Transações recentes
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1E40AF),
            child: Text(
              _getUserInitials(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${_getUserName()}!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Text(
                  'Bem-vindo de volta',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          // Botão de logout
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF666666),
              size: 24,
            ),
            tooltip: 'Sair',
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo disponível',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.visibility,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'R\$ 2.450,00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conta: 1234-5',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: FontAwesomeIcons.pix,
                label: 'Pix',
                color: const Color(0xFF10B981),
                onTap: _showPixDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.swap_horiz,
                label: 'Transferir',
                color: const Color(0xFF3B82F6),
                onTap: _showTransferDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.qr_code_scanner,
                label: 'QR Code',
                color: const Color(0xFF8B5CF6),
                onTap: _showQRCodeDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.credit_card,
                label: 'Cartão',
                color: const Color(0xFFF59E0B),
                onTap: _showCardDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPixDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pix'),
        content: const Text('Funcionalidade de Pix será implementada em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transferência'),
        content: const Text('Funcionalidade de transferência será implementada em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: const Text('Funcionalidade de QR Code será implementada em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cartão'),
        content: const Text('Funcionalidade de cartão será implementada em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transações recentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Vai para aba de transações
                });
              },
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          icon: Icons.shopping_cart,
          title: 'Supermercado ABC',
          subtitle: 'Hoje, 14:30',
          amount: '-R\$ 85,50',
          isExpense: true,
        ),
        _buildTransactionItem(
          icon: Icons.account_balance,
          title: 'Depósito',
          subtitle: 'Ontem, 09:15',
          amount: '+R\$ 500,00',
          isExpense: false,
        ),
        _buildTransactionItem(
          icon: FontAwesomeIcons.pix,
          title: 'Pix recebido',
          subtitle: 'Ontem, 16:45',
          amount: '+R\$ 120,00',
          isExpense: false,
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isExpense ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Serviços',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    icon: Icons.payment,
                    title: 'Pagamentos',
                    subtitle: 'Contas e boletos',
                    color: const Color(0xFF10B981),
                  ),
                  _buildServiceCard(
                    icon: Icons.credit_card,
                    title: 'Cartão virtual',
                    subtitle: 'Criar cartão temporário',
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildServiceCard(
                    icon: Icons.savings,
                    title: 'Investimentos',
                    subtitle: 'Aplicar dinheiro',
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildServiceCard(
                    icon: Icons.help_outline,
                    title: 'Suporte',
                    subtitle: 'Fale conosco',
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Todas as transações',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 20, // Simula 20 transações
                itemBuilder: (context, index) {
                  return _buildTransactionItem(
                    icon: index % 3 == 0 ? Icons.shopping_cart : 
                          index % 3 == 1 ? FontAwesomeIcons.pix : Icons.account_balance,
                    title: 'Transação ${index + 1}',
                    subtitle: '${index + 1} dias atrás',
                    amount: index % 2 == 0 ? '-R\$ ${(index + 1) * 10},00' : '+R\$ ${(index + 1) * 15},00',
                    isExpense: index % 2 == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: 'Dados pessoais',
              subtitle: 'Editar informações',
            ),
            _buildProfileOption(
              icon: Icons.security,
              title: 'Segurança',
              subtitle: 'Senha e biometria',
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
              subtitle: 'Configurar alertas',
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Ajuda',
              subtitle: 'Central de suporte',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logout
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF666666),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E40AF),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Serviços',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
