# Script para criar todas as telas faltantes no Flutter User App

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📱 CRIANDO TELAS COMPLETAS NO FLUTTER USER APP 📱         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$flutterAppDir = Join-Path $baseDir "apps/user_app_flutter/lib"
$screensDir = Join-Path $flutterAppDir "screens"

# Telas que precisam ser criadas/completadas
$screensToCreate = @{
    "qr_payment_screen.dart" = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class QrPaymentScreen extends StatefulWidget {
  final String qrCode;
  
  const QrPaymentScreen({Key? key, required this.qrCode}) : super(key: key);
  
  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = false;
  String? _error;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento QR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('QR Code: \${widget.qrCode}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _confirmPayment,
              child: _loading 
                ? const CircularProgressIndicator()
                : const Text('Confirmar Pagamento'),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
  
  Future<void> _confirmPayment() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final result = await _apiService.confirmQRPayment(widget.qrCode);
      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
"@
    
    "card_payment_screen.dart" = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CardPaymentScreen extends StatefulWidget {
  final double amount;
  
  const CardPaymentScreen({Key? key, required this.amount}) : super(key: key);
  
  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _cardTokenController = TextEditingController();
  bool _loading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento com Cartão')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Valor: R\$ \${widget.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cardTokenController,
                decoration: const InputDecoration(labelText: 'Token do Cartão'),
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _processPayment,
                child: _loading 
                  ? const CircularProgressIndicator()
                  : const Text('Pagar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      final result = await _apiService.processCardPayment(
        _cardTokenController.text,
        widget.amount,
      );
      if (mounted) {
        Navigator.pop(context, result);
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
    _cardTokenController.dispose();
    super.dispose();
  }
}
"@
    
    "security_screen.dart" = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);
  
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segurança')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dispositivos'),
            subtitle: const Text('Gerenciar dispositivos confiáveis'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navegar para tela de dispositivos
            },
          ),
          ListTile(
            title: const Text('Sessões Ativas'),
            subtitle: const Text('Ver e revogar sessões'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final sessions = await _apiService.getActiveSessions();
              // TODO: Mostrar lista de sessões
            },
          ),
          ListTile(
            title: const Text('Modo Pânico', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Bloquear todas as sessões e cartões'),
            trailing: const Icon(Icons.warning, color: Colors.red),
            onTap: _showPanicModeDialog,
          ),
        ],
      ),
    );
  }
  
  void _showPanicModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ativar Modo Pânico?'),
        content: const Text('Isso irá bloquear todas as sessões e cartões. Tem certeza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _apiService.activatePanicMode();
              await _authService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Ativar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
"@
    
    "support_screen.dart" = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);
  
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiService _apiService = ApiService();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _tickets = [];
  
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }
  
  Future<void> _loadTickets() async {
    try {
      final tickets = await _apiService.getTickets();
      setState(() => _tickets = tickets);
    } catch (e) {
      // Erro ao carregar tickets
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento')),
      body: Column(
        children: [
          Expanded(
            child: _tickets.isEmpty
              ? const Center(child: Text('Nenhum ticket encontrado'))
              : ListView.builder(
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    return ListTile(
                      title: Text(ticket['subject'] ?? ''),
                      subtitle: Text(ticket['status'] ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navegar para detalhe do ticket
                      },
                    );
                  },
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showCreateTicketDialog,
              child: const Text('Novo Ticket'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCreateTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Assunto'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _createTicket,
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _createTicket() async {
    setState(() => _loading = true);
    
    try {
      await _apiService.createTicket(
        _subjectController.text,
        _descriptionController.text,
      );
      Navigator.pop(context);
      _loadTickets();
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
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
"@
    
    "privacy_screen.dart" = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);
  
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ApiService _apiService = ApiService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LGPD')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Exportar Meus Dados'),
            subtitle: const Text('Baixar todos os seus dados'),
            trailing: const Icon(Icons.download),
            onTap: () async {
              final result = await _apiService.exportData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exportação iniciada: \${result['downloadUrl']}')),
              );
            },
          ),
          ListTile(
            title: const Text('Excluir Meus Dados'),
            subtitle: const Text('Solicitar exclusão de dados'),
            trailing: const Icon(Icons.delete),
            onTap: _showDeleteDialog,
          ),
          ListTile(
            title: const Text('Consentimentos'),
            subtitle: const Text('Gerenciar consentimentos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final consents = await _apiService.getConsents();
              // TODO: Mostrar tela de consentimentos
            },
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Dados?'),
        content: const Text('Esta ação não pode ser desfeita. Tem certeza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _apiService.deleteData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exclusão agendada')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
"@
}

Write-Host "`nCriando telas faltantes no Flutter User App..." -ForegroundColor Cyan

foreach ($screenFile in $screensToCreate.Keys) {
    $screenPath = Join-Path $screensDir $screenFile
    
    if (Test-Path $screenPath) {
        Write-Host "  ⚠ $screenFile já existe" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  Criando $screenFile..." -ForegroundColor Yellow
    Set-Content -Path $screenPath -Value $screensToCreate[$screenFile] -Encoding UTF8
    Write-Host "    ✓ $screenFile criado" -ForegroundColor Green
}

Write-Host "`n✅ Telas criadas no Flutter User App!" -ForegroundColor Green
Write-Host ""
