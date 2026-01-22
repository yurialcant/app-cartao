import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/bootstrap_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/card_provider.dart';
import 'providers/notification_provider.dart';

// Screens
import 'screens/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/statement_screen.dart';
import 'screens/card_screen.dart';
import 'screens/verification_code_screen.dart';
import 'screens/partners_screen.dart';
import 'screens/corporate_request_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/support_screen.dart';
import 'screens/settings_screen.dart';

// Models
import 'models/tenant_config.dart';
import 'models/user_profile.dart';

// Services
import 'services/auth_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage and biometrics
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final LocalAuthentication localAuth = LocalAuthentication();

  // Check if privacy mode was enabled
  bool privacyModeEnabled = await secureStorage.read(key: 'privacy_mode') == 'true';

  // #region agent log
  try {
    // Note: Using dynamic import to avoid issues in Flutter
    // This would be replaced with proper logging in production
    print('Flutter app main() called - User App initialized');
  } catch (e) {
    print('Logging not available in Flutter context');
  }
  // #endregion

  runApp(
    MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => AuthProvider(secureStorage, localAuth)),
        ChangeNotifierProvider(create: (_) => BootstrapProvider()),

        // Feature providers
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Services
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
      ],
      child: BenefitsApp(privacyModeEnabled: privacyModeEnabled),
    ),
  );
}

class BenefitsApp extends StatefulWidget {
  final bool privacyModeEnabled;

  const BenefitsApp({
    super.key,
    required this.privacyModeEnabled
  });

  @override
  State<BenefitsApp> createState() => _BenefitsAppState();
}

class _BenefitsAppState extends State<BenefitsApp> {
  late ThemeData _themeData;
  late TenantConfig _tenantConfig;

  @override
  void initState() {
    super.initState();
    // Initialize with default theme - will be updated by bootstrap
    _themeData = _createDefaultTheme();
    _tenantConfig = TenantConfig.defaultConfig();
  }

  ThemeData _createDefaultTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      // Privacy mode affects theme
      textTheme: widget.privacyModeEnabled ?
        const TextTheme(bodyLarge: TextStyle(color: Colors.transparent)) :
        null,
    );
  }

  ThemeData _createTenantTheme(TenantConfig config) {
    // Create theme based on tenant branding
    final Color primaryColor = Color(int.parse(config.branding.primaryColor.replaceFirst('#', '0xff')));

    return ThemeData(
      primaryColor: primaryColor,
      fontFamily: config.branding.fontFamily ?? 'Roboto',
      // Apply privacy mode
      textTheme: widget.privacyModeEnabled ?
        const TextTheme(bodyLarge: TextStyle(color: Colors.transparent)) :
        null,
    );
  }

  void _updateTheme(TenantConfig config) {
    setState(() {
      _tenantConfig = config;
      _themeData = _createTenantTheme(config);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: _tenantConfig.branding.appName,
      theme: _themeData,
      routerConfig: _createRouter(),
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      routes: [
        // Auth flow
        GoRoute(
          path: '/',
          builder: (context, state) => AuthWrapper(
            onTenantConfigLoaded: _updateTheme,
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Main app routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/wallets',
          builder: (context, state) => const WalletScreen(),
        ),
        GoRoute(
          path: '/statement',
          builder: (context, state) => const StatementScreen(),
        ),
        GoRoute(
          path: '/cards',
          builder: (context, state) => const CardScreen(),
        ),
        GoRoute(
          path: '/verification-code',
          builder: (context, state) => const VerificationCodeScreen(),
        ),
        GoRoute(
          path: '/partners',
          builder: (context, state) => const PartnersScreen(),
        ),
        GoRoute(
          path: '/corporate-request',
          builder: (context, state) => const CorporateRequestScreen(),
        ),

        // Additional screens
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const SupportScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoginRoute = state.location == '/login';

        // Check module access
        final bootstrapProvider = Provider.of<BootstrapProvider>(context, listen: false);
        final modules = bootstrapProvider.tenantConfig?.modules ?? {};

        // Module-based redirects
        if (state.location.startsWith('/cards') && !(modules['cards'] ?? true)) {
          return '/home'; // Module disabled
        }
        if (state.location.startsWith('/partners') && !(modules['partners'] ?? true)) {
          return '/home'; // Module disabled
        }

        // Auth redirects
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }

        if (isLoggedIn && isLoginRoute) {
          return '/home';
        }

        return null;
      },
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/benefits',
      builder: (context, state) => const BenefitsScreen(),
    ),
    GoRoute(
      path: '/expense',
      builder: (context, state) => const ExpenseScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final isLoginRoute = state.location == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    if (isLoggedIn && isLoginRoute) {
      return '/home';
    }

    return null;
  },
);

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}