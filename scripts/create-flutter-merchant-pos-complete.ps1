# Script para criar Flutter Merchant POS completo

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🏪 CRIANDO FLUTTER MERCHANT POS COMPLETO 🏪               ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$merchantPosDir = Join-Path $baseDir "apps/merchant_pos_flutter"

if (-not (Test-Path $merchantPosDir)) {
    New-Item -ItemType Directory -Path $merchantPosDir -Force | Out-Null
}

# Criar estrutura básica
$libDir = Join-Path $merchantPosDir "lib"
$screensDir = Join-Path $libDir "screens"
$servicesDir = Join-Path $libDir "services"
$modelsDir = Join-Path $libDir "models"

foreach ($dir in @($libDir, $screensDir, $servicesDir, $modelsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Criar pubspec.yaml
$pubspecContent = @"
name: merchant_pos_flutter
description: Merchant POS Flutter App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  qr_flutter: ^4.1.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
"@

$pubspecPath = Join-Path $merchantPosDir "pubspec.yaml"
if (-not (Test-Path $pubspecPath)) {
    Set-Content -Path $pubspecPath -Value $pubspecContent -Encoding UTF8
    Write-Host "  ✓ pubspec.yaml criado" -ForegroundColor Green
}

# Criar main.dart básico
$mainDartContent = @"
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_charge_screen.dart';
import 'screens/card_charge_screen.dart';
import 'screens/shift_screen.dart';

void main() {
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
        '/card-charge': (context) => const CardChargeScreen(),
        '/shift': (context) => const ShiftScreen(),
      },
    );
  }
}
"@

$mainDartPath = Join-Path $libDir "main.dart"
if (-not (Test-Path $mainDartPath)) {
    Set-Content -Path $mainDartPath -Value $mainDartContent -Encoding UTF8
    Write-Host "  ✓ main.dart criado" -ForegroundColor Green
}

# Criar telas básicas
$screens = @{
    "login_screen.dart" = @"
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Merchant POS', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuário'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading 
                ? const CircularProgressIndicator()
                : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final success = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: \$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
"@
    
    "home_screen.dart" = @"
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
"@
    
    "qr_charge_screen.dart" = @"
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class QrChargeScreen extends StatefulWidget {
  const QrChargeScreen({Key? key}) : super(key: key);
  
  @override
  State<QrChargeScreen> createState() => _QrChargeScreenState();
}

class _QrChargeScreenState extends State<QrChargeScreen> {
  final _amountController = TextEditingController();
  final _apiService = ApiService();
  String? _qrCode;
  bool _loading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cobrar QR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _createCharge,
              child: _loading 
                ? const CircularProgressIndicator()
                : const Text('Gerar QR'),
            ),
            if (_qrCode != null) ...[
              const SizedBox(height: 40),
              QrImageView(
                data: _qrCode!,
                size: 200,
              ),
              const SizedBox(height: 20),
              Text('Aguardando pagamento...'),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _createCharge() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }
    
    setState(() {
      _loading = true;
      _qrCode = null;
    });
    
    try {
      final result = await _apiService.createQRCharge(amount);
      setState(() {
        _qrCode = result['qrCode'] as String?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: \$e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
"@
}

Write-Host "`nCriando estrutura do Merchant POS..." -ForegroundColor Cyan

foreach ($screenFile in $screens.Keys) {
    $screenPath = Join-Path $screensDir $screenFile
    if (-not (Test-Path $screenPath)) {
        Set-Content -Path $screenPath -Value $screens[$screenFile] -Encoding UTF8
        Write-Host "  ✓ $screenFile criado" -ForegroundColor Green
    }
}

# Criar ApiService básico
$apiServiceContent = @"
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiService {
  late final Dio _dio;
  final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8084'
      : 'http://localhost:8084';
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }
  
  Future<Map<String, dynamic>> createQRCharge(double amount) async {
    final response = await _dio.post(
      '/charges/qr',
      data: {'amount': amount},
    );
    return response.data;
  }
}
"@

$apiServicePath = Join-Path $servicesDir "api_service.dart"
if (-not (Test-Path $apiServicePath)) {
    Set-Content -Path $apiServicePath -Value $apiServiceContent -Encoding UTF8
    Write-Host "  ✓ ApiService criado" -ForegroundColor Green
}

# Criar AuthService básico
$authServiceContent = @"
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class AuthService {
  final Dio _dio = Dio();
  final _storage = FlutterSecureStorage();
  final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8084'
      : 'http://localhost:8084';
  
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '\$baseUrl/auth/login',
        data: {'username': username, 'password': password},
      );
      final token = response.data['access_token'];
      await _storage.write(key: 'token', value: token);
      return true;
    } catch (e) {
      return false;
    }
  }
}
"@

$authServicePath = Join-Path $servicesDir "auth_service.dart"
if (-not (Test-Path $authServicePath)) {
    Set-Content -Path $authServicePath -Value $authServiceContent -Encoding UTF8
    Write-Host "  ✓ AuthService criado" -ForegroundColor Green
}

Write-Host "`n✅ Flutter Merchant POS criado!" -ForegroundColor Green
Write-Host ""
