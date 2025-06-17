# Modular Architecture Documentation

## Overview

The Vogu Health app has been refactored into a modular, maintainable architecture following clean architecture principles. This document explains the structure, design patterns, and how to work with the new system.

## Architecture Layers

### 🏗️ **Core Layer** (`lib/core/`)
Contains interfaces, configurations, and shared utilities that define the contract between layers.

#### **Interfaces** (`lib/core/interfaces/`)
- `api_client.dart` - Defines the contract for API operations
- `repository.dart` - Defines data access contracts for each domain
- `state_manager.dart` - Defines state management contracts

#### **Configuration** (`lib/core/config/`)
- `app_config.dart` - Centralized configuration management
- Environment-specific settings
- Validation rules
- Feature flags

#### **Exceptions** (`lib/core/exceptions/`)
- `api_exceptions.dart` - Standardized exception hierarchy
- Type-safe error handling
- Consistent error messages

#### **Dependency Injection** (`lib/core/di/`)
- `service_locator.dart` - Dependency injection container
- Service registration and resolution
- Test-friendly architecture

### 📊 **Data Layer** (`lib/data/`)
Contains concrete implementations of data access and business logic.

#### **Repositories** (`lib/data/repositories/`)
- `sleep_data_repository_impl.dart`
- `heart_rate_data_repository_impl.dart`
- `weight_data_repository_impl.dart`
- `insights_repository_impl.dart`
- `daily_summary_repository_impl.dart`

### 🎨 **Presentation Layer** (`lib/presentation/`)
Contains UI state management and presentation logic.

#### **State Managers** (`lib/presentation/state_managers/`)
- `sleep_data_state_manager_impl.dart`
- Heart rate, weight, and insights state managers (to be implemented)

### 🧩 **Models** (`lib/models/`)
Data models and DTOs for API communication.

### 🎯 **Services** (`lib/services/`)
Core service implementations.

### 🖼️ **Widgets** (`lib/widgets/`)
UI components and screens.

## Design Patterns

### 1. **Dependency Injection**
```dart
// Service registration
serviceLocator.registerLazySingleton<ApiClient>(
  () => HealthApiService(client: serviceLocator<http.Client>()),
);

// Service resolution
final apiClient = getService<ApiClient>();
```

### 2. **Repository Pattern**
```dart
// Interface
abstract class SleepDataRepository {
  Future<ApiResponse> submit(SleepDataRequest request);
  Future<List<SleepDataResponse>> getData({int days = 7});
}

// Implementation
class SleepDataRepositoryImpl implements SleepDataRepository {
  final ApiClient _apiClient;
  // Implementation details...
}
```

### 3. **State Management Pattern**
```dart
// Interface
abstract class SleepDataStateManager extends ChangeNotifier {
  HealthDataState get state;
  Future<bool> submitData({...});
  Future<void> loadData({int days = 7});
}

// Implementation
class SleepDataStateManagerImpl extends ChangeNotifier 
    implements SleepDataStateManager {
  final SleepDataRepository _repository;
  // Implementation details...
}
```

### 4. **Configuration Pattern**
```dart
// Centralized configuration
class AppConfig {
  static const String defaultApiBaseUrl = 'http://localhost:8000';
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  // Environment-specific
  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    return env.isNotEmpty ? env : defaultApiBaseUrl;
  }
}
```

## Benefits of Modular Architecture

### ✅ **Maintainability**
- Clear separation of concerns
- Single responsibility principle
- Easy to locate and modify specific functionality

### ✅ **Testability**
- Dependency injection enables easy mocking
- Isolated components can be tested independently
- Clear interfaces make testing straightforward

### ✅ **Scalability**
- Easy to add new features
- Modular components can be reused
- Clear extension points

### ✅ **Flexibility**
- Easy to swap implementations
- Configuration-driven behavior
- Environment-specific settings

### ✅ **Code Quality**
- Consistent error handling
- Type-safe interfaces
- Standardized patterns

## How to Add New Features

### 1. **Add New API Endpoint**
```dart
// 1. Add to ApiClient interface
abstract class ApiClient {
  Future<ApiResponse> submitNewData(NewDataRequest request);
}

// 2. Implement in HealthApiService
class HealthApiService implements ApiClient {
  @override
  Future<ApiResponse> submitNewData(NewDataRequest request) async {
    // Implementation
  }
}
```

### 2. **Add New Repository**
```dart
// 1. Define interface
abstract class NewDataRepository {
  Future<ApiResponse> submit(NewDataRequest request);
  Future<List<NewDataResponse>> getData({int days = 7});
}

// 2. Implement repository
class NewDataRepositoryImpl implements NewDataRepository {
  final ApiClient _apiClient;
  // Implementation
}

// 3. Register in service locator
serviceLocator.registerLazySingleton<NewDataRepository>(
  () => NewDataRepositoryImpl(serviceLocator<ApiClient>()),
);
```

### 3. **Add New State Manager**
```dart
// 1. Define interface
abstract class NewDataStateManager extends HealthDataStateManager {
  List<NewDataResponse> get newData;
  Future<bool> submitData(NewDataRequest request);
}

// 2. Implement state manager
class NewDataStateManagerImpl extends ChangeNotifier 
    implements NewDataStateManager {
  final NewDataRepository _repository;
  // Implementation
}

// 3. Register in service locator
serviceLocator.registerFactory<NewDataStateManager>(
  () => NewDataStateManagerImpl(serviceLocator<NewDataRepository>()),
);
```

### 4. **Add to UI**
```dart
// 1. Add to main.dart providers
ChangeNotifierProvider<NewDataStateManager>(
  create: (_) => getService<NewDataStateManager>(),
),

// 2. Use in widgets
Consumer<NewDataStateManager>(
  builder: (context, stateManager, child) {
    // UI implementation
  },
)
```

## Testing Strategy

### **Unit Tests**
```dart
// Test repository
class MockApiClient extends Mock implements ApiClient {}
class MockSleepDataRepository extends Mock implements SleepDataRepository {}

void main() {
  group('SleepDataRepositoryImpl', () {
    late MockApiClient mockApiClient;
    late SleepDataRepositoryImpl repository;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = SleepDataRepositoryImpl(mockApiClient);
    });

    test('should submit sleep data successfully', () async {
      // Test implementation
    });
  });
}
```

### **Integration Tests**
```dart
// Test state manager with real repository
void main() {
  group('SleepDataStateManager Integration', () {
    late SleepDataStateManager stateManager;

    setUp(() {
      // Use real repository with mock API client
      final mockApiClient = MockApiClient();
      final repository = SleepDataRepositoryImpl(mockApiClient);
      stateManager = SleepDataStateManagerImpl(repository);
    });

    test('should load data and update state', () async {
      // Test implementation
    });
  });
}
```

## Configuration Management

### **Environment Variables**
```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Production
flutter run --dart-define=API_BASE_URL=https://api.voguhealth.com --dart-define=ENVIRONMENT=production
```

### **Feature Flags**
```dart
// In AppConfig
static const bool enableOfflineMode = false;
static const bool enableAnalytics = false;

// In code
if (AppConfig.enableOfflineMode) {
  // Offline functionality
}
```

## Error Handling

### **Exception Hierarchy**
```dart
ApiException (base)
├── NetworkException
├── ServerException
├── ClientException
├── ValidationException
├── TimeoutException
└── NoDataException
```

### **Error Handling in UI**
```dart
Consumer<SleepDataStateManager>(
  builder: (context, stateManager, child) {
    if (stateManager.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (stateManager.error != null) {
      return ErrorWidget(stateManager.error!);
    }
    
    return DataWidget(stateManager.sleepData);
  },
)
```

## Performance Considerations

### **Lazy Loading**
- Services are registered as lazy singletons
- State managers are created on demand
- Data is loaded only when needed

### **Caching**
- HTTP client can be extended with caching
- State managers cache data in memory
- Repository layer can implement caching strategies

### **Memory Management**
- Proper disposal of resources
- Weak references where appropriate
- Efficient state updates

## Migration Guide

### **From Old Architecture**
1. Replace direct service usage with dependency injection
2. Use state managers instead of direct API calls
3. Update error handling to use new exception types
4. Use configuration instead of hardcoded values

### **Example Migration**
```dart
// Old way
final apiService = HealthApiService();
await apiService.submitSleepData(...);

// New way
final stateManager = getService<SleepDataStateManager>();
await stateManager.submitData(...);
```

## Best Practices

### **1. Interface Segregation**
- Keep interfaces small and focused
- Don't force implementations to depend on methods they don't use

### **2. Dependency Inversion**
- Depend on abstractions, not concretions
- Use dependency injection for all dependencies

### **3. Single Responsibility**
- Each class has one reason to change
- Separate concerns clearly

### **4. Open/Closed Principle**
- Open for extension, closed for modification
- Use interfaces and inheritance appropriately

### **5. Consistent Naming**
- Use clear, descriptive names
- Follow established patterns
- Use consistent file organization

## Troubleshooting

### **Common Issues**

1. **Service Not Registered**
   ```dart
   // Error: Service not found
   // Solution: Register service in service_locator.dart
   serviceLocator.registerLazySingleton<YourService>(
     () => YourServiceImpl(),
   );
   ```

2. **State Not Updating**
   ```dart
   // Error: UI not reflecting state changes
   // Solution: Ensure notifyListeners() is called
   void _setState(HealthDataState newState) {
     _state = newState;
     notifyListeners(); // Don't forget this!
   }
   ```

3. **Configuration Not Working**
   ```dart
   // Error: Configuration not applied
   // Solution: Check environment variables
   print('API URL: ${AppConfig.apiBaseUrl}');
   ```

## Future Enhancements

### **Planned Improvements**
1. Add more state managers for all data types
2. Implement caching layer
3. Add offline support
4. Implement analytics
5. Add more comprehensive error handling
6. Create more reusable UI components

### **Extension Points**
1. Add new data types easily
2. Implement different storage strategies
3. Add new UI themes
4. Support multiple API endpoints
5. Add real-time updates

This modular architecture provides a solid foundation for maintaining and extending the Vogu Health application while ensuring code quality, testability, and scalability. 