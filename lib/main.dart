import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/services/storage_service.dart';
import 'package:vogu_health/services/health_data_service.dart';
import 'package:vogu_health/services/feedback_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  final cacheBox = await Hive.openBox('api_cache');
  
  // Initialize StorageService
  final storageService = StorageService();
  
  runApp(
    MultiProvider(
      providers: [
        // Base services
        Provider<StorageService>(
          create: (_) => storageService,
        ),
        Provider<ApiService>(
          create: (context) => ApiService(
            http.Client(),
            cacheBox,
            context.read<StorageService>(),
          ),
        ),
        // Dependent services
        ChangeNotifierProvider<HealthDataService>(
          create: (context) => HealthDataService(
            context.read<StorageService>(),
            context.read<ApiService>(),
          ),
        ),
        Provider<FeedbackService>(
          create: (context) => FeedbackService(
            context.read<StorageService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vogu Health',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(
        apiService: context.read<ApiService>(),
      ),
    );
  }
}
