# Health API Service Implementation

This document describes the comprehensive Flutter API service implementation for interacting with the FastAPI health data tracking backend.

## Overview

The implementation includes:

1. **API Models** (`lib/models/api_models.dart`) - Complete request/response models
2. **API Service** (`lib/services/health_api_service.dart`) - Core API client
3. **Provider** (`lib/providers/health_api_provider.dart`) - State management wrapper
4. **Dashboard Widget** (`lib/widgets/health_data_dashboard.dart`) - Complete UI example
5. **Usage Examples** (`lib/examples/api_usage_example.dart`) - Comprehensive examples

## Features

- ✅ Complete API endpoint coverage
- ✅ Type-safe request/response models
- ✅ Comprehensive error handling
- ✅ State management with Provider
- ✅ Beautiful, responsive UI
- ✅ Real-time data submission and retrieval
- ✅ AI insights integration
- ✅ Offline/online status handling

## Setup

### 1. Dependencies

The following dependencies are already included in `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  provider: ^6.0.5
  json_annotation: ^4.8.1
  intl: ^0.19.0

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

### 2. Generate Code

Run the build runner to generate JSON serialization code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. API Configuration

Update the base URL in `lib/services/health_api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:8000'; // Change to your API URL
```

## Usage

### Basic API Service Usage

```dart
import 'package:vogu_health/services/health_api_service.dart';
import 'package:vogu_health/models/api_models.dart';

void main() async {
  final apiService = HealthApiService();
  
  // Submit sleep data
  final phases = SleepPhases(deep: 120, light: 240, rem: 90, awake: 30);
  await apiService.submitSleepData(
    startTime: DateTime.now().subtract(Duration(hours: 8)),
    endTime: DateTime.now(),
    quality: 85,
    phases: phases,
  );
  
  // Get sleep data
  final sleepData = await apiService.getSleepData(days: 7);
  print('Retrieved ${sleepData.length} sleep records');
  
  // Get AI insights
  final insights = await apiService.getRecentInsights(days: 7);
  print('AI Status: ${insights.status}');
  
  apiService.dispose();
}
```

### Provider Usage (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/providers/health_api_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthApiProvider()),
      ],
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HealthApiProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return Column(
          children: [
            Text('Sleep Records: ${provider.sleepData.length}'),
            ElevatedButton(
              onPressed: () => provider.loadSleepData(),
              child: Text('Load Sleep Data'),
            ),
          ],
        );
      },
    );
  }
}
```

## API Endpoints

### 1. Submit Sleep Data
```dart
await apiService.submitSleepData(
  startTime: DateTime.now().subtract(Duration(hours: 8)),
  endTime: DateTime.now(),
  quality: 85,
  phases: SleepPhases(deep: 120, light: 240, rem: 90, awake: 30),
);
```

### 2. Submit Heart Rate Data
```dart
await apiService.submitHeartRateData(
  timestamp: DateTime.now(),
  value: 75,
  restingRate: 60,
  activityType: 'walking',
);
```

### 3. Submit Weight Data
```dart
await apiService.submitWeightData(
  timestamp: DateTime.now(),
  value: 70.5,
  bmi: 22.5,
  bodyComposition: BodyComposition(
    bodyFat: 18.5,
    muscleMass: 40.2,
    waterPercentage: 55.0,
    boneMass: 3.2,
  ),
);
```

### 4. Get Health Data
```dart
// Get sleep data
final sleepData = await apiService.getSleepData(days: 7);

// Get heart rate data
final heartRateData = await apiService.getHeartRateData(days: 7);

// Get weight data
final weightData = await apiService.getWeightData(days: 7);

// Generic method
final data = await apiService.getHealthData(
  metricType: MetricType.sleep,
  days: 7,
);
```

### 5. Get Daily Summary
```dart
final summary = await apiService.getDailyHealthSummary(
  date: DateTime.now(),
);
```

### 6. Get AI Insights
```dart
// Recent insights
final recentInsights = await apiService.getRecentInsights(days: 7);

// Daily insights
final dailyInsights = await apiService.getDailyInsights(
  date: DateTime.now(),
);
```

## Data Models

### Request Models

```dart
// Sleep data request
SleepDataRequest(
  startTime: "2024-03-20T22:00:00Z",
  endTime: "2024-03-21T06:00:00Z",
  quality: 85,
  phases: SleepPhases(deep: 120, light: 240, rem: 90, awake: 30),
  source: "mobile_app",
)

// Heart rate data request
HeartRateDataRequest(
  timestamp: "2024-03-21T12:00:00Z",
  value: 75,
  restingRate: 60,
  activityType: "walking",
  source: "mobile_app",
)

// Weight data request
WeightDataRequest(
  timestamp: "2024-03-21T08:00:00Z",
  value: 70.5,
  bmi: 22.5,
  bodyComposition: BodyComposition(...),
  source: "mobile_app",
)
```

### Response Models

```dart
// Sleep data response
SleepDataResponse(
  id: 1,
  startTime: "2025-04-14T11:45:02.813004+00:00",
  endTime: "2025-04-14T19:03:02.813004+00:00",
  quality: 74,
  deepSleep: 79,
  lightSleep: 220,
  remSleep: 76,
  awakeTime: 27,
  source: "storage_import",
  createdAt: "2025-06-15 20:11:31",
)

// AI insights response
HealthInsights(
  summary: "Your health numbers look good!",
  status: "good", // "good", "fair", or "poor"
  highlights: ["Sleep quality is improving"],
  recommendations: ["Keep up your current sleep routine"],
  nextSteps: "Check your sleep quality trends",
)
```

## Error Handling

The API service includes comprehensive error handling:

```dart
try {
  final data = await apiService.getSleepData(days: 7);
} on HealthApiException catch (e) {
  print('API Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
  print('Endpoint: ${e.endpoint}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Integration with Existing App

### Option 1: Replace Main App
Use `lib/main_with_health_api.dart` as your main entry point.

### Option 2: Add to Existing App
1. Add the provider to your existing `MultiProvider`
2. Add a route to the health dashboard
3. Add navigation buttons where needed

```dart
// In your existing main.dart
MultiProvider(
  providers: [
    // Your existing providers
    ChangeNotifierProvider(create: (_) => YourExistingProvider()),
    
    // Add the health API provider
    ChangeNotifierProvider(create: (_) => HealthApiProvider()),
  ],
  child: MaterialApp(
    routes: {
      '/health-dashboard': (context) => HealthDataDashboard(),
    },
  ),
)
```

## Testing

### Run the Example App
```bash
flutter run -t lib/main_with_health_api.dart
```

### Test API Connection
```dart
final apiService = HealthApiService();
final isConnected = await apiService.testConnection();
print('API Connected: $isConnected');
```

### Run Usage Examples
```dart
final example = HealthApiUsageExample();
await example.runAllExamples();
```

## File Structure

```
lib/
├── models/
│   ├── api_models.dart          # API request/response models
│   └── api_models.g.dart        # Generated JSON serialization
├── services/
│   └── health_api_service.dart  # Core API client
├── providers/
│   └── health_api_provider.dart # State management wrapper
├── widgets/
│   └── health_data_dashboard.dart # Complete UI example
├── examples/
│   └── api_usage_example.dart   # Usage examples
└── main_with_health_api.dart    # Example main app
```

## Configuration

### Environment Variables
You can configure the API URL using environment variables:

```dart
// In health_api_service.dart
static const String baseUrl = String.fromEnvironment(
  'HEALTH_API_URL',
  defaultValue: 'http://localhost:8000',
);
```

### Timeout Configuration
```dart
// In health_api_service.dart
static const Duration timeout = Duration(seconds: 30);
```

## Troubleshooting

### Common Issues

1. **Build Runner Errors**
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **API Connection Issues**
   - Check if the FastAPI server is running
   - Verify the base URL in `health_api_service.dart`
   - Check network connectivity

3. **JSON Serialization Errors**
   - Ensure all models have proper `@JsonSerializable()` annotations
   - Run build runner after model changes

4. **Provider Not Found**
   - Ensure `HealthApiProvider` is added to `MultiProvider`
   - Check import statements

## Contributing

When adding new endpoints or models:

1. Add the model to `api_models.dart`
2. Add the method to `health_api_service.dart`
3. Add the method to `health_api_provider.dart`
4. Update the dashboard widget if needed
5. Run build runner to generate code
6. Test the implementation

## License

This implementation is part of the Vogu Health application. 