import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:vogu_health/services/health_api_service.dart';

/// Global service locator for dependency injection
final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core services
  serviceLocator.registerLazySingleton<http.Client>(() => http.Client());
  
  // API Service
  serviceLocator.registerLazySingleton<HealthApiService>(
    () => HealthApiService(client: serviceLocator<http.Client>()),
  );
}

/// Dispose all dependencies
Future<void> disposeDependencies() async {
  await serviceLocator.reset();
}

/// Get a service by type
T getService<T extends Object>() {
  return serviceLocator<T>();
}

/// Register a service for testing
void registerServiceForTesting<T extends Object>(T service) {
  serviceLocator.registerSingleton<T>(service);
} 