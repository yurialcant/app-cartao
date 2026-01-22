import 'package:flutter/material.dart';
import 'package:merchant_pos_flutter/config/app_environment.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_charge_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/transaction_history_screen.dart';

void main() {
  // Inicializa a configuração de ambiente
  AppEnvironment().initialize(environment: Environment.development);
  
  // Imprime informações de debug
  print(AppEnvironment().getDebugInfo());
  
  runApp(const MerchantPOSApp());
}

class MerchantPOSApp extends StatelessWidget {
  const MerchantPOSApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merchant POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/qr-charge': (context) => const QrChargeScreen(),
        '/pos': (context) => const PosScreen(),
        '/transaction-history': (context) => const TransactionHistoryScreen(),
      },
    );
  }
}
