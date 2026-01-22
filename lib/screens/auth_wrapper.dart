import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/bootstrap_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// AuthWrapper - handles authentication state and bootstrap loading
class AuthWrapper extends StatefulWidget {
  final Function(TenantConfig)? onTenantConfigLoaded;

  const AuthWrapper({
    super.key,
    this.onTenantConfigLoaded,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _bootstrapLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBootstrapIfAuthenticated();
  }

  Future<void> _loadBootstrapIfAuthenticated() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bootstrapProvider = Provider.of<BootstrapProvider>(context, listen: false);

    if (authProvider.isAuthenticated &&
        authProvider.token != null &&
        authProvider.tenantId != null) {

      // Load tenant config
      final success = await bootstrapProvider.loadBootstrap(
        authProvider.token!,
        authProvider.tenantId!, // This should be tenant slug in real implementation
      );

      if (success && bootstrapProvider.tenantConfig != null) {
        widget.onTenantConfigLoaded?.call(bootstrapProvider.tenantConfig!);
      }

      if (mounted) {
        setState(() {
          _bootstrapLoaded = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _bootstrapLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bootstrapProvider = Provider.of<BootstrapProvider>(context);

    // Show loading while initializing
    if (authProvider.isLoading || !_bootstrapLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if bootstrap failed
    if (authProvider.isAuthenticated &&
        bootstrapProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar configuração',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                bootstrapProvider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _bootstrapLoaded = false;
                  });
                  await _loadBootstrapIfAuthenticated();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Route based on auth state
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}