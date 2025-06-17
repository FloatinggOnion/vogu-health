import 'package:flutter/material.dart';
import 'package:vogu_health/services/health_api_service.dart';
import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/presentation/widgets/data_submission_dialog.dart';
import 'package:vogu_health/presentation/widgets/health_chart.dart';

/// Main health dashboard screen
class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthApiService _apiService = HealthApiService();
  bool _isLoading = false;
  List<SleepDataResponse> _sleepData = [];
  List<HeartRateDataResponse> _heartRateData = [];
  List<WeightDataResponse> _weightData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load sleep data
    try {
      print('Loading sleep data...');
      final sleepData = await _apiService.getSleepData(days: 7);
      print('Sleep data loaded: ${sleepData.length} records');
      setState(() => _sleepData = sleepData);
    } catch (e, stackTrace) {
      print('Error loading sleep data: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading sleep data: $e')),
      );
    }

    // Load heart rate data
    try {
      print('Loading heart rate data...');
      final heartRateData = await _apiService.getHeartRateData(days: 7);
      print('Heart rate data loaded: ${heartRateData.length} records');
      setState(() => _heartRateData = heartRateData);
    } catch (e, stackTrace) {
      print('Error loading heart rate data: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading heart rate data: $e')),
      );
    }

    // Load weight data
    try {
      print('Loading weight data...');
      final weightData = await _apiService.getWeightData(days: 7);
      print('Weight data loaded: ${weightData.length} records');
      setState(() => _weightData = weightData);
    } catch (e, stackTrace) {
      print('Error loading weight data: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading weight data: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  String _formatSleepDuration(List<SleepDataResponse> sleepData) {
    if (sleepData.isEmpty) return 'N/A';
    
    // Sort by start time in descending order to get the most recent sleep record
    sleepData.sort((a, b) => DateTime.parse(b.startTime).compareTo(DateTime.parse(a.startTime)));
    final latestSleep = sleepData.first;
    
    final startTime = DateTime.parse(latestSleep.startTime);
    final endTime = DateTime.parse(latestSleep.endTime);
    final duration = endTime.difference(startTime);
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatSleepQuality(List<SleepDataResponse> sleepData) {
    if (sleepData.isEmpty) return 'N/A';
    sleepData.sort((a, b) => DateTime.parse(b.startTime).compareTo(DateTime.parse(a.startTime)));
    return '${sleepData.first.quality ?? 'N/A'}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataCard(
                      'Sleep',
                      Icons.bedtime,
                      Colors.indigo,
                      _formatSleepDuration(_sleepData),
                      'hours (Quality: ${_formatSleepQuality(_sleepData)})',
                    ),
                    HealthChart(
                      data: _sleepData,
                      title: 'Sleep Duration & Quality',
                      valueLabel: 'Duration (hours)',
                      secondaryValueLabel: 'Quality',
                      primaryColor: Colors.indigo,
                      secondaryColor: Colors.purple,
                      showSecondaryAxis: true,
                      getPrimaryValue: (data) {
                        final startTime = DateTime.parse(data.startTime);
                        final endTime = DateTime.parse(data.endTime);
                        return endTime.difference(startTime).inHours.toDouble();
                      },
                      getSecondaryValue: (data) => data.quality?.toDouble() ?? 0,
                      getTimestamp: (data) => DateTime.parse(data.startTime),
                    ),
                    const SizedBox(height: 12),
                    _buildDataCard(
                      'Heart Rate',
                      Icons.favorite,
                      Colors.red,
                      _heartRateData.isNotEmpty
                          ? _heartRateData.last.value?.toString() ?? 'N/A'
                          : 'N/A',
                      'bpm',
                    ),
                    HealthChart(
                      data: _heartRateData,
                      title: 'Heart Rate & Resting Rate',
                      valueLabel: 'Heart Rate',
                      secondaryValueLabel: 'Resting Rate',
                      primaryColor: Colors.red,
                      secondaryColor: Colors.orange,
                      showSecondaryAxis: true,
                      getPrimaryValue: (data) => data.value?.toDouble() ?? 0,
                      getSecondaryValue: (data) => data.restingRate?.toDouble() ?? 0,
                      getTimestamp: (data) => DateTime.parse(data.timestamp),
                    ),
                    const SizedBox(height: 12),
                    _buildDataCard(
                      'Weight',
                      Icons.monitor_weight,
                      Colors.green,
                      _weightData.isNotEmpty
                          ? _weightData.last.value?.toString() ?? 'N/A'
                          : 'N/A',
                      'kg',
                    ),
                    HealthChart(
                      data: _weightData,
                      title: 'Weight & BMI',
                      valueLabel: 'Weight',
                      secondaryValueLabel: 'BMI',
                      primaryColor: Colors.green,
                      secondaryColor: Colors.teal,
                      showSecondaryAxis: true,
                      getPrimaryValue: (data) => data.value?.toDouble() ?? 0,
                      getSecondaryValue: (data) => data.bmi?.toDouble() ?? 0,
                      getTimestamp: (data) => DateTime.parse(data.timestamp),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => DataSubmissionDialog(),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    IconData icon,
    Color color,
    String value,
    String unit,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    unit,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 