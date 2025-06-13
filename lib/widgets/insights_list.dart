import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/models/health_data.dart';
import 'package:vogu_health/models/health_insight.dart' as insight;
import 'package:vogu_health/widgets/date_range_selector.dart';

class InsightsList extends StatefulWidget {
  const InsightsList({super.key});

  @override
  State<InsightsList> createState() => _InsightsListState();
}

class _InsightsListState extends State<InsightsList> {
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
      return 'No insights available for the selected period. Try a different date range.';
    } else if (error is InvalidDateRangeException) {
      return 'Invalid date range. End date must be after start date.';
    } else if (error is FutureDateException) {
      return 'Cannot fetch insights for future dates.';
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
      mainAxisSize: MainAxisSize.min,
      children: [
        DateRangeSelector(
          startDate: _startDate,
          endDate: _endDate,
          onRangeChanged: _onDateRangeChanged,
          errorMessage: _errorMessage,
        ),
        FutureBuilder<List<insight.HealthInsight>>(
          future: apiService.getRecentInsights(days: _endDate.difference(_startDate).inDays),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final errorMessage = _getErrorMessage(snapshot.error);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _errorMessage = errorMessage;
                  });
                }
              });
              
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        errorMessage ?? 'An error occurred',
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

            final insights = snapshot.data;
            if (insights == null || insights.isEmpty) {
              return const Center(child: Text('No insights available'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: insights.length,
              itemBuilder: (context, index) {
                final insight = insights[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getInsightIcon(insight.category),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                insight.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          insight.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (insight.recommendations != null && insight.recommendations!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Recommendations',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    if (insight.severity != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getSeverityColor(insight.severity!),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getSeverityLabel(insight.severity!),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...insight.recommendations!.map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    '• $rec',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                        if (insight.metrics != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Metrics',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...insight.metrics!.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  entry.value.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 80) return Colors.red;
    if (severity >= 60) return Colors.orange;
    if (severity >= 40) return Colors.yellow.shade700;
    if (severity >= 20) return Colors.blue;
    return Colors.green;
  }

  String _getSeverityLabel(int severity) {
    if (severity >= 80) return 'Critical';
    if (severity >= 60) return 'High';
    if (severity >= 40) return 'Medium';
    if (severity >= 20) return 'Low';
    return 'Info';
  }

  IconData _getInsightIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sleep':
        return Icons.bedtime;
      case 'heart':
        return Icons.favorite;
      case 'weight':
        return Icons.monitor_weight;
      case 'activity':
        return Icons.directions_run;
      case 'stress':
        return Icons.psychology;
      default:
        return Icons.insights;
    }
  }

  IconData _getErrorIcon(dynamic error) {
    if (error is NoDataException) return Icons.search_off;
    if (error is InvalidDateRangeException) return Icons.date_range;
    if (error is FutureDateException) return Icons.update;
    if (error is DateRangeTooLargeException) return Icons.calendar_month;
    return Icons.error_outline;
  }

  bool _shouldShowRetryButton(dynamic error) {
    return error is NetworkException || error is ServerException;
  }
} 