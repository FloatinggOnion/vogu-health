import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/health_data_service.dart';
import 'package:vogu_health/services/feedback_service.dart';
import 'package:vogu_health/models/health_data.dart';
import '../widgets/current_stats.dart';
import '../widgets/health_trends.dart';
import '../widgets/insights_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final healthDataService = context.read<HealthDataService>();
      final feedbackService = context.read<FeedbackService>();
      healthDataService.getHealthDataByDateRange(
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        DateTime.now().toIso8601String(),
      );
      healthDataService.loadHealthDataHistory();
      feedbackService.loadFeedbackHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthDataService = context.read<HealthDataService>();
    final feedbackService = context.read<FeedbackService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vogu Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final healthDataService = context.read<HealthDataService>();
              healthDataService.getHealthDataByDateRange(
                DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
                DateTime.now().toIso8601String(),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HealthData>>(
        future: healthDataService.getHealthDataByDateRange(
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          DateTime.now().toIso8601String(),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final healthData = snapshot.data ?? [];

          return IndexedStack(
            index: _selectedIndex,
            children: const [
              CurrentStats(),
              HealthTrends(),
              InsightsList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final healthDataService = context.read<HealthDataService>();
          final newData = HealthData(
            date: DateTime.now().toIso8601String(),
            hrv: 75.0,
            heartRate: 72,
            createdAt: DateTime.now().toIso8601String(),
          );
          await healthDataService.insertHealthData(newData);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.monitor_heart),
            label: 'Current',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Trends',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
} 