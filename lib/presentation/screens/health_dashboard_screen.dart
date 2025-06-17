import 'package:flutter/material.dart';
import 'package:vogu_health/services/health_api_service.dart';
import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/presentation/widgets/data_submission_dialog.dart';

/// Main health dashboard screen
class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthApiService _apiService = HealthApiService();
  List<SleepDataResponse> _sleepData = [];
  List<HeartRateDataResponse> _heartRateData = [];
  List<WeightDataResponse> _weightData = [];
  bool _isLoading = false;

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
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const DataSubmissionDialog(),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Data'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$value $unit',
                    style: Theme.of(context).textTheme.bodyLarge,
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