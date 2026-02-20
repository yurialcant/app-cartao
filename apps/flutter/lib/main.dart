import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/session_manager.dart';
import 'core/services/navigation_service.dart';
import 'core/config/app_version.dart';

void main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========================================
  // 🔧 INICIALIZAÇÃO DE SERVIÇOS
  // ========================================
  
  // Inicializa o Service Locator (GetIt)
  await ServiceLocator.init();
  
  // Inicializa o gerenciador de sessão
  await SessionManager().initialize();
  
  // Inicializa o serviço de navegação
  await NavigationService().initialize();
  
  // Garante que o AppStorage está inicializado
  print('🔍 DEBUG: [Main] App inicializando...');
  
  // ========================================
  // 🏷️ INFORMAÇÕES DE VERSÃO
  // ========================================
  
  // Imprime informações de versão no console
  AppVersion.printDebugInfo();
  
  print('🚀 [Main] Iniciando ${AppVersion.appName} ${AppVersion.fullVersion}');
  print('🔧 [Main] Ambiente: ${AppVersion.environment}');
  print('📅 [Main] Data de lançamento: ${AppVersion.releaseDate}');
  
  // ========================================
  // 📱 CONFIGURAÇÕES DO SISTEMA
  // ========================================
  
  // Trava orientação em portrait (vertical)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Configura o estilo da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // ========================================
  // 🚀 EXECUTA O APP
  // ========================================
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

/// Aplicativo principal
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '${AppVersion.appName} ${AppVersion.displayVersion}',
      debugShowCheckedModeBanner: false,
      
      // ========================================
      // 🎨 TEMA PERSONALIZADO
      // ========================================
      
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Por enquanto, sempre tema claro
      
      // ========================================
      // 🧭 ROTEAMENTO COM NOVO SISTEMA
      // ========================================
      
      routerConfig: AppRouter.router,
      
      // ========================================
      // 📱 CONFIGURAÇÕES ADICIONAIS
      // ========================================
      
      // Localização - ESSENCIAL para MaterialLocalizations
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      
      // Localizações para Material Design
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Configurações de debug
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      
      // Configurações de scroll
      scrollBehavior: const ScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
