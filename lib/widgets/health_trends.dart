import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/models/health_data.dart';
import 'package:vogu_health/widgets/date_range_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vogu_health/screens/home_screen.dart';
import 'package:intl/intl.dart';

class HealthTrends extends StatefulWidget {
  const HealthTrends({super.key});

  @override
  State<HealthTrends> createState() => _HealthTrendsState();
}

class _HealthTrendsState extends State<HealthTrends> {
  String _selectedMetric = 'heart-rate';
  int _selectedDays = 7;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 7));
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _errorMessage = null;
    });
  }

  String? _getErrorMessage(dynamic error) {
    if (error is NoDataException) {
      return 'No data available for the selected period. Try a different date range.';
    } else if (error is InvalidDateRangeException) {
      return 'Invalid date range. End date must be after start date.';
    } else if (error is FutureDateException) {
      return 'Cannot fetch data for future dates.';
    } else if (error is DateRangeTooLargeException) {
      return 'Date range too large. Maximum allowed range is 365 days.';
    } else if (error is ApiException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final apiService = context.findAncestorStateOfType<HomeScreenState>()?.widget.apiService;

    if (apiService == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Error: API service not found'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Health Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 7, label: Text('7D')),
                    ButtonSegment(value: 30, label: Text('30D')),
                    ButtonSegment(value: 90, label: Text('90D')),
                  ],
                  selected: {_selectedDays},
                  onSelectionChanged: (Set<int> selection) {
                    setState(() {
                      _selectedDays = selection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'heart-rate',
                  label: Text('Heart Rate'),
                  icon: Icon(Icons.favorite),
                ),
                ButtonSegment(
                  value: 'sleep',
                  label: Text('Sleep'),
                  icon: Icon(Icons.bedtime),
                ),
                ButtonSegment(
                  value: 'weight',
                  label: Text('Weight'),
                  icon: Icon(Icons.monitor_weight),
                ),
              ],
              selected: {_selectedMetric},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedMetric = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: FutureBuilder<HealthMetrics>(
                future: apiService.getMetricsByDateRange(
                  DateTime.now().subtract(Duration(days: _selectedDays)),
                  DateTime.now(),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading trends',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final metrics = snapshot.data;
                  if (metrics == null) {
                    return const Center(child: Text('No data available'));
                  }

                  switch (_selectedMetric) {
                    case 'heart-rate':
                      return _buildHeartRateChart(metrics.heartRate);
                    case 'sleep':
                      return _buildSleepChart(metrics.sleep);
                    case 'weight':
                      return _buildWeightChart(metrics.weight);
                    default:
                      return const Center(child: Text('Invalid metric selected'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateChart(List<HeartRateData> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No heart rate data available'));
    }

    final spots = data.map((point) {
      return FlSpot(
        point.timestamp.millisecondsSinceEpoch.toDouble(),
        point.value.toDouble(),
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart(List<SleepData> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No sleep data available'));
    }

    final spots = data.map((point) {
      final duration = point.endTime.difference(point.startTime).inMinutes / 60;
      return FlSpot(
        point.startTime.millisecondsSinceEpoch.toDouble(),
        duration,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<WeightData> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No weight data available'));
    }

    final spots = data.map((point) {
      return FlSpot(
        point.timestamp.millisecondsSinceEpoch.toDouble(),
        point.value,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}kg',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
} 