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
        SnackBar(content: Text('Erro: \')),
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
