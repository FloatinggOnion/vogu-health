import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/models/health_data.dart';
import 'package:vogu_health/widgets/date_range_selector.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthTrends extends StatefulWidget {
  const HealthTrends({super.key});

  @override
  State<HealthTrends> createState() => _HealthTrendsState();
}

class _HealthTrendsState extends State<HealthTrends> {
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
    final apiService = context.watch<ApiService>();

    return Column(
      children: [
        DateRangeSelector(
          startDate: _startDate,
          endDate: _endDate,
          onRangeChanged: _onDateRangeChanged,
          errorMessage: _errorMessage,
        ),
        Expanded(
          child: FutureBuilder<HealthMetrics>(
            future: apiService.getMetricsByDateRange(_startDate, _endDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                setState(() {
                  _errorMessage = _getErrorMessage(snapshot.error);
                });
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getErrorIcon(snapshot.error),
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _getErrorMessage(snapshot.error) ?? 'An error occurred',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_shouldShowRetryButton(snapshot.error))
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                          child: const Text('Try Again'),
                        ),
                    ],
                  ),
                );
              }

              final metrics = snapshot.data;
              if (metrics == null || metrics.heartRate.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Trends',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: metrics.heartRate.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.heartRate.toDouble(),
                                );
                              }).toList(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMetricSummary(
                          context,
                          'Avg Heart Rate',
                          '${_calculateAverage(metrics.heartRate.map((hr) => hr.heartRate).toList()).toStringAsFixed(0)} bpm',
                        ),
                        _buildMetricSummary(
                          context,
                          'Avg Sleep',
                          '${_calculateAverage(metrics.sleep.map((s) => s.totalSleepTime / 60).toList()).toStringAsFixed(1)} hrs',
                        ),
                        _buildMetricSummary(
                          context,
                          'Avg Weight',
                          '${_calculateAverage(metrics.weight.map((w) => w.weight).toList()).toStringAsFixed(1)} kg',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getErrorIcon(dynamic error) {
    if (error is NoDataException) {
      return Icons.data_usage;
    } else if (error is InvalidDateRangeException || error is FutureDateException) {
      return Icons.event_busy;
    } else if (error is DateRangeTooLargeException) {
      return Icons.date_range;
    }
    return Icons.error_outline;
  }

  bool _shouldShowRetryButton(dynamic error) {
    return error is! InvalidDateRangeException && 
           error is! FutureDateException && 
           error is! DateRangeTooLargeException;
  }

  Widget _buildMetricSummary(
    BuildContext context,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  double _calculateAverage(List<num> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
} 