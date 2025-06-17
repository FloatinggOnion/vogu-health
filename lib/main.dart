import 'package:flutter/material.dart';
import 'package:vogu_health/presentation/screens/health_tabs_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: const HealthTabsScreen(),
    );
  }
}

// Alternative: If you want to add the health API to your existing app,
// you can modify your existing main.dart like this:

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/core/di/service_locator.dart';
import 'package:vogu_health/presentation/state_managers/sleep_data_state_manager_impl.dart';
// Import your existing providers and screens

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await initializeDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Your existing providers
        ChangeNotifierProvider(create: (_) => YourExistingProvider()),
        
        // Add the new state managers using dependency injection
        ChangeNotifierProvider<SleepDataStateManager>(
          create: (_) => getService<SleepDataStateManager>(),
        ),
      ],
      child: MaterialApp(
        title: 'Your App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const YourExistingHomeScreen(),
        routes: {
          // Add a route to the health dashboard
          '/health-dashboard': (context) => const HealthDataDashboard(),
        },
      ),
    );
  }
}

// Then in your existing home screen, you can add a button to navigate to the health dashboard:
class YourExistingHomeScreen extends StatelessWidget {
  const YourExistingHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your existing content
            const Text('Welcome to Your App'),
            
            // Add a button to access the health dashboard
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/health-dashboard');
              },
              child: const Text('Health Data Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
*/ 