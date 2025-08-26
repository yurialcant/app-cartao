import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _cpfController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##');

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await Future.delayed(const Duration(seconds: 1)); // simula requisição

      if (!mounted) return;
      context.go('/first-access-token'); // próxima etapa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci minha senha'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recuperar Senha',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Informe seu CPF para iniciar o processo'),
              const SizedBox(height: 24),

              const Text('CPF'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cpfController,
                inputFormatters: [_cpfMask],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Digite seu CPF',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 14) {
                    return 'CPF inválido';
                  }
                  return null;
                },
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Enviar código'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
