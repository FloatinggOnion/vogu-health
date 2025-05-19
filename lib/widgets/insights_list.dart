import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogu_health/services/api_service.dart';
import 'package:vogu_health/models/health_data.dart';
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
      children: [
        DateRangeSelector(
          startDate: _startDate,
          endDate: _endDate,
          onRangeChanged: _onDateRangeChanged,
          errorMessage: _errorMessage,
        ),
        Expanded(
          child: FutureBuilder<List<HealthInsight>>(
            future: apiService.getInsightsByDateRange(_startDate, _endDate),
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

              final insights = snapshot.data;
              if (insights == null || insights.isEmpty) {
                return const Center(child: Text('No insights available'));
              }

              return ListView.builder(
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
                                  insight.category,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            insight.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (insight.recommendation != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getActionIcon(insight.actionType),
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recommendation',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      if (insight.priority != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(insight.priority!),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            insight.priority!,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    insight.recommendation!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (insight.confidence != null) ...[
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: insight.confidence! / 100,
                                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Confidence: ${insight.confidence!.toStringAsFixed(0)}%',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(insight.timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  IconData _getInsightIcon(String category) {
    switch (category.toLowerCase()) {
      case 'heart':
        return Icons.favorite;
      case 'sleep':
        return Icons.bedtime;
      case 'weight':
        return Icons.monitor_weight;
      case 'activity':
        return Icons.directions_run;
      default:
        return Icons.insights;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getActionIcon(String? actionType) {
    switch (actionType?.toLowerCase()) {
      case 'exercise':
        return Icons.directions_run;
      case 'sleep':
        return Icons.bedtime;
      case 'nutrition':
        return Icons.restaurant;
      case 'stress':
        return Icons.psychology;
      case 'meditation':
        return Icons.self_improvement;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 