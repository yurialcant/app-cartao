import 'package:get_it/get_it.dart';
import '../storage/app_storage.dart';

/// Service Locator usando GetIt para injeção de dependências
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  /// Inicializa o service locator
  static Future<void> init() async {
    // Inicializa AppStorage
    await AppStorage.init();
    
    // Aqui você pode registrar seus serviços
    // Por exemplo:
    // _getIt.registerLazySingleton<AuthService>(() => AuthService());
    // _getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  }
  
  /// Registra um singleton
  static void registerSingleton<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }
  
  /// Registra um lazy singleton
  static void registerLazySingleton<T extends Object>(T Function() factory) {
    _getIt.registerLazySingleton<T>(factory);
  }
  
  /// Registra uma factory
  static void registerFactory<T extends Object>(T Function() factory) {
    _getIt.registerFactory<T>(factory);
  }
  
  /// Obtém uma instância
  static T get<T extends Object>() {
    return _getIt.get<T>();
  }
  
  /// Verifica se está registrado
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
  
  /// Remove um registro
  static void unregister<T extends Object>() {
    _getIt.unregister<T>();
  }
  
  /// Remove todos os registros
  static void reset() {
    _getIt.reset();
  }
}
