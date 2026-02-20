import 'package:get_it/get_it.dart';
import '../storage/app_storage.dart';
import '../services/session_manager.dart';
import '../services/navigation_service.dart';
import '../services/attempt_control_service.dart';

/// Service Locator usando GetIt para injeção de dependências
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  /// Inicializa todos os serviços
  static Future<void> init() async {
    print('🔍 DEBUG: [ServiceLocator] Inicializando serviços...');
    
    // Registra serviços essenciais
    _getIt.registerLazySingleton<SessionManager>(() => SessionManager());
    _getIt.registerLazySingleton<NavigationService>(() => NavigationService());
    _getIt.registerLazySingleton<AttemptControlService>(() => AttemptControlService());
    
    print('🔍 DEBUG: [ServiceLocator] Todos os serviços registrados com sucesso');
  }
  
  /// Obtém uma instância de um serviço
  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
  
  /// Verifica se um serviço está registrado
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
  
  /// Reseta todos os serviços (útil para testes)
  static Future<void> reset() async {
    await _getIt.reset();
    print('🔍 DEBUG: [ServiceLocator] Todos os serviços resetados');
  }
}
