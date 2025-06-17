import 'package:flutter/material.dart';
import 'package:vogu_health/models/api_models.dart';
import 'package:vogu_health/services/health_api_service.dart';
import 'package:vogu_health/presentation/widgets/health_chart.dart';

class HealthTrendsScreen extends StatefulWidget {
  const HealthTrendsScreen({Key? key}) : super(key: key);

  @override
  State<HealthTrendsScreen> createState() => _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends State<HealthTrendsScreen> {
  final HealthApiService _apiService = HealthApiService();
  bool _isLoading = false;
  List<SleepDataResponse> _sleepData = [];
  List<HeartRateDataResponse> _heartRateData = [];
  List<WeightDataResponse> _weightData = [];
  
  // Time period options
  final List<TimePeriod> _timePeriods = [
    TimePeriod('7 Days', 7),
    TimePeriod('30 Days', 30),
    TimePeriod('90 Days', 90),
    TimePeriod('1 Year', 365),
  ];
  
  TimePeriod _selectedPeriod = TimePeriod('7 Days', 7);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load sleep data
      final sleepData = await _apiService.getSleepData(days: _selectedPeriod.days);
      setState(() => _sleepData = sleepData);
      
      // Load heart rate data
      final heartRateData = await _apiService.getHeartRateData(days: _selectedPeriod.days);
      setState(() => _heartRateData = heartRateData);
      
      // Load weight data
      final weightData = await _apiService.getWeightData(days: _selectedPeriod.days);
      setState(() => _weightData = weightData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time period selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _timePeriods.map((period) {
              return ChoiceChip(
                label: Text(period.label),
                selected: _selectedPeriod == period,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedPeriod = period);
                    _loadData();
                  }
                },
              );
            }).toList(),
          ),
        ),
        
        // Charts
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
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
        ),
      ],
    );
  }
}

class TimePeriod {
  final String label;
  final int days;

  const TimePeriod(this.label, this.days);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimePeriod &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          days == other.days;

  @override
  int get hashCode => label.hashCode ^ days.hashCode;
} 