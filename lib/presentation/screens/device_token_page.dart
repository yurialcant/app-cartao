// lib/screens/device_token_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceTokenScreen extends StatefulWidget {
  const DeviceTokenScreen({super.key});

  @override
  State<DeviceTokenScreen> createState() => _DeviceTokenScreenState();
}

class _DeviceTokenScreenState extends State<DeviceTokenScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _validateToken() {
    if (_formKey.currentState!.validate()) {
      // Simula validação e redireciona para próxima etapa
      context.go('/first-access-register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validação de Acesso'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digite o código que você recebeu',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tokenController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Código de 6 dígitos',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Código inválido';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _validateToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Validar e Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
