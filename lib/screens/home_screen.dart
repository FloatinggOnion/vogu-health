import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/health_data_service.dart';
import 'package:vogu_health/services/feedback_service.dart';
import 'package:vogu_health/models/health_data.dart' as health_data;
import '../widgets/current_stats.dart';
import '../widgets/health_trends.dart';
import '../widgets/insights_list.dart';
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/widgets/health_data_entry_form.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showEntryForm = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final healthDataService = context.read<HealthDataService>();
      final feedbackService = context.read<FeedbackService>();
      
      // Load initial data
      healthDataService.loadData(days: 7);
      feedbackService.loadFeedbackHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthDataService = context.read<HealthDataService>();
    final feedbackService = context.read<FeedbackService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_showEntryForm ? Icons.analytics : Icons.add),
            onPressed: () {
              setState(() {
                _showEntryForm = !_showEntryForm;
              });
            },
            tooltip: _showEntryForm ? 'Show Analytics' : 'Add Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh of all data
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showEntryForm)
                  HealthDataEntryForm(
                    apiService: widget.apiService,
                    onSuccess: () {
                      setState(() {
                        _showEntryForm = false;
                      });
                    },
                  )
                else
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CurrentStats(),
                      SizedBox(height: 24),
                      HealthTrends(),
                      SizedBox(height: 24),
                      InsightsList(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final healthDataService = context.read<HealthDataService>();
          final newData = health_data.HeartRateData(
            timestamp: DateTime.now(),
            value: 72,
            restingRate: 65,
            activityType: 'resting',
          );
          await healthDataService.submitHeartRateData(newData);
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