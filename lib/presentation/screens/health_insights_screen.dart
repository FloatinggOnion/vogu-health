import 'package:flutter/material.dart';
import 'package:vogu_health/models/insight_models.dart';
import 'package:vogu_health/services/health_api_service.dart';
import 'package:intl/intl.dart';

/// Screen that displays health insights and recommendations
class HealthInsightsScreen extends StatefulWidget {
  const HealthInsightsScreen({super.key});

  @override
  State<HealthInsightsScreen> createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends State<HealthInsightsScreen> {
  final _apiService = HealthApiService();
  bool _isLoading = true;
  String? _error;
  InsightResponse? _recentInsights;
  InsightResponse? _dailyInsights;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recentInsights = await _apiService.getRecentInsights();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dailyInsights = await _apiService.getDailyInsights(today);

      setState(() {
        _recentInsights = recentInsights;
        _dailyInsights = dailyInsights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load insights: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green.shade100;
      case 'fair':
        return Colors.orange.shade100;
      case 'poor':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildInsightCard({
    required String title,
    required InsightResponse insight,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getStatusColor(insight.status),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(insight.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      insight.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                insight.summary,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (insight.highlights.isNotEmpty) ...[
                const Text(
                  'Highlights',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...insight.highlights.map((highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(highlight)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (insight.recommendations.isNotEmpty) ...[
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...insight.recommendations.map((recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(recommendation)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (insight.nextSteps.isNotEmpty) ...[
                const Text(
                  'Next Steps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(insight.nextSteps)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInsights,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInsights,
      child: ListView(
        children: [
          if (_recentInsights != null)
            _buildInsightCard(
              title: 'Recent Insights',
              insight: _recentInsights!,
            ),
          if (_dailyInsights != null)
            _buildInsightCard(
              title: 'Today\'s Insights',
              insight: _dailyInsights!,
            ),
        ],
      ),
    );
  }
} 